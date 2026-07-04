param(
    [string]$ChannelId = "",
    [string]$OutputPath = "$PSScriptRoot\chzzk-live-cache.json",
    [switch]$Loop,
    [int]$IntervalSec = 30,
    [string]$SkinName = "ChzzkLivePersonal"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ChannelId)) {
    throw "ChannelId is required. Set ChannelId in ChzzkLivePersonal.ini."
}

function U([int[]]$Codes) {
    -join ($Codes | ForEach-Object { [char]$_ })
}

function Clean-RainmeterValue([string]$Value) {
    if ([string]::IsNullOrEmpty($Value)) {
        return ""
    }

    return ($Value -replace "[`r`n]+", " " -replace "#", "_")
}
function Read-SkinSettings {
    param([string]$Path)

    $settings = @{}
    if (-not (Test-Path -LiteralPath $Path)) {
        return $settings
    }

    foreach ($line in Get-Content -LiteralPath $Path) {
        $trimmed = $line.Trim()
        if ($trimmed -eq "" -or $trimmed.StartsWith(";") -or $trimmed.StartsWith("[")) {
            continue
        }

        $parts = $trimmed.Split("=", 2)
        if ($parts.Count -eq 2) {
            $settings[$parts[0].Trim()] = $parts[1].Trim()
        }
    }

    return $settings
}

function Find-RainmeterExe {
    $paths = @(
        "$env:ProgramFiles\Rainmeter\Rainmeter.exe",
        "${env:ProgramFiles(x86)}\Rainmeter\Rainmeter.exe"
    )

    foreach ($path in $paths) {
        if ($path -and (Test-Path -LiteralPath $path)) {
            return $path
        }
    }

    return "Rainmeter.exe"
}

function Set-RainmeterVariables {
    param(
        [string]$RainmeterExe,
        [string]$SkinName,
        [hashtable]$Variables
    )

    foreach ($key in $Variables.Keys) {
        & $RainmeterExe "!SetVariable" $key ([string]$Variables[$key]) $SkinName | Out-Null
    }

    & $RainmeterExe "!UpdateMeter" "*" $SkinName | Out-Null
    & $RainmeterExe "!Redraw" $SkinName | Out-Null
}

function Update-ChzzkCache {
    param(
        [string]$ChannelId,
        [string]$OutputPath
    )

    $fallbackTitle = U @(0xBC29, 0xC1A1, 0x0020, 0xC81C, 0xBAA9, 0x0020, 0xC5C6, 0xC74C)
    $fallbackCategory = U @(0xCE74, 0xD14C, 0xACE0, 0xB9AC, 0x0020, 0xC5C6, 0xC74C)
    $statusLiveText = U @(0xBC29, 0xC1A1, 0x0020, 0xC911)
    $statusOfflineText = U @(0xC624, 0xD504, 0xB77C, 0xC778)
    $statusErrorText = U @(0xC5F0, 0xACB0, 0x0020, 0xC624, 0xB958)
    $fallbackHeaderText = U @(0xCE58, 0xC9C0, 0xC9C1, 0x0020, 0x004C, 0x0049, 0x0056, 0x0045)
    $liveSuffix = U @(0x0020, 0x004C, 0x0049, 0x0056, 0x0045)
    $viewerPrefix = U @(0xC2DC, 0xCCAD, 0xC790, 0x0020)
    $viewerSuffix = U @(0xBA85, 0x0020, 0x00B7, 0x0020)
    $errorCategory = U @(0xC624, 0xB958)
    $waitingText = U @(0xB300, 0xAE30, 0x0020, 0xC911)
    $hourText = U @(0xC2DC, 0xAC04)
    $minuteText = U @(0xBD84)

    $settings = Read-SkinSettings -Path (Join-Path $PSScriptRoot "settings.inc")
    if ($settings.ContainsKey("LiveText") -and -not [string]::IsNullOrWhiteSpace($settings["LiveText"])) {
        $statusLiveText = [string]$settings["LiveText"]
    }
    if ($settings.ContainsKey("OfflineText") -and -not [string]::IsNullOrWhiteSpace($settings["OfflineText"])) {
        $statusOfflineText = [string]$settings["OfflineText"]
    }
    if ($settings.ContainsKey("CheckingText") -and -not [string]::IsNullOrWhiteSpace($settings["CheckingText"])) {
        $waitingText = [string]$settings["CheckingText"]
    }
    $uri = "https://api.chzzk.naver.com/polling/v2/channels/$ChannelId/live-status"
    $channelUri = "https://api.chzzk.naver.com/service/v1/channels/$ChannelId"
    $headers = @{
        "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36"
        "Accept" = "application/json,text/plain,*/*"
        "Referer" = "https://chzzk.naver.com/live/$ChannelId"
        "Origin" = "https://chzzk.naver.com"
    }

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        $client = New-Object System.Net.WebClient
        foreach ($key in $headers.Keys) {
            $client.Headers.Add($key, $headers[$key])
        }

        $headerText = $fallbackHeaderText
        try {
            $channelBytes = $client.DownloadData($channelUri)
            $channelText = [System.Text.Encoding]::UTF8.GetString($channelBytes)
            $channelResponse = $channelText | ConvertFrom-Json
            $channelContent = $channelResponse.content
            if ($null -eq $channelContent) {
                $channelContent = $channelResponse
            }

            if ($channelContent.channelName) {
                $headerText = "$($channelContent.channelName)$liveSuffix"
            }
        }
        catch {
            $headerText = $fallbackHeaderText
        }

        $responseBytes = $client.DownloadData($uri)
        $responseText = [System.Text.Encoding]::UTF8.GetString($responseBytes)
        $response = $responseText | ConvertFrom-Json

        $content = $response.content
        if ($null -eq $content) {
            $content = $response
        }

        $status = if ($content.status) { [string]$content.status } else { "UNKNOWN" }
        $title = if ($content.liveTitle) { [string]$content.liveTitle } else { $fallbackTitle }
        $category = if ($content.liveCategoryValue) { [string]$content.liveCategoryValue } else { $fallbackCategory }
        $viewerCount = if ($null -ne $content.concurrentUserCount) { [string]$content.concurrentUserCount } else { "-" }
        $uptimeText = $waitingText

        if ($status -eq "OPEN") {
            $statusText = $statusLiveText
            $stateColor = "80,220,120,255"
            $dotColor = "80,220,120,255"

            if ($content.openDate) {
                $openDate = [datetime]::ParseExact([string]$content.openDate, "yyyy-MM-dd HH:mm:ss", [Globalization.CultureInfo]::InvariantCulture)
                $span = (Get-Date) - $openDate
                $hours = [int][Math]::Floor($span.TotalHours)
                $minutes = [int]$span.Minutes

                if ($hours -gt 0) {
                    $uptimeText = "$hours$hourText $minutes$minuteText"
                }
                else {
                    $uptimeText = "$minutes$minuteText"
                }
            }
        }
        else {
            $statusText = $statusOfflineText
            $stateColor = "150,150,150,255"
            $dotColor = "150,150,150,255"
        }

        $errorText = ""
    }
    catch {
        $headerText = $fallbackHeaderText
        $status = "ERROR"
        $title = $statusErrorText
        $category = $errorCategory
        $viewerCount = "-"
        $statusText = $statusErrorText
        $uptimeText = $waitingText
        $stateColor = "255,190,90,255"
        $dotColor = "255,190,90,255"
        $errorText = $_.Exception.Message
    }

    $incPath = [System.IO.Path]::ChangeExtension($OutputPath, ".inc")
    $updatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $info = "$viewerPrefix$viewerCount$viewerSuffix$category"

    $variables = [ordered]@{
        LiveHeader = Clean-RainmeterValue $headerText
        LiveStatus = Clean-RainmeterValue $status
        LiveStatusText = Clean-RainmeterValue $statusText
        LiveTitle = Clean-RainmeterValue $title
        LiveViewerCount = Clean-RainmeterValue $viewerCount
        LiveCategory = Clean-RainmeterValue $category
        LiveInfo = Clean-RainmeterValue $info
        LiveUpdatedAt = Clean-RainmeterValue $updatedAt
        LiveUptime = Clean-RainmeterValue $uptimeText
        LiveStateColor = Clean-RainmeterValue $stateColor
        LiveDotColor = Clean-RainmeterValue $dotColor
        LiveError = Clean-RainmeterValue $errorText
    }

    $lines = @("[Variables]")
    foreach ($entry in $variables.GetEnumerator()) {
        $lines += "$($entry.Key)=$($entry.Value)"
    }

    Set-Content -LiteralPath $incPath -Value $lines -Encoding Unicode
    return $variables
}

if ($Loop) {
    $mutexName = "Global\ChzzkLivePersonalUpdater-$ChannelId"
    $createdNew = $false
    $mutex = New-Object System.Threading.Mutex($true, $mutexName, [ref]$createdNew)

    if (-not $createdNew) {
        return
    }

    try {
        $rainmeterExe = Find-RainmeterExe

        while ($true) {
            $variables = Update-ChzzkCache -ChannelId $ChannelId -OutputPath $OutputPath
            Set-RainmeterVariables -RainmeterExe $rainmeterExe -SkinName $SkinName -Variables $variables
            Start-Sleep -Seconds ([Math]::Max(10, $IntervalSec))
        }
    }
    finally {
        $mutex.ReleaseMutex()
        $mutex.Dispose()
    }
}
else {
    Update-ChzzkCache -ChannelId $ChannelId -OutputPath $OutputPath | Out-Null
}


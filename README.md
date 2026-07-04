# Chzzk Peek

치지직 스트리머의 방송 상태를 바탕화면에서 확인하는 Rainmeter 스킨입니다.

스트리머의 방송 상태, 방송 제목, 시청자 수, 카테고리, 업타임을 작게 표시합니다. CHZZK API를 Rainmeter의 WebParser로 직접 읽지 않고 PowerShell 캐시 스크립트로 가져와서, 타임아웃이나 한글 인코딩 문제를 줄이는 방식으로 동작합니다.

> 비공식 프로젝트입니다. NAVER 또는 CHZZK와 관련이 없으며, 공식적으로 승인된 프로젝트가 아닙니다.

## Preview

스크린샷은 추후 추가 예정입니다.

## Features

- 방송 중 / 오프라인 상태 표시
- 방송 제목 표시
- 시청자 수와 카테고리 표시
- 방송 업타임 표시
- 스트리머 이름 기반 헤더 표시
- 설정 파일에서 채널 ID, 갱신 주기, 색상, 배경 투명도 변경

## Requirements

- Windows
- Rainmeter
- Rainmeter RunCommand plugin
- Windows PowerShell

## Download Rainmeter

Rainmeter가 설치되어 있지 않다면 공식 사이트에서 먼저 설치합니다.

1. [rainmeter.net](https://www.rainmeter.net/)에 접속합니다.
2. **Download** 페이지에서 최신 버전 설치 파일을 다운로드합니다.
3. 설치 파일을 실행하고 기본 옵션으로 설치합니다.
4. 설치가 끝나면 Rainmeter를 실행합니다.

## Installation

1. GitHub 저장소의 **Releases** 페이지로 이동합니다.
2. 최신 릴리스에서 `.rmskin` 파일을 다운로드합니다.
3. 다운로드한 `.rmskin` 파일을 더블클릭합니다.
4. Rainmeter Skin Installer가 열리면 **Install**을 누릅니다.
5. Rainmeter에서 `ChzzkPeek > ChzzkPeek.ini` 스킨을 불러옵니다.

## Manual Installation

소스 파일로 직접 설치하려면 이 저장소를 다운로드한 뒤, 폴더를 Rainmeter 스킨 폴더 아래에 넣습니다.

```txt
Documents\Rainmeter\Skins\ChzzkPeek
```

그 다음 Rainmeter에서 **Refresh all**을 실행하고 `ChzzkPeek > ChzzkPeek.ini` 스킨을 불러옵니다.

## Settings

설정은 아래 파일에서 바꿀 수 있습니다.

```txt
@Resources\settings.inc
```

예시:

```ini
[Variables]
ChannelId=9eef2be9e25d137c0f55b13673e40749
CheckSeconds=60
BackgroundAlpha=150
MainColor=245,245,245,255
SubColor=185,185,185,255
LiveText=뱅온
OfflineText=오프라인
CheckingText=확인 중
```

### Options

| Name | Description |
| --- | --- |
| `ChannelId` | CHZZK 채널 ID |
| `CheckSeconds` | 방송 상태 확인 주기, 초 단위 |
| `BackgroundAlpha` | 배경 투명도. `0`은 투명, `255`는 불투명 |
| `MainColor` | 헤더와 방송 제목 색상 |
| `SubColor` | 업타임, 시청자 수, 카테고리 색상 |
| `LiveText` | 방송 중일 때 표시할 텍스트 |
| `OfflineText` | 오프라인일 때 표시할 텍스트 |
| `CheckingText` | 확인 중일 때 표시할 텍스트 |

`ChannelId` 또는 `CheckSeconds`를 바꾼 뒤에는 Rainmeter에서 스킨을 한 번 새로고침하는 것을 권장합니다.

## Finding Channel ID

CHZZK 채널 주소가 아래와 같다면:

```txt
https://chzzk.naver.com/abcdef123456
```

`settings.inc`에는 마지막 부분만 넣습니다.

```ini
ChannelId=abcdef123456
```

## Notes

- CHZZK의 비공식 API 응답 구조가 바뀌면 동작하지 않을 수 있습니다.
- 한글이 깨질 경우 `.ini`와 `.inc` 파일을 UTF-16 LE 형식으로 저장해 보세요.
- PowerShell 스크립트는 중복 실행을 막기 위해 같은 채널 ID 기준으로 하나의 갱신 루프만 유지합니다.

## License

MIT License

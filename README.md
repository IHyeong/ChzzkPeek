# Chzzk Peek

CHZZK 방송 상태를 바탕화면에서 확인하는 Rainmeter 스킨입니다.

스트리머의 방송 상태, 방송 제목, 시청자 수, 카테고리, 업타임을 작게 표시합니다. CHZZK API를 Rainmeter의 WebParser로 직접 읽지 않고 PowerShell 캐시 스크립트로 가져와서, 타임아웃이나 한글 인코딩 문제를 줄이는 방식으로 동작합니다.

## 미리보기

<img width="302" height="157" alt="image" src="https://github.com/user-attachments/assets/209473b7-9308-439c-84df-fe90cfb16f13" />

<img width="1917" height="1078" alt="image" src="https://github.com/user-attachments/assets/ba115df7-6507-4a73-ba70-146277df4725" />



## 주요 기능

- 방송 중 / 오프라인 상태 표시
- 방송 제목 표시
- 시청자 수와 카테고리 표시
- 방송 업타임 표시
- 스트리머 이름 기반 헤더 표시
- 설정 파일에서 채널 ID, 갱신 주기, 색상, 배경 투명도 변경

## 필요 사항

- Windows
- Rainmeter
- Rainmeter RunCommand 플러그인
- Windows PowerShell

## Rainmeter 설치

Rainmeter가 설치되어 있지 않다면 공식 사이트에서 먼저 설치합니다.

1. [rainmeter.net](https://www.rainmeter.net/)에 접속합니다.
   접속 후 **Download** 페이지에서 최신 버전 설치 파일을 다운로드합니다.
   - [레인미터 다운로드 바로가기(사이트 접속 생략)](https://github.com/rainmeter/rainmeter/releases/download/v4.5.26.3894/Rainmeter-4.5.26.exe)<br>
2. 설치 파일을 실행하고 기본 옵션으로 설치합니다.
3. 설치가 끝나면 Rainmeter를 실행합니다.
   - 설치하면 여러 기본 위젯이 나옵니다. 우클릭으로 클릭 후 [스킨 닫기] 클릭

## 설치 방법

1. [파일 다운 받기](https://github.com/IHyeong/ChzzkPeek/releases/download/v1.0.1/ChzzkPeek_1.0.1.rmskin)
2. 다운로드한 `.rmskin` 파일을 더블클릭합니다.
3. Rainmeter Skin Installer가 열리면 **Install**을 누릅니다.

## 설정

<img width="517" height="563" alt="image" src="https://github.com/user-attachments/assets/661a96df-ba02-4ef6-9576-1a92d348dac5" /> <br>

기타 설정은 아래 파일에서 바꿀 수 있습니다.
`작업 표시줄 아이콘 - rainmeter(우클릭) - 스킨 - 폴더 열기 - ChzzkPeek -@Resources\settings.inc`

예시:

```ini
[Variables]
ChannelId=af3323d30e11ae42c39d7203c7e07fa2
CheckSeconds=60
BackgroundAlpha=150
MainColor=245,245,245,255
SubColor=185,185,185,255
LiveText=뱅온
OfflineText=오프라인
CheckingText=확인 중
```

### 설정 항목

| 이름 | 설명 |
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

## 채널 ID 찾기

CHZZK 채널 주소가 아래와 같다면:

```txt
https://chzzk.naver.com/abcdef123456
```

`settings.inc`에는 마지막 부분만 넣습니다.

```ini
ChannelId=abcdef123456
```

## 참고 사항

- CHZZK의 비공식 API 응답 구조가 바뀌면 동작하지 않을 수 있습니다.
- 한글이 깨질 경우 `.ini`와 `.inc` 파일을 UTF-16 LE 형식으로 저장해 보세요.
- PowerShell 스크립트는 중복 실행을 막기 위해 같은 채널 ID 기준으로 하나의 갱신 루프만 유지합니다.

## 라이선스

MIT License

# 루티 다운로드 리포트

GitHub Actions가 App Store Connect의 **최초 다운로드 수**를 조회해 Discord 웹훅으로 전송한다. 별도 서버·Cloudflare·Discord 명령어용 앱은 사용하지 않는다.

## 실행 방법

- **자동 전송:** 매주 수요일 10:17 KST, 지난주 월요일~일요일 **UTC** 자료.
- **수동 실행:** 저장소 → Actions → **Routee App Store Downloads** → **Run workflow**.
- 실행 브랜치는 기본 브랜치인 `develop`을 선택한다. 다른 브랜치에서는 실제 조회·전송을 실행하지 않는다.
- `period`: `last_week`(지난주), `last_7_days`(최근 7일), `last_30_days`(최근 30일).
- `send_to_discord`: 체크하면 전송하고, 해제하면 API 조회만 검증한다. 최근 7일·30일의 종료일은 실행일 UTC의 이틀 전이다.
- GitHub의 **Re-run jobs**는 중복 전송을 막기 위해 전송하지 않는다. 의도적으로 다시 보내려면 먼저 Discord 채널을 확인하고 새 **Run workflow**를 실행한다.

수동 실행에는 저장소 쓰기 권한이 필요하다. 예약 실행은 지연될 수 있고, 공개 저장소에 60일간 활동이 없으면 GitHub가 예약 실행을 비활성화할 수 있다.

## 집계 기준

`App Store Downloads Standard` 보고서에서 `Download Type = First-time Download`인 행의 `Counts`를 합산한다. Apple 계정 기준 처음 받기/구입을 누른 횟수이며 재다운로드·업데이트·회원가입 수와 구분한다.

- 모든 세그먼트를 수집한 다음 집계한다.
- 동일한 데이터 날짜가 여러 보고서에 있으면 최신 `processingDate` 값으로 교체한다. 과거 값과 더하지 않는다.
- 해당 날짜로부터 2일 이상 뒤에 생성된 자료를 완료된 자료로 사용한다.
- 다른 다운로드 유형만 있는 날짜의 최초 다운로드는 0건이다. 날짜 자체가 없거나 자료가 미완성인 경우에는 0건으로 추정하지 않는다.
- 미확인 날짜가 있으면 **확인된 소계와 미확인 날짜**를 보낸다. 완전한 주간 합계로 표시하지 않는다.
- Apple 조회가 실패하면 수치를 만들어 보내지 않고 실행을 실패로 표시한다.
- 매 실행에서 최근 처리일 35일 내 파일을 새로 읽는다. 별도 DB·캐시가 필요 없으며 출시 이후 누적 지표는 제공하지 않는다.

## 최초 설정

Apple API 접근 승인, API 키 발급, 보고서 생성 요청이 필요하다. 새 ONGOING 요청 생성은 Admin 키가 필요하고, 이후 운영 조회에는 **Sales and Reports** 권한의 팀 API 키를 사용한다. 최초 보고서 생성에는 24~48시간이 걸릴 수 있다.

1. 초기 설정용 Admin 키로 아래 관리 명령을 실행한다. 기존 활성 ONGOING 요청이 있으면 새로 만들지 않는다.
2. 초기 설정용 키는 운영 workflow에 등록하지 않는다. 임시 키로 발급했다면 설정 후 폐기한다.
3. 운영 조회용 키와 웹훅을 저장소의 **Settings → Secrets and variables → Actions**에 등록한다.

| Repository Secret | 내용 |
| --- | --- |
| `ROUTEE_ASC_KEY_ID` | 운영 조회용 API Key ID |
| `ROUTEE_ASC_ISSUER_ID` | 팀 Issuer ID |
| `ROUTEE_ASC_PRIVATE_KEY` | 운영 조회용 `.p8` PEM 전체 |
| `ROUTEE_DISCORD_WEBHOOK_URL` | 리포트를 받을 Discord 채널 웹훅 URL |

대상 앱 ID는 출시용 루티 `6791870747`이다. 활성 ONGOING 요청이 여러 개라면 Repository Variable `ROUTEE_ASC_REPORT_REQUEST_ID`로 하나를 지정한다.

처음에는 `send_to_discord`를 해제해 조회를 확인한다. 보고서가 준비된 후 전송을 실행한다. ONGOING 생성 이전의 전체 이력을 보장하지 않으며 ONE_TIME_SNAPSHOT의 과거 자료 수집은 현재 구현하지 않았다.

## 로컬 실행

Node.js 22 이상이 필요하며 외부 런타임 패키지는 사용하지 않는다. workflow는 Node.js 24를 사용한다.

```sh
cd automation/app-store-discord
npm test
npm run preview
```

`preview`는 명시적으로 표시된 가상 수치만 출력하며 외부에 전송하지 않는다. 실제 설정은 `.env.example`을 참고해 Git에서 제외된 `.env`에 저장한다. 기존 `.env`를 덮어쓰지 않는다.

```sh
# 기본값은 안내만 출력. --apply일 때만 기존 요청 조회/생성을 실행한다.
node --env-file=.env scripts/request-reports.mjs --apply

# 실제 조회만 검증. 통계 본문은 콘솔에 출력하지 않는다.
node --env-file=.env scripts/run-report.mjs --period last_week

# 실제 Discord 전송
node --env-file=.env scripts/run-report.mjs --period last_week --send
```

관리 스크립트는 PEM 대신 `ASC_PRIVATE_KEY_PATH`로 로컬 `.p8` 경로를 받을 수 있다. 운영 workflow에는 PEM을 Secret으로 전달한다.

## 공개 저장소에서의 정보 처리

- 실제 다운로드 수·보고서 본문·원본 파일은 GitHub 로그, Job Summary, Artifact에 남기지 않는다. Discord에만 전송한다.
- API 키와 웹훅 URL은 코드에 넣지 않는다. 네트워크 예외 원문도 출력하지 않는다.
- PR에서는 모의 테스트만 실행하며 Secrets에 접근하지 않는다. 실제 조회는 `develop`의 예약·수동 실행에 한정한다.
- workflow 권한은 `contents: read`이며, 외부 Actions는 검증한 커밋 SHA에 고정한다.
- 웹훅 전송은 자동 재시도하지 않는다. 결과가 불확실하면 Discord 채널 확인 후 새 수동 실행을 선택한다.

## 공식 근거

- [Apple 다운로드 보고서](https://developer.apple.com/documentation/analytics-reports/app-download)
- [Apple 정정 데이터 처리](https://developer.apple.com/documentation/analytics-reports/data-completeness-corrections)
- [보고서 생성·다운로드 권한](https://developer.apple.com/documentation/appstoreconnectapi/downloading-analytics-reports)
- [GitHub 예약 실행](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule)
- [GitHub 수동 실행](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow)

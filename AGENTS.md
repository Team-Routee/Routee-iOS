# AGENTS.md

이 문서는 Routee-iOS에서 작업하는 AI 에이전트와 기여자를 위한 지침이다.

- Xcode 프로젝트는 `Routee-iOS/Routee-iOS.xcodeproj`에 있다.
- 앱 소스는 `Routee-iOS/Routee-iOS`에 있다. `Presentation/`과 `Data/` 경로는 앱 소스 디렉터리를 기준으로 한다.

## 현재 코드의 관례

### 화면과 구조

- Swift와 UIKit 기반의 MVVM 구조다. 화면 레이아웃에는 SnapKit을 사용하고, UI 속성을 설정할 때 Then의 `.do`를 주로 사용한다.
- `Presentation/<Feature>`에서 필요에 따라 `Model`, `View`, `ViewController`, `ViewModel`을 나눈다. `Archive/Home`처럼 기능 안에서 화면 단위로 한 번 더 나누기도 한다. 공용 UI와 확장은 `Presentation/Common`에 있다.
- View는 UI 구성과 렌더링을, ViewController는 사용자 이벤트 연결과 화면 전환을, ViewModel은 Repository 호출과 화면용 데이터 가공을 맡는다. `Data`와 `Presentation`은 역할에 따라 분리되어 있고, 일부 DTO와 화면 모델은 서로의 타입을 참조한다.
- 일반 기능 화면은 `BaseUIView`와 `BaseUIViewController`를 사용한다. `BaseUIView`는 `setStyle()` → `setUI()` → `setLayout()` 순서로 호출한다. `BaseUIViewController`는 `viewDidLoad()`에서 키보드 닫기 제스처를 설치한 뒤 `setView()` → `setAddTarget()` → `setDelegate()`를 호출한다.
- 화면 전용 View는 보통 `private let rootView`로 보관한다. 기존 VC에는 `loadView()`에서 연결하는 방식과 `setView()`에서 연결하는 방식이 공존한다. 탭 바와 커스텀 버튼처럼 전용 UIKit 타입을 상속하는 사례도 있다.

### 네트워크와 인증

| 경로 | 역할 |
| --- | --- |
| `Data/Network/DTO` | 요청·응답 스키마, 공통 응답 래퍼, 일부 DTO 변환 메서드 |
| `Data/Network/EndPoint` | 기능별 `*API`와 요청 메타데이터. URL, HTTP 메서드, 헤더, 쿼리, 본문, 인코딩을 정의한다. |
| `Data/Network/Repository` | 기능별 데이터 요청. EndPoint를 만들어 NetworkService에 전달하고, 결과를 호출부가 사용할 형태로 반환한다. |
| `Data/Network/Base` | Alamofire 기반 `NetworkService`, `AuthInterceptor`, 공통 오류 및 로거 |
| `Data/Network/Persistence` | `KeychainService`와 토큰 재발급을 담당하는 `TokenService` |

- 일부 인증 Repository는 Keychain에서 토큰을 읽고 빈 값인지 확인한다. `.withAuth`와 `.withAuthTimeZone` 요청에는 `AuthInterceptor`가 최신 access token을 Bearer 헤더에 설정한다.
- 인터셉터가 적용된 요청이 첫 HTTP 401을 받으면 인터셉터가 `DefaultTokenService`에 재발급을 요청하고, 성공 시 원래 요청을 최대 한 번 재시도한다. 재발급 서비스는 actor이며 진행 중인 재발급 작업을 공유한다. 재발급 HTTP 요청이 실패하면 Keychain을 정리하고 로그인 화면 이동 알림을 보낸다.
- 로그인 시 토큰 저장과 로그아웃 시 정리는 `AuthRepository`가 담당한다. 앱 시작 시 화면 분기는 `SceneDelegate`에서 처리한다.
- Repository 반환값에는 `toModel()`로 변환한 화면 모델, 단일 값, 응답 DTO가 모두 있다. 일부 ViewModel은 요청 DTO도 직접 만든다.

## 신규 코드와 수정하는 코드에 적용할 규칙

요청 범위 안에서 아래 규칙을 적용한다. 기존 코드의 관례와 인터페이스는 요청을 해결하는 데 변경이 필요한 경우에만 정리한다. 현재 기능에 필요한 만큼만 구조를 추가하고, 단순한 UIKit 패턴과 기존 컴포넌트·유틸리티를 우선 재사용한다.

### 화면 작성

- 일반 기능 화면은 `BaseUIView`와 `BaseUIViewController`를 사용한다. 탭 바, 컨트롤 등 UIKit 전용 타입이 필요한 경우 해당 타입을 상속한다.
- VC의 `loadView()`에서 `view = rootView`를 할당해 `viewDidLoad()` 전에 화면의 루트 뷰를 정한다. `BaseUIViewController`를 사용하는 화면에서 타깃과 델리게이트 연결은 각각 `setAddTarget()`과 `setDelegate()`를 사용한다.
- `BaseUIView`를 사용하는 View는 `UI Properties`에 UI 요소를 선언하고 생성자에 필요한 인자를 전달한다. 속성 설정은 `setStyle()`에서 `.do`로 묶고, 뷰 계층은 `setUI()`, SnapKit 제약은 `setLayout()`에 둔다.
- Repository가 필요한 ViewModel은 해당 프로토콜을 생성자로 받는다. 화면의 상태 갱신은 메인 액터에서 처리하고, 화면에 종속되는 ViewModel에는 필요에 따라 `@MainActor`를 적용한다. 네트워크·DTO·Repository·저장 코드의 액터 격리는 실제로 필요한 범위에 둔다.

### API 추가와 변경

1. API 계약에 따라 필요한 `RequestDTO`와 `ResponseDTO`를 추가한다. 요청 DTO는 `Encodable`, 공통 클라이언트에서 디코딩하는 응답 DTO는 `Decodable & Sendable`을 사용한다. DTO에 UI 동작이나 저장 로직을 넣지 않는다.
2. 기능별 `*API`에 EndPoint를 추가한다. EndPoint는 요청 메타데이터를 구성하고, 화면 상태나 Keychain을 직접 조회하지 않는다. 인증과 타임존이 필요한지 확인하고 Repository에서 기존 `HeaderType`에 필요한 값을 제공한다.
3. 새 API는 Repository에 `async throws` 메서드를 추가한다. 요청 DTO는 Repository 경계에서 구성하고, 화면에 필요한 모델이나 값으로 반환한다. 기존 API는 요청 해결에 필요한 경우에만 Repository 인터페이스와 호출부를 함께 바꾼다. 변환은 기존 `toModel()` 또는 `toDTO()` 패턴을 재사용한다. Repository에 UIKit 렌더링이나 화면 전환 로직을 넣지 않는다.
4. 응답 계약에 맞춰 Service 메서드를 선택한다. `request`는 `BaseResponse<T>`의 `data`를 반환한다. `requestEmpty`는 `EmptyResponse`를 디코딩하므로 본문이 완전히 비어 있는 응답의 계약과 구분한다. 래퍼 없는 응답에는 `requestPlain`, presigned URL 업로드에는 `presignedURLUploadData`를 사용한다.
5. ViewModel에서 Repository를 호출한다. 화면에서 API URL이나 헤더를 조립하거나 `NetworkService` 및 토큰 저장소에 직접 접근하지 않는다. 공통 HTTP 전송과 디코딩은 `NetworkService`에 둔다. `.withAuth`와 `.withAuthTimeZone` 요청의 Bearer 헤더는 인터셉터가 전송 직전에 설정한다. 401 재시도는 기존 인터셉터와 재발급 서비스를 사용한다.

### 코드 스타일과 검증

- Apple 프레임워크와 외부 라이브러리의 import는 빈 줄로 구분하고 각 그룹 안에서 알파벳 오름차순으로 정렬한다.
- 하위 클래스를 둘 의도가 없는 클래스에는 `final`을 붙인다.
- `// MARK: - UI Properties`, `// MARK: - UI Setting`, `// MARK: - Public Methods` 등 실제 내용이 있는 섹션만 사용한다. 필요하면 `Properties`, `Private Methods`, `Actions`를 추가한다.
- SwiftLint 설정은 저장소 루트 기준 `Routee-iOS/.swiftlint.yml`을 기준으로 한다. `sorted_imports`, `mark`, `force_unwrapping`이 활성화되어 있고 `line_length`는 비활성화되어 있다. 변경 범위의 경고는 가능한 한 해결하고 규칙의 로컬 비활성화는 피한다.
- 비동기 코드에서는 `@Sendable` 클로저의 캡처와 액터 격리를 확인한다. continuation을 사용하는 코드를 변경할 때는 모든 경로에서 정확히 한 번 resume하는지 확인한다. 인스턴스 상태를 쓰지 않는 내부 헬퍼는 필요에 따라 `static`으로 두고 `Self`로 호출한다.

### 설정, 보안, 로깅

- access token과 refresh token은 `KeychainService`를 통해 Keychain에 저장한다. `UserDefaults`에 저장하지 않는다.
- 프로젝트 로그에는 `RouteeLogger`를 사용한다. 인증 헤더, 토큰, Apple identity token, authorization code, API 키 등은 마스킹하거나 생략한다. 민감정보가 들어갈 수 있는 응답 원문이나 전체 응답 객체를 로그에 남기지 않는다.
- 런타임 설정은 빌드 설정에서 전달된 `Info.plist` 값을 사용한다. 설정 조회나 URL 조립 로직을 추가·수정할 때는 실패를 호출부에 오류로 전달한다. 기존 공통 인터페이스 변경은 해당 작업에 포함된 경우에 진행한다.
- 로컬 설정값, 비밀값, API 키, 토큰, 생성된 빌드 산출물을 커밋하지 않는다. `Config.xcconfig`는 빌드 설정 파일로만 사용하고 `Copy Bundle Resources`에 넣지 않는다.

## 작업 범위와 Git

- `rg`로 관련 파일을 찾고 변경에 필요한 코드와 설정을 우선 확인한다. 빌드 산출물과 패키지 캐시는 문제 확인에 필요한 경우에만 조사한다.
- 변경 범위를 요청한 기능이나 수정에 한정하고, 사용자의 별도 변경을 되돌리지 않는다. 명시적인 요청 없이 Git 이력을 다시 쓰거나 파괴적인 Git 명령을 실행하지 않는다.
- 작업 결과에는 주요 변경, 판단이 필요한 부분, 실제 검증 범위를 적는다.

### 태그 컨벤션

`feat` : 새로운 기능 구현 시 사용

`style` : UI 구현 시 사용

`fix` : 버그나 오류 해결 시 사용

`docs` : README, 템플릿 등 프로젝트 내 문서 수정 시 사용

`setting` : 프로젝트 관련 설정 변경 시 사용

`add` : 사진 등 에셋이나 라이브러리 추가 시 사용

`refactor` : 기존 코드를 리팩토링하거나 수정할 시 사용

`chore` : 별로 중요한 수정이 아닐 시 사용

`network` : 네트워크 작업 시 사용

`merge` : 머지하기

### 커밋 컨벤션

`[태그] #이슈번호 - 작업내용`

```text
[feat] #3 - 업장 상세페이지 컴포넌트 사용하도록 수정 및 관리자 조회 API 추가
[style] #2 - 근무중인 가게 상세페이지 구현
[add] #1 - 아이콘 에셋 추가
[chore] #6 - 코드 리뷰 반영
```

### 브랜치 컨벤션

`태그/#이슈번호`

```text
feat/#1
add/#3
refactor/#53
```

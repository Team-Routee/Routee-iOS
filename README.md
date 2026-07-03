# 루티 Routee

> 긴 호흡의 운동을 하나의 기록으로 남기고, 쉽게 공유할 수 있도록 돕는 경험 플랫폼

함께 산을 오를 때, 누구나 공유하고 싶어지는 산행 기록을 쉽게 만들 수 있도록, <br>
트렌디한 산행 리캡으로 기록해주는 iOS 애플리케이션입니다.<br>

<br>

## 기술 스택
| 분류 | 기술 | 역할 |
|:---:|:---:|---|
| UI 프레임워크 | **UIKit** | 높은 안정성의 UI Framework |
| 아키텍처 | **MVVM** | UI, 데이터 계층 분리로 유지보수 용이 |
| 네트워킹 | **Alamofire** | 공통 네트워크 요청 처리 및 API 레이어 추상화 |
| 비동기/반응형 | **Combine** | 지속적인 상태 바인딩 최적화, ViewModel의 Input/Output 스트림 관리 |
| 비동기 처리 | **Swift Concurrency** | 네트워크 요청의 명확하고 안전한 비동기 흐름 관리 |
| 지도 | **NMapsMap** | 네이버 지도를 활용하여 간단한 약도부터 유명 관광지 표시 등 다양한 정보 제공 |
| 애니메이션 | **Lottie** | 트렌디한 UI 표현, 디자이너 협업 효율, 벡터 기반 경량 애니메이션 |
| 이미지 처리 | **Kingfisher** | 이미지 캐싱 및 네트워크 병목 방지 |
| 로그 관리 | **OSLog** | 구조화된 로깅을 지원하여 성능 저하 없이 효율적으로 로그 수집 및 분석 가능 |
| 패키지 관리 및 모듈화 | **SPM** | Swift Package Manager 기반 외부 라이브러리 관리 |
| 버전 관리 | **Git, GitHub** | 브랜치 전략 기반 협업, PR 및 코드리뷰 활용 |
| 협업 도구 | **Figma, Notion** | 디자인 및 기능 흐름 시각화, 문서화 기반 협업 |
<br>

## Architecture
<img width="4266" height="2400" alt="아키텍처" src="https://github.com/user-attachments/assets/fad04f8d-f958-4ea4-b4cf-00a5df7533b7" />

<br>

## 프로젝트 구조

```Text
📁 Routee-iOS
└── 📁 Routee-iOS
    ├── 📁 Application                     # 앱 진입점과 환경 설정 관련
    │   ├── 📃 AppDelegate.swift           # 앱 생명주기 진입 지점
    │   └── 📃 SceneDelegate.swift         # 씬 생명주기 관리
    ├── 📁 Core                            # 앱 전역 설정 및 공통 환경값 관리
    │   └── 📃 ConfigManager.swift         # 설정값 관리
    ├── 📁 Data                            # Data 계층
    │   └── 📁 Network              
    │       ├── 📁 Base                    # 공통 네트워크 설정
    │       ├── 📁 DTO                     # 서버 요청/응답 데이터 모델
    │       ├── 📁 EndPoint                # 각 API 명세
    │       ├── 📁 Persistence             # 로컬 저장소 관리 (ex: 토큰, 캐시 등)
    │       └── 📁 Repository              # 도메인 데이터 처리 (ex: API 호출, 토큰 저장 등)
    ├── 📁 Presentation                    # Presentation 계층
    │    ├── 📁 Common                     # 전역적으로 사용하는 공통 요소
    │    │   ├── 📁 Base                   # BaseViewController, BaseView 등 공통 베이스
    │    │   ├── 📁 Components             # 공통 컴포넌트
    │    │   ├── 📁 Extensions             # 확장 기능
    │    │   └── 📁 Resources              # 리소스 관련 (ex: 이미지, 폰트)
    │    │       └── 📁 Assets.xcassets    # 이미지 에셋, 컬러셋
    │    ├── 📁 Login                      # 로그인 화면
    │    └── 📁 TabBar                     # 탭바 화면
    │        ├── 📁 ViewController
    │        └── 📁 View
    └──  📃 Info.plist                     # 앱 설정 및 빌드 설정값 관리
```

## Convention

### Code Style
- [Swift 스타일 쉐어 가이드](https://github.com/StyleShare/swift-style-guide)를 따릅니다.  
- `final`, `extension`, `do {}` 패턴 활용, `setStyle / setLayout / setUI` 분리 등 적용.

### Commit 태그

| 태그       | 설명                                                   |
|------------|--------------------------------------------------------|
| `feat`     | 새로운 기능 구현                                       |
| `style`    | UI 구현                                |
| `fix`      | 버그 및 오류 수정                                      |
| `docs`     | README, 템플릿 등 프로젝트 내 문서 수정                                  |
| `setting`  | 프로젝트 관련 설정 변경                            |
| `add`      | 에셋, 라이브러리 추가                                   |
| `refactor` | 코드 리팩토링 (기능 변경 없이 구조 개선)              |
| `chore`    | 사소한 수정                         |
| `hotfix`   | 긴급 수정 (배포 또는 개발 중 발생한 치명적 이슈 해결) |


### Commit Message 규칙

1. **소문자**로 작성합니다.  
2. **한글**로 작성합니다.
3. [태그] #이슈번호 - 작업내용

```markdown
[feat] #1 - 로그인 화면 UI 구현  
[add] #3 - 온보딩 이미지 에셋 추가  
[fix] #5 - 캘린더 날짜 선택 오류 수정  
```

<br>

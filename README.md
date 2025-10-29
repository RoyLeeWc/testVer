# 📱 LezhinSnack iOS 프로젝트

이 문서는 **balcony-ios-short-form (LezhinSnack)** iOS 네이티브
프로젝트의 구조와 설정, 규약을 인수인계용으로 정리한 내용 입니다.

------------------------------------------------------------------------

## 🗂 개요

이 프로젝트는 다음과 같은 주요 구성 요소로 이루어져 있습니다:

-   ⚙️ **SPM 기반 의존성 관리** (CocoaPods 미사용)
-   💳 **인앱결제** : StoreKit2
-   🎨 **UIKit 기반 UI** (SnapKit, 100% CodeBase)
-   🎯 **LezhinSnack.xcodeproj** --- Xcode 프로젝트 파일
-   📂 **LezhinSnack/** --- 애플리케이션 소스 코드
-   ⚙️ **.swiftlint.yml** --- SwiftLint 규약
-   📖 **README.md** --- 프로젝트 설정 및 안내

------------------------------------------------------------------------

## ⚙️ Setup

### 1. Homebrew 설치

[Homebrew 공식 사이트](https://brew.sh/)를 참고해 설치합니다.

### 2. SwiftLint 설치

``` bash
brew install swiftlint
```

------------------------------------------------------------------------

## 📝 SwiftLint 규약

이 프로젝트는 코드의 일관성과 유지보수성을 위해 **SwiftLint**를 적극
활용합니다.

### ✅ 활성화된 규칙

-   `line_length` --- 코드 라인의 길이 제한
-   `nesting` --- 중첩 깊이 제한
-   `function_body_length` --- 함수 길이 제한
-   `type_body_length` --- 클래스/구조체 길이 제한
-   `function_parameter_count` --- 매개변수 수 제한
-   `identifier_name` --- 명확한 네이밍 강제
-   `cyclomatic_complexity` --- 순환 복잡도 관리

### ⚠️ 비활성화된 규칙

-   `trailing_comma` --- 배열·딕셔너리·매개변수 목록 마지막 쉼표 강제하지 않음
-   `empty_enum_arguments` --- 열거형 케이스 호출 시 .foo 와 .foo() 모두 허용
-   `shorthand_operator` --- a = a + b 와 a += b 모두 허용
-   `class_delegate_protocol` --- 델리게이트 프로토콜에서 AnyObject 제약을 강제하지 않음
-   `for_where` --- for + if 와 for … where … 모두 허용

👉 참고: [SwiftLint 공식 GitHub](https://github.com/realm/SwiftLint)

------------------------------------------------------------------------

## 📂 디렉토리 구조

``` plaintext
LezhinSnack/
├── Sources/
│   ├── Common/
│   ├── Coordinator/
│   ├── Data/
│   ├── Domain/
│   └── Presentation/
├── Resources/
├── Base.lproj/
├── en.lproj/
├── ja.lproj/
└── zh-Hans.lproj/
```

### 📦 Sources

#### 🔧 Common

-   `Extension/` --- UIKit & Foundation 확장 (`UIColor`, `UIView`,
    `String` 등)\
-   `Manager/` --- (싱글톤) 로딩 인디케이터, 동시성, 현지화
-   `UIComponent/` --- 재사용 가능한 UI 컴포넌트
-   `Util/` --- 유틸리티 함수

#### 🧭 Coordinator

**⚠️ 주의:** 앱 전체에 적용된 것은 아니며, 초기 진입 위주로 구현됨
- `AppCoordinator.swift` --- 앱 진입
- `MainCoordinator.swift` --- 주요 화면
- `SplashCoordinator.swift` --- 스플래시 화면
- `Coordinator.swift` --- 공통 프로토콜

#### 📡 Data Layer

**⚠️ 주의:** 현재는 테스트용 목업 API만 연동되어 있음
- `API/` --- 엔드포인트, 응답 정의
- `DTO/` --- API 응답 DTO
- `Repository/` --- Domain 계층과 연결
- `Services/` --- 네트워크, 키체인, 스토리지

#### 🏛 Domain Layer

**⚠️ 주의:** UseCase는 목업 코드만 존재. 추후 실제 API 반영 필요
- `Entity/` --- 핵심 비즈니스 모델
- `UseCase/` --- 데이터 흐름 제어

#### 🎨 Presentation Layer

**⚠️ 주의:** API 스펙이 확정되지 않은 상태에서 목업 기반으로 구현됨
- `AppLaunch/` --- 초기 실행
- `Auth/` --- 인증
- `Home/` --- 홈 탭
- `InAppPurchase/` --- 인앱 결제
- `MyList/` --- 저장 목록
- `MyPage/` --- 마이페이지
- `Viewer/` --- 콘텐츠 뷰어
👉 각 기능 디렉토리는 `View/`, `ViewModel/` 로 구분

------------------------------------------------------------------------

## 🎨 Resources

앱에서 사용하는 **이미지, 폰트, 에셋**을 포함

------------------------------------------------------------------------

## 🌍 현지화 (Localization)

### 정적(Localizable.xcstrings)

-   `Resources/Localized/Localizable.xcstrings`
    ⚠️ 현재는 **목업 현지화 문구**만 반영 → 추후 실제 사업부 문구로 교체
    필요

### 동적(DynamicStrings)

-   `Resources/Localized/DynamicStrings`
-   Firebase Remote Config, 로컬 DB 기반 동적 문자열 관리\
    ⚠️ 도입 여부는 내부 검토 단계. 추후 기획자와 협의 필요

------------------------------------------------------------------------

## 📌 Handover Notes

-   전체 구조는 **Clean Architecture** 기반
-   **Presentation 레이어는 목업 상태** → 실제 API 적용 시 추가확인 필요
-   **Data/Domain Layer 역시 목업 기반** → UseCase/Repository 목업상태 보완 필요 
-   **현지화 리소스 교체 필요** (정적 문구 = 목업, 동적 문구 = 미도입)
-   **코디네이터 패턴 부분적 도입** → 확장 혹은 단순화 된 구조로 폐기 필요, 

------------------------------------------------------------------------


# UseCase 구조 개선 예시

-   기존:

``` swift
// AuthUseCase.swift
class AuthUseCase {
    func login(...) { ... }
    func logout(...) { ... }
    func register(...) { ... }
}
```

-   개선 방향:

``` swift
// LoginUseCase.swift
class LoginUseCase {
    func execute(...) { ... }
}

// LogoutUseCase.swift
class LogoutUseCase {
    func execute(...) { ... }
}

// RegisterUseCase.swift
class RegisterUseCase {
    func execute(...) { ... }
}
```
------------------------------------------------------------------------

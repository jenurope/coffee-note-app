# Architecture

## Pattern Overview

- 전반 구조는 "Flutter 화면 -> Cubit 상태 -> Service 데이터 접근 -> Supabase"의 기능 중심 아키텍처다.
- `lib/screens/`는 사용자 플로우 단위로 나뉘고, `lib/cubits/`는 기능별 화면 상태와 비동기 로드를 담당하며, `lib/services/`는 외부 데이터 접근을 담당한다.
- 공통 조립 지점은 `lib/main.dart`, `lib/app.dart`, `lib/core/di/service_locator.dart`, `lib/router/app_router.dart` 네 파일에 집중되어 있다.
- 완전한 레이어 분리는 아니지만, 화면이 데이터 SDK를 직접 호출하지 않고 대부분 Cubit/Service를 거치므로 앱 규모 대비 책임 분리는 비교적 명확하다.

## Layers

- 앱 부트스트랩
  - `lib/main.dart`
  - `lib/app.dart`
  - `lib/config/supabase_config.dart`
  - `lib/core/firebase/firebase_bootstrap.dart`
- 프레젠테이션
  - 화면: `lib/screens/**`
  - 재사용 위젯: `lib/widgets/**`
  - 테마/로컬라이제이션: `lib/config/theme.dart`, `lib/l10n/**`
- 상태 관리
  - 인증/대시보드/목록/상세 Cubit: `lib/cubits/**`
  - Freezed 상태 객체: `lib/cubits/**/**_state.dart`
- 데이터 접근
  - 백엔드 서비스: `lib/services/**`
  - 의존성 주입: `lib/core/di/service_locator.dart`
- 도메인 모델
  - 엔티티와 DTO: `lib/models/**`
  - 선택지/카탈로그: `lib/domain/catalogs/**`
- 플랫폼/운영
  - Android flavor/광고: `android/app/**`
  - iOS Firebase/env 설정: `ios/Firebase/**`, `ios/Flutter/**`
  - SQL 및 운영 문서: `supabase/sql/**`, `docs/**`

## Data Flow

- 앱 시작
  - `lib/main.dart`가 Flutter binding과 native splash를 준비한다.
  - `SupabaseConfig.initialize()`로 환경 기반 SDK를 초기화한다.
  - `setupServiceLocator()`로 서비스와 광고 관련 싱글턴을 등록한다.
  - `FirebaseBootstrap.initialize()`로 관측 계층을 붙인다.
  - `MultiBlocProvider`로 전역 Cubit을 만든 뒤 `CoffeeNoteApp`을 실행한다.
- 일반 화면 흐름
  - 화면이 Cubit 메서드를 호출한다. 예: `lib/screens/beans/bean_list_screen.dart` -> `BeanListCubit.load()`
  - Cubit이 `AuthCubit` 상태를 참조하거나 서비스 메서드를 호출한다.
  - 서비스가 Supabase 테이블/RPC/Storage와 통신한 뒤 모델 객체를 반환한다.
  - Cubit이 성공/실패 상태를 방출하고, 화면은 `BlocBuilder`/`BlocListener`로 렌더링한다.
- 게스트 흐름
  - `AuthCubit`가 `AuthGuest` 상태이면 `BeanListCubit`, `DashboardCubit` 같은 일부 Cubit이 `GuestSampleService`를 사용한다.
- 라우팅 흐름
  - `createRouterFromCubit()`가 `AuthCubit`와 `DashboardCubit` 변화를 `Listenable`로 바꿔 `GoRouter`를 갱신한다.
  - `resolveAppRedirect()`가 인증 상태, 기능 노출 설정, locale 기반 커뮤니티 가시성을 종합해 이동을 결정한다.

## Key Abstractions

- `AuthCubit` / `AuthState`
  - 인증, 게스트 모드, 약관 동의 대기 상태를 단일 진입점으로 표현한다.
- `DashboardCubit`
  - 인증 사용자와 게스트 사용자에 따라 서로 다른 데이터 공급원을 사용해 메인 요약 화면을 구성한다.
- 기능별 List/Detail Cubit
  - `BeanListCubit`, `LogListCubit`, `PostListCubit`, `BeanDetailCubit`, `PostDetailCubit` 등이 화면별 읽기/쓰기 후 상태 갱신을 맡는다.
- `AuthService`, `CoffeeBeanService`, `CoffeeLogService`, `CommunityService`, `ImageUploadService`, `ServiceInquiryService`
  - 외부 I/O를 담당하는 애플리케이션 서비스 계층이다.
- `AppRouteBuilders` + `GoRouter`
  - 경로 정의와 화면 생성 시 의존성 주입(`BlocProvider`)을 묶는다.
- `UserErrorMessage`
  - 서비스/SDK 예외를 화면에서 보여줄 수 있는 로컬라이즈 키로 바꾸는 번역 계층이다.
- `AdsBootstrap` / `FirebaseBootstrap`
  - 앱의 비기능 요구사항(수익화, 관측)을 부트스트랩 단계에서 붙이는 교차 관심사 객체다.

## Entry Points

- 앱 엔트리: `lib/main.dart`
- 앱 조립/MaterialApp: `lib/app.dart`
- 라우터 생성: `lib/router/app_router.dart`
- 서비스 등록: `lib/core/di/service_locator.dart`
- 플랫폼 실행 스크립트: `run_dev.sh`, `run_prod.sh`, `build_prod_aab.sh`
- Android 네이티브 확장: `android/app/src/main/kotlin/com/gooun/works/coffeelog/MainActivity.kt`

## Error Handling

- 서비스 계층은 예외를 `debugPrint`로 기록한 뒤 rethrow 하거나 nullable/fallback 값을 돌려준다.
- Cubit 계층은 예외를 받아 `UserErrorMessage.from()`으로 사용자 메시지 키를 만들고 에러 상태를 방출한다.
- 앱 시작 단계는 초기화 실패 시 `_InitializationErrorApp`을 렌더링해 완전 크래시 대신 안내 화면을 보여준다.
- Firebase 관측은 초기화 실패해도 앱을 계속 실행하도록 설계되어 있다.

## Cross-Cutting Concerns

- 로컬라이제이션: `lib/l10n/**`, `context.l10n`, `supportedLocales`가 전반 UI에 걸쳐 사용된다.
- 인증/권한: `AuthCubit`, 라우터 redirect, 서비스 계층 RLS 가정이 함께 동작한다.
- 기능 플래그: `AppFeatureVisibility`와 `DashboardState.userProfile` 값이 하단 탭/경로 접근 가능 여부를 바꾼다.
- 지역 정책: `lib/core/locale/community_visibility_policy.dart`가 앱 locale과 디바이스 국가코드로 커뮤니티 노출 여부를 결정한다.
- 광고: Android 전용이며, UI 목록 배치 규칙은 `lib/ads/community_feed_ad_layout.dart`에 따로 분리되어 있다.
- 이미지 처리: `lib/services/image_upload_service.dart`가 업로드 전 크기 축소, 버킷별 공개/비공개 URL 정책을 통합한다.

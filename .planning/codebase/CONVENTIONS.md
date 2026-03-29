# Coding Conventions

## Naming Patterns

- 기능 단위 분류를 우선한다. 예: `lib/screens/community/post_detail_screen.dart`, `lib/cubits/community/post_detail_cubit.dart`, `lib/services/community_service.dart`
- Cubit 상태는 Freezed sealed class로 정의하고 `Initial`, `Loading`, `Loaded`, `Error` 같은 상태명을 반복 사용한다. 예: `lib/cubits/auth/auth_state.dart`
- 모델은 도메인 명사를 그대로 사용한다. 예: `CoffeeBean`, `CoffeeLog`, `CommunityPost`, `ServiceInquiry`, `UserProfile`
- 테스트 파일은 소스 파일명을 거의 그대로 따라 `*_test.dart`로 작성한다.

## Code Style

- 내부 모듈은 상대 import, 외부 라이브러리는 package import를 주로 사용한다. `lib/main.dart`, `lib/cubits/*`, `lib/screens/*`에서 일관되게 보인다.
- 상태 객체와 설정값은 `const`, `final`, `static const`를 적극적으로 사용한다.
- 비동기 로직은 Cubit/Service에서 `async`/`await`로 작성하고, 화면은 가능한 한 선언적으로 유지한다.
- 리스트 상태는 `List.unmodifiable(...)`로 감싸 불변 의도를 드러내는 경우가 많다. 예: `lib/cubits/bean/bean_list_cubit.dart`
- 파일 내 private helper는 `_name` 패턴을 사용하고, 작은 보조 메서드로 로직을 쪼개는 편이다.

## Import Organization

- 보통 Flutter/Dart SDK import -> 외부 패키지 import -> 내부 상대 import 순서다.
- 내부 공용 코드는 barrel file보다 직접 경로 import를 선호한다.
- 로컬라이제이션은 `package:coffee_note_app/l10n/app_localizations.dart` 또는 `lib/l10n/l10n.dart` extension을 통해 접근한다.

## Error Handling

- 서비스 계층은 예외를 삼키지 않고 대부분 `debugPrint` 후 rethrow 한다. 사용자 메시지 변환은 서비스보다 Cubit/UI에서 처리한다.
- Cubit 계층은 `UserErrorMessage.from(...)` 또는 명시적 error key를 사용해 화면 친화적 상태로 변환한다.
- 앱 부트스트랩은 초기화 실패 시 즉시 종료하기보다 `_InitializationErrorApp`으로 안내 화면을 보여준다.
- Firebase/Ads 같은 부가 기능 실패는 앱 전체 실패로 연결하지 않는 편이다.

## Logging

- 전용 로거 프레임워크 없이 `debugPrint`를 기본 로그 수단으로 사용한다.
- 서비스와 Cubit에 "무슨 단계에서 실패했는지"를 문자열로 남기는 형태가 많다. 예: `BeanListCubit.load error`, `Firebase 초기화 실패`, `SignInWithGoogle error`
- 운영 로그 집계는 Firebase Crashlytics에 한정되고, 일반 비즈니스 이벤트 로깅 체계는 아직 얕다.

## Comments

- 주석은 "왜 이런 예외 처리가 필요한지" 같은 의도 설명에 주로 사용되며 한국어가 많다.
- 외부 제약이나 계약을 강조하는 주석이 눈에 띈다. 예: `service_locator.dart`의 호출 순서 규칙, `service_inquiry_service.dart`의 guest insert-only 정책 설명
- 자명한 코드에 장황한 주석을 붙이기보다는, 운영 리스크가 있는 지점에만 간결하게 적는 편이다.

## Function Design

- 화면은 입력 검증, 위젯 조합, 사용자 상호작용에 집중하고 네트워크 접근은 Cubit/Service로 위임한다.
- Cubit 메서드는 `load`, `reload`, `loadMore`, `updateFilters`, `onAuthStateChanged`처럼 화면 시나리오 중심 이름을 사용한다.
- Service 메서드는 테이블/행동 중심으로 `getPosts`, `createInquiry`, `uploadImage`, `withdrawAccount` 같은 동사형 API를 노출한다.
- 복잡한 파싱/보정 로직은 private helper로 밀어 넣는다. 예: `CommunityPost._parseLikeStatsCount`, `ImageUploadService._processPhotoImage`

## Module Design

- 의존성 주입은 `setupServiceLocator()` 한곳에서 등록하고, 각 Cubit은 기본적으로 `getIt<T>()`를 사용하되 테스트 시 생성자 주입을 허용한다.
- 인증 사용자와 게스트 사용자 흐름을 같은 Cubit 안에서 분기하는 패턴이 많다. 예: `BeanListCubit`, `DashboardCubit`
- 라우터는 단순 경로 테이블이 아니라 인증, locale, 기능 설정을 모두 포함하는 정책 계층으로 쓰인다.
- 생성 코드(`*.freezed.dart`, `app_localizations*.dart`)를 저장소에 포함해 빌드 전제 조건을 단순화한다.

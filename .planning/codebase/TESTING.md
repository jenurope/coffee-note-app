# Testing Patterns

## Test Framework

- 기본 테스트 프레임워크는 `flutter_test`다.
- mocking은 `mocktail`을 사용한다.
- `bloc_test`가 `pubspec.yaml`에 포함되어 있지만 현재 저장소에서는 표준 `test()`/`testWidgets()`와 `whenListen()` 조합이 더 많이 쓰인다.
- 위젯 테스트에서 라우팅은 실제 `GoRouter`를 띄우는 방식으로 많이 검증한다. 예: `test/router/router_navigation_flow_test.dart`

## Test File Organization

- 테스트는 `test/` 아래에서 소스 구조를 상당히 충실하게 따라간다.
- 현재 테스트 파일 수는 46개다.
- 주요 분류
  - 핵심 로직: `test/core/**`, `test/services/**`, `test/cubits/**`
  - 라우팅/내비게이션: `test/router/**`
  - 화면: `test/screens/**`
  - 공용 위젯: `test/widgets/**`
  - 광고/도메인 모델: `test/ads/**`, `test/models/**`, `test/domain/**`

## Test Structure

- `group()`으로 클래스나 화면 단위 묶음을 만들고, 각 시나리오는 한국어 설명의 `test()` 또는 `testWidgets()`로 작성한다.
- Arrange/Act/Assert가 비교적 선명하다.
- Cubit 테스트는 mock service를 주입해 상태 변화를 확인한다. 예: `test/cubits/auth_cubit_test.dart`
- 위젯 테스트는 로컬라이제이션 delegate, `MaterialApp`/`GoRouter`, 필요한 BlocProvider를 감싼 헬퍼를 두는 패턴이 많다.
- 라우터 테스트는 back stack, tab stack, redirect 정책처럼 사용자 플로우를 실제에 가깝게 검증한다.

## Mocking

- mock 객체는 파일 내부 private class로 정의하는 경우가 많다. 예: `_MockAuthService`, `_MockSupabaseClient`
- stream 기반 상태 검증에는 `whenListen()`을 자주 사용한다.
- enum/value object 인자가 필요한 경우 `registerFallbackValue(...)`를 사용한다. 예: `test/screens/beans/bean_list_screen_test.dart`
- 서비스 로직 테스트에서는 Supabase client/auth client를 mock으로 대체한다.

## Fixtures and Factories

- 공용 fixtures 디렉터리는 없고, 테스트 파일 내부 헬퍼 함수/가짜 서비스로 필요한 데이터를 만든다.
- 대표 예시
  - `_testUser(...)` in `test/cubits/auth_cubit_test.dart`
  - `_buildTestApp(...)` in `test/router/router_navigation_flow_test.dart`
  - `_FakeMobileAdsClient` in `test/ads/ads_bootstrap_test.dart`
- 이 방식은 파일별 독립성은 좋지만, 데이터 생성 규칙이 여러 파일에 중복될 가능성이 있다.

## Coverage

- 강한 영역
  - 인증 상태 전이와 세션 검증 fallback
  - 라우팅 redirect/back stack/탭 히스토리
  - 주요 화면 폼/리스트/상세 UI
  - 광고 부트스트랩과 배치 규칙
  - 이미지 업로드의 버킷/경로 처리
- 약한 영역
  - 실제 Supabase 연동 통합 테스트
  - flavor/Firebase/AdMob/native 설정 검증
  - 배포 스크립트와 SQL 마이그레이션 검증
  - 앱 시작 초기화 전체 플로우의 플랫폼별 E2E

## Test Types

- 순수 단위 테스트: 서비스, 모델 파싱, 카탈로그, 정책 함수
- 상태 테스트: Cubit 상태 전이
- 위젯 테스트: 화면 렌더링, 폼 검증, 내비게이션
- 라우터 플로우 테스트: `GoRouter` 기반 사용자 이동 시나리오
- 저장소 안에는 integration_test 기반 테스트, golden 테스트, 디바이스 E2E 테스트는 보이지 않는다.

## Common Patterns

- 인증 상태에 따라 UI가 바뀌는 화면은 `AuthCubit.test(...)`나 mocked auth cubit을 주입해 분기별 렌더링을 검증한다.
- 네비게이션 회귀 방지를 위해 "뒤로가기 후 어느 화면이 남아야 하는가"를 직접 검증한다.
- 로컬라이제이션 문자열이 중요한 위젯은 `AppLocalizations.delegate`를 포함한 테스트 앱 래퍼를 사용한다.
- 큰 화면 테스트도 많지만, 스크롤/overflow 회귀를 잡기 위한 작은 화면 테스트도 일부 포함된다. 예: `test/screens/beans/bean_list_screen_test.dart`

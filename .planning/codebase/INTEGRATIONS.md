# External Integrations

## APIs & External Services

- Supabase가 핵심 백엔드다. 인증, PostgREST 테이블 접근, RPC, Storage를 모두 `lib/services/*.dart`에서 사용한다.
- Google 로그인은 `lib/services/auth_service.dart`에서 `GoogleSignIn`으로 토큰을 받은 뒤 Supabase `signInWithIdToken`으로 연결한다.
- Firebase Analytics/Crashlytics는 `lib/core/firebase/firebase_bootstrap.dart`를 통해 모바일 앱에서만 초기화된다.
- Android 광고/동의 수집은 `lib/ads/ads_bootstrap.dart`, `lib/ads/consent_manager.dart`, `lib/ads/mobile_ads_client.dart`와 Kotlin 네이티브 광고 팩토리(`android/app/src/main/kotlin/com/gooun/works/coffeelog/CommunityFeedNativeAdFactory.kt`)가 함께 처리한다.
- 앱 버전 표시는 `package_info_plus`를 사용하며 프로필 화면 테스트에서 그 존재가 확인된다. 관련 UI 흐름은 `test/screens/profile/profile_screen_test.dart`에서 다뤄진다.

## Data Storage

- Supabase 테이블
  - 프로필/권한: `profiles`, `terms_catalog`, `user_terms_consents`
  - 기록 도메인: `coffee_beans`, `coffee_logs`
  - 커뮤니티: `community_posts`, `community_comments`, `community_post_likes`, `community_comment_likes`, `community_reports`
  - 문의: `service_inquiries`
- Supabase RPC
  - 회원 탈퇴: `withdraw_my_account` in `lib/services/auth_service.dart`
  - 커뮤니티 소프트 삭제: `soft_delete_community_post` in `lib/services/community_service.dart`
- Supabase Storage 버킷
  - 비공개 경로 기반: `beans`, `logs`
  - 공개 URL 기반: `avatars`, `community`
  - 업로드 정책과 반환 차이는 `lib/services/image_upload_service.dart`에 캡슐화되어 있다.
- 게스트 모드는 원격 저장소 대신 `lib/services/guest_sample_service.dart`, `lib/models/guest_dashboard_snapshot.dart`의 로컬 샘플 데이터를 사용한다.

## Authentication & Identity

- 인증 소스는 Supabase Auth이며 현재 세션 검증은 `AuthService.getValidatedCurrentUser()`에서 수행한다.
- `getClaims()` 검증 실패 시 `getUser()` fallback을 두는 우회 로직이 `lib/services/auth_service.dart`에 들어 있다. 이는 Supabase SDK/토큰 상태 이슈를 흡수하기 위한 방어 코드다.
- Google OAuth 식별자는 `dart-define` 값 `GOOGLE_IOS_CLIENT_ID`, `GOOGLE_WEB_CLIENT_ID`에 의존한다.
- 약관 동의 플로우는 `AuthCubit`와 `AuthService`가 함께 처리하며 데이터는 `terms_catalog`, `user_terms_consents`에서 읽고 쓴다.
- 사용자 기능 노출 설정은 `profiles.is_bean_records_enabled`, `profiles.is_coffee_records_enabled` 값으로 라우터/메인 탭에 반영된다.

## Monitoring & Observability

- Firebase 관측은 `lib/core/firebase/firebase_bootstrap.dart`가 담당한다.
- `prod` 환경에서만 Analytics/Crashlytics 수집을 활성화하고 `dev`에서는 초기화하되 수집은 끈다.
- Flutter 오류, PlatformDispatcher 오류, zone 오류를 모두 전역으로 가로채 Crashlytics로 보내도록 구성되어 있다.
- 애플리케이션 자체 로깅은 대부분 `debugPrint` 수준이다. 구조화 로깅, 원격 로그 집계, 메트릭 파이프라인은 없다.

## CI/CD & Deployment

- 저장소 내 GitHub Actions나 별도 CI 파이프라인 정의는 보이지 않는다. 배포/검증은 현재 수동 스크립트 중심이다.
- 개발/운영 실행은 `run_dev.sh`, `run_prod.sh`, 배포용 Android 번들 생성은 `build_prod_aab.sh`를 사용한다.
- Android는 `android/app/build.gradle.kts`에서 flavor, manifest placeholder, release signing, prod 필수 환경값을 검증한다.
- iOS는 `ios/Runner.xcodeproj/project.pbxproj` 빌드 스크립트가 환경별 Firebase plist를 복사한다.
- Supabase SQL 적용은 CI가 아니라 `supabase/sql/README.md`, `docs/environment-separation.md`의 수동 절차에 따라 Dashboard에서 수행한다.

## Environment Configuration

- 주요 로컬 파일
  - `dart_define.dev.json`
  - `dart_define.prod.json`
  - `android/app/google-services.json`
  - `ios/Firebase/dev/GoogleService-Info.plist`
  - `ios/Firebase/prod/GoogleService-Info.plist`
  - `android/key.properties`
- 예시 파일은 모두 버전 관리되며 실제 값 파일은 로컬에서 복사 생성하는 방식이다.
- 운영 지침과 금지 사항은 `README.md`, `docs/environment-separation.md`를 함께 읽어야 전체 맥락이 맞는다.

## Webhooks & Callbacks

- 저장소 안에 서버 측 webhook 처리기나 외부 callback endpoint 구현은 없다.
- OAuth redirect는 직접 구현한 HTTP callback이 아니라 Google Sign-In SDK + Supabase Auth 조합으로 처리된다.
- Android 네이티브 광고는 `communityFeedNative` 팩토리 이름으로 Flutter 엔진에 등록된다. 이는 외부 webhook은 아니지만 네이티브 채널 경계의 중요한 통합 지점이다.

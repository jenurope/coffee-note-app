# Technology Stack

## Languages

- 애플리케이션 주 언어는 Dart이며 Flutter UI, Cubit 상태, 서비스 계층이 모두 `lib/` 아래에 구현되어 있다.
- Android 전용 네이티브 광고 연동은 Kotlin으로 작성되어 있으며 `android/app/src/main/kotlin/com/gooun/works/coffeelog/`에 위치한다.
- 빌드 및 실행 보조 스크립트는 Bash 기반이며 `run_dev.sh`, `run_prod.sh`, `build_prod_aab.sh`, `run_worktree.sh`에서 관리한다.
- 백엔드 스키마와 운영 절차 문서는 SQL/Markdown으로 유지되며 `supabase/sql/*.sql`, `supabase/sql/README.md`, `docs/environment-separation.md`에 정리되어 있다.
- 로컬 이미지/브랜딩 자산을 만드는 보조 유틸은 Python 스크립트로 존재하며 `create_*.py`, `check_png.py`, `make_transparent.py`가 대표적이다.

## Runtime

- Flutter SDK와 Dart SDK 기준은 `pubspec.yaml`의 `sdk: ^3.10.7`이다.
- 앱 엔트리포인트는 `lib/main.dart`이며 여기서 `SupabaseConfig.initialize()`, `setupServiceLocator()`, `FirebaseBootstrap.initialize()`를 순차 실행한 뒤 `CoffeeNoteApp`을 구동한다.
- Android는 `android/app/build.gradle.kts`에서 `dev`/`prod` flavor를 사용하고 Java/Kotlin 17을 요구한다.
- iOS는 `ios/Runner.xcodeproj/project.pbxproj`의 빌드 스크립트로 환경별 `GoogleService-Info.plist`를 복사해 초기화한다.
- 웹/데스크톱 폴더(`web/`, `macos/`, `linux/`, `windows/`)는 존재하지만 Firebase 수집과 광고는 실제 코드상 모바일 중심으로 제한되어 있다. 예를 들어 `lib/core/firebase/firebase_bootstrap.dart`, `lib/ads/ads_bootstrap.dart`는 지원 플랫폼이 아니면 초기화를 건너뛴다.

## Frameworks

- UI 프레임워크는 Flutter MaterialApp 기반이며 앱 조립은 `lib/app.dart`에서 수행한다.
- 상태관리는 `flutter_bloc` + Cubit 조합을 사용한다. 주요 상태 모듈은 `lib/cubits/auth/`, `lib/cubits/bean/`, `lib/cubits/log/`, `lib/cubits/community/`, `lib/cubits/dashboard/`에 있다.
- 라우팅은 `go_router` 기반이며 전체 경로 정의와 인증/기능 플래그 리다이렉트 로직은 `lib/router/app_router.dart`에 모여 있다.
- 의존성 주입은 `get_it`를 사용하며 등록 지점은 `lib/core/di/service_locator.dart` 하나로 집중되어 있다.
- 백엔드 SDK는 `supabase_flutter`이며 인증, 테이블 조회, RPC, Storage 모두 여기서 처리한다. 진입점은 `lib/config/supabase_config.dart`다.
- 불변 상태 표현은 `freezed_annotation`/`freezed`를 사용한다. 예시는 `lib/cubits/auth/auth_state.dart`, 생성물은 `*.freezed.dart`로 함께 커밋되어 있다.
- 다국어는 `flutter_localizations`와 ARB 기반 생성 코드(`lib/l10n/app_*.arb`, `lib/l10n/app_localizations*.dart`)를 사용한다.
- 리치 텍스트/마크다운 편집은 `flutter_quill`, `markdown_quill`, `flutter_markdown`, `markdown` 조합을 사용한다.

## Key Dependencies

- 인증/백엔드: `supabase_flutter`, `google_sign_in`
- 상태/구조: `flutter_bloc`, `get_it`, `freezed_annotation`
- 라우팅: `go_router`
- 미디어: `image_picker`, `image`, `cached_network_image`, `crop_your_image`
- 관측: `firebase_core`, `firebase_analytics`, `firebase_crashlytics`
- 수익화: `google_mobile_ads`
- 편집/콘텐츠: `flutter_quill`, `markdown_quill`, `flutter_markdown`
- 메타데이터/부가 기능: `intl`, `package_info_plus`, `flutter_native_splash`
- 테스트/생성: `flutter_test`, `mocktail`, `bloc_test`, `build_runner`, `freezed`, `flutter_launcher_icons`

## Configuration

- 런타임 환경값은 루트의 `dart_define.dev.json`, `dart_define.prod.json`으로 주입되며, 예시 파일은 `dart_define.dev.example.json`, `dart_define.prod.example.json`이다.
- Supabase 필수 환경값은 `lib/config/supabase_config.dart`에서 `APP_ENV`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`로 읽는다.
- Google OAuth 클라이언트 ID는 `lib/services/auth_service.dart`에서 `GOOGLE_IOS_CLIENT_ID`, `GOOGLE_WEB_CLIENT_ID`로 읽는다.
- AdMob 설정은 `lib/ads/ads_config.dart`와 `android/app/build.gradle.kts` 양쪽에서 검증한다.
- 린트는 `analysis_options.yaml`의 `package:flutter_lints/flutter.yaml` 기반이다.
- 로컬라이제이션 설정은 `l10n.yaml`, 자산 설정은 `pubspec.yaml`의 `assets/images/`, 스플래시/아이콘 설정도 `pubspec.yaml` 안에 함께 있다.
- 환경 분리와 수동 운영 절차는 `README.md`, `docs/environment-separation.md`에 상세 문서화되어 있다.

## Platform Requirements

- 개발 실행 시 `flutter run` 단독 호출이 아니라 `./run_dev.sh` 또는 `./run_prod.sh` 사용이 사실상 규칙이다.
- Android Firebase 설정 파일 `android/app/google-services.json`은 예시 파일을 복사해 채워야 한다.
- iOS Firebase 설정 파일은 `ios/Firebase/dev/GoogleService-Info.plist`, `ios/Firebase/prod/GoogleService-Info.plist` 경로에 배치해야 한다.
- iOS 선택 오버라이드 설정은 `ios/Flutter/Env.dev.xcconfig`, `ios/Flutter/Env.prod.xcconfig`를 사용할 수 있다.
- Play Store용 release 빌드는 `android/key.properties`가 없으면 실패하도록 `android/app/build.gradle.kts`에서 강제한다.
- 프로덕션 AAB 빌드는 `./build_prod_aab.sh`가 `APP_ENV=prod`, Supabase 키, AdMob 키 존재 여부를 사전 검증한다.

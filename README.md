# 커피로그 (CoffeeLog)

커피 원두와 커피 기록을 관리하는 Flutter 앱입니다.

## 실행 방법

> **⚠️ 중요:** `flutter run`을 직접 사용하지 마세요. 환경변수(`dart-define`)가 누락되면 앱이 정상 동작하지 않습니다.

### 앱 실행

```bash
# 기본 개발 환경 실행 (dev flavor)
./run_dev.sh

# 운영 환경 명시 실행 (prod flavor)
./run_prod.sh

# 특정 디바이스 지정
./run_dev.sh chrome
./run_dev.sh <device-id>
```

`run_dev.sh`, `run_prod.sh`는 내부적으로 `--flavor` + `--dart-define-from-file` 옵션을 사용해 환경별 설정을 전달합니다.

### 환경 파일 설정

프로젝트 루트에 아래 로컬 파일을 생성해 사용합니다(버전관리 제외).

```json
{
  "APP_ENV": "dev|prod",
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "your-publishable-key",
  "GOOGLE_IOS_CLIENT_ID": "your-ios-client-id.apps.googleusercontent.com",
  "GOOGLE_WEB_CLIENT_ID": "your-web-client-id.apps.googleusercontent.com",
  "FIREBASE_PROJECT_ID": "your-firebase-project-id",
  "FIREBASE_MESSAGING_SENDER_ID": "your-firebase-sender-id",
  "FIREBASE_ANDROID_API_KEY": "your-android-api-key",
  "FIREBASE_ANDROID_APP_ID": "your-android-app-id",
  "FIREBASE_IOS_API_KEY": "your-ios-api-key",
  "FIREBASE_IOS_APP_ID": "your-ios-app-id"
}
```

1. `dart_define.dev.example.json` -> `dart_define.dev.json`
2. `dart_define.prod.example.json` -> `dart_define.prod.json`

### iOS 로컬 설정 파일

Google URL Scheme/표시명을 로컬에서 오버라이드하려면 아래 파일을 생성합니다(선택).

1. `ios/Flutter/Env.dev.example.xcconfig` -> `ios/Flutter/Env.dev.xcconfig`
2. `ios/Flutter/Env.prod.example.xcconfig` -> `ios/Flutter/Env.prod.xcconfig`

`Env.*.xcconfig`를 만들지 않아도 예시 파일 기본값으로 빌드는 가능합니다.

### Firebase 수집 정책/보안 메모

- 오픈스펙 범위: Firebase `Analytics` + `Crashlytics`만 포함 (앱 푸시/FCM 제외)
- Firebase 수집 정책은 `APP_ENV` 기준으로 동작합니다.
  - `prod`: Analytics/Crashlytics 활성화
  - `dev`: Analytics/Crashlytics 비활성화
- `FIREBASE_MESSAGING_SENDER_ID`는 Firebase Core 초기화 필수값이며, FCM 사용 여부와는 별개입니다.
- `dart-define` 값(특히 Firebase API 키/앱 ID)은 앱 바이너리에서 추출 가능하므로 비밀값으로 간주하지 않습니다.
- 보안은 아래 운영 통제로 보완합니다.
  - Firebase 앱을 패키지/번들 ID 기준으로 dev/prod 분리 등록
  - Google Cloud API Key에 Android 패키지+SHA, iOS 번들 ID 제한 적용

### 환경 분리 운영 가이드

상세 체크리스트는 `/docs/environment-separation.md`를 참고하세요.

## 기술 스택

- **Flutter** (Dart)
- **상태관리**: flutter_bloc (Cubit) + Freezed
- **DI**: GetIt
- **라우팅**: go_router
- **백엔드**: Supabase (Auth, Database, Storage)

## 프로젝트 구조

```
lib/
├── config/          # 앱 설정 (테마, Supabase)
├── core/            # DI, BLoC Observer
├── cubits/          # 상태관리 (Auth, Bean, Log, Community, Dashboard)
├── models/          # 데이터 모델 (Freezed)
├── router/          # GoRouter 설정
├── screens/         # UI 화면
├── services/        # 비즈니스 로직 (Supabase 연동)
└── widgets/         # 공통 위젯
```

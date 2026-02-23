# 프로덕션/개발 환경 분리 가이드

## 1. 환경 매트릭스

| 구분 | prod | dev |
| --- | --- | --- |
| Flutter flavor | `prod` | `dev` |
| APP_ENV | `prod` | `dev` |
| Android applicationId | `com.gooun.works.coffeelog` | `com.gooun.works.coffeelog.dev` |
| iOS bundle id | `com.gooun.works.coffeelog` | `com.gooun.works.coffeelog.dev` |
| 앱 이름 | 커피로그 | 커피로그 DEV |
| Supabase 프로젝트 | `jbfcltrhniuwxswatyqg` | `csfsencsdhfmhgaezhno` |
| Firebase 프로젝트 | 단일 프로젝트(공용) | 단일 프로젝트(공용) |

## 2. 로컬 파일 준비

### 2-1. Flutter dart-define 파일

1. `dart_define.dev.example.json`을 `dart_define.dev.json`으로 복사
2. `dart_define.prod.example.json`을 `dart_define.prod.json`으로 복사
3. 각 파일에서 아래 키를 실제 값으로 채움
   - `APP_ENV`
   - `SUPABASE_URL`
   - `SUPABASE_PUBLISHABLE_KEY`
   - `GOOGLE_IOS_CLIENT_ID`
   - `GOOGLE_WEB_CLIENT_ID`

### 2-2. Firebase 설정 파일

`dart-define`이 아니라 플랫폼 설정 파일로 Firebase를 초기화합니다.

1. Android 파일 준비
   - `android/app/src/main/google-services.json.example` -> `android/app/src/main/google-services.json`
   - 단일 `google-services.json`에 `com.gooun.works.coffeelog` / `com.gooun.works.coffeelog.dev` client를 함께 포함
2. iOS 파일 준비
   - `ios/Firebase/dev/GoogleService-Info.plist.example` -> `ios/Firebase/dev/GoogleService-Info.plist`
   - `ios/Firebase/prod/GoogleService-Info.plist.example` -> `ios/Firebase/prod/GoogleService-Info.plist`
3. 예시 파일 값을 각 Firebase 앱의 실제 값으로 교체

### 2-3. iOS 선택 오버라이드 파일

기본값은 `Env.*.example.xcconfig`에서 로드됩니다. 필요 시 아래 파일로 덮어씁니다.

1. `ios/Flutter/Env.dev.example.xcconfig` -> `ios/Flutter/Env.dev.xcconfig`
2. `ios/Flutter/Env.prod.example.xcconfig` -> `ios/Flutter/Env.prod.xcconfig`

## 3. 실행 방법

```bash
# 개발 환경 (기본 권장)
./run_dev.sh

# 운영 환경 점검
./run_prod.sh
```

직접 실행 시에도 flavor와 define 파일을 반드시 함께 지정합니다.

```bash
flutter run --flavor dev --dart-define-from-file=dart_define.dev.json
flutter run --flavor prod --dart-define-from-file=dart_define.prod.json
```

## 4. Supabase 개발 프로젝트 세팅 체크리스트

### 4-1. 대상 프로젝트 확인

- 개발: `csfsencsdhfmhgaezhno`
- 프로덕션: `jbfcltrhniuwxswatyqg`

> 원칙: 파괴적 SQL(`truncate`, `drop` 포함)은 개발 프로젝트에서만 수행합니다.

### 4-2. SQL 적용 순서

`/supabase/sql/README.md`의 대상 파일 순서를 그대로 사용합니다.

1. `20260223_dev_bootstrap_final.sql`

SQL Editor 실행 시 Role은 `postgres`(owner)로 지정합니다.

`20260223_dev_bootstrap_final.sql`의 Storage 정책 섹션 실행 시 `ERROR: must be owner of table objects`가 발생하면, Storage Policy는 SQL이 아닌 Dashboard UI에서 수동으로 생성합니다.

### 4-3. 적용 후 검증

1. 개발 앱(dev flavor)에서 로그인/원두/기록/커뮤니티/문의 기능 확인
2. 이미지 업로드(beans/logs/avatars/community) 및 조회 확인
3. 서비스 문의 비로그인 등록, 로그인 사용자 조회 권한 확인
4. 댓글 삭제 후 소프트 삭제 placeholder 동작 확인

## 5. OAuth 수동 작업 체크리스트

환경 분리 시 Google OAuth는 패키지/번들 식별자마다 별도 설정이 필요합니다.

1. Google Cloud Console에서 dev/prod용 iOS 클라이언트 분리
2. 필요 시 dev/prod용 Web Client 분리 후 Supabase Google Provider에 반영
3. iOS URL Scheme(`com.googleusercontent.apps...`)를 환경별로 확인
4. `dart_define.*.json`의 `GOOGLE_IOS_CLIENT_ID`, `GOOGLE_WEB_CLIENT_ID` 값 점검
5. 각 flavor에서 Google 로그인 성공 여부 확인

## 6. Firebase 수동 작업 체크리스트

단일 Firebase 프로젝트를 유지하되, 앱 식별자는 dev/prod로 분리합니다.
오픈스펙 범위는 Firebase `Analytics` + `Crashlytics`이며, 앱 푸시(FCM)는 포함하지 않습니다.

1. Firebase 프로젝트에 Android 앱 2개 등록
   - `com.gooun.works.coffeelog`
   - `com.gooun.works.coffeelog.dev`
2. Firebase 프로젝트에 iOS 앱 2개 등록
   - `com.gooun.works.coffeelog`
   - `com.gooun.works.coffeelog.dev`
3. Firebase 설정 파일 배치
   - Android: 단일 `google-services.json`을 `android/app/src/main`에 배치
   - iOS: `GoogleService-Info.plist`를 환경 경로에 배치
4. 수집 정책 확인
   - `APP_ENV=prod`: Analytics/Crashlytics 활성화
   - `APP_ENV=dev`: Analytics/Crashlytics 비활성화
5. Google Cloud API Key 제한 적용
   - Android: 패키지명 + SHA 인증서 제한
   - iOS: 번들 ID 제한
6. 제한 후 `run_dev.sh`, `run_prod.sh`로 초기화 오류(403 등) 여부 확인

## 7. 금지 사항

1. `flutter run` 단독 실행 금지
2. prod 앱으로 dev DB에 연결하거나, dev 앱으로 prod DB에 연결 금지
3. prod 프로젝트에 개발용 파괴적 SQL 실행 금지
4. Firebase API 키/앱 ID를 비밀값으로 오해하고 서버 비밀키처럼 취급 금지

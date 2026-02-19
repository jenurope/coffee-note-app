# 커피로그 (CoffeeLog)

커피 원두와 커피 기록을 관리하는 Flutter 앱입니다.

## 실행 방법

> **⚠️ 중요:** `flutter run`을 직접 사용하지 마세요. Supabase 환경변수가 전달되지 않아 앱이 정상 동작하지 않습니다.

### 앱 실행

```bash
# 기본 실행 (dart_define.json에서 환경변수 로드)
./run.sh

# 특정 디바이스 지정
./run.sh chrome
./run.sh <device-id>
```

`run.sh`는 내부적으로 `--dart-define-from-file=dart_define.json` 옵션을 사용하여 Supabase URL과 Publishable Key(환경변수명: `SUPABASE_PUBLISHABLE_KEY`)를 전달합니다.

### 환경변수 설정

프로젝트 루트에 `dart_define.json` 파일이 필요합니다:

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "your-publishable-key"
}
```

> `dart_define.json`은 `.gitignore`에 포함되어 있으므로 별도로 생성해야 합니다.

### Supabase 인증 마이그레이션 (개발환경 원샷)

1. Supabase `Project Settings > API Keys`에서 Publishable/Secret Key 체계를 사용하도록 정리합니다.
2. 앱 환경변수 `SUPABASE_PUBLISHABLE_KEY` 값이 Publishable Key(`sb_publishable_...`)인지 확인합니다.
3. `Project Settings > JWT > Signing Keys`에서 Standby Key를 만든 뒤 Rotate를 수행합니다.
4. 전환 확인 후 `Legacy API key`와 `Legacy JWT secret`을 비활성화합니다.
5. `/.well-known/jwks.json`의 `keys`가 비어있지 않은지 확인합니다.
6. 앱 로그인 후 `getClaims` 검증 로그에서 알고리즘이 `HS256`이 아닌지 확인합니다.

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

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

`run.sh`는 내부적으로 `--dart-define-from-file=dart_define.json` 옵션을 사용하여 Supabase URL과 Anon Key를 전달합니다.

### 환경변수 설정

프로젝트 루트에 `dart_define.json` 파일이 필요합니다:

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your-anon-key"
}
```

> `dart_define.json`은 `.gitignore`에 포함되어 있으므로 별도로 생성해야 합니다.

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

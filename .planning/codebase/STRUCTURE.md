# Codebase Structure

## Directory Layout

```text
.
├── android/                  # Android flavor, signing, native ads
├── assets/images/            # 앱 아이콘, 스플래시, 기타 이미지
├── docs/                     # 운영/환경 분리 문서
├── ios/                      # iOS Firebase/env/xcode 설정
├── lib/
│   ├── ads/                  # 광고 설정, 동의, 슬롯 배치
│   ├── config/               # 환경/테마/Supabase 설정
│   ├── core/                 # DI, 에러, Firebase, 공통 정책
│   ├── cubits/               # 기능별 상태 관리
│   ├── domain/catalogs/      # 선택형 도메인 카탈로그
│   ├── l10n/                 # ARB와 생성된 로컬라이제이션 코드
│   ├── models/               # 앱 모델과 DTO
│   ├── router/               # GoRouter와 기능 노출 정책
│   ├── screens/              # 기능별 화면
│   ├── services/             # Supabase/Storage/Auth 연동
│   └── widgets/              # 공용 위젯
├── supabase/sql/             # 수동 적용 SQL 스크립트
├── test/                     # 소스 구조를 거의 따라가는 테스트
└── web/, macos/, linux/, windows/
```

## Directory Purposes

- `lib/ads/`: 광고 활성 조건, UMP 동의 수집, 광고 슬롯 규칙, Android 네이티브 광고 대응
- `lib/config/`: `APP_ENV`, Supabase 초기화, 앱 테마
- `lib/core/`: 앱 전역에서 공유하는 저수준 유틸과 정책
- `lib/cubits/`: 인증, 대시보드, 원두, 기록, 커뮤니티 관련 상태 전이
- `lib/domain/catalogs/`: 원두/커피 기록 선택값을 화면과 분리해 관리
- `lib/models/`: 서버 응답/화면 상태에서 공용으로 사용하는 모델
- `lib/router/`: 경로 상수, redirect 정책, 라우터 refresh glue code
- `lib/screens/`: 실제 사용자 화면과 폼
- `lib/services/`: Supabase 쿼리, RPC, Storage, OAuth, 이미지 업로드
- `lib/widgets/`: 여러 화면에서 재사용되는 UI 구성요소
- `test/`: 단위/위젯 테스트. `lib/`의 기능 분류를 거의 그대로 반영한다.
- `supabase/sql/`: 개발 환경 부트스트랩 및 후속 스키마 변경 SQL

## Key File Locations

- 앱 시작: `lib/main.dart`
- 앱 루트 위젯: `lib/app.dart`
- 라우터: `lib/router/app_router.dart`
- 전역 DI: `lib/core/di/service_locator.dart`
- 인증 서비스: `lib/services/auth_service.dart`
- 커뮤니티 서비스: `lib/services/community_service.dart`
- 이미지 업로드: `lib/services/image_upload_service.dart`
- 환경 분리 문서: `docs/environment-separation.md`
- Android flavor/signing 검증: `android/app/build.gradle.kts`
- Supabase 운영 가이드: `supabase/sql/README.md`

## Naming Conventions

- 화면은 `*_screen.dart`
- 상태 관리자는 `*_cubit.dart`, 상태 타입은 `*_state.dart`
- 서비스는 `*_service.dart`
- 카탈로그는 `*_catalog.dart`
- 공통 위젯은 역할 기반 이름(`bean_list_tile.dart`, `form_leave_confirm_dialog.dart`)을 사용한다.
- Freezed 생성 파일은 원본과 같은 디렉터리에 `*.freezed.dart`로 둔다.
- 로컬라이제이션 리소스는 `app_ko.arb`, `app_en.arb`, `app_ja.arb`와 생성된 `app_localizations*.dart` 쌍으로 유지한다.

## Where to Add New Code

- 새 기능 화면: `lib/screens/<feature>/`
- 새 상태 관리자: `lib/cubits/<feature>/`
- 새 백엔드 접근 로직: `lib/services/`
- 새 모델: `lib/models/`
- 새 선택형 상수/분류 로직: `lib/domain/catalogs/`
- 새 공용 위젯: `lib/widgets/` 또는 하위 서브디렉터리
- 새 라우트 추가 시: `lib/router/app_router.dart`와 필요한 화면/Cubit을 함께 수정
- 새 테스트는 대응하는 소스 위치를 따라 `test/` 아래 미러링해서 추가

## Special Directories

- `.planning/codebase/`: 현재 코드베이스 맵 문서 위치
- `.agents/`, `.codex/`: 로컬 에이전트/도구 설정
- `ios/Firebase/`: 환경별 Firebase plist 보관 위치
- `ios/Flutter/`: flavor별 xcconfig 및 로컬 오버라이드 파일 위치
- `android/app/src/main/kotlin/com/gooun/works/coffeelog/`: Android 커스텀 네이티브 광고 코드
- `assets/images/`: 런처 아이콘, 스플래시, 기타 브랜딩 리소스

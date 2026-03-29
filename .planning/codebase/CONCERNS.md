# Codebase Concerns

## Tech Debt

- `lib/router/app_router.dart`가 877줄로 커져 라우팅 정의, redirect 정책, notifier glue code가 한 파일에 섞여 있다.
- `lib/services/community_service.dart`가 1269줄, `lib/services/auth_service.dart`가 876줄로 커서 도메인별 세부 책임을 더 쪼갤 시점에 가깝다.
- 커뮤니티 상세/작성 화면도 각각 1000줄 안팎(`lib/screens/community/post_detail_screen.dart`, `lib/screens/community/post_form_screen.dart`)이라 UI 회귀와 수정 비용이 커질 수 있다.
- GetIt 전역 싱글턴 패턴은 간단하지만, 기능이 더 늘어나면 의존성 추적과 테스트 격리가 점점 어려워질 수 있다.
- 게스트/인증 사용자 분기가 여러 Cubit에 반복되어 동일 규칙을 수정할 때 파편화 위험이 있다.

## Known Bugs

- `AuthService.getValidatedCurrentUser()` 안에 `getClaims()` null-check 오류 우회 로직이 존재한다. 이는 현재 인증 검증이 외부 SDK 버그/제약을 품고 있다는 신호다.
- `supabase/sql/README.md`에 따르면 storage policy 적용은 소유권 문제로 SQL 실행이 실패할 수 있어 Dashboard 수동 작업이 필요하다. 운영 절차가 코드만으로 완결되지 않는다.
- 커뮤니티 조회는 아바타/프로필 조인 실패 시 다른 쿼리로 재시도한다. 이는 스키마/권한 드리프트가 실제로 발생했거나 최소한 충분히 우려된다는 의미다.

## Security Considerations

- `SUPABASE_PUBLISHABLE_KEY`, Firebase 앱 설정, AdMob 식별자는 클라이언트 앱에 들어가는 값이므로 서버 비밀처럼 숨겨지지 않는다. 보안은 공급자 콘솔의 도메인/패키지/번들 제한에 크게 의존한다.
- `community`, `avatars` 버킷은 공개 URL을 사용하므로 민감한 파일이 업로드되지 않도록 기능 단에서 엄격히 제한해야 한다.
- dev/prod 환경이 `dart-define` 파일과 flavor 조합에 의존하므로 잘못된 조합으로 배포하면 데이터 분리 사고가 날 수 있다.
- 게스트 문의 생성은 insert-only RLS 가정에 의존하므로 정책 변경 시 기능이 쉽게 깨질 수 있다.

## Performance Bottlenecks

- 대시보드는 인증 사용자 기준으로 프로필, 통계, 최근 목록을 여러 번 순차 호출한다. 네트워크 지연이 큰 환경에서는 첫 진입 체감이 나빠질 수 있다.
- `CommunityService`는 게시글/댓글/좋아요 메타데이터를 여러 쿼리와 fallback으로 조합하므로 커뮤니티 규모가 커질수록 병목이 될 가능성이 높다.
- 이미지 리사이즈 로직 `lib/services/image_upload_service.dart`는 CPU 집약적이지만 별도 isolate 분리가 없어 큰 이미지를 연속 처리하면 UI 끊김 위험이 있다.
- 광고와 게시글을 섞는 피드 구조는 단순하지만, 향후 페이지네이션이 복잡해지면 인덱스 계산과 실제 데이터 수의 불일치가 생길 수 있다.

## Fragile Areas

- 로컬 필수 파일 수가 많다. `dart_define.*.json`, Firebase 설정 파일, `android/key.properties` 중 하나만 빠져도 실행/배포가 실패한다.
- Android 광고는 Flutter 코드와 Kotlin 네이티브 팩토리가 함께 맞물리므로 플러그인 업데이트 시 깨질 가능성이 있다.
- 기능 노출 설정이 라우터 redirect, 하단 탭, 대시보드 상태와 모두 연결되어 있어 작은 정책 변경도 여러 계층을 동시에 손봐야 한다.
- 커뮤니티 노출 정책이 locale + 디바이스 국가코드 조합에 의존해 테스트와 실제 기기 결과가 달라질 수 있다.

## Scaling Limits

- 서비스가 테이블별 CRUD 집합을 넘어 점점 업무 규칙까지 품고 있어 기능 확장 시 한 서비스 파일이 지나치게 비대해질 수 있다.
- 라우트 정의가 단일 파일 집중형이라 탭/딥링크/권한 조합이 더 늘어나면 유지보수 난도가 급격히 올라간다.
- SQL 마이그레이션이 수동 적용 중심이라 팀 규모가 커지면 적용 순서와 환경 드리프트 관리가 어려워진다.
- CI/CD 부재는 프로젝트가 커질수록 회귀 탐지 속도를 떨어뜨린다.

## Dependencies at Risk

- `supabase_flutter`: 현재도 인증 검증 workaround가 들어가 있어 업그레이드 시 회귀 가능성 점검이 필요하다.
- `google_mobile_ads`: Android 네이티브 광고 팩토리까지 사용 중이라 SDK 버전 변화의 영향 범위가 크다.
- `flutter_quill`/`markdown_quill`: 편집기 계열 의존성은 버전 충돌과 플랫폼별 버그 가능성이 상대적으로 높다.
- `freezed` + 생성 코드 커밋 방식: 생성기 버전이 바뀌면 대량 diff와 생성물 불일치 위험이 있다.

## Missing Critical Features

- 자동화된 CI, 정적 분석/테스트 파이프라인
- 실제 Supabase 프로젝트를 대상으로 한 통합 검증
- 배포 전 환경 파일/네이티브 설정을 한 번에 검사하는 단일 doctor 스크립트
- SQL 마이그레이션 적용 이력 관리와 검증 자동화
- 운영 로그/비즈니스 이벤트 추적 체계

## Test Coverage Gaps

- `run_dev.sh`, `run_prod.sh`, `build_prod_aab.sh` 같은 운영 스크립트는 자동 검증 범위 밖이다.
- `android/app/build.gradle.kts`, iOS plist 복사 스크립트, 네이티브 광고 팩토리는 단위 테스트가 없다.
- 실제 Google 로그인, Firebase 초기화, AdMob consent 흐름은 대부분 수동 점검 전제다.
- Supabase SQL과 RLS 정책 변경이 앱 코드와 계속 맞는지 확인하는 회귀 테스트가 없다.

# 개발환경 SQL 최종 실행 가이드

## 대상 프로젝트
- dev: `csfsencsdhfmhgaezhno`
- prod(참조 전용): `jbfcltrhniuwxswatyqg`

## 최종 파일
- `20260223_dev_bootstrap_final.sql`

## 실행 순서
1. Supabase Dashboard에서 dev 프로젝트(`csfsencsdhfmhgaezhno`)로 이동
2. SQL Editor Role을 `postgres`로 선택
3. `20260223_dev_bootstrap_final.sql` 전체 실행

## 주의사항
- 이 가이드는 개발환경 전용입니다.
- 본 스크립트는 public 스키마 재생성 포함 파괴적 작업입니다.
- prod 프로젝트에는 절대 실행하지 않습니다.

## `ERROR 42501: must be owner of table objects` 대응
스크립트 내 storage 정책 섹션 실행 중 위 에러가 발생하면 현재 Role에 `storage.objects` 정책 변경 권한이 없는 상태입니다.

1. 스크립트의 public/buckets 섹션까지만 완료
2. Storage 정책은 Dashboard UI에서 수동 생성
3. 정책 조건은 같은 파일의 storage policies 섹션 `create policy` 구문을 그대로 사용

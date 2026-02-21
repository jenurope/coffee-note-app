# 개발환경 SQL 실행 가이드

## 대상 파일
- `20260219_dev_reset_and_code_constraints.sql`
- `20260220_storage_media_buckets_and_policies.sql`
- `20260221_storage_community_bucket_and_policies.sql`

## 실행 목적
- 개발환경 데이터를 초기화합니다.
- 카테고리 컬럼(`coffee_type`, `roast_level`, `brew_method`, `grind_size`)을 코드값만 허용하도록 CHECK 제약을 적용합니다.
- `beans/logs/avatars` 스토리지 버킷을 생성(또는 동기화)하고, 업로드/조회 RLS 정책을 설정합니다.
- `community` 스토리지 버킷을 생성(또는 동기화)하고, 기존 미디어 버킷 정책에 포함합니다.

## 실행 방법
1. Supabase SQL Editor에서 Role을 `postgres`(owner 권한)로 선택한 뒤 스크립트를 실행합니다.
2. 실행 후 앱에서 신규 데이터 등록 시 코드값만 저장되는지 확인합니다.
3. 스토리지 스크립트 실행 후 원두/커피/프로필 이미지 업로드가 정상 동작하는지 확인합니다.
4. 커뮤니티 글 본문 이미지 업로드가 정상 동작하는지 확인합니다.

## 주의사항
- 이 스크립트는 개발환경 전용입니다.
- `truncate ... restart identity cascade`가 포함되어 있어 관련 데이터가 모두 삭제됩니다.
- 스토리지 스크립트는 데이터 삭제 없이 버킷/정책을 idempotent하게 맞춥니다.
- `storage.objects` 정책 생성/삭제는 owner 권한이 필요합니다.

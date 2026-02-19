# 개발환경 SQL 실행 가이드

## 대상 파일
- `20260219_dev_reset_and_code_constraints.sql`

## 실행 목적
- 개발환경 데이터를 초기화합니다.
- 카테고리 컬럼(`coffee_type`, `roast_level`, `brew_method`, `grind_size`)을 코드값만 허용하도록 CHECK 제약을 적용합니다.

## 실행 방법
1. Supabase SQL Editor 또는 로컬 `psql`에서 스크립트를 실행합니다.
2. 실행 후 앱에서 신규 데이터 등록 시 코드값만 저장되는지 확인합니다.

## 주의사항
- 이 스크립트는 개발환경 전용입니다.
- `truncate ... restart identity cascade`가 포함되어 있어 관련 데이터가 모두 삭제됩니다.

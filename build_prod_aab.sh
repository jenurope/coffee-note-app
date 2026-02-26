#!/bin/bash
# 플레이스토어 업로드용 AAB 빌드 스크립트(prod flavor)
# 사용법: ./build_prod_aab.sh [추가 flutter build 옵션]

set -euo pipefail

ENV_FILE="dart_define.prod.json"
if [ ! -f "$ENV_FILE" ]; then
  echo "파일이 없습니다: $ENV_FILE"
  echo "dart_define.prod.example.json을 복사해 값을 채운 뒤 다시 실행하세요."
  exit 1
fi

if ! grep -Eq '"APP_ENV"[[:space:]]*:[[:space:]]*"prod"' "$ENV_FILE"; then
  echo "APP_ENV 값이 prod가 아닙니다: $ENV_FILE"
  exit 1
fi

for key in SUPABASE_URL SUPABASE_PUBLISHABLE_KEY; do
  if ! grep -Eq "\"${key}\"[[:space:]]*:[[:space:]]*\"[^\"]+\"" "$ENV_FILE"; then
    echo "필수 키가 누락되었거나 비어 있습니다: $key"
    exit 1
  fi
done

flutter build appbundle --release --flavor prod --dart-define-from-file="$ENV_FILE" "$@"

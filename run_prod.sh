#!/bin/bash
# 운영 환경(prod flavor) 실행 스크립트
# 사용법: ./run_prod.sh [device]

set -euo pipefail

DEVICE_ARG=""
if [ -n "${1-}" ]; then
  DEVICE_ARG="-d $1"
fi

ENV_FILE="dart_define.prod.json"
if [ ! -f "$ENV_FILE" ]; then
  echo "파일이 없습니다: $ENV_FILE"
  echo "dart_define.prod.example.json을 복사해 값을 채운 뒤 다시 실행하세요."
  exit 1
fi

flutter run $DEVICE_ARG --flavor prod --dart-define-from-file="$ENV_FILE"

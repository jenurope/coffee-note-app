#!/bin/bash
# 커피 노트 앱 개발 환경 실행 스크립트(dev flavor)
# 사용법: ./run_worktree.sh [device] (예: ./run_worktree.sh, ./run_worktree.sh emulator-5554)

set -euo pipefail

# 디바이스 인자 처리
DEVICE_ARG=""
if [ -n "$1" ]; then
  DEVICE_ARG="-d $1"
fi

ROOT_DIR="/Users/jw/workspace/coffee-note-app"
ENV_FILE="$ROOT_DIR/dart_define.dev.json"

if [ ! -f "$ENV_FILE" ]; then
  echo "파일이 없습니다: $ENV_FILE"
  echo "dart_define.dev.example.json을 복사해 값을 채운 뒤 다시 실행하세요."
  exit 1
fi

flutter run $DEVICE_ARG --flavor dev "--dart-define-from-file=$ENV_FILE"

#!/bin/bash
# 커피 노트 앱 실행 스크립트
# 사용법: ./run.sh [device] (예: ./run.sh, ./run.sh chrome)

# 디바이스 인자 처리
DEVICE_ARG=""
if [ -n "$1" ]; then
  DEVICE_ARG="-d $1"
fi

# Flutter 실행 (dart_define.json 사용)
flutter run $DEVICE_ARG --dart-define-from-file=dart_define.json

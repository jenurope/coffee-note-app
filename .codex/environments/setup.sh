#!/bin/bash
# Codex environment bootstrap for coffee-note-app
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "[codex setup] coffee-note-app"

if ! command -v flutter >/dev/null 2>&1; then
  echo "[warn] flutter command not found in PATH"
  exit 0
fi

if [ ! -f "dart_define.dev.json" ]; then
  echo "[warn] dart_define.dev.json is missing"
  echo "       copy dart_define.dev.example.json -> dart_define.dev.json"
fi

if [ ! -f "dart_define.prod.json" ]; then
  echo "[warn] dart_define.prod.json is missing"
  echo "       copy dart_define.prod.example.json -> dart_define.prod.json"
fi

echo "[ok] setup checks completed"

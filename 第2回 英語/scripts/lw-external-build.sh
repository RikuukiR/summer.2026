#!/usr/bin/env bash
# LaTeX Workshop 外部ビルド用（保存 → main.pdf + main-book.pdf を同期生成）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== LaTeX Workshop build: 第2回 英語 ==="
make all
python3 "${ROOT}/scripts/verify-pdf-sync.py"

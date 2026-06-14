#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

make all

echo "=== Creating booklet PDF ==="
pdfbook2 --paper=a4paper --short-edge main.pdf

echo ""
echo "=== 冊子PDF: main-book.pdf ==="
echo "印刷: 両面・短辺とじ → A4を真ん中で二つ折り（A5冊子）"

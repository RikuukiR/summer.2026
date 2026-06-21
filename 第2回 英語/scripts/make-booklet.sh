#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

make booklet

echo ""
echo "印刷: 両面・短辺とじ → A4を真ん中で二つ折り（A5冊子）"

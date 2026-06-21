#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

make booklet

echo ""
echo "印刷: A3・両面・短辺とじ → 真ん中で二つ折り（A4冊子）"

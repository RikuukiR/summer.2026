#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

make booklet

echo ""
echo "印刷: A3・両面・長辺とじ → 真ん中で二つ折り（A4冊子）"
echo "  ファイル: main-book.pdf"
echo "※ プリンターの「冊子印刷」はオフにしてください（面付け済み）"
echo "※ 短辺とじではなく長辺とじで印刷してください"

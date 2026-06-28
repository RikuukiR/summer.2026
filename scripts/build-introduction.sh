#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")/../Introduction" && pwd)"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$DIR"

UPLATEX="/Library/TeX/texbin/uplatex"
DVIPDFMX="/Library/TeX/texbin/dvipdfmx"
TEX="summer_2026_introduction.tex"
DVI="summer_2026_introduction.dvi"
PDF="summer_2026_introduction.pdf"
BOOKLET="summer_2026_introduction-book.pdf"
BOOKLET_SCRIPT="${ROOT}/scripts/make-booklet-pdf.sh"

echo "=== Compiling LaTeX (A4) ==="
"$UPLATEX" -interaction=nonstopmode -file-line-error -kanji=utf8 "$TEX"
"$UPLATEX" -interaction=nonstopmode -file-line-error -kanji=utf8 "$TEX"
"$DVIPDFMX" -o "$PDF" "$DVI"

echo "=== Creating booklet PDF (A3 imposition) ==="
"$BOOKLET_SCRIPT" "$PDF" "$BOOKLET"

echo ""
echo "=== Build completed ==="
echo "  画面確認: ${PDF}"
echo "  印刷用:   ${BOOKLET}"
echo "印刷: A3・両面・短辺とじ → 真ん中で二つ折り（A4冊子）"
echo "※ プリンターの「冊子印刷」はオフにしてください（面付け済み）"

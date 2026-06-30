#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")/../Introduction" && pwd)"
cd "$DIR"

UPLATEX="/Library/TeX/texbin/uplatex"
DVIPDFMX="/Library/TeX/texbin/dvipdfmx"
TEX="summer_2026_self_analysis_sheet.tex"
PDF="summer_2026_self_analysis_sheet.pdf"
BASE="${TEX%.tex}"

"$UPLATEX" -interaction=nonstopmode -file-line-error -kanji=utf8 "$TEX"
"$UPLATEX" -interaction=nonstopmode -file-line-error -kanji=utf8 "$TEX"
"$DVIPDFMX" -o "$PDF" "${BASE}.dvi"

echo "=== Build completed ==="
echo "  提出用: ${DIR}/${PDF}"

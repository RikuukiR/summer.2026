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
TMPPDF="summer_2026_introduction.tmp.pdf"

"$UPLATEX" -interaction=nonstopmode -file-line-error -kanji=utf8 "$TEX"
"$UPLATEX" -interaction=nonstopmode -file-line-error -kanji=utf8 "$TEX"
"$DVIPDFMX" -o "$TMPPDF" "$DVI"
mv -f "$TMPPDF" "$PDF"

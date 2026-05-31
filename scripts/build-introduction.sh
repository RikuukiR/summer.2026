#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/../Introduction" && pwd)"
cd "$DIR"
UPLATEX="/Library/TeX/texbin/uplatex"
DVIPDFMX="/Library/TeX/texbin/dvipdfmx"
"$UPLATEX" -interaction=nonstopmode -file-line-error -kanji=utf8 summer_2026_introduction.tex
"$UPLATEX" -interaction=nonstopmode -file-line-error -kanji=utf8 summer_2026_introduction.tex
"$DVIPDFMX" summer_2026_introduction.dvi

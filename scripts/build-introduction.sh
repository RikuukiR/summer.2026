#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")/../Introduction" && pwd)"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$DIR"

UPLATEX="/Library/TeX/texbin/uplatex"
DVIPDFMX="/Library/TeX/texbin/dvipdfmx"
INTRO_TEX="summer_2026_introduction.tex"
SHEET_TEX="summer_2026_self_analysis_sheet.tex"
INTRO_PDF="summer_2026_introduction.pdf"
SHEET_PDF="summer_2026_self_analysis_sheet.pdf"
BOOKLET="summer_2026_introduction-book.pdf"
BOOKLET_SCRIPT="${ROOT}/scripts/make-booklet-pdf.sh"

compile_tex() {
  local tex="$1"
  local pdf="$2"
  local base="${tex%.tex}"
  echo "=== Compiling ${tex} ==="
  "$UPLATEX" -interaction=nonstopmode -file-line-error -kanji=utf8 "$tex"
  "$UPLATEX" -interaction=nonstopmode -file-line-error -kanji=utf8 "$tex"
  "$DVIPDFMX" -o "$pdf" "${base}.dvi"
}

compile_tex "$INTRO_TEX" "$INTRO_PDF"
compile_tex "$SHEET_TEX" "$SHEET_PDF"

echo "=== Creating booklet PDF (A3 imposition) ==="
"$BOOKLET_SCRIPT" --pad --no-rotate-even --no-crop "$INTRO_PDF" "$BOOKLET"

echo ""
echo "=== Build completed ==="
echo "  講義資料（画面確認）: ${DIR}/${INTRO_PDF}"
echo "  講義資料（印刷用）  : ${DIR}/${BOOKLET}"
echo "  提出用シート        : ${DIR}/${SHEET_PDF}"
echo "印刷: A3・両面・短辺とじ → 真ん中で二つ折り（A4冊子）"
echo "※ プリンターの「冊子印刷」はオフにしてください（面付け済み）"
echo "※ 自己分析シートは中綴じ資料に含めず、別刷りで配布・提出してください"

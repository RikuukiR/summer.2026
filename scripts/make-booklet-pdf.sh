#!/usr/bin/env bash
# A3 中綴じ面付け（短辺とじ）
# 用法: make-booklet-pdf.sh [--pad] [--no-rotate-even] <source.pdf> <output-book.pdf>
set -euo pipefail

usage() {
  echo "用法: make-booklet-pdf.sh [--pad] [--no-rotate-even] [--no-crop] <source.pdf> <output-book.pdf>" >&2
  exit 1
}

PAD=false
ROTATE_EVEN=true
NO_CROP=false
while [ $# -gt 0 ]; do
  case "$1" in
    --pad)
      PAD=true
      shift
      ;;
    --no-rotate-even)
      ROTATE_EVEN=false
      shift
      ;;
    --no-crop)
      NO_CROP=true
      shift
      ;;
    *)
      break
      ;;
  esac
done

[ $# -eq 2 ] || usage

SRC="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
DEST="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PAD_SCRIPT="${ROOT}/scripts/pad-pdf-for-booklet.py"
ROTATE_SCRIPT="${ROOT}/scripts/rotate-booklet-even-pages.py"

if [ ! -f "$SRC" ]; then
  echo "入力 PDF が見つかりません: $SRC" >&2
  exit 1
fi

WORKDIR="$(mktemp -d)"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

INPUT="$SRC"
if $PAD; then
  INPUT="${WORKDIR}/padded.pdf"
  python3 "$PAD_SCRIPT" "$SRC" "$INPUT"
fi

pdfbook2_args=(--paper=a3paper --short-edge)
if $NO_CROP; then
  # 内容領域への自動クロップを止め、原稿の余白どおり A4 全面を面付けする
  pdfbook2_args+=(--no-crop --bottom-margin=45 --top-margin=35 --outer-margin=45)
fi
pdfbook2 "${pdfbook2_args[@]}" "$INPUT"
BOOK_TMP="${INPUT%.pdf}-book.pdf"
if $ROTATE_EVEN; then
  python3 "$ROTATE_SCRIPT" "$BOOK_TMP"
fi
mv -f "$BOOK_TMP" "$DEST"

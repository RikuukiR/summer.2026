#!/usr/bin/env bash
# A3 中綴じ面付け（短辺とじ・数学 main-book.pdf と同じ設定）
# 用法: make-booklet-pdf.sh [--pad] <source.pdf> <output-book.pdf>
set -euo pipefail

usage() {
  echo "用法: make-booklet-pdf.sh [--pad] <source.pdf> <output-book.pdf>" >&2
  exit 1
}

PAD=false
if [ "${1:-}" = "--pad" ]; then
  PAD=true
  shift
fi

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

pdfbook2 --paper=a3paper --short-edge "$INPUT"
BOOK_TMP="${INPUT%.pdf}-book.pdf"
python3 "$ROTATE_SCRIPT" "$BOOK_TMP"
mv -f "$BOOK_TMP" "$DEST"

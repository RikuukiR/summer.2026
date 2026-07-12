#!/usr/bin/env bash
# PDF を Preview で開く（更新後も再読み込み）
set -u

if [ $# -lt 1 ] || [ -z "$1" ]; then
  echo "用法: refresh-pdf.sh <PDFのパス>" >&2
  exit 1
fi

PDF="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"

if [ ! -f "$PDF" ]; then
  echo "PDF が見つかりません: $PDF" >&2
  exit 1
fi

/usr/bin/open -a Preview "$PDF"

#!/usr/bin/env bash
# PDF を Preview で開く（既に開いていれば何もしない）
set -u

if [ $# -lt 1 ] || [ -z "$1" ]; then
  echo "用法: refresh-pdf.sh <PDFのパス>" >&2
  exit 1
fi

PDF="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
PDF_NAME="$(basename "$PDF")"

if [ ! -f "$PDF" ]; then
  echo "PDF が見つかりません: $PDF" >&2
  exit 1
fi

open_count=$(/usr/bin/osascript 2>/dev/null <<APPLESCRIPT || echo 0
tell application "Preview"
  count (every document whose name is "$PDF_NAME")
end tell
APPLESCRIPT
)
if [ "${open_count:-0}" -gt 0 ]; then
  exit 0
fi

/usr/bin/open -g -a Preview "$PDF"

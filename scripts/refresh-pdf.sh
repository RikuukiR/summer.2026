#!/usr/bin/env bash
# PDF を再ビルド後に表示へ反映する（Preview は自動更新しないため再オープンする）
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

if [ -d "/Applications/Skim.app" ]; then
  /usr/bin/open -a Skim "$PDF"
  osascript -e 'tell application "Skim" to activate' 2>/dev/null || true
  exit 0
fi

# Preview: 同じファイルを開いている場合は一度閉じてから開き直す
osascript <<APPLESCRIPT
tell application "Preview"
  set targetPath to "$PDF"
  repeat with d in documents
    try
      if (POSIX path of (path of d)) is targetPath then
        close d saving no
      end if
    end try
  end repeat
end tell
APPLESCRIPT

sleep 0.2
/usr/bin/open -a Preview "$PDF"
osascript -e 'tell application "Preview" to activate' 2>/dev/null || true

#!/usr/bin/env bash
# PDF を再ビルド後に Preview / Skim へ反映する
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

if [ -d "/Applications/Skim.app" ]; then
  /usr/bin/open -a Skim "$PDF"
  osascript -e 'tell application "Skim" to activate' 2>/dev/null || true
  exit 0
fi

# Preview: ファイル名で既存タブを閉じて開き直す（パス比較より確実）
/usr/bin/osascript <<APPLESCRIPT 2>/dev/null || /usr/bin/open -a Preview "$PDF"
tell application "Preview"
  set pdfName to "$PDF_NAME"
  set pdfPath to POSIX file "$PDF"
  repeat with d in documents
    try
      if (name of d as text) is pdfName then
        close d saving no
      end if
    end try
  end repeat
  open pdfPath
  activate
end tell
APPLESCRIPT

#!/usr/bin/env bash
# Introduction の PDF を Preview で前面表示する
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PDF="${ROOT}/Introduction/summer_2026_introduction.pdf"

if [ ! -f "$PDF" ]; then
  echo "PDF がありません。先にビルドしてください:" >&2
  echo "  ${ROOT}/scripts/build-introduction.sh" >&2
  exit 1
fi

/usr/bin/open -a Preview "$PDF"
osascript -e 'tell application "Preview" to activate' 2>/dev/null || true
echo "Preview で開きました:"
echo "  $PDF"

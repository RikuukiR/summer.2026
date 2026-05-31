#!/usr/bin/env bash
# Introduction/summer_2026_introduction.tex を監視し、Preview で PDF を更新する
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIR="${ROOT}/Introduction"
TEX="${DIR}/summer_2026_introduction.tex"
PDF="${DIR}/summer_2026_introduction.pdf"

build() {
  "${ROOT}/scripts/build-introduction.sh"
}

open_pdf() {
  "${ROOT}/scripts/refresh-pdf.sh" "$PDF"
}

echo "=== Introduction PDF プレビュー ==="
echo "ビルド中..."
if ! build; then
  echo "ビルドに失敗しました。ターミナルのログを確認してください。" >&2
  exit 1
fi

echo "Preview で開いています..."
open_pdf
echo ""
echo "監視中: ${TEX}"
echo "（.tex を保存すると自動で再ビルド・PDF更新）"
echo "停止: このターミナルで Ctrl+C"
echo "LWATCH_READY"

mtime() {
  stat -f "%m" "$TEX" 2>/dev/null || stat -c "%Y" "$TEX"
}

last=$(mtime)
while true; do
  sleep 1
  cur=$(mtime)
  if [ "$cur" != "$last" ]; then
    last=$cur
    sleep 0.5
    echo "[$(date '+%H:%M:%S')] 変更を検知 → ビルド..."
    if build; then
      "${ROOT}/scripts/refresh-pdf.sh" "$PDF"
      echo "[$(date '+%H:%M:%S')] PDF を更新しました"
    else
      echo "[$(date '+%H:%M:%S')] ビルド失敗" >&2
    fi
  fi
done

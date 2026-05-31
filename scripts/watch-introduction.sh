#!/usr/bin/env bash
# Introduction/summer_2026_introduction.tex を監視し、外部 PDF を更新する
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIR="${ROOT}/Introduction"
TEX="${DIR}/summer_2026_introduction.tex"
PDF="${DIR}/summer_2026_introduction.pdf"

build() {
  "${ROOT}/scripts/build-introduction.sh"
}

# 初回: 前面で開く
build
/usr/bin/open "$PDF"

echo "監視中: ${TEX}"
echo "停止: ターミナルで Ctrl+C"

mtime() {
  stat -f "%m" "$TEX" 2>/dev/null || stat -c "%Y" "$TEX"
}

last=$(mtime)
while true; do
  sleep 1
  cur=$(mtime)
  if [ "$cur" != "$last" ]; then
    last=$cur
    sleep 0.4
    if build; then
      /usr/bin/open -g "$PDF"
    fi
  fi
done

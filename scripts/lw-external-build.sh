#!/usr/bin/env bash
# LaTeX Workshop 外部ビルド用（保存 → ビルド → PDF 再表示）
set -euo pipefail

TEX="${1:-}"
if [ -z "$TEX" ]; then
  echo "用法: lw-external-build.sh <ルート.tex のパス>" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAME="$(basename "$TEX")"
DIR="$(cd "$(dirname "$TEX")" && pwd)"

case "$NAME" in
  summer_2026_introduction.tex)
    exec "${ROOT}/scripts/build-introduction.sh"
    ;;
  summer_2026_demo.tex)
    cd "$DIR"
    UPLATEX="/Library/TeX/texbin/uplatex"
    DVIPDFMX="/Library/TeX/texbin/dvipdfmx"
    BASE="summer_2026_demo"
    "$UPLATEX" -interaction=nonstopmode -file-line-error -kanji=utf8 "${BASE}.tex"
    "$UPLATEX" -interaction=nonstopmode -file-line-error -kanji=utf8 "${BASE}.tex"
    "$DVIPDFMX" -o "${BASE}.tmp.pdf" "${BASE}.dvi"
    mv -f "${BASE}.tmp.pdf" "${BASE}.pdf"
    ;;
  *)
    echo "未対応の TeX ファイル: $TEX" >&2
    exit 1
    ;;
esac

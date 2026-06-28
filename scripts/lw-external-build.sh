#!/usr/bin/env bash
# LaTeX Workshop 外部ビルド用（保存 → ビルド → PDF 再表示）
set -euo pipefail

TEX="${1:-}"
if [ -z "$TEX" ]; then
  echo "用法: lw-external-build.sh <TeX ファイルのパス>" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAME="$(basename "$TEX")"
DIR="$(cd "$(dirname "$TEX")" && pwd)"
INTRO_DIR="${ROOT}/Introduction"

# Introduction 配下の任意の .tex（sections 含む）→ ルートをビルド
if [[ "$DIR" == "$INTRO_DIR" || "$DIR" == "$INTRO_DIR"/* ]]; then
  exec "${ROOT}/scripts/build-introduction.sh"
fi

ENGLISH_DIR="${ROOT}/第2回 英語"
MATH_DIR="${ROOT}/第2回 数学"

# 第2回 英語 / 第2回 数学 配下の任意の .tex → make all（main.pdf + 冊子を同期）
if [[ "$DIR" == "$ENGLISH_DIR" || "$DIR" == "$ENGLISH_DIR"/* ]]; then
  exec "${ENGLISH_DIR}/scripts/lw-external-build.sh" "$TEX"
fi

if [[ "$DIR" == "$MATH_DIR" || "$DIR" == "$MATH_DIR"/* ]]; then
  exec "${MATH_DIR}/scripts/build-main.sh"
fi

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

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

# English/*-E 配下
for project_dir in "${ROOT}/English"/*-E; do
  [ -d "$project_dir" ] || continue
  if [[ "$DIR" == "$project_dir" || "$DIR" == "$project_dir"/* ]]; then
    if [ -f "${project_dir}/scripts/lw-external-build.sh" ]; then
      exec "${project_dir}/scripts/lw-external-build.sh" "$TEX"
    elif [ -f "${project_dir}/scripts/build-main.sh" ]; then
      exec "${project_dir}/scripts/build-main.sh"
    fi
  fi
done

# Mathematics/*-M 配下
for project_dir in "${ROOT}/Mathematics"/*-M; do
  [ -d "$project_dir" ] || continue
  if [[ "$DIR" == "$project_dir" || "$DIR" == "$project_dir"/* ]]; then
    if [ -f "${project_dir}/scripts/lw-external-build.sh" ]; then
      exec "${project_dir}/scripts/lw-external-build.sh" "$TEX"
    elif [ -f "${project_dir}/scripts/build-main.sh" ]; then
      exec "${project_dir}/scripts/build-main.sh"
    fi
  fi
done

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

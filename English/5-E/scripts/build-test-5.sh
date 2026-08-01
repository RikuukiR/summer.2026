#!/usr/bin/env bash
# sections/test5/ 配下の最終テスト PDF を生成
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR="${ROOT}/sections/test5"
MAIN_TEX="test-main.tex"
PDF_NAME="最終テスト.pdf"

cd "$TEST_DIR"

MODE="$(grep -E '^\\showanswer(true|false)' "${ROOT}/preamble.tex" | tail -1 | tr -d ' \t' || true)"
echo "=== 最終テスト ビルド開始 (${MODE:-unknown}) ==="

rm -f "${MAIN_TEX%.tex}.aux" "${MAIN_TEX%.tex}.log" "${MAIN_TEX%.tex}.dvi"

uplatex -synctex=1 -interaction=nonstopmode -file-line-error "$MAIN_TEX"
uplatex -synctex=1 -interaction=nonstopmode -file-line-error "$MAIN_TEX"
dvipdfmx "${MAIN_TEX%.tex}.dvi"
mv -f "${MAIN_TEX%.tex}.pdf" "${TEST_DIR}/${PDF_NAME}"

rm -f "${MAIN_TEX%.tex}.aux" "${MAIN_TEX%.tex}.log" "${MAIN_TEX%.tex}.dvi" "${MAIN_TEX%.tex}.synctex.gz"

echo "=== 完了: ${TEST_DIR}/${PDF_NAME} ==="

#!/usr/bin/env bash
# sections/test5/ 配下の最終テスト PDF（nor / adv）を生成
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR="${ROOT}/sections/test5"

build_one() {
  local main_tex="$1"
  local pdf_name="$2"
  cd "$TEST_DIR"
  rm -f "${main_tex%.tex}.aux" "${main_tex%.tex}.log" "${main_tex%.tex}.dvi"
  uplatex -synctex=1 -interaction=nonstopmode -file-line-error "$main_tex"
  uplatex -synctex=1 -interaction=nonstopmode -file-line-error "$main_tex"
  dvipdfmx "${main_tex%.tex}.dvi"
  mv -f "${main_tex%.tex}.pdf" "${TEST_DIR}/${pdf_name}"
  rm -f "${main_tex%.tex}.aux" "${main_tex%.tex}.log" "${main_tex%.tex}.dvi" "${main_tex%.tex}.synctex.gz"
}

MODE="$(grep -E '^\\showanswer(true|false)' "${ROOT}/preamble.tex" | tail -1 | tr -d ' \t' || true)"
echo "=== 最終テスト ビルド開始 (${MODE:-unknown}) ==="

build_one "test-main-nor.tex" "最終テスト_nor.pdf"
echo "=== 完了: ${TEST_DIR}/最終テスト_nor.pdf ==="

build_one "test-main-adv.tex" "最終テスト_adv.pdf"
echo "=== 完了: ${TEST_DIR}/最終テスト_adv.pdf ==="

# 後方互換: test-main.tex → 最終テスト_nor.pdf を 最終テスト.pdf にもコピー
cp -f "${TEST_DIR}/最終テスト_nor.pdf" "${TEST_DIR}/最終テスト.pdf"
echo "=== 完了: ${TEST_DIR}/最終テスト.pdf（nor 版） ==="

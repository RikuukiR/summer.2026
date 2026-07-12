#!/usr/bin/env bash
# sections/test3/ 配下のテスト PDF を生成
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR="${ROOT}/sections/test3"

build_test() {
  local main_tex="$1"
  local pdf_name="$2"
  local label="$3"

  cd "$TEST_DIR"

  MODE="$(grep -E '^\\showanswer(true|false)' "${ROOT}/preamble.tex" | tail -1 | tr -d ' \t' || true)"
  echo "=== ${label} ビルド開始 (${MODE:-unknown}) ==="

  rm -f "${main_tex%.tex}.aux" "${main_tex%.tex}.log" "${main_tex%.tex}.dvi"

  uplatex -synctex=1 -interaction=nonstopmode -file-line-error "$main_tex"
  uplatex -synctex=1 -interaction=nonstopmode -file-line-error "$main_tex"
  dvipdfmx "${main_tex%.tex}.dvi"
  mv -f "${main_tex%.tex}.pdf" "${TEST_DIR}/${pdf_name}"

  rm -f "${main_tex%.tex}.aux" "${main_tex%.tex}.log" "${main_tex%.tex}.dvi" "${main_tex%.tex}.synctex.gz"

  echo "=== 完了: ${TEST_DIR}/${pdf_name} ==="
}

TARGET="${1:-all}"

case "$TARGET" in
  confirm)
    build_test "test-main.tex" "第3回 確認テスト.pdf" "第3回 確認テスト"
    ;;
  review)
    build_test "review-main.tex" "第3回 復習テスト.pdf" "第3回 復習テスト"
    ;;
  all)
    build_test "test-main.tex" "第3回 確認テスト.pdf" "第3回 確認テスト"
    build_test "review-main.tex" "第3回 復習テスト.pdf" "第3回 復習テスト"
    ;;
  *)
    echo "用法: build-test-3.sh [confirm|review|all]" >&2
    exit 1
    ;;
esac

#!/usr/bin/env bash
# LaTeX Workshop / 保存時ビルド用
# 編集中の教材に応じて該当 PDF のみを同期生成する
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

resolve_project() {
  local tex_path="${1:-}"
  local tex_dir=""

  if [[ -n "$tex_path" && -f "$tex_path" ]]; then
    tex_dir="$(cd "$(dirname "$tex_path")" && pwd)"
  fi

  case "$tex_dir" in
    "$ROOT"/作図|"$ROOT"/作図/*)
      echo "作図"
      return 0
      ;;
    "$ROOT"/式の計算の利用|"$ROOT"/式の計算の利用/*)
      echo "式の計算の利用"
      return 0
      ;;
  esac

  echo "作図"
}

TEX="${1:-}"
if [[ -z "$TEX" ]]; then
  MODE="$(grep -E '^\\showanswer(true|false)' preamble.tex | tail -1 | tr -d ' \t' || true)"
  echo "=== 3-M 数学 全教材ビルド開始 (${MODE:-unknown}) ==="
  make -B all
  python3 "${ROOT}/scripts/verify-pdf-sync.py"
  echo "=== 完了: 作図 / 式の計算の利用 の PDF を更新しました ==="
  exit 0
fi

if [[ -n "$TEX" ]]; then
  TEX_DIR="$(cd "$(dirname "$TEX")" && pwd)"
  TEST3_DIR="${ROOT}/sections/test3"
  if [[ "$TEX_DIR" == "$TEST3_DIR" || "$TEX_DIR" == "$TEST3_DIR"/* ]]; then
    MODE="$(grep -E '^\\showanswer(true|false)' preamble.tex | tail -1 | tr -d ' \t' || true)"
    case "$(basename "$TEX")" in
      第3回\ 復習テスト.tex|review-main.tex)
        echo "=== 第3回 復習テスト ビルド開始 (${MODE:-unknown}) ==="
        bash "${ROOT}/scripts/build-test-3.sh" review
        echo "=== 完了: sections/test3/第3回 復習テスト.pdf を更新しました ==="
        "${ROOT}/scripts/refresh-pdf.sh" "${TEST3_DIR}/第3回 復習テスト.pdf"
        ;;
      test-setup.tex)
        echo "=== 第3回 テスト類 ビルド開始 (${MODE:-unknown}) ==="
        bash "${ROOT}/scripts/build-test-3.sh" all
        echo "=== 完了: sections/test3/ のテスト PDF を更新しました ==="
        "${ROOT}/scripts/refresh-pdf.sh" "${TEST3_DIR}/第3回 確認テスト.pdf"
        "${ROOT}/scripts/refresh-pdf.sh" "${TEST3_DIR}/第3回 復習テスト.pdf"
        ;;
      *)
        echo "=== 第3回 確認テスト ビルド開始 (${MODE:-unknown}) ==="
        bash "${ROOT}/scripts/build-test-3.sh" confirm
        echo "=== 完了: sections/test3/第3回 確認テスト.pdf を更新しました ==="
        "${ROOT}/scripts/refresh-pdf.sh" "${TEST3_DIR}/第3回 確認テスト.pdf"
        ;;
    esac
    exit 0
  fi
fi

PROJECT="$(resolve_project "$TEX")"
PDF="${ROOT}/${PROJECT}/main.pdf"
BOOK="${ROOT}/${PROJECT}/main-book.pdf"
MODE="$(grep -E '^\\showanswer(true|false)' preamble.tex | tail -1 | tr -d ' \t' || true)"

echo "=== 3-M 数学 (${PROJECT}) ビルド開始 (${MODE:-unknown}) ==="
make -B "${PDF}" "${BOOK}"
python3 "${ROOT}/scripts/verify-pdf-sync.py" "${PROJECT}"

echo "=== 完了: ${PDF} / ${BOOK} を更新しました ==="
"${ROOT}/scripts/refresh-pdf.sh" "${PDF}"

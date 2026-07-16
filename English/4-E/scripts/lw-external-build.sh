#!/usr/bin/env bash
# LaTeX Workshop / 保存時ビルド用
# どの .tex を保存しても main.pdf + main-book.pdf を必ず同期生成する
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TEX="${1:-}"
if [[ -n "$TEX" ]]; then
  TEX_DIR="$(cd "$(dirname "$TEX")" && pwd)"
  TEST4_DIR="${ROOT}/sections/test4"
  if [[ "$TEX_DIR" == "$TEST4_DIR" || "$TEX_DIR" == "$TEST4_DIR"/* ]]; then
    MODE="$(grep -E '^\\showanswer(true|false)' preamble.tex | tail -1 | tr -d ' \t' || true)"
    case "$(basename "$TEX")" in
      第4回\ 復習テスト.tex|review-main.tex)
        echo "=== 第4回 復習テスト ビルド開始 (${MODE:-unknown}) ==="
        bash "${ROOT}/scripts/build-test-4.sh" review
        echo "=== 完了: sections/test4/第4回 復習テスト.pdf を更新しました ==="
        "${ROOT}/scripts/refresh-pdf.sh" "${TEST4_DIR}/第4回 復習テスト.pdf"
        ;;
      test-setup.tex)
        echo "=== 第4回 テスト類 ビルド開始 (${MODE:-unknown}) ==="
        bash "${ROOT}/scripts/build-test-4.sh" all
        echo "=== 完了: sections/test4/ のテスト PDF を更新しました ==="
        "${ROOT}/scripts/refresh-pdf.sh" "${TEST4_DIR}/第4回 確認テスト.pdf"
        "${ROOT}/scripts/refresh-pdf.sh" "${TEST4_DIR}/第4回 復習テスト.pdf"
        ;;
      *)
        echo "=== 第4回 確認テスト ビルド開始 (${MODE:-unknown}) ==="
        bash "${ROOT}/scripts/build-test-4.sh" confirm
        echo "=== 完了: sections/test4/第4回 確認テスト.pdf を更新しました ==="
        "${ROOT}/scripts/refresh-pdf.sh" "${TEST4_DIR}/第4回 確認テスト.pdf"
        ;;
    esac
    exit 0
  fi
fi

MODE="$(grep -E '^\\showanswer(true|false)' preamble.tex | tail -1 | tr -d ' \t' || true)"
echo "=== 4-E 英語 ビルド開始 (${MODE:-unknown}) ==="

# showanswer 切替を確実に反映（キャッシュでスキップされないよう強制再ビルド）
make -B main.pdf main-book.pdf test-4

python3 "${ROOT}/scripts/verify-pdf-sync.py"

echo "=== 完了: main.pdf / main-book.pdf を更新しました ==="
"${ROOT}/scripts/refresh-pdf.sh" "${ROOT}/main.pdf"

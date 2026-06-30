#!/usr/bin/env bash
# LaTeX Workshop / 保存時ビルド用
# どの .tex を保存しても main.pdf + main-book.pdf を必ず同期生成する
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

MODE="$(grep -E '^\\showanswer(true|false)' preamble.tex | tail -1 | tr -d ' \t' || true)"
echo "=== 第1回 英語 ビルド開始 (${MODE:-unknown}) ==="

# showanswer 切替を確実に反映（キャッシュでスキップされないよう強制再ビルド）
make -B all

python3 "${ROOT}/scripts/verify-pdf-sync.py"

echo "=== 完了: main.pdf / main-book.pdf を更新しました ==="
"${ROOT}/scripts/refresh-pdf.sh" "${ROOT}/main.pdf"

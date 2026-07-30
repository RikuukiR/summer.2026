#!/usr/bin/env bash
# main.pdf と main-book.pdf を同期生成
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

MODE="$(grep -E '^\\showanswer(true|false)' preamble.tex | tail -1 | tr -d ' \t' || true)"
echo "=== 4-M 数学 ビルド開始 (${MODE:-unknown}) ==="

make -B main.pdf main-book.pdf
rm -f .crop-tmp*.pdf

echo "=== 完了: main.pdf / main-book.pdf を更新しました ==="

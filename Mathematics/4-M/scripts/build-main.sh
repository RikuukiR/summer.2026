#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# LaTeX Workshop からのビルドはプレビュー用に main.pdf のみ生成
make main.pdf

#!/usr/bin/env bash
# LaTeX Workshop 手動ビルド用
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

"${ROOT}/scripts/build-main.sh"

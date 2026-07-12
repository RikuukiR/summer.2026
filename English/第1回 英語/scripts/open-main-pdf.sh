#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PDF="${ROOT}/main.pdf"

if [ ! -f "$PDF" ]; then
  echo "PDF がありません。先にビルドします..."
  "${ROOT}/scripts/build-main.sh"
fi

"${ROOT}/scripts/refresh-pdf.sh" "$PDF"

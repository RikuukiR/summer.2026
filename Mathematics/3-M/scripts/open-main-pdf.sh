#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="${1:-作図}"
PDF="${ROOT}/${PROJECT}/main.pdf"

if [ ! -f "$PDF" ]; then
  echo "PDF がありません。先にビルドします..."
  make -C "$ROOT" "${PROJECT}/main.pdf"
fi

"${ROOT}/scripts/refresh-pdf.sh" "$PDF"

#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PDF="${ROOT}/Introduction/summer_2026_introduction.pdf"

if [ ! -f "$PDF" ]; then
  echo "PDF がありません。先にビルドしてください:" >&2
  echo "  ${ROOT}/scripts/build-introduction.sh" >&2
  exit 1
fi

exec "${ROOT}/scripts/refresh-pdf.sh" "$PDF"

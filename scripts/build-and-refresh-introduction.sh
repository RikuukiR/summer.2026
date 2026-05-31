#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"${ROOT}/scripts/build-introduction.sh"
"${ROOT}/scripts/refresh-pdf.sh" "${ROOT}/Introduction/summer_2026_introduction.pdf"

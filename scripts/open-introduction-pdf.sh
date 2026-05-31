#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec "${ROOT}/scripts/refresh-pdf.sh" "${ROOT}/Introduction/summer_2026_introduction.pdf"

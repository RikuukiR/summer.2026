#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

exec "${ROOT}/scripts/lw-external-build.sh" "${1:-${ROOT}/main.tex}"

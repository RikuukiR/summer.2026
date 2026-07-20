#!/usr/bin/env bash
# 各教材を監視し、外部 PDF（Preview）を更新する
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

build_all() {
  if ! make -C "$ROOT" -B all; then
    return 1
  fi
  return 0
}

echo "=== 3-M 数学 外部 PDF プレビュー ==="
echo "ビルド中..."
if ! build_all; then
  echo "ビルドに失敗しました。ターミナルのログを確認してください。" >&2
  exit 1
fi

"${ROOT}/scripts/refresh-pdf.sh" "${ROOT}/作図/main.pdf"
"${ROOT}/scripts/refresh-pdf.sh" "${ROOT}/式の計算の利用/main.pdf"

echo ""
echo "Preview で開きました:"
echo "  - ${ROOT}/作図/main.pdf"
echo "  - ${ROOT}/式の計算の利用/main.pdf"
echo "監視中: preamble.tex, 作図/, 式の計算の利用/"
echo "（.tex を保存すると自動で再ビルド）"
echo "停止: このターミナルで Ctrl+C"

mtime_all() {
  find "$ROOT" \( -maxdepth 1 -name 'preamble.tex' -o -path '*/作図/*.tex' -o -path '*/作図/*/*.tex' -o -path '*/式の計算の利用/*.tex' -o -path '*/式の計算の利用/*/*.tex' \) -print0 2>/dev/null \
    | sort -z \
    | xargs -0 stat -f "%m %N" 2>/dev/null \
    | md5 -q 2>/dev/null || echo 0
}

last=$(mtime_all)
while true; do
  sleep 1
  cur=$(mtime_all)
  if [ "$cur" != "$last" ]; then
    last=$cur
    sleep 0.5
    echo "[$(date '+%H:%M:%S')] 変更を検知 → ビルド..."
    if build_all; then
      echo "[$(date '+%H:%M:%S')] PDF を更新しました"
    else
      echo "[$(date '+%H:%M:%S')] ビルド失敗" >&2
    fi
  fi
done

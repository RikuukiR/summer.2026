#!/usr/bin/env bash
# Introduction 配下の .tex を監視し、外部 PDF を更新する
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIR="${ROOT}/Introduction"
PDF="${DIR}/summer_2026_introduction.pdf"

build() {
  "${ROOT}/scripts/build-introduction.sh"
}

latest_mtime() {
  find "$DIR" -name '*.tex' -print0 2>/dev/null \
    | xargs -0 stat -f '%m' 2>/dev/null \
    | sort -n \
    | tail -1
}

echo "=== Introduction 外部 PDF プレビュー ==="
echo "ビルド中..."
if ! build; then
  echo "ビルドに失敗しました。ターミナルのログを確認してください。" >&2
  exit 1
fi

"${ROOT}/scripts/refresh-pdf.sh" "$PDF"

echo ""
if [ -d "/Applications/Skim.app" ]; then
  echo "Skim で開きました: ${PDF}"
  echo "（Skim はファイル更新を自動で再読み込みします。ウィンドウは開き直しません）"
else
  echo "Preview で開きました: ${PDF}"
  echo "（Preview は自動更新されません。Skim の利用を推奨: brew install --cask skim）"
fi
echo "  画面確認: ${PDF}"
echo "  印刷用:   ${DIR}/summer_2026_introduction-book.pdf"
echo "監視中: ${DIR} 配下の .tex"
echo "（.tex を保存すると自動で再ビルド）"
echo "停止: このターミナルで Ctrl+C"

last="$(latest_mtime)"
while true; do
  sleep 1
  cur="$(latest_mtime)"
  if [ -n "$cur" ] && [ "$cur" != "$last" ]; then
    last="$cur"
    sleep 0.5
    echo "[$(date '+%H:%M:%S')] 変更を検知 → ビルド..."
    if build; then
      echo "[$(date '+%H:%M:%S')] PDF を更新しました"
    else
      echo "[$(date '+%H:%M:%S')] ビルド失敗" >&2
    fi
  fi
done

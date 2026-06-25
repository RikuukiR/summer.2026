#!/usr/bin/env bash
# main.tex / preamble.tex / sections/*.tex を監視し、外部 PDF を更新する
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PDF="${ROOT}/main.pdf"

build() {
  local before after
  before=""
  [ -f "$PDF" ] && before=$(stat -f %m "$PDF" 2>/dev/null || echo "")
  if ! "${ROOT}/scripts/build-main.sh"; then
    return 1
  fi
  after=$(stat -f %m "$PDF" 2>/dev/null || echo "")
  if [ -n "$before" ] && [ "$before" = "$after" ]; then
    echo "[$(date '+%H:%M:%S')] ビルドをスキップ（PDF は最新です）" >&2
    return 2
  fi
  return 0
}

echo "=== 第2回 英語 外部 PDF プレビュー ==="
echo "ビルド中..."
build
build_status=$?
if [ "$build_status" -eq 1 ]; then
  echo "ビルドに失敗しました。ターミナルのログを確認してください。" >&2
  exit 1
fi

"${ROOT}/scripts/refresh-pdf.sh" "$PDF"

echo ""
echo "Preview で開きました: ${PDF}"
echo "（更新後は Preview でファイルを開き直すか、再ビルド後に再度開いてください）"
echo "監視中: main.tex, preamble.tex, sections/"
echo "（.tex を保存すると自動で再ビルド）"
echo "停止: このターミナルで Ctrl+C"

mtime_all() {
  find "$ROOT" \( -maxdepth 1 -name 'main.tex' -o -maxdepth 1 -name 'preamble.tex' -o -path '*/sections/*.tex' -o -path '*/sections/*/*.tex' \) -print0 2>/dev/null \
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
    build
    build_status=$?
    case $build_status in
      0) echo "[$(date '+%H:%M:%S')] PDF を更新しました" ;;
      1) echo "[$(date '+%H:%M:%S')] ビルド失敗" >&2 ;;
    esac
  fi
done

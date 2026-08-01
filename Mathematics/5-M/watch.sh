#!/bin/bash

# LaTeX Auto-compile Script
# リアルタイムでファイル変更を監視してPDFを自動生成

echo "=== LaTeX Auto-compile Script ==="
echo "監視対象: main.tex, preamble.tex, sections/"
echo "終了するには Ctrl+C を押してください"
echo ""

# 初回コンパイル
echo "初回コンパイル中..."
make all
echo "初回コンパイル完了"
echo ""

# fswatch が利用可能かチェック
if command -v fswatch >/dev/null 2>&1; then
    echo "fswatch を使用してファイル監視を開始します..."
    fswatch -o main.tex preamble.tex sections | while read f; do
        echo "ファイル変更を検出しました ($(date))"
        make all
        echo "コンパイル完了"
        echo ""
    done
else
    echo "fswatch が見つかりません。ポーリング方式で監視します..."
    echo "fswatch をインストールすることをお勧めします: brew install fswatch"
    echo ""

    # ポーリング方式でファイル監視
    while true; do
        sleep 2
        if [[ main.tex -nt main.pdf ]] || [[ preamble.tex -nt main.pdf ]] || find sections -name '*.tex' -newer main.pdf 2>/dev/null | grep -q .; then
            echo "ファイル変更を検出しました ($(date))"
            make all
            echo "コンパイル完了"
            echo ""
        fi
    done
fi

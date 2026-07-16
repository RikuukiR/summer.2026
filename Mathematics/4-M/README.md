# 4-M 数学 - LaTeX 教材

## 概要

この教材は2026年度一斉夏期講習「4-M 数学」用の LaTeX 教材です。
テーマは「関数」（正比例・反比例・一次関数・二次関数）です。
リアルタイムで PDF の変更を確認できる自動コンパイル機能付きです。

## ディレクトリ構成

```
4-M/
├── README.md      # このファイル
├── main.tex       # メインのLaTeX教材
├── preamble.tex   # LaTeXプリアンブル
├── Makefile       # LaTeXコンパイル用
├── watch.sh       # 自動コンパイルスクリプト
└── sections/      # セクション別のTeXファイル
    ├── 正比例/
    ├── 反比例/
    ├── 一次関数/
    ├── テクニック/
    └── 二次関数/
```

## 🚀 使用方法

### VS Code での使用（推奨）

**前提条件**: LaTeX Workshop 拡張機能がインストールされていること

1. **ビルド方法**：
   - `Cmd+Option+B` (Mac)
   - コマンドパレット → "Tasks: Run Task" → "4-M 数学: ビルド"

2. **PDF プレビュー**：
   - `Cmd+Option+P` でビルド＋外部 PDF を開く

3. **リアルタイム更新**：
   - `Cmd+Option+W` で監視モード開始

### コマンドラインでの使用

```bash
make all          # PDFの作成
make clean        # 補助ファイルを削除
make answer       # 解答版の作成
./watch.sh        # 自動コンパイル
```

## ⚙️ カスタマイズ

### 解答の表示/非表示

`preamble.tex` の以下の行を変更：

```latex
\showanswerfalse  % 解答を隠す
\showanswertrue   % 解答を表示（現在の設定）
```

## 作成者

Riku Sugawara  
ITTO 個別指導学院 札幌東校  
2026 年 7 月

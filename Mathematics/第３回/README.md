# 第3回 数学 - LaTeX 教材

## 概要

この教材は2026年度一斉夏期講習「第3回 数学」用の LaTeX 教材です。
リアルタイムで PDF の変更を確認できる自動コンパイル機能付きです。

## ディレクトリ構成

```
第３回/
├── README.md      # このファイル
├── main.tex       # メインのLaTeX教材
├── preamble.tex   # LaTeXプリアンブル
├── Makefile       # LaTeXコンパイル用
├── watch.sh       # 自動コンパイルスクリプト
├── scripts/       # ビルド・冊子・テスト生成
└── sections/      # セクション別のTeXファイル
    ├── プレースホルダー/
    └── test3/     # 確認テスト・復習テスト
```

## 使用方法

### VS Code での使用（推奨）

**前提条件**: LaTeX Workshop 拡張機能がインストールされていること

1. **ビルド方法**：

   - `Cmd+S`（保存と同時にビルド）
   - `Cmd+Option+B`
   - コマンドパレット → "Tasks: Run Task" → "第3回 数学: ビルド"

2. **PDF プレビュー**：

   - `Cmd+Option+P`（ビルドして外部 PDF を開く）
   - `Cmd+Option+W`（外部 PDF + リアルタイム更新）

### コマンドラインでの使用

```bash
make all          # PDF・冊子・テストの作成
make clean        # 補助ファイルを削除
make student      # 生徒用（解答非表示）
make teacher      # 先生用（解答表示）
make test-3       # 確認・復習テストのみ
```

### リアルタイム自動コンパイル

```bash
./watch.sh
# または
make watch
make watch-poll
```

## カスタマイズ

### 解答の表示/非表示

`preamble.tex` の以下の行を変更：

```latex
\showanswerfalse  % 解答を隠す（デフォルト）
\showanswertrue   % 解答を表示
```

## 必要な環境

- **LaTeX**: upLaTeX
- **PDF 変換**: dvipdfmx
- **冊子面付け**: pdfbook2（共通 `../scripts/make-booklet-pdf.sh`）
- **自動監視**: fswatch（推奨）

## 作成者

Riku Sugawara  
ITTO 個別指導学院 札幌東校  
2026 年 7 月

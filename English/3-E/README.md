# 3-E 英語 - LaTeX 教材

## 概要

この教材は2026年度一斉夏期講習「3-E 英語」用の LaTeX 教材です。
リアルタイムで PDF の変更を確認できる自動コンパイル機能付きです。

## ディレクトリ構成

```
3-E/
├── README.md      # このファイル
├── main.tex       # メインのLaTeX教材
├── preamble.tex   # LaTeXプリアンブル
├── Makefile       # LaTeXコンパイル用
├── watch.sh       # 自動コンパイルスクリプト
└── sections/      # セクション別のTeXファイル
    ├── プレースホルダー/
    └── test3/
```

## 🚀 使用方法

### VS Code での使用（推奨）

**前提条件**: LaTeX Workshop 拡張機能がインストールされていること

1. **ビルド方法**：

   - `Ctrl+Alt+B` (Windows/Linux) または `Cmd+Option+B` (Mac)
   - コマンドパレット (`Ctrl+Shift+P`) → "LaTeX Workshop: Build LaTeX project"
   - 右クリックメニュー → "Build LaTeX project"

2. **PDF プレビュー**：

   - `Ctrl+Alt+V` (Windows/Linux) または `Cmd+Option+V` (Mac)
   - コマンドパレット → "LaTeX Workshop: View LaTeX PDF"

3. **タスクランナー**：
   - `Ctrl+Shift+P` → "Tasks: Run Task" → "3-E 英語: ビルド"

### コマンドラインでの使用

```bash
make all          # PDFの作成
make clean        # 補助ファイルを削除
make answer       # 解答版の作成
```

### 🔄 リアルタイム自動コンパイル

**方法 1: watch.sh スクリプトを使用（推奨）**

```bash
./watch.sh
```

**方法 2: Makefile の watch ターゲットを使用**

```bash
make watch        # fswatch使用（要インストール）
make watch-poll   # ポーリング方式（どこでも動作）
```

### fswatch のインストール（推奨）

```bash
# macOS
brew install fswatch

# Ubuntu/Debian
sudo apt-get install inotify-tools

# その他のLinux
# 各ディストリビューションのパッケージマネージャーを使用
```

## 📝 教材の特徴

- **穴埋め問題形式**: `\fitblank{}`コマンドで学習効果を向上
- **定義・定理ボックス**: 重要概念を明確化
- **解答表示の切り替え**: `\showanswerfalse/true`で制御
- **リアルタイム編集**: ファイル保存と同時に PDF 更新

## ⚙️ カスタマイズ

### 解答の表示/非表示

`preamble.tex` の以下の行を変更することで、全ての空欄の答えを一括で表示/非表示にできます：

```latex
\showanswerfalse  % 解答を隠す（デフォルト）
\showanswertrue   % 解答を表示
```

## 🔧 必要な環境

- **LaTeX**: pLaTeX または upLaTeX
- **PDF 変換**: dvipdfmx
- **自動監視**: fswatch（推奨）または inotify-tools
- **必要パッケージ**: preamble.tex 参照

## 作成者

Riku Sugawara  
ITTO 個別指導学院 札幌東校  
2026 年 7 月

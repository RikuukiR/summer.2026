# 4-M 数学 - LaTeX 教材

## 概要

2026年度一斉夏期講習「4-M 数学」用の LaTeX 教材（関数：比例・反比例・一次関数・二次関数）。

## 生成される PDF

| ファイル | 用途 |
|---|---|
| `main.pdf` | 編集・確認用（A4・1ページ＝原稿1ページ） |
| `main-book.pdf` | **印刷用冊子**（A3面付け・短辺とじ） |

## ビルド

```bash
make all              # main.pdf + main-book.pdf
make booklet          # main-book.pdf のみ
make student          # 生徒用（解答非表示）
make teacher          # 先生用（解答表示）
./scripts/make-booklet.sh   # 冊子のみ（メッセージ付き）
```

VS Code / LaTeX Workshop のレシピ **「make all」** でも両方生成されます。

### 印刷

- **用紙:** A3・両面・**短辺とじ**
- **仕上げ:** 真ん中で二つ折り → A4冊子
- **注意:** プリンターの「冊子印刷」は **オフ**（面付け済み）

## ディレクトリ構成

```
4-M/
├── main.tex           # メイン原稿
├── preamble.tex       # プリアンブル（\showanswer の切替）
├── Makefile
├── sections/          # セクション別 TeX
└── scripts/
    ├── build-main.sh       # main.pdf + main-book.pdf 同期ビルド
    ├── lw-external-build.sh  # LaTeX Workshop 用
    ├── make-booklet.sh     # 冊子生成（ラッパー）
    └── verify-pdf-sync.py  # 両 PDF の同期確認
```

## 解答の表示/非表示

`preamble.tex` の `\showanswertrue` / `\showanswerfalse` を変更。

## 作成者

Riku Sugawara — ITTO 個別指導学院 札幌東校 — 2026年7月

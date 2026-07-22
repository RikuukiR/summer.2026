# 3-M 数学 - LaTeX 教材

## 概要

この教材は2026年度一斉夏期講習「3-M 数学」用の LaTeX 教材です。
**作図** と **式の計算の利用** は、それぞれ独立した PDF としてビルドします。

## ディレクトリ構成

```
3-M/
├── README.md
├── preamble.tex          # 共通プリアンブル
├── Makefile
├── watch.sh
├── scripts/
├── 作図/
│   ├── main.tex          # → 作図/main.pdf
│   └── sections/
└── 式の計算の利用/
    ├── main.tex          # → 式の計算の利用/main.pdf
    └── sections/
```

## 使用方法

### VS Code での使用（推奨）

1. **ビルド**：編集中の `.tex` を保存（`Cmd+S`）すると、該当教材のみビルドされます。
2. **PDF プレビュー**：`Cmd+Option+P` / `Cmd+Option+W`（Preview で開く）

### コマンドライン

```bash
make all          # 両教材の PDF・冊子を生成
make clean
make student
make teacher
```

## 生成される PDF

| 教材 | PDF | 冊子 |
|---|---|---|
| 作図 | `作図/main.pdf` | `作図/main-book.pdf` |
| 式の計算の利用 | `式の計算の利用/main.pdf` | `式の計算の利用/main-book.pdf` |

## 冊子印刷

`main-book.pdf` は A3 面付け済みです。プリンターの「冊子印刷」は**オフ**にして、次の設定で印刷してください。

- 用紙: A3
- 両面印刷: 短辺とじ
- 印刷後: 真ん中で二つ折り（A4 冊子）

```bash
make booklet          # 冊子 PDF のみ再生成
bash scripts/make-booklet.sh
```

## 作成者

Riku Sugawara  
ITTO 個別指導学院 札幌東校  
2026 年 7 月

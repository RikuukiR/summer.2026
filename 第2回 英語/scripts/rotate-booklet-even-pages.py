#!/usr/bin/env python3
"""面付けPDFの各ページを閲覧時正立（Rotate=0）に補正する。

pdfbook2 --short-edge は奇数シートに 180° 回転を付けるため、
Preview 等で表と裏が交互に逆さになる。面付け配置は維持しつつ
回転メタデータを打ち消して、すべて通常の向きで見えるようにする。
"""
import sys
from pathlib import Path

from pypdf import PdfReader, PdfWriter


def main() -> None:
    if len(sys.argv) != 2:
        print("用法: rotate-booklet-even-pages.py <booklet.pdf>", file=sys.stderr)
        sys.exit(1)

    path = Path(sys.argv[1])
    reader = PdfReader(str(path))
    writer = PdfWriter()
    normalized: list[int] = []

    for index, page in enumerate(reader.pages):
        rot = int(page.get("/Rotate", 0) or 0) % 360
        if rot:
            page.rotate(360 - rot)
            normalized.append(index + 1)
        writer.add_page(page)

    with path.open("wb") as handle:
        writer.write(handle)

    if normalized:
        print(f"Normalized page orientation: {normalized}")
    else:
        print("All pages already upright")


if __name__ == "__main__":
    main()

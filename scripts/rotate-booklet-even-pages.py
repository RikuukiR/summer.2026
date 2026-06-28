#!/usr/bin/env python3
"""面付けPDFの偶数シート（裏面側）を180°回転する。

pdfbook2 --short-edge は奇数シートのみ回転するため、
短辺とじ印刷で裏面（2|7 など）の向きがずれるプリンター向けの補正。
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

    for index, page in enumerate(reader.pages):
        if index % 2 == 1:
            page.rotate(180)
        writer.add_page(page)

    with path.open("wb") as handle:
        writer.write(handle)

    rotated = [i + 1 for i in range(len(reader.pages)) if i % 2 == 1]
    print(f"Rotated even pages: {rotated}")


if __name__ == "__main__":
    main()

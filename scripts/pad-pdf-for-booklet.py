#!/usr/bin/env python3
"""PDF に白ページを追加し、中綴じ用に 4 の倍数のページ数にする。

閲覧用 PDF には白ページを含めず、冊子生成時のみこのスクリプトを通す。
"""
import sys
from pathlib import Path

from pypdf import PageObject, PdfReader, PdfWriter


def main() -> None:
    if len(sys.argv) != 3:
        print("用法: pad-pdf-for-booklet.py <入力.pdf> <出力.pdf>", file=sys.stderr)
        sys.exit(1)

    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])
    reader = PdfReader(str(src))
    writer = PdfWriter()

    for page in reader.pages:
        writer.add_page(page)

    count = len(reader.pages)
    remainder = count % 4
    pad = 0 if remainder == 0 else 4 - remainder

    if pad:
        ref = reader.pages[-1]
        width = ref.mediabox.width
        height = ref.mediabox.height
        for _ in range(pad):
            writer.add_page(PageObject.create_blank_page(width=width, height=height))

    with dst.open("wb") as handle:
        writer.write(handle)

    print(f"Booklet source: {count} pages + {pad} blank -> {count + pad} pages")


if __name__ == "__main__":
    main()

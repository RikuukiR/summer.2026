#!/usr/bin/env python3
"""main.pdf と main-book.pdf の解答表示が一致しているか確認する。"""
from __future__ import annotations

import re
import sys
from pathlib import Path

from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "main.pdf"
BOOK = ROOT / "main-book.pdf"
PREAMBLE = ROOT / "preamble.tex"

# 解答が表示されるときだけ PDF テキストに現れる目印
MARKERS = ("35", "smart", "Could you tell", "減点方式", "主語と動詞")


def read_showanswer() -> str:
    for line in PREAMBLE.read_text(encoding="utf-8").splitlines():
        m = re.match(r"^\\showanswer(true|false)\s*$", line.strip())
        if m:
            return m.group(1)
    return "unknown"


def answers_visible(path: Path) -> bool:
    text = "".join((page.extract_text() or "") for page in PdfReader(str(path)).pages)
    return any(marker in text for marker in MARKERS)


def main() -> None:
    if not MAIN.is_file():
        print("ERROR: main.pdf がありません", file=sys.stderr)
        sys.exit(1)
    if not BOOK.is_file():
        print("ERROR: main-book.pdf がありません", file=sys.stderr)
        sys.exit(1)

    mode = read_showanswer()
    main_on = answers_visible(MAIN)
    book_on = answers_visible(BOOK)

    print(f"showanswer: {mode}")
    print(f"main.pdf answers visible: {main_on}")
    print(f"main-book.pdf answers visible: {book_on}")

    expected = mode == "true"
    if main_on != expected or book_on != expected:
        print(
            "ERROR: PDF の解答表示が preamble.tex の設定と一致しません",
            file=sys.stderr,
        )
        sys.exit(1)
    if main_on != book_on:
        print(
            "ERROR: main.pdf と main-book.pdf の解答表示が一致しません",
            file=sys.stderr,
        )
        sys.exit(1)

    state = "表示" if main_on else "非表示"
    print(f"OK: 両 PDF の解答は「{state}」で一致しています")


if __name__ == "__main__":
    main()

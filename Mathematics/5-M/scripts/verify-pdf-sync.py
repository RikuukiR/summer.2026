#!/usr/bin/env python3
"""main.pdf と main-book.pdf の同期を確認する。"""
from __future__ import annotations

import re
import sys
from pathlib import Path

from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[1]
PREAMBLE = ROOT / "preamble.tex"
STAMP = ROOT / ".showanswer-stamp"
SYNC_TOLERANCE = 80


def read_showanswer() -> str:
    if STAMP.is_file():
        stamp = STAMP.read_text(encoding="utf-8").strip()
        m = re.match(r"^\\showanswer(true|false)$", stamp)
        if m:
            return m.group(1)

    for line in PREAMBLE.read_text(encoding="utf-8").splitlines():
        m = re.match(r"^\\showanswer(true|false)\s*$", line.strip())
        if m:
            return m.group(1)
    return "unknown"


def extract_text(path: Path) -> str:
    return "".join((page.extract_text() or "") for page in PdfReader(str(path)).pages)


def main() -> None:
    main_pdf = ROOT / "main.pdf"
    book_pdf = ROOT / "main-book.pdf"

    if not main_pdf.is_file():
        print(f"ERROR: {main_pdf} がありません", file=sys.stderr)
        sys.exit(1)
    if not book_pdf.is_file():
        print(f"ERROR: {book_pdf} がありません", file=sys.stderr)
        sys.exit(1)

    mode = read_showanswer()
    main_len = len(extract_text(main_pdf))
    book_len = len(extract_text(book_pdf))
    delta = abs(main_len - book_len)

    print(f"showanswer: {mode}")
    print(f"main.pdf text length: {main_len}")
    print(f"main-book.pdf text length: {book_len}")

    if delta > SYNC_TOLERANCE:
        print(
            "ERROR: main.pdf と main-book.pdf が同期されていません。",
            file=sys.stderr,
        )
        sys.exit(1)

    state = "表示" if mode == "true" else "非表示"
    print(f"OK: 両 PDF は同期済み（preamble 設定: 解答{state}）")


if __name__ == "__main__":
    main()

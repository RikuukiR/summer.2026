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
STAMP = ROOT / ".showanswer-stamp"

# main.pdf と main-book.pdf の抽出テキスト量の許容差
SYNC_TOLERANCE = 80
# 解答表示の有無で抽出テキスト量が大きく変わる（生徒用 < 先生用）
STUDENT_MAX_LEN = 3500
TEACHER_MIN_LEN = 3800
# 本文がこれ未満のときは解答有無のヒューリスティックをスキップ（新規プロジェクト用）
MIN_CONTENT_FOR_ANSWER_CHECK = 3500


def read_preamble_showanswer() -> str:
    for line in PREAMBLE.read_text(encoding="utf-8").splitlines():
        m = re.match(r"^\\showanswer(true|false)\s*$", line.strip())
        if m:
            return m.group(1)
    return "unknown"


def read_stamp_showanswer() -> str | None:
    if not STAMP.is_file():
        return None
    stamp = STAMP.read_text(encoding="utf-8").strip()
    m = re.match(r"^\\showanswer(true|false)$", stamp)
    return m.group(1) if m else None


def extract_text(path: Path) -> str:
    return "".join((page.extract_text() or "") for page in PdfReader(str(path)).pages)


def main() -> None:
    if not MAIN.is_file():
        print("ERROR: main.pdf がありません", file=sys.stderr)
        sys.exit(1)
    if not BOOK.is_file():
        print("ERROR: main-book.pdf がありません", file=sys.stderr)
        sys.exit(1)

    preamble_mode = read_preamble_showanswer()
    stamp_mode = read_stamp_showanswer()
    main_len = len(extract_text(MAIN))
    book_len = len(extract_text(BOOK))
    delta = abs(main_len - book_len)

    print(f"preamble.tex: \\showanswer{preamble_mode}")
    if stamp_mode is not None:
        print(f".showanswer-stamp: \\showanswer{stamp_mode}")
    print(f"main.pdf text length: {main_len}")
    print(f"main-book.pdf text length: {book_len}")

    if preamble_mode == "unknown":
        print("ERROR: preamble.tex に \\showanswertrue/false がありません", file=sys.stderr)
        sys.exit(1)

    if stamp_mode is not None and stamp_mode != preamble_mode:
        print(
            "ERROR: preamble.tex を変更しましたが PDF が未再生成です。"
            " make -B all を実行してください。",
            file=sys.stderr,
        )
        sys.exit(1)

    if delta > SYNC_TOLERANCE:
        print(
            "ERROR: main.pdf と main-book.pdf が同期されていません。"
            " make -B all を実行してください。",
            file=sys.stderr,
        )
        sys.exit(1)

    if main_len < MIN_CONTENT_FOR_ANSWER_CHECK:
        state = "表示" if preamble_mode == "true" else "非表示"
        print(
            f"OK: 両 PDF は同期済み（本文が短いため解答チェックをスキップ、preamble 設定: 解答{state}）"
        )
        return

    if preamble_mode == "false" and main_len > TEACHER_MIN_LEN:
        print(
            "ERROR: preamble は \\showanswerfalse ですが、"
            "PDF に解答が含まれている可能性があります。"
            " make -B all を実行してください。",
            file=sys.stderr,
        )
        sys.exit(1)

    if preamble_mode == "true" and main_len < STUDENT_MAX_LEN:
        print(
            "ERROR: preamble は \\showanswertrue ですが、"
            "PDF に解答が反映されていない可能性があります。"
            " make -B all を実行してください。",
            file=sys.stderr,
        )
        sys.exit(1)

    state = "表示" if preamble_mode == "true" else "非表示"
    print(f"OK: 両 PDF は同期済み（preamble 設定: 解答{state}）")


if __name__ == "__main__":
    main()

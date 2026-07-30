#!/usr/bin/env python3
"""Fix punctuation: half-width outside problem env, Japanese inside example/exercise."""
from __future__ import annotations

import re
from pathlib import Path

PROBLEM_RE = re.compile(
    r'\\begin\{(example|exercise)\}(?:\[[^\]]*\])?|\\end\{(example|exercise)\}'
)
TECH_LINE = re.compile(
    r'^\s*\\(?:begin\{tikzpicture|draw|fill|node|coordinate|tikzset|path|resizebox|begin\{enumerate)'
)


def find_problem_regions(content: str) -> list[tuple[int, int]]:
    regions: list[tuple[int, int]] = []
    stack: list[int] = []
    for m in PROBLEM_RE.finditer(content):
        if m.group(0).startswith('\\begin'):
            stack.append(m.start())
        elif stack:
            start = stack.pop()
            regions.append((start, m.end()))
    return regions


def split_math(text: str) -> list[tuple[str, str]]:
    parts: list[tuple[str, str]] = []
    i = 0
    n = len(text)
    while i < n:
        if text.startswith('\\[', i):
            j = text.find('\\]', i + 2)
            if j == -1:
                j = n - 2
            parts.append(('math', text[i : j + 2]))
            i = j + 2
        elif text[i] == '$':
            j = i + 1
            while j < n:
                if text[j] == '$' and text[j - 1] != '\\':
                    break
                j += 1
            parts.append(('math', text[i : j + 1]))
            i = j + 1
        else:
            j = i
            while j < n and text[j] != '$' and not text.startswith('\\[', j):
                j += 1
            parts.append(('text', text[i:j]))
            i = j
    return parts


def convert_outside_text(text: str) -> str:
    text = text.replace('、', ',')
    text = text.replace('。', '.')
    text = text.replace('，', ',')
    return text


def convert_problem_text(text: str) -> str:
    text = text.replace('，', '、')
    text = text.replace(',', '、')
    text = re.sub(r'(?<=[ぁ-んァ-ン一-龥々])\.(\s|$)', r'。\1', text)
    return text


def process_segment(segment: str, is_problem: bool) -> str:
    out: list[str] = []
    for kind, chunk in split_math(segment):
        if kind == 'math':
            out.append(chunk)
        elif is_problem:
            out.append(convert_problem_text(chunk))
        else:
            out.append(convert_outside_text(chunk))
    return ''.join(out)


def process_content(content: str) -> str:
    regions = find_problem_regions(content)
    if not regions:
        return process_segment(content, False)

    result: list[str] = []
    pos = 0
    for start, end in sorted(regions):
        if pos < start:
            result.append(process_segment(content[pos:start], False))
        result.append(process_segment(content[start:end], True))
        pos = end
    if pos < len(content):
        result.append(process_segment(content[pos:], False))
    return ''.join(result)


def fix_technical_commas(content: str) -> str:
    """Restore commas inside TikZ/LaTeX syntax within problem environments."""

    def fix_tikz_block(match: re.Match[str]) -> str:
        return match.group(1).replace('、', ',')

    content = re.sub(
        r'(\\begin\{tikzpicture\}.*?\\end\{tikzpicture\})',
        fix_tikz_block,
        content,
        flags=re.DOTALL,
    )

    lines: list[str] = []
    for line in content.split('\n'):
        if TECH_LINE.match(line):
            line = re.sub(
                r'\[([^\]]*)\]',
                lambda m: '[' + m.group(1).replace('、', ',') + ']',
                line,
            )
            line = re.sub(
                r'\(([^)]*)\)',
                lambda m: '(' + m.group(1).replace('、', ',') + ')',
                line,
            )
        lines.append(line)
    return '\n'.join(lines)


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    targets = list((root / 'sections').rglob('*.tex')) + [root / 'main.tex']

    for path in sorted(targets):
        if not path.exists():
            continue
        original = path.read_text(encoding='utf-8')
        updated = fix_technical_commas(process_content(original))
        if updated != original:
            path.write_text(updated, encoding='utf-8')
            print(f'updated: {path.relative_to(root)}')


if __name__ == '__main__':
    main()

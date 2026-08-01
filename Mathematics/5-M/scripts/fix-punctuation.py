#!/usr/bin/env python3
"""Fix punctuation and spacing across LaTeX sources.

- Half-width comma outside example/exercise; Japanese comma inside.
- After `,` / `、`, insert half-width space before the following character.
- Add half-width space before/after underline commands (fitblank, Blank),
  except immediately before punctuation (、，,).
"""
from __future__ import annotations

import re
from pathlib import Path

PROBLEM_RE = re.compile(
    r'\\begin\{(example|exercise)\}(?:\[[^\]]*\])?|\\end\{(example|exercise)\}'
)
TECH_LINE = re.compile(
    r'^\s*\\(?:begin\{tikzpicture|draw|fill|node|coordinate|tikzset|path|resizebox|begin\{enumerate)'
)
TIKZ_BLOCK_RE = re.compile(
    r'\\begin\{tikzpicture\}.*?\\end\{tikzpicture\}',
    re.DOTALL,
)
UNDERLINE_CMD_RE = re.compile(
    r'\\(?:fitblank(?:bf|box|fixed|blue|bfblue)?|Blank)\b'
)
SKIP_AFTER_COMMA = (
    '\\\\',
    '\\quad',
    '\\qquad',
    '\\hspace',
    '\\newline',
    '\\item',
    '\\[',
)
NO_SPACE_BEFORE_UNDERLINE = frozenset(' \t\n{[(\\$')
NO_SPACE_AFTER_UNDERLINE = frozenset(' \t\n、，,。.!?）)」』$^_%\\{：:')


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


def skip_bracket_group(text: str, start: int) -> int:
    if start >= len(text) or text[start] != '[':
        return start
    depth = 0
    i = start
    while i < len(text):
        ch = text[i]
        if ch == '\\':
            i += 2
            continue
        if ch == '[':
            depth += 1
        elif ch == ']':
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return len(text)


def skip_brace_group(text: str, start: int) -> int:
    if start >= len(text) or text[start] != '{':
        return start
    depth = 0
    i = start
    while i < len(text):
        ch = text[i]
        if ch == '\\':
            i += 2
            continue
        if ch == '{':
            depth += 1
        elif ch == '}':
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return len(text)


def should_space_after_comma(text: str, pos: int) -> bool:
    after = text[pos:]
    if not after or after[0] in ' \t\n':
        return False
    for skip in SKIP_AFTER_COMMA:
        if after.startswith(skip):
            return False
    return True


def fix_comma_spacing(text: str) -> str:
    out: list[str] = []
    i = 0
    while i < len(text):
        ch = text[i]
        if ch in ',、':
            out.append(ch)
            i += 1
            if should_space_after_comma(text, i):
                if i >= len(text) or text[i] != ' ':
                    out.append(' ')
            continue
        out.append(ch)
        i += 1
    return ''.join(out)


def fix_commas_in_split_parts(parts: list[tuple[str, str]]) -> list[tuple[str, str]]:
    fixed: list[tuple[str, str]] = []
    for i, (kind, chunk) in enumerate(parts):
        if kind != 'text':
            fixed.append((kind, chunk))
            continue
        chunk = fix_comma_spacing(chunk)
        if chunk and chunk[-1] in ',、':
            if i + 1 < len(parts) and parts[i + 1][0] == 'math':
                chunk += ' '
        fixed.append(('text', chunk))
    return fixed


def fix_colon_after_underline(text: str) -> str:
    """Remove space before full-width colon immediately after underline commands."""
    out: list[str] = []
    i = 0
    n = len(text)
    while i < n:
        match = UNDERLINE_CMD_RE.match(text, i)
        if not match:
            out.append(text[i])
            i += 1
            continue
        cmd_start = i
        i = match.end()
        if i < n and text[i] == '[':
            i = skip_bracket_group(text, i)
        while i < n and text[i] == '{':
            i = skip_brace_group(text, i)
        out.append(text[cmd_start:i])
        if i < n and text[i] == ' ' and i + 1 < n and text[i + 1] == '：':
            i += 1
    return ''.join(out)


def fix_underline_spacing(text: str) -> str:
    out: list[str] = []
    i = 0
    n = len(text)
    while i < n:
        match = UNDERLINE_CMD_RE.match(text, i)
        if not match:
            out.append(text[i])
            i += 1
            continue

        if out and out[-1] not in NO_SPACE_BEFORE_UNDERLINE:
            out.append(' ')

        cmd_start = i
        i = match.end()
        if i < n and text[i] == '[':
            i = skip_bracket_group(text, i)
        while i < n and text[i] == '{':
            i = skip_brace_group(text, i)

        out.append(text[cmd_start:i])

        if i < n and text[i] not in NO_SPACE_AFTER_UNDERLINE:
            out.append(' ')

    return ''.join(out)


def protect_tikz_blocks(content: str) -> tuple[str, list[str]]:
    blocks: list[str] = []

    def repl(match: re.Match[str]) -> str:
        blocks.append(match.group(0))
        return f'@@TIKZ{len(blocks) - 1}@@'

    protected = TIKZ_BLOCK_RE.sub(repl, content)
    return protected, blocks


def restore_tikz_blocks(content: str, blocks: list[str]) -> str:
    for idx, block in enumerate(blocks):
        content = content.replace(f'@@TIKZ{idx}@@', block)
    return content


def apply_spacing(content: str) -> str:
    protected, blocks = protect_tikz_blocks(content)
    parts = fix_commas_in_split_parts(split_math(protected))
    out: list[str] = []
    for kind, chunk in parts:
        if kind == 'math':
            out.append(chunk)
        else:
            out.append(fix_colon_after_underline(fix_underline_spacing(chunk)))
    return restore_tikz_blocks(''.join(out), blocks)


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    targets = list((root / 'sections').rglob('*.tex')) + [root / 'main.tex']

    for path in sorted(targets):
        if not path.exists():
            continue
        original = path.read_text(encoding='utf-8')
        updated = apply_spacing(fix_technical_commas(process_content(original)))
        if updated != original:
            path.write_text(updated, encoding='utf-8')
            print(f'updated: {path.relative_to(root)}')


if __name__ == '__main__':
    main()

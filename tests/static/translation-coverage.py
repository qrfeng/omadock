#!/usr/bin/env python3
"""Report display strings that a Chinese dock would still show in English.

Two ways a label ends up translated: the call site wraps it in I18n.t(), or the
leaf widget translates it at display time. Either way the string must be a key
in Locale.js DICT - that is the only real requirement, so this scans every
string literal that lands on a display property (label/hint/text/title/tooltip
/placeholder/description, including inside ternaries and concatenations) and
lists the ones with no dictionary entry.

Deliberately not translated (skipped): private-use and CJK glyph strings,
proper nouns and identifiers, paths, and anything already a key.

Usage: tests/static/translation-coverage.py [--verbose]
Exit 0 = full coverage; 1 = gaps (printed one per line).
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
PROP = re.compile(r'(?:^|[,{(])\s*(label|hint|text|title|tooltipText|placeholderText|description)\s*:\s*')
ESCAPE = re.compile(r"\\u([0-9a-fA-F]{4})")
LITERAL = re.compile(r'"((?:[^"\\\n]|\\.)*)"')
SKIP_WORDS = {
    "Yaru", "Omarchy", "GitHub", "English", "中文", "Sans", "GTK", "USB", "Silkscreen",
    "Escape", "Active Mode:", "hyprctl", "Quickshell", "Hyprland",
}


def dictionary():
    src = (ROOT / "Locale.js").read_text()
    body = src[src.index("var DICT"):]
    return {m.group(1) for m in re.finditer(r'^\s*"((?:[^"\\]|\\.)+)":', body, re.M)}


def translatable(s):
    if not s.strip():
        return False
    # Glyphs (nerd-font private use area), Chinese, emoji: never a dictionary key.
    if any(ord(c) > 0x2FFF for c in s):
        return False
    if "/" in s or s.endswith(".desktop"):
        return False
    # An identifier, not a label: camelCase, or a single lowercase token
    # ("autohide", "grid"). Every user-facing string in this plugin is
    # capitalised or contains a space.
    if re.fullmatch(r"[a-z][a-z0-9._-]*", s):
        return False  # an id or icon name: "autohide", "drive-removable-media"
    if not re.search(r"[A-Za-z]{2}", s):
        return False  # punctuation, a bare sign, a glyph: "(", "99+", "›"
    if s.startswith("@"):
        return False  # a contributor handle
    if s in SKIP_WORDS:
        return False
    return True


def main():
    verbose = "--verbose" in sys.argv
    d = dictionary()
    gaps = {}
    for path in sorted(ROOT.rglob("*.qml")):
        if path.name.endswith(".upstream") or ".git" in path.parts:
            continue
        rel = path.relative_to(ROOT)
        for n, line in enumerate(path.read_text(errors="replace").splitlines(), 1):
            if "//" in line.split('"')[0]:
                continue
            # Only the literals that follow a display property count: the same
            # line often carries `{ value: "off", label: "Off" }`, and a value
            # is data that must never be translated.
            tail = ""
            for m in PROP.finditer(line):
                tail += line[m.end():]
            for lit in LITERAL.findall(tail):
                s = lit.replace('\\"', '"')
                s = ESCAPE.sub(lambda m: chr(int(m.group(1), 16)), s)
                if translatable(s) and s not in d:
                    gaps.setdefault(s, []).append(f"{rel}:{n}")
    if gaps:
        print(f"translation coverage: {len(gaps)} string(s) without a Locale.js entry")
        for s, where in sorted(gaps.items()):
            print(f'  "{s}"  ({", ".join(where[:3])}{" ..." if len(where) > 3 else ""})')
        if verbose:
            print(f"\ndictionary holds {len(d)} keys")
        return 1
    print(f"translation coverage PASSED: every display string has a dictionary entry ({len(d)} keys)")
    return 0


if __name__ == "__main__":
    sys.exit(main())

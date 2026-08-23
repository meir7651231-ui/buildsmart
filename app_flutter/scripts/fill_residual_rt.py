#!/usr/bin/env python3
"""R8 residual fill — size/finish printed verbatim in a product's own name that
earlier passes missed (cm/inch/slash sizes; pure-colour words). Idempotent.

  • color  — pure colour word in the name (לבן/אפור/שחור/פרגמון…) and the product
             has no color yet. Pure colours are NEVER a body material, so this is
             R8-safe in any category. gate-117-pinned SKUs are skipped.
  • מידה    — inch/cm size in the name for products whose dims has no real spec key
             (only תיאור, or no dims). Merged into the existing dims map.

Usage: python scripts/fill_residual_rt.py
"""
import re, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

F = 'lib/data/lipskey_catalog.dart'
PARITY = 'test/lipskey_pdf_parity_test.dart'

PURE = ['פרגמון', 'אנתרציט', 'אפור', 'לבן', 'שחור', "בז'", 'קרם', 'חרדל']
SIZE_PATS = [
    r'\d+(?:\.\d+)?\s?["׳]\s?-\s?\d+/\d+\s?["׳]?',   # 1"-3/4"
    r'\d+/\d+\s?["׳]',                                # 3/4"
    r'DN\s?\d+',
    r'\d+(?:\.\d+)?\s?["׳]',                          # 1.5"  2"  1"
    r'\d+\s?ס"מ',
    r'\d+\s?מ"מ',
]

def size_in(name):
    for pat in SIZE_PATS:
        m = re.search(pat, name)
        if m:
            return m.group(0).strip()
    return None

def color_in(name):
    for c in PURE:
        if c in name:
            return c
    return None

def main():
    s = open(F, encoding='utf-8').read()
    gate117 = set(re.findall(r"'(\d{6,})'", open(PARITY, encoding='utf-8').read()))
    parts = s.split('LipskeyCatalogProduct(')
    out = [parts[0]]
    nc = nd = 0
    for part in parts[1:]:
        m = re.search(r"sku:\s*'([^']*)'", part)
        sku = m.group(1) if m else None
        head = part[:1700]
        nm = re.search(r"nameHe:\s*'([^']*)'", head)
        nm = nm.group(1) if nm else ''
        has_color = re.search(r"\bcolor:\s*'", head) is not None
        dmatch = re.search(r"dims:\s*\{([^}]*)\}", head)
        keys = re.findall(r"'([^']+)':", dmatch.group(1)) if dmatch else []
        real = [k for k in keys if k != 'תיאור']
        # color
        if not has_color and sku not in gate117:
            c = color_in(nm)
            if c:
                part = re.sub(r"(\s+)page:", r"\1color: '%s',\1page:" % c, part, count=1)
                nc += 1
                print(f"  🎨 {sku}  +{c}   «{nm[:30]}»")
        # size (only into a product that has no real spec key yet)
        if not real and sku not in gate117:
            sz = size_in(nm)
            if sz:
                if dmatch:
                    part = re.sub(r"dims:\s*\{", "dims: {'מידה': '%s', " % sz, part, count=1)
                else:
                    part = re.sub(r"(\s+)page:", r"\1dims: {'מידה': '%s'},\1page:" % sz, part, count=1)
                nd += 1
                print(f"  📐 {sku}  +{sz}   «{nm[:30]}»")
        out.append(part)
    open(F, 'w', encoding='utf-8').write('LipskeyCatalogProduct('.join(out))
    print(f"\napplied: color {nc}  ·  מידה {nd}")

if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Apply the catalog audit's high-confidence, R8-safe dims fixes only:
  • UNIT errors  — dims['מידה'] in ס"מ where the name says מ"מ → correct to מ"מ
                   (the name is authoritative; verified contradiction).
  • GARBLED מידה — values my own name-parse mangled on complex HDPE sizes
                   ("50×11/4"" → "50*114", "63×2"" → "63*2 90"). The value is
                   garbage; REMOVE the key (the name still shows the real size).
Conservative: only the SKUs the audit flagged + verified individually. Typos in
source-derived text, image-asset mismatches, and ambiguous cases are NOT touched.
Usage: python scripts/fix_audit_dims.py
"""
import re, sys, io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
F = 'lib/data/lipskey_catalog.dart'

FIX_UNIT = {'7777707C': ('200 ס"מ', '200 מ"מ'), '7777708C': ('250 ס"מ', '250 מ"מ')}
REMOVE_MIDA = {'910603440', '9106320031', '9105011411', '9105011241', '9105020030', '9102010011'}


def main():
    s = open(F, encoding='utf-8').read()
    parts = s.split('LipskeyCatalogProduct(')
    out = [parts[0]]
    nfix = nrem = 0
    for part in parts[1:]:
        m = re.search(r"sku:\s*'([^']*)'", part)
        sku = m.group(1) if m else None
        if sku in FIX_UNIT:
            old, new = FIX_UNIT[sku]
            frag_old = "'מידה': '%s'" % old
            if frag_old in part[:1700]:
                part = part.replace(frag_old, "'מידה': '%s'" % new, 1)
                nfix += 1
        if sku in REMOVE_MIDA:
            # remove the מידה entry (it is garbled) — handle middle or trailing position
            new_part = re.sub(r"'מידה':\s*'[^']*',\s*", "", part, count=1)
            if new_part == part:  # מידה may be the last key (no trailing comma)
                new_part = re.sub(r",\s*'מידה':\s*'[^']*'", "", part, count=1)
            if new_part != part:
                part = new_part
                nrem += 1
        out.append(part)
    open(F, 'w', encoding='utf-8').write('LipskeyCatalogProduct('.join(out))
    print(f"unit-fixed: {nfix}  ·  garbled-מידה removed: {nrem}")


if __name__ == '__main__':
    main()

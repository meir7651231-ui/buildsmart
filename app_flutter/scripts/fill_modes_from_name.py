#!/usr/bin/env python3
"""R8 name-borne spec for decorative items the Qondus photo-catalog never gave
dimensions for. A faucet/shower's own nameHe verbatim carries real specs the
showroom catalog omits from any table:
  • dims['מצבים'] — spray-mode count ("5 מצבים" → '5')
  • dims['אורך']  — reach ("קצר"/"ארוך")
  • dims['סוג']   — type ("טלסקופי"/"נשלף"/"מהקיר"/"כפול"/"יחיד"/"שולחני")
Only fills products that currently have NO real spec key (only תיאור / no dims);
merges into the existing dims map; gate-117-pinned SKUs are skipped; idempotent.
Usage: python scripts/fill_modes_from_name.py
"""
import re, sys, io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
F = 'lib/data/lipskey_catalog.dart'
PARITY = 'test/lipskey_pdf_parity_test.dart'
TYPE_TOKENS = ['טלסקופי', 'נשלף', 'מהקיר', 'שולחני', 'כפול', 'יחיד']


def name_specs(nm):
    out = {}
    m = re.search(r'(\d+)\s*מצבים', nm)
    if m:
        out['מצבים'] = m.group(1)
    for t in ['קצר', 'ארוך']:
        if t in nm:
            out['אורך'] = t
            break
    for t in TYPE_TOKENS:
        if t in nm:
            out['סוג'] = t
            break
    return out


def main():
    s = open(F, encoding='utf-8').read()
    gate117 = set(re.findall(r"'(\d{6,})'", open(PARITY, encoding='utf-8').read()))
    parts = s.split('LipskeyCatalogProduct(')
    out = [parts[0]]
    n = 0
    for part in parts[1:]:
        m = re.search(r"sku:\s*'([^']*)'", part)
        sku = m.group(1) if m else None
        head = part[:1700]
        nm = re.search(r"nameHe:\s*'([^']*)'", head)
        nm = nm.group(1) if nm else ''
        dmatch = re.search(r"dims:\s*\{([^}]*)\}", head)
        keys = re.findall(r"'([^']+)':", dmatch.group(1)) if dmatch else []
        real = [k for k in keys if k != 'תיאור']
        if not real and sku not in gate117:
            sp = name_specs(nm)
            sp = {k: v for k, v in sp.items() if k not in keys}  # idempotent
            if sp:
                frag = ''.join(f"'{k}': '{v}', " for k, v in sp.items())
                if dmatch:
                    part = re.sub(r"dims:\s*\{", "dims: {" + frag, part, count=1)
                else:
                    part = re.sub(r"(\s+)page:",
                                  r"\1dims: {" + frag.rstrip(', ') + r"},\1page:",
                                  part, count=1)
                n += 1
                print(f"  + {sku:<10} {sp}   «{nm[:30]}»")
        out.append(part)
    open(F, 'w', encoding='utf-8').write('LipskeyCatalogProduct('.join(out))
    print(f"\napplied name-borne spec to {n} products")


if __name__ == '__main__':
    main()

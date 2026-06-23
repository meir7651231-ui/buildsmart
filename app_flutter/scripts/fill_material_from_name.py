#!/usr/bin/env python3
"""R8 100%-certain material from a product's OWN name. A product literally named
"רשת נחושת" / "תעלת ניקוז נירוסטה" / "אקדח מים פליז" IS made of that material —
verbatim from its own name, so 100% certain regardless of any look-alike brand.

Conservative — only STRUCTURAL materials (נחושת/נירוסטה/פליז/פלסטיק):
  • finishes (כרום/ברונזה/ניקל) are NOT materials → skipped (they belong to color)
  • "ציר פלסטיק" = a plastic HINGE on a (non-plastic) toilet seat → skipped to
    avoid mis-attributing a sub-component's material to the whole product
Adds dims['חומר']; gate-117 excluded; merges into existing dims; idempotent.
Usage: python scripts/fill_material_from_name.py
"""
import re, sys, io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
F = 'lib/data/lipskey_catalog.dart'
PARITY = 'test/lipskey_pdf_parity_test.dart'
MATERIALS = ['נירוסטה', 'נחושת', 'פליז', 'פלסטיק']


def material_in(name):
    for m in MATERIALS:
        if m in name:
            if m == 'פלסטיק' and 'ציר פלסטיק' in name:
                continue  # plastic hinge, not the product's body
            return m
    return None


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
        if 'חומר' not in keys and sku not in gate117:
            mat = material_in(nm)
            if mat:
                frag = "'חומר': '%s', " % mat
                if dmatch:
                    part = re.sub(r"dims:\s*\{", "dims: {" + frag, part, count=1)
                else:
                    part = re.sub(r"(\s+)page:",
                                  r"\1dims: {" + frag.rstrip(', ') + r"},\1page:",
                                  part, count=1)
                n += 1
                print(f"  + {sku:<10} חומר={mat:<8} «{nm[:32]}»")
        out.append(part)
    open(F, 'w', encoding='utf-8').write('LipskeyCatalogProduct('.join(out))
    print(f"\napplied material to {n} products")


if __name__ == '__main__':
    main()

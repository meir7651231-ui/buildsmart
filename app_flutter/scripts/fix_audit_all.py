#!/usr/bin/env python3
"""Apply the catalog audit's REMAINING high-confidence, R8-safe fixes.
Verified individually against current data; false-positives excluded (clean
{'תיאור':..} dims wrongly flagged as garbled; "דיור"=Dior brand, not a typo;
77775150 name/color agree). gate-117 safety: typos are on NON-pinned SKUs,
image=null doesn't touch a pinned field, and parity does NOT pin 'דגם'.
Scoped per-SKU block. Usage: python scripts/fix_audit_all.py
"""
import re, sys, io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
F = 'lib/data/lipskey_catalog.dart'

# typo → corrected, replaced everywhere inside the product block (name + תיאור)
TYPOS = {
    '77777755': ('חרום', 'חרוט'), '77777756': ('חרום', 'חרוט'), '77777708': ('חרום', 'חרוט'),
    '77777709': ('חרום', 'חרוט'), '77777710': ('חרום', 'חרוט'), '77777100': ('חרום', 'חרוט'),
    '77773001': ('מקסטין', 'מקטין'), '77772011': ('מקסטין', 'מקטין'), '77772012': ('מקסטין', 'מקטין'),
    '77000010': ('מוהיר', 'מהיר'), '77000011': ('מוהיר', 'מהיר'),
    '777M2206': ('סהקיר', 'מהקיר'), '777M2207': ('סהקיר', 'מהקיר'),
    '777Z3063': ('מונע', 'מונח'), '7772364D': ('אביזיה', 'איביזה'), '777M1114': ('וינה', 'ויגה'),
    '777A5033': ('מפאורת', 'מפוארת'), '777A5034': ('מפאורת', 'מפוארת'),
    '77772606': ('ושתומים', 'ושסתום'), '77777010': ('מנגית', 'מגניט'), '779096F': ('גרפיטי', 'גרפיני'),
    '686366': ('3/8 - 2/1', '3/8 - 1/2'), '164873': ('ברך אסלה לבן', 'ברך אסלה פרגמון'),
}
# specific single dims replacements
DIMS_REPLACE = {
    '77777120A': ("'מידה': '2\"×3/8\"'", "'מידה': '1/2\"×3/8\"'"),
    '218126': ("'דגם': 'פקק 2.5\" שחור'", "'דגם': 'פקק 2\" שחור'"),
    '218127': ("'דגם': 'פקק 2\" שחור'", "'דגם': 'פקק 2.5\" שחור'"),
}
# wrong-product images (vision-confirmed) → null so a clean placeholder shows
IMAGE_NULL = {'152785', '145629', '168525', '169604', '178864', '178867', '178870',
              '196587', '116167', '118221', '120011', '610918', '186466', '686366',
              '78071545', '77773001', '777M1801'}
NAME_FILL = {'77701150': "אנג\\'ל מקלח יד 5 מצבים"}

s = open(F, encoding='utf-8').read()
parts = s.split('LipskeyCatalogProduct(')
out = [parts[0]]
n_typo = n_dims = n_img = n_name = 0
for part in parts[1:]:
    m = re.search(r"sku:\s*'([^']*)'", part)
    sku = m.group(1) if m else None
    if sku in TYPOS:
        old, new = TYPOS[sku]
        if old in part:
            part = part.replace(old, new); n_typo += 1
    if sku in DIMS_REPLACE:
        old, new = DIMS_REPLACE[sku]
        if old in part:
            part = part.replace(old, new, 1); n_dims += 1
    if sku in IMAGE_NULL:
        np = re.sub(r"imageFile:\s*'[^']*'", "imageFile: null", part, count=1)
        if np != part:
            part = np; n_img += 1
    if sku in NAME_FILL:
        np = part.replace("nameHe: ''", "nameHe: '%s'" % NAME_FILL[sku], 1)
        if np != part:
            part = np; n_name += 1
    out.append(part)
open(F, 'w', encoding='utf-8').write('LipskeyCatalogProduct('.join(out))
print(f"typos: {n_typo}/{len(TYPOS)}  ·  dims: {n_dims}/{len(DIMS_REPLACE)}  ·  image→null: {n_img}/{len(IMAGE_NULL)}  ·  name-fill: {n_name}/{len(NAME_FILL)}")

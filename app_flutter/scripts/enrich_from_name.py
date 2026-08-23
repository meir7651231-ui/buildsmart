#!/usr/bin/env python3
"""R8-safe name-parse enrichment → knowledge/_enrich_validated.json.

The product's OWN nameHe is verbatim catalog data, so pulling a size/finish that
is literally printed in the name is R8-compliant (no invention). Two streams:

  • dims['מידה']  — for thin products (no dims) whose name contains a size token
                    (DN.., 1/2", 200 מ"מ, 16×16…). Adds תיאור=name too.
  • color         — for products with NO color whose name ends/contains a finish
                    word — ONLY in DECORATIVE categories (taps/showers/covers),
                    never in raw-material categories (copper/HDPE fittings) where
                    נחושת/פליז denote the MATERIAL, not a finish.

Output feeds apply_lipskey_enrich.py (idempotent). Usage: python scripts/enrich_from_name.py
"""
import re, json, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

CATALOG = 'lib/data/lipskey_catalog.dart'
OUT = 'knowledge/_enrich_validated.json'

# longest-first so "זהב מוברש" wins over "זהב"
FINISHES = ['זהב מוברש', 'ניקל מוברש', 'שחור מט', 'מט שחור', 'גרפיני', 'אנתרציט',
            'כרום', 'ניקל', 'זהב', 'שחור', 'לבן', 'נחושת', 'ברונזה', 'פרגמון']

# categories where a finish-word is a real visible FINISH (not body material)
DECOR_CATS = {
    'ברזי כיור', 'ברזי קיר', 'ברזי מטבח', 'ברזי אמבטיה', 'ברזי מקלחת', 'ברזי ניל',
    'ראשי מקלחת', 'מזלפי יד', 'זרועות דוש', 'צינורות מקלחת', 'אביזרי מקלחת',
    'מכסים ורשתות', 'מערכות אמבטיה', 'מערכות שטיפה', 'מושבי אסלה', 'גופי תברואה',
    'אביזרי חדר רחצה', 'ידיות אחיזה', 'ערכות רחצה', 'אביזרי ברזים', 'דיורים ופיות',
}

SIZE_PATS = [
    r'DN\s?\d+',
    r'\d+\s?["׳]\s?[×*xX]\s?\d+\s?/?\d*\s?["׳]?',
    r'\d+\s?/\s?\d+\s?["׳]',
    r'\d+\s?[×*xX]\s?\d+',
    r'\d+\s?מ"מ',
    r'\d+\s?["׳]',
]

def size_in(name):
    for pat in SIZE_PATS:
        m = re.search(pat, name)
        if m:
            return m.group(0).strip()
    return None

def finish_in(name):
    for f in FINISHES:
        if f in name:
            return f
    return None

def main():
    src = open(CATALOG, encoding='utf-8').read()
    parts = src.split('LipskeyCatalogProduct(')[1:]
    dims_out, color_out = [], []
    for p in parts:
        b = p[:1700]
        m = re.search(r"sku:\s*'([^']*)'", b)
        if not m: continue
        sku = m.group(1)
        nm = re.search(r"nameHe:\s*'([^']*)'", b); nm = nm.group(1) if nm else ''
        cat = re.search(r"categoryHe:\s*'([^']*)'", b); cat = cat.group(1) if cat else ''
        has_dims = re.search(r"\bdims:\s*\{", b) is not None
        has_color = re.search(r"\bcolor:\s*'", b) is not None
        # dims from name (thin products only)
        if not has_dims:
            sz = size_in(nm)
            d = {}
            if sz: d['מידה'] = sz
            if nm: d['תיאור'] = nm
            if d: dims_out.append({'sku': sku, 'dims': d})
        # color from name (decorative categories only)
        if not has_color and cat in DECOR_CATS:
            f = finish_in(nm)
            if f: color_out.append({'sku': sku, 'color': f})
    json.dump({'dims': dims_out, 'colors': color_out},
              open(OUT, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print(f"name-parse → dims:{len(dims_out)}  color:{len(color_out)}  (wrote {OUT})")

if __name__ == '__main__':
    main()

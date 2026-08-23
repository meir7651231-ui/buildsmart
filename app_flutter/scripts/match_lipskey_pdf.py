#!/usr/bin/env python3
"""Match the swarm's VALIDATED Lipskey-PDF extraction against the live catalog.

Input  : knowledge/_pdf_extracted.json  = {"products":[{sku,color,nameHe,nameEn,dims,page,confidence}]}
Catalog: lib/data/lipskey_catalog.dart  (the 924 LipskeyCatalogProduct SKUs)
Output : knowledge/_enrich_validated.json = {"dims":[{sku,dims}], "colors":[{sku,color}]}
         (consumed by apply_lipskey_enrich.py — only SKUs that EXIST in the catalog)
Report : prints matched/new/low-confidence tallies; lists NEW SKUs (in PDF, not catalog) for
         a user decision on whether to ADD them as new products.

R8: never invents — only forwards what the validated extraction holds. nameHe is NOT overwritten
(it drives the chip parser); the PDF name is folded into dims['תיאור'] only when absent.
"""
import json, re, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

EXTRACT = 'knowledge/_pdf_extracted.json'
CATALOG = 'lib/data/lipskey_catalog.dart'
OUT = 'knowledge/_enrich_validated.json'

# qty keys the catalog stores as first-class int fields (NOT inside dims)
PACK_KEYS = ('כמות באריזה', 'אריזה')
PALLET_KEYS = ('כמות במשטח', 'משטח')

def as_int(v):
    m = re.search(r'\d+', str(v))
    return int(m.group()) if m else None

def main():
    ext = json.load(open(EXTRACT, encoding='utf-8'))
    products = ext.get('products', ext if isinstance(ext, list) else [])
    cat = open(CATALOG, encoding='utf-8').read()
    cat_skus = set(re.findall(r"sku:\s*'([^']*)'", cat))
    # gate-117 (lipskey_pdf_parity_test) authoritatively pins these SKUs — incl.
    # color (often null for accessories). NEVER override their color from the PDF.
    try:
        parity = open('test/lipskey_pdf_parity_test.dart', encoding='utf-8').read()
        gate117 = set(re.findall(r"'(\d{6})'", parity))
    except FileNotFoundError:
        gate117 = set()
    # which catalog products already have color / dims (don't double-apply)
    parts = cat.split('LipskeyCatalogProduct(')[1:]
    has_color, has_dims, has_pack, has_pallet = set(), set(), set(), set()
    for p in parts:
        blk = p[:1700]
        m = re.search(r"sku:\s*'([^']*)'", blk)
        if not m: continue
        s = m.group(1)
        if re.search(r"\bcolor:\s*'", blk): has_color.add(s)
        if re.search(r"\bdims:\s*\{", blk): has_dims.add(s)
        if re.search(r"\bqtyPack:\s*\d", blk): has_pack.add(s)
        if re.search(r"\bqtyPallet:\s*\d", blk): has_pallet.add(s)

    by_sku = {}              # merge multi-page mentions of the same sku
    new_skus = {}
    low_conf = 0
    for p in products:
        sku = str(p.get('sku', '')).strip()
        if not sku: continue
        if p.get('confidence') == 'low':
            low_conf += 1
            continue          # R8 caution: skip unsure SKU reads
        if sku not in cat_skus:
            new_skus.setdefault(sku, p)   # in PDF but not our catalog → candidate new product
            continue
        cur = by_sku.setdefault(sku, {'dims': {}, 'color': None, 'pack': None, 'pallet': None})
        dims = dict(p.get('dims') or {})
        # lift pack/pallet OUT of dims into the catalog's first-class int fields.
        # ALWAYS pop the qty keys (so multi-row SKUs don't leak them into dims);
        # keep only the first numeric value seen.
        for k in list(dims.keys()):
            if k in PACK_KEYS:
                iv = as_int(dims.pop(k))
                if iv is not None and cur['pack'] is None: cur['pack'] = iv
            elif k in PALLET_KEYS:
                iv = as_int(dims.pop(k))
                if iv is not None and cur['pallet'] is None: cur['pallet'] = iv
        # fold PDF name into תיאור (non-destructive — never touch nameHe)
        if p.get('nameHe') and 'תיאור' not in dims:
            dims['תיאור'] = p['nameHe']
        cur['dims'].update({k: v for k, v in dims.items() if v not in (None, '', [])})
        if p.get('color') and not cur['color']:
            cur['color'] = p['color']

    dims_out, color_out, qty_out = [], [], []
    for sku, v in by_sku.items():
        if v['dims'] and sku not in has_dims:
            dims_out.append({'sku': sku, 'dims': v['dims']})
        if v['color'] and sku not in has_color and sku not in gate117:
            color_out.append({'sku': sku, 'color': v['color']})
        q = {}
        if v['pack'] is not None and sku not in has_pack: q['qtyPack'] = v['pack']
        if v['pallet'] is not None and sku not in has_pallet: q['qtyPallet'] = v['pallet']
        if q:
            q['sku'] = sku
            qty_out.append(q)

    json.dump({'dims': dims_out, 'colors': color_out, 'qty': qty_out},
              open(OUT, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)

    print(f"extracted finish-SKUs        : {len(products)}")
    print(f"  low-confidence (skipped)   : {low_conf}")
    print(f"  matched to catalog         : {len(by_sku)}")
    print(f"    → dims to apply (new)    : {len(dims_out)}")
    print(f"    → color to apply (new)   : {len(color_out)}")
    print(f"    → qty pack/pallet (new)  : {len(qty_out)}")
    print(f"  NOT in catalog (new SKUs)  : {len(new_skus)}")
    if new_skus:
        print("  --- sample new SKUs (PDF has, catalog lacks) — user decision to add ---")
        for sku, p in list(new_skus.items())[:15]:
            print(f"    {sku}  {p.get('nameHe','')[:40]}  [{p.get('color','')}] p{p.get('page','?')}")
    print(f"wrote {OUT}")

if __name__ == '__main__':
    main()

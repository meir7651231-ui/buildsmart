#!/usr/bin/env python3
"""Apply VALIDATED Lipskey enrichment (dims + color) onto lib/data/lipskey_catalog.dart.

Deterministic single-writer applier — the swarm's audit+validate produce the data;
this script inserts each verified field into the right product block. R8: it only
inserts what the validated payload contains (verbatim from the catalog pages/names).

Input  : knowledge/_enrich_validated.json  = {"dims":[{"sku","dims":{..}}], "colors":[{"sku","color"}]}
Target : lib/data/lipskey_catalog.dart
Skips  : a field already present on that product (idempotent, never overwrites).
Usage  : python scripts/apply_lipskey_enrich.py [--dry]
"""
import json, re, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

DRY = '--dry' in sys.argv
CATALOG = 'lib/data/lipskey_catalog.dart'
PAYLOAD = 'knowledge/_enrich_validated.json'

def dart_value(v):
    if isinstance(v, bool):  return 'true' if v else 'false'
    if isinstance(v, (int, float)): return str(v)
    s = str(v).replace('\\', r'\\').replace("'", r"\'")
    return f"'{s}'"

def dart_map(d):
    inner = ', '.join(f"{dart_value(str(k))}: {dart_value(v)}" for k, v in d.items())
    return '{' + inner + '}'

def main():
    payload = json.load(open(PAYLOAD, encoding='utf-8'))
    dims_by_sku = {e['sku']: e['dims'] for e in payload.get('dims', []) if e.get('dims')}
    color_by_sku = {e['sku']: e['color'] for e in payload.get('colors', []) if e.get('color')}
    qty_by_sku = {e['sku']: e for e in payload.get('qty', [])}
    src = open(CATALOG, encoding='utf-8').read()
    lines = src.split('\n')
    out = []
    cur_sku = None
    applied_dims = applied_color = skip_dims = skip_color = 0
    applied_pack = applied_pallet = skip_pack = skip_pallet = 0
    # track which optional fields the current block already has
    block_has = set()
    i = 0
    while i < len(lines):
        ln = lines[i]
        stripped = ln.rstrip()
        # ── single-line product: `LipskeyCatalogProduct(... page: N, ...),` on ONE line
        #    (AQUATEC/Qondus rows) — insert the new fields before the closing `),`.
        if stripped.lstrip().startswith('LipskeyCatalogProduct(') and stripped.endswith('),'):
            m = re.search(r"sku:\s*'([^']*)'", ln)
            if m:
                s = m.group(1)
                inserts = []
                if s in color_by_sku:
                    if re.search(r"\bcolor:\s*'", ln): skip_color += 1
                    else: inserts.append(f"color: {dart_value(color_by_sku[s])}"); applied_color += 1
                if s in qty_by_sku:
                    q = qty_by_sku[s]
                    if 'qtyPack' in q:
                        if re.search(r"\bqtyPack:\s*\d", ln): skip_pack += 1
                        else: inserts.append(f"qtyPack: {int(q['qtyPack'])}"); applied_pack += 1
                    if 'qtyPallet' in q:
                        if re.search(r"\bqtyPallet:\s*\d", ln): skip_pallet += 1
                        else: inserts.append(f"qtyPallet: {int(q['qtyPallet'])}"); applied_pallet += 1
                if s in dims_by_sku:
                    if re.search(r"\bdims:\s*\{", ln): skip_dims += 1
                    else: inserts.append(f"dims: {dart_map(dims_by_sku[s])}"); applied_dims += 1
                if inserts:
                    ln = stripped[:-2] + ', ' + ', '.join(inserts) + '),'
                out.append(ln)
                cur_sku = None
                i += 1
                continue
        m_sku = re.search(r"^\s*sku:\s*'([^']*)',", ln)
        if m_sku:
            cur_sku = m_sku.group(1)
            block_has = set()
        if cur_sku:
            if re.search(r"^\s*color:\s*", ln): block_has.add('color')
            if re.search(r"^\s*dims:\s*", ln):  block_has.add('dims')
            if re.search(r"^\s*qtyPack:\s*", ln): block_has.add('qtyPack')
            if re.search(r"^\s*qtyPallet:\s*", ln): block_has.add('qtyPallet')
        out.append(ln)
        # insert AFTER the page: line (page is required → always present, sits after sku)
        m_page = re.search(r"^(\s*)page:\s*\d+,", ln)
        if m_page and cur_sku:
            indent = m_page.group(1)
            if cur_sku in color_by_sku:
                if 'color' in block_has:
                    skip_color += 1
                else:
                    out.append(f"{indent}color: {dart_value(color_by_sku[cur_sku])},")
                    applied_color += 1
            if cur_sku in qty_by_sku:
                q = qty_by_sku[cur_sku]
                if 'qtyPack' in q:
                    if 'qtyPack' in block_has: skip_pack += 1
                    else:
                        out.append(f"{indent}qtyPack: {int(q['qtyPack'])},"); applied_pack += 1
                if 'qtyPallet' in q:
                    if 'qtyPallet' in block_has: skip_pallet += 1
                    else:
                        out.append(f"{indent}qtyPallet: {int(q['qtyPallet'])},"); applied_pallet += 1
            if cur_sku in dims_by_sku:
                if 'dims' in block_has:
                    skip_dims += 1
                else:
                    out.append(f"{indent}dims: {dart_map(dims_by_sku[cur_sku])},")
                    applied_dims += 1
        i += 1
    new = '\n'.join(out)
    print(f"dims:      applied {applied_dims}  (skipped-already-present {skip_dims})")
    print(f"color:     applied {applied_color}  (skipped-already-present {skip_color})")
    print(f"qtyPack:   applied {applied_pack}  (skipped-already-present {skip_pack})")
    print(f"qtyPallet: applied {applied_pallet}  (skipped-already-present {skip_pallet})")
    if DRY:
        print("[dry-run] not written")
        return
    open(CATALOG, 'w', encoding='utf-8').write(new)
    print(f"wrote {CATALOG}")

if __name__ == '__main__':
    main()

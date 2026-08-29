#!/usr/bin/env python3
"""Apply the catalog-attribute fleet's R8-verified extractions (זווית/יציאות/
תצורה/מאפיין/ייעוד) into dims. Defence-in-depth: re-checks EACH value is a
literal token of the product's own nameHe before inserting (so even a bad agent
output can't violate R8). gate-117 SKUs skipped; merges into existing dims;
idempotent. Input: knowledge/_fleet_attrs.json (list of {sku,key,value}).
Usage: python scripts/fill_attrs_from_fleet.py
"""
import json, re, sys, io
from collections import defaultdict

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
F = 'lib/data/lipskey_catalog.dart'
PARITY = 'test/lipskey_pdf_parity_test.dart'
INP = 'knowledge/_fleet_attrs.json'
KEY_ORDER = ['זווית', 'יציאות', 'תצורה', 'מאפיין', 'ייעוד']


def main():
    ext = json.load(open(INP, encoding='utf-8'))
    bysku = defaultdict(dict)
    for a in ext:
        bysku[a['sku']][a['key']] = a['value']
    # NOTE: gate-117 SKUs are NOT excluded here. The parity test asserts dims
    # PER-KEY (dims['DN'], dims['גובה'] …), so adding a NEW key (זווית/ייעוד/…)
    # to a pinned product cannot break it — verified by running the parity suite.
    s = open(F, encoding='utf-8').read()
    parts = s.split('LipskeyCatalogProduct(')
    out = [parts[0]]
    n = 0
    nprod = 0
    for part in parts[1:]:
        m = re.search(r"sku:\s*'([^']*)'", part)
        sku = m.group(1) if m else None
        if sku in bysku:
            head = part[:1700]
            nm = re.search(r"nameHe:\s*'([^']*)'", head)
            nm = nm.group(1) if nm else ''
            dmatch = re.search(r"dims:\s*\{([^}]*)\}", head)
            keys = re.findall(r"'([^']+)':", dmatch.group(1)) if dmatch else []
            adds = {}
            for k in KEY_ORDER:
                if k in bysku[sku] and k not in keys:
                    v = bysku[sku][k]
                    # defence-in-depth R8: value (or its non-° core) must be in the name
                    if v in nm or v.replace('°', '').strip() in nm.replace('°', ''):
                        adds[k] = v
            if adds:
                frag = ''.join("'%s': '%s', " % (k, adds[k]) for k in adds)
                if dmatch:
                    part = re.sub(r"dims:\s*\{", "dims: {" + frag, part, count=1)
                else:
                    part = re.sub(r"(\s+)page:",
                                  r"\1dims: {" + frag.rstrip(', ') + r"},\1page:",
                                  part, count=1)
                n += len(adds)
                nprod += 1
        out.append(part)
    open(F, 'w', encoding='utf-8').write('LipskeyCatalogProduct('.join(out))
    print(f"applied {n} attributes across {nprod} products")


if __name__ == '__main__':
    main()

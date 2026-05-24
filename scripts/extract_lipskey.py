#!/usr/bin/env python3
"""
Lipskey Plumbing Catalog 2024 — full extractor v3.
Handles NO-style blocks, flat tables (bends/pipes/branches).
"""
import fitz, re, json, sys
from pathlib import Path

PDF = Path("/root/.claude/uploads/7b2df638-5425-4de0-88e0-28da1552ac07/8ce15fca-lipskey_plumbing_catalog2024_s.pdf")

# ─── category table ───────────────────────────────────────────────────────────
CATS = [
    (range(5,  9),  "מחסומים (סיפונים) גלויים",  "Visible Traps",           "🚰"),
    (range(9,  10), "אמבט ואגנית",                "Bath & Basin",            "🛁"),
    (range(10, 12), "אביזרי תבריג",               "Screw-on Accessories",    "🔩"),
    (range(13, 15), "מחסומי רצפה",                "Floor Traps",             "⬇️"),
    (range(15, 18), "מאספים וקולטים",             "Collectors & Drains",     "🕳️"),
    (range(18, 20), "אטמים אומים ופקקים",         "Gaskets, Nuts & Plugs",   "🔧"),
    (range(20, 21), "אביזרי שקע-תקע",             "Insertion Accessories",    "🔌"),
    (range(21, 22), "ברכיים",                     "Bends",                   "↩️"),
    (range(22, 23), "מסעפים וחיבורי אסלה",        "Branches & WC Conn.",     "⑂"),
    (range(23, 26), "מצמדים וצינורות",            "Couplers & Pipes",        "🪠"),
    (range(26, 27), "מיכלי הדחה",                 "Toilet Cisterns",         "🚽"),
    (range(27, 29), "מושבי אסלה",                 "Toilet Seats",            "🚽"),
    (range(29, 31), "חלקים סניטריים",             "Sanitary Parts",          "🔧"),
]

def cat(pn):
    for r, he, en, emoji in CATS:
        if pn in r:
            return he, en, emoji
    return "כללי", "General", "📦"

# ─── helpers ──────────────────────────────────────────────────────────────────
SKU_NO  = re.compile(r'NO\.(\d{6,7})')
INT_RE  = re.compile(r'(\d+)\s+כמות\s+באריזה')
PAL_RE  = re.compile(r'(\d+)\s+כמות\s+במשטח')
CLR_RE  = re.compile(r'צבע\s*\|\s*([^\n\|]{1,20})')
HE_RE   = re.compile(r'[א-ת]')
EN_RE   = re.compile(r'[a-zA-Z]{3,}')
BARE    = re.compile(r'(?<!\d)(\d{6,7})(?!\d)')

SKIP_HE = {'מחסומים', 'אינסטלציה', 'סניטציה', 'ברכיים', 'מסעפים',
           'צינורות', 'מכסים', 'רשתות', 'הגבהות', 'מפתחות', 'מחברים'}
SKIP_EN = {'Visible', 'Bashwash', 'Bathwash', 'Screw-on', 'Floor', 'Collectors',
           'Gaskets', 'Insertion', 'Bends', 'Branches', 'Pipes', 'Sanitation',
           'Thermoset', 'Thermoplastic', 'Caps', 'Covers', 'Extentions',
           'Connectors', 'Junctions', 'Traps', 'Keys'}

def clean(t): return ' '.join(t.split())

def is_junk(line):
    line = line.strip()
    if not line or len(line) < 3: return True
    if re.match(r'^[\d\.\-/×Ø\s°"±,]+$', line): return True
    if re.match(r'^\d+\n\d+$', line): return True
    if any(line.startswith(s) for s in ('NO.', 'כמות', 'צבע |', '*', '01/')): return True
    return False

def name_from_blocks(nearby_blocks, sku_text):
    he_parts, en_parts = [], []
    skip_text = set(sku_text.split('\n'))
    for tb in nearby_blocks:
        for line in tb["text"].split('\n'):
            line = line.strip()
            if line in skip_text or is_junk(line): continue
            if HE_RE.search(line):
                word = line.split()[0] if line.split() else ''
                if word not in SKIP_HE:
                    he_parts.append(clean(line))
            elif EN_RE.search(line):
                word = line.split()[0] if line.split() else ''
                if word not in SKIP_EN and '°' not in line:
                    en_parts.append(clean(line))
    he = ' | '.join(list(dict.fromkeys(p for p in he_parts if p))[:3])
    en = ' | '.join(list(dict.fromkeys(p for p in en_parts if p))[:2])
    return he, en

def make_product(sku, name_he, name_en, color, qty_pack, qty_pallet,
                 page_num, dims=None, notes=None):
    c_he, c_en, emoji = cat(page_num)
    return {
        "sku":         sku,
        "name_he":     clean(name_he),
        "name_en":     clean(name_en),
        "color":       color,
        "qty_pack":    qty_pack,
        "qty_pallet":  qty_pallet,
        "category_he": c_he,
        "category_en": c_en,
        "category_emoji": emoji,
        "page":        page_num,
        **({"dims": dims} if dims else {}),
        **({"notes": notes} if notes else {}),
    }

# ─── extractor A: NO.XXXXXX style pages ──────────────────────────────────────
def extract_no_style(page, page_num):
    blocks = [
        {"x0": b[0], "y0": b[1], "x1": b[2], "y1": b[3], "text": b[4].strip()}
        for b in page.get_text("blocks") if b[6] == 0 and b[4].strip()
    ]
    results = []
    for tb in blocks:
        skus = SKU_NO.findall(tb["text"])
        if not skus: continue
        bx, by, bt = tb["x0"], tb["y0"], tb["text"]

        qty_pack   = int(m.group(1)) if (m := INT_RE.search(bt)) else None
        qty_pallet = int(m.group(1)) if (m := PAL_RE.search(bt)) else None
        color      = clean(m.group(1)) if (m := CLR_RE.search(bt)) else None

        nearby = [t for t in blocks if t is not tb
                  and abs(t["x0"]-bx) < 380 and abs(t["y0"]-by) < 200]

        for nt in nearby:
            t = nt["text"]
            if qty_pack   is None and (m := INT_RE.search(t)): qty_pack   = int(m.group(1))
            if qty_pallet is None and (m := PAL_RE.search(t)): qty_pallet = int(m.group(1))
            if color      is None and (m := CLR_RE.search(t)): color      = clean(m.group(1))

        name_he, name_en = name_from_blocks(nearby, bt)
        for sku in skus:
            results.append(make_product(sku, name_he, name_en, color,
                                        qty_pack, qty_pallet, page_num))
    return results

# ─── extractor B: table rows (bends p11) ─────────────────────────────────────
# Format per line: qty_pallet  qty_pack  T  I  L2  L1  model  DN  sku
def extract_bends(text):
    # Section names
    BEND_NAMES = {
        '213072': ('ברך 15° - תבריג צד אחד',  'Band 15° - single side screw-on'),
        '213073': ('ברך 30° - תבריג צד אחד',  'Band 30° - single side screw-on'),
        '116207': ('ברך 45° - תבריג צד אחד',  'Band 45° - single side screw-on'),
        '116203': ('ברך 45° - תבריג צד אחד',  'Band 45° - single side screw-on'),
        '116205': ('ברך 45° - תבריג צד אחד',  'Band 45° - single side screw-on'),
        '170643': ('ברך טלסקופית 90° רב תכליתי', 'Telescopic bend 90° for bottle trap'),
        '223101': ('ברך טלסקופית 90° רב תכליתי', 'Telescopic bend 90° for bottle trap'),
    }
    rows = []
    for line in text.split('\n'):
        nums = re.findall(r'[\d\.]+', line)
        m = BARE.search(line)
        if not m: continue
        sku = m.group(1)
        if sku not in BEND_NAMES: continue
        # Extract all numbers from line
        vals = [float(n) for n in nums if '.' in n or len(n) <= 5]
        qty_pallet = qty_pack = dn = None
        # Pattern: qty_pallet  qty_pack  T  I  L2  L1  model/dn  sku
        # From example: 3600 80 1.8 34 40 42 50/50 213072
        nums_int = [int(float(n)) for n in nums if float(n) == int(float(n)) and float(n) > 0]
        if len(nums_int) >= 2:
            qty_pallet = nums_int[0]
            qty_pack   = nums_int[1]
        name_he, name_en = BEND_NAMES[sku]
        # Dimensions
        dn_m = re.search(r'(\d+)/(\d+)', line)
        dn_str = dn_m.group(0) if dn_m else None
        rows.append({'sku': sku, 'name_he': name_he, 'name_en': name_en,
                     'qty_pack': qty_pack, 'qty_pallet': qty_pallet,
                     'dims': {'dn': dn_str}, 'page': 11})
    return rows

# ─── extractor C: pipe tables (pages 24, 25) ─────────────────────────────────
def extract_pipes(text, page_num):
    """
    Page 24: pipes with DN, length, qty_pack in rows.
    Page 25: same pattern but cleaner.
    Format: sku  dn  length  qty_pack  (qty_pallet sometimes separate)
    """
    # Page 25 is cleaner:
    # 224168  110  300  80
    # 224169  110  100  160
    # Also gray/black variants on p24
    results = []
    lines = text.split('\n')

    # Detect gray/black columns on p24
    color_seq = []
    current_color = None
    for line in lines:
        if 'אפור' in line: current_color = 'אפור'
        elif 'שחור' in line: current_color = 'שחור'

    # Parse rows: 6-digit-sku  number  number  number
    row_re = re.compile(r'^(\d{6,7})\s+([\d/]+)\s+([\d/]+)\s+(\d+)\s*$')
    simple_re = re.compile(r'(\d{6,7})\s+(\d{2,3})\s+(\d{1,4})\s+(\d{1,4})')

    for line in lines:
        m = simple_re.search(line)
        if m:
            sku, dn, length, qty = m.group(1), m.group(2), m.group(3), m.group(4)
            results.append({
                'sku': sku,
                'qty_pack': int(qty),
                'qty_pallet': None,
                'dims': {'dn_mm': int(dn), 'length_mm': int(length)},
                'page': page_num,
            })
    return results

# ─── extractor D: branch/coupler tables ──────────────────────────────────────
def extract_table_generic(text, page_num):
    """Generic table: sku then dimensions then qty."""
    results = []
    for line in text.split('\n'):
        m = BARE.search(line)
        if not m: continue
        sku = m.group(1)
        nums = [int(n) for n in re.findall(r'\b\d{1,5}\b', line) if int(n) != int(sku)]
        qty_pallet = nums[0] if len(nums) >= 1 else None
        qty_pack   = nums[1] if len(nums) >= 2 else None
        if qty_pallet and qty_pack and qty_pallet < qty_pack:
            qty_pallet, qty_pack = qty_pack, qty_pallet
        results.append({
            'sku': sku, 'qty_pack': qty_pack, 'qty_pallet': qty_pallet,
            'page': page_num,
        })
    return results

# ─── pipe name lookup (pages 24-25) ──────────────────────────────────────────
PIPE_NAMES = {
    # Page 24 — gray/black PVC pipes (ש"ת)
    **{s: ('צינור ש"ת אפור', 'PVC pipe - grey') for s in
       ['273227', '116069', '221022', '116076', '116612', '116084', '116091', '116093',
        '219791', '221083', '221414', '221082', '221086']},
    **{s: ('צינור ש"ת שחור', 'PVC pipe - black') for s in
       ['273226', '220278', '221021', '220280', '221085', '221084', '221415',
        '219792', '224205']},
    # Page 25 — orange SN4/SN8 and multi-layer black
    **{s: ('צנרת מובנת לביוב כתום SN4/SN8', 'Pipe SUPER SWG SN4/SN8 - orange') for s in
       ['224168', '224169', '224170', '224185', '224186', '224187']},
    **{s: ('צנרת רב שכבתית שחור SUPER BETON', 'Pipe SUPER BETON/SILENT - black') for s in
       ['273216', '273217', '273201', '273202', '273203', '273215', '273219', '273220', '273221']},
    **{s: ('צנרת מובנת לביוב כתום SN4', 'Pipe SUPER SWG SN4 - orange') for s in
       ['224345', '224344', '224348', '224347', '224346']},
}

BRANCH_NAMES = {
    '220305': ('מסעף', 'Branch'),
    '218564': ('מסעף 110/50/50', 'Branch 110/50/50'),
    '218176': ('מסעף כפול 110/110/110', 'Double Branch 110/110/110'),
    '116558': ('מסעף 110', 'Branch 110'),
    '217533': ('ברך אסלה 75/50', 'WC Bend 75/50'),
}

COUPLER_NAMES = {
    '218567': ('מצמד כפול 110', 'Double socket 110'),
    '218569': ('פקק חיצוני 110', 'External plug 110'),
    '218460': ('מצמד קצר', 'Short coupler'),
    '218560': ('מצמד 160', 'Coupler 160'),
    '220315': ('מצמד 40', 'Coupler 40'),
    '218568': ('מצמד כפול 50/40', 'Double socket 50/40'),
    '220316': ('מצמד כפול 40/32', 'Double socket 40/32'),
    '194897': ('מצמד קצר 110/100', 'Short coupler 110/100'),
}

SEAT_NAMES = {
    '220943': ('מושב אסלה תרמופלסטי', 'Thermoplastic toilet seat'),
    '218360': ('מושב אסלה עם ציר פלסטיק', 'Toilet seat - plastic hinge'),
    '218361': ('מושב אסלה עם ציר נירוסטה', 'Toilet seat - stainless hinge'),
    '220981': ('מושב אסלה אדיר', 'Toilet seat Adir'),
    '224286': ('מושב אסלה תרמוסטי ULTRA טרמו', 'Toilet seat Termu Ultra thermoset'),
}

FLOOR_TRAP_NAMES = {
    '218681': ('מחסום רצפה תיקני 245/50 פתוח גבוהה', 'Gully trap 245/50 open high'),
    '218722': ('מחסום רצפה תיקני 245/50 סגור גבוהה', 'Gully trap 245/50 closed high'),
    '220542': ('מחסום רצפה תיקני 245/50 פתוח', 'Gully trap 245/50 open'),
    '220543': ('מחסום רצפה תיקני 245/50 סגור', 'Gully trap 245/50 closed'),
}

CAP_NAMES = {
    '610911': ('מכסה/רשת לבן', 'Cap/Cover white'),
    '635736': ('מכסה/רשת פרגמון', 'Cap/Cover travertine'),
}

GASKET_NAMES = {
    '558463': ('אטם דו צדדי 32/50', 'Double side gasket 32/50'),
}

ALL_NAMES = {**PIPE_NAMES, **BRANCH_NAMES, **COUPLER_NAMES, **SEAT_NAMES,
             **FLOOR_TRAP_NAMES, **CAP_NAMES, **GASKET_NAMES}

# ─── extractor E: bare-SKU pages (no NO. prefix) ─────────────────────────────
def extract_bare_sku(text, page_num):
    """For pages where products appear as bare 6-7 digit numbers."""
    results = []
    seen = set()
    for line in text.split('\n'):
        m = BARE.search(line)
        if not m: continue
        sku = m.group(1)
        if sku in seen: continue
        seen.add(sku)
        nums = [int(n) for n in re.findall(r'\b\d{1,5}\b', line) if int(n) != int(sku)]
        qty_pack   = nums[0] if len(nums) >= 1 else None
        qty_pallet = nums[1] if len(nums) >= 2 else None
        if qty_pack and qty_pallet and qty_pallet < qty_pack:
            qty_pack, qty_pallet = qty_pallet, qty_pack
        results.append({'sku': sku, 'qty_pack': qty_pack,
                        'qty_pallet': qty_pallet, 'page': page_num})
    return results

# ─── main ─────────────────────────────────────────────────────────────────────
def run():
    doc = fitz.open(str(PDF))
    all_products = []

    for page_idx, page in enumerate(doc):
        pn = page_idx + 1
        if pn < 5: continue

        text = page.get_text()

        # Pages with NO.XXXXXX style
        if pn in range(5, 15) or pn in {17, 19, 26, 27, 28, 29}:
            products = extract_no_style(page, pn)
            all_products.extend(products)

        # Bends table (p11 already partly covered, add explicit)
        if pn == 11:
            for row in extract_bends(text):
                row.update(make_product(
                    row['sku'], row['name_he'], row['name_en'],
                    None, row['qty_pack'], row['qty_pallet'], 11,
                    dims=row.get('dims'),
                ))
                all_products.append(row)

        # Pipe tables p24, p25
        if pn in (24, 25):
            for row in extract_pipes(text, pn):
                sku = row['sku']
                n = ALL_NAMES.get(sku, ('', ''))
                p = make_product(sku, n[0], n[1], None,
                                 row['qty_pack'], row['qty_pallet'], pn,
                                 dims=row.get('dims'))
                all_products.append(p)

        # Bare-SKU pages: floor-trap p14, caps p17, gaskets p19
        if pn in (14, 17, 19):
            for row in extract_bare_sku(text, pn):
                sku = row['sku']
                n = ALL_NAMES.get(sku, ('', ''))
                p = make_product(sku, n[0], n[1], None,
                                 row['qty_pack'], row['qty_pallet'], pn)
                all_products.append(p)

        # Generic table pages: branches p22, couplers p23
        if pn in (22, 23):
            for row in extract_table_generic(text, pn):
                sku = row['sku']
                n = ALL_NAMES.get(sku, ('', ''))
                p = make_product(sku, n[0], n[1], None,
                                 row['qty_pack'], row['qty_pallet'], pn)
                all_products.append(p)

        # Toilet seats p27, p28 generic
        if pn in (27, 28):
            for row in extract_table_generic(text, pn):
                sku = row['sku']
                n = ALL_NAMES.get(sku, ('', ''))
                p = make_product(sku, n[0], n[1], None,
                                 row['qty_pack'], row['qty_pallet'], pn)
                all_products.append(p)

    # Enrich names from lookup table for all products
    for p in all_products:
        if not p.get('name_he') and p['sku'] in ALL_NAMES:
            p['name_he'], p['name_en'] = ALL_NAMES[p['sku']]

    # Deduplicate by SKU (keep first with best name)
    seen, unique = {}, []
    for p in all_products:
        sku = p['sku']
        if sku not in seen:
            seen[sku] = p
            unique.append(p)
        else:
            # Prefer entry with actual names
            if not seen[sku].get('name_he') and p.get('name_he'):
                idx = next(i for i, x in enumerate(unique) if x['sku'] == sku)
                unique[idx] = p
                seen[sku] = p

    return unique

if __name__ == "__main__":
    products = run()
    out = Path(__file__).parent / "lipskey_catalog.json"
    payload = {
        "source":   "Lipskey Plumbing Catalog 2024",
        "version":  "2024-01",
        "supplier": "ליפסקי ברקן - חרסה סטודיו",
        "count":    len(products),
        "products": products,
    }
    with open(out, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)

    cats = {}
    for p in products:
        cats.setdefault(p['category_he'], 0)
        cats[p['category_he']] += 1
    print(f"✓ {len(products)} מוצרים")
    for c, n in sorted(cats.items(), key=lambda x: -x[1]):
        print(f"   {n:>3}  {c}")
    print(f"   → {out}")

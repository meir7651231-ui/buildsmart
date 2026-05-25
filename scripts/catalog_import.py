#!/usr/bin/env python3
"""
catalog_import.py — צינור-ייבוא-אצווה: CSV/JSON → קוד Dart (צעד 89).

קולט קובץ מוצרים (CSV עם כותרות, או JSON מערך/‏{products:[...]}) ופולט
רשומות `LipskeyCatalogProduct(...)` מוכנות להדבקה ל-lipskey_catalog.dart.
מחיל את נרמול-השם הבטוח (פרק 11 בפרוטוקול) ואת מלכודת-הגרש של Dart (פרק 12).

שדות נתמכים (מפתח JSON / כותרת CSV):
  sku* nameHe* nameEn color qtyPack qtyPallet categoryHe categoryEn
  categoryEmoji page imageFile brand
(* חובה. שאר השדות אופציונליים — נשמטים מהפלט אם ריקים.)

שימוש:
  python3 scripts/catalog_import.py <file.csv|file.json> [--validate]
  python3 scripts/catalog_import.py --bench 50000        # benchmark (צעד 84)
"""
import csv
import json
import re
import sys
import time

REQUIRED = ("sku", "nameHe")
INT_FIELDS = ("qtyPack", "qtyPallet", "page")
STR_FIELDS = ("sku", "nameHe", "nameEn", "color", "categoryHe", "categoryEn",
              "categoryEmoji", "imageFile", "brand")


# ── name normalisation (פרוטוקול פרק 11 — בטוח, על nameHe בלבד) ───────────────
def normalize_name(n):
    if not n:
        return n
    n = n.replace("״", '"').replace("“", '"').replace("”", '"')
    # strip packaging segments
    parts = [p.strip(" )(") for p in n.split("|")]
    parts = [p for p in parts if p and not re.search(r"כמות (באריזה|במשטח)", p)
             and not re.fullmatch(r"\d+ ?(במשטח|באריזה)?", p)]
    n = " · ".join(dict.fromkeys(parts)) if parts else n.split("|")[0]
    # space at digit↔letter boundary WITHOUT reordering (don't break words)
    n = re.sub(r"(?<=[א-ת])(?=\d)", " ", n)
    n = re.sub(r'(?<=[\d"])(?=[א-ת])', " ", n)
    return " ".join(n.split())


# ── Dart string literal — single-quoted, escaping the apostrophe gotcha ───────
def dart_str(s):
    if s is None:
        return "null"
    s = s.replace("\\", r"\\").replace("'", r"\'").replace("$", r"\$")
    return f"'{s}'"


def emit_one(p):
    lines = ["  LipskeyCatalogProduct("]
    lines.append(f"    sku: {dart_str(p['sku'])},")
    lines.append(f"    nameHe: {dart_str(normalize_name(p['nameHe']))},")
    lines.append(f"    nameEn: {dart_str(p.get('nameEn') or '')},")
    if p.get("color"):
        lines.append(f"    color: {dart_str(p['color'])},")
    if p.get("qtyPack") not in (None, ""):
        lines.append(f"    qtyPack: {int(p['qtyPack'])},")
    if p.get("qtyPallet") not in (None, ""):
        lines.append(f"    qtyPallet: {int(p['qtyPallet'])},")
    lines.append(f"    categoryHe: {dart_str(p.get('categoryHe') or '')},")
    lines.append(f"    categoryEn: {dart_str(p.get('categoryEn') or '')},")
    lines.append(f"    categoryEmoji: {dart_str(p.get('categoryEmoji') or '📦')},")
    lines.append(f"    page: {int(p.get('page') or 0)},")
    if p.get("imageFile"):
        lines.append(f"    imageFile: {dart_str(p['imageFile'])},")
    if p.get("brand"):
        lines.append(f"    brand: {dart_str(p['brand'])},")
    lines.append("  ),")
    return "\n".join(lines)


def load(path):
    if path.endswith(".json"):
        data = json.load(open(path, encoding="utf-8"))
        return data["products"] if isinstance(data, dict) else data
    with open(path, encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def validate(rows):
    errs, seen = [], set()
    for i, p in enumerate(rows):
        for r in REQUIRED:
            if not str(p.get(r) or "").strip():
                errs.append(f"שורה {i}: שדה חובה חסר '{r}'")
        sku = str(p.get("sku") or "")
        if sku and sku in seen:
            errs.append(f"שורה {i}: מק\"ט כפול {sku}")
        seen.add(sku)
    return errs


def cmd_bench(n):
    """צעד 84 — מייצר n רשומות סינתטיות ומודד parse+normalize+emit."""
    cats = ["מחסומים", "ברכיים", "מצמדים", "אטמים", "צינורות", "מסעפים"]
    sizes = ["DN50", "DN110", "75/50", '1.25"', "DN40", "160/110"]
    t0 = time.time()
    rows = [{
        "sku": str(100000 + i),
        "nameHe": f"מוצר {cats[i % len(cats)]} {sizes[i % len(sizes)]} מס׳{i}",
        "nameEn": f"part {i}", "categoryHe": cats[i % len(cats)],
        "categoryEn": "x", "categoryEmoji": "📦", "page": i % 200,
        "brand": "ליפסקי" if i % 3 else "AQUATEC",
    } for i in range(n)]
    t_gen = time.time() - t0
    t0 = time.time()
    errs = validate(rows)
    t_val = time.time() - t0
    t0 = time.time()
    out = "\n".join(emit_one(p) for p in rows)
    t_emit = time.time() - t0
    print(f"benchmark · {n:,} רשומות")
    print(f"  generate : {t_gen*1000:7.1f} ms")
    print(f"  validate : {t_val*1000:7.1f} ms  ({len(errs)} שגיאות)")
    print(f"  emit Dart: {t_emit*1000:7.1f} ms  ({len(out):,} תווים)")
    total = t_gen + t_val + t_emit
    print(f"  סה\"כ     : {total*1000:7.1f} ms  →  {n/total:,.0f} רשומות/שנייה")
    # scale gate: must stay well under a minute for 50k
    ok = total < 30
    print("✅ עומד בקנה-מידה" if ok else "❌ איטי מדי")
    sys.exit(0 if ok else 1)


def main():
    a = sys.argv[1:]
    if not a:
        print(__doc__)
        sys.exit(1)
    if a[0] == "--bench":
        cmd_bench(int(a[1]) if len(a) > 1 else 50000)
        return
    rows = load(a[0])
    errs = validate(rows)
    if errs:
        print("❌ אימות נכשל:", file=sys.stderr)
        for e in errs[:20]:
            print("   " + e, file=sys.stderr)
        if "--validate" in a:
            sys.exit(1)
    if "--validate" in a:
        print(f"✅ {len(rows)} רשומות — אימות נקי")
        return
    print("\n".join(emit_one(p) for p in rows))


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
catalog_qa.py — כלי QA רב-פעמי לקטלוג BuildSmart.

מטרה: לחלץ את כל שמות/מק"טים/קטגוריות המוצרים מקובץ הנתונים של Dart,
לבדוק אותם אוטומטית, ולייצא דוח קל-לעיון — כך שגם כשיהיו עשרות אלפי
מוצרים אפשר לחקור ולתחזק אותם בקלות.

מקור הנתונים:  app_flutter/lib/data/lipskey_catalog.dart
                (כל מוצר = LipskeyCatalogProduct( ... ) )

────────────────────────────────────────────────────────────────────────
פרוטוקול עבודה (כל סבב QA):

  1)  python3 scripts/catalog_qa.py audit
      → מדפיס סיכום בעיות: שמות פגומים · ריקים · מק"ט כפול · שם כפול
        בקטגוריה · ללא גודל (DN/אינץ') · ללא תמונה · קטגוריה לא ממופה.

  2)  python3 scripts/catalog_qa.py export catalog_qa.csv
      → מייצא CSV מלא (sku,name,nameEn,category,page,image,brand,size,flags)
        פותחים ב-Excel/Sheets, ממיינים לפי flags, מתקנים מה שצריך.

  3)  python3 scripts/catalog_qa.py pdfmap <catalog.pdf>
      → ממפה page→[skus] מתוך ה-PDF, כדי לדעת באיזה עמוד כל מוצר.

  4)  python3 scripts/catalog_qa.py verify <catalog.pdf> <sku1> <sku2> ...
      → מרנדר את עמודי ה-PDF של אותם מק"טים לקבצי PNG ב-/tmp,
        לקריאה ויזואלית ותיקון שם מדויק מהמקור.

  כלל זהב: שם שאי-אפשר לאמת מול ה-PDF — לא ממציאים. מתקנים רק
           ניקוי בטוח (הסרת זבל/נרמול) או מה שנקרא ויזואלית מהמקור.
────────────────────────────────────────────────────────────────────────
"""
import csv
import os
import re
import sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CATALOG = os.path.join(ROOT, "app_flutter/lib/data/lipskey_catalog.dart")
TREE = os.path.join(ROOT, "app_flutter/lib/data/catalog_tree.dart")

HE = re.compile(r"[א-ת]")
# size / dimension token: DN.., ratios (50/40), inch (3/4"), pure DN numbers
SIZE = re.compile(r'(DN\s?\d+|\d+/\d+|\d+["׳״]|\b(?:32|40|50|60|75|90|110|130|160|200)\b)')

# Hebrew/brand fragments that are legitimate even though they look "english"
OK_EN = ("soft", "ULTRA", "DN", "NTM", "HDPE", "PP-MD", "SILENT", "BETON",
         "PEX", "A/C")


# ─── parsing ─────────────────────────────────────────────────────────────────
def _field(body, name):
    """Read a Dart named arg, single- or double-quoted."""
    m = re.search(rf"{name}:\s*(['\"])(.*?)\1", body, re.DOTALL)
    return m.group(2) if m else ""


def parse_catalog(path=CATALOG):
    src = open(path, encoding="utf-8").read()
    out = []
    for m in re.finditer(
        r"LipskeyCatalogProduct\((.*?)\),\s*(?=LipskeyCatalogProduct|\];)",
        src, re.DOTALL,
    ):
        b = m.group(1)
        out.append({
            "sku": _field(b, "sku"),
            "name": _field(b, "nameHe"),
            "nameEn": _field(b, "nameEn"),
            "category": _field(b, "categoryHe"),
            "page": _field(b, "page"),
            "image": bool(re.search(r"imageFile:\s*'", b)),
            "brand": _field(b, "brand") or "ליפסקי",
        })
    return out


def tree_categories(path=TREE):
    src = open(path, encoding="utf-8").read()
    return set(re.findall(r"lipskeyCategory:\s*'([^']+)'", src))


# ─── checks ──────────────────────────────────────────────────────────────────
def flags_for(p):
    """Return list of issue flags for one product."""
    f = []
    n = p["name"]
    if not n.strip():
        f.append("EMPTY")
    if "|" in n or "כמות" in n or "״" in n or "“" in n:
        f.append("JUNK")
    if re.search(r"\d[א-ת]", n) or re.search(r"[א-ת]\d", n):
        f.append("STUCK")          # digit glued to letter
    if n.count("(") != n.count(")"):
        f.append("PARENS")
    if len(HE.findall(n)) < 2 and not re.search(r"[A-Za-z]{3}", n):
        f.append("SHORT")
    if not SIZE.search(n):
        f.append("NOSIZE")         # no DN/inch → breaks compatibility matching
    if not p["image"]:
        f.append("NOIMG")
    return f


def size_token(n):
    m = SIZE.search(n)
    return m.group(0) if m else ""


def audit(products, tcats):
    g = defaultdict(list)
    for p in products:
        for fl in flags_for(p):
            g[fl].append(p)

    # duplicate SKUs
    by_sku = defaultdict(list)
    for p in products:
        by_sku[p["sku"]].append(p)
    dup_sku = {k: v for k, v in by_sku.items() if len(v) > 1}

    # identical name within a category
    by_cn = defaultdict(list)
    for p in products:
        by_cn[(p["category"], p["name"])].append(p["sku"])
    dup_name = {k: v for k, v in by_cn.items() if len(v) > 1}

    # categories not present in the drill tree
    cats = {p["category"] for p in products}
    unmapped = cats - tcats

    return g, dup_sku, dup_name, unmapped, cats


# ─── commands ────────────────────────────────────────────────────────────────
def cmd_audit():
    products = parse_catalog()
    tcats = tree_categories()
    g, dup_sku, dup_name, unmapped, cats = audit(products, tcats)
    print("=" * 56)
    print(f"  ביקורת קטלוג — {len(products)} מוצרים · {len(cats)} קטגוריות")
    print("=" * 56)
    HARD = ["EMPTY", "JUNK", "STUCK", "PARENS"]
    for fl in ["EMPTY", "JUNK", "STUCK", "PARENS", "SHORT", "NOSIZE", "NOIMG"]:
        items = g.get(fl, [])
        mark = "❌" if fl in HARD and items else ("⚠️" if items else "✅")
        print(f"  {mark} {fl:<7} {len(items)}")
        if fl in HARD:
            for p in items[:6]:
                print(f"        {p['sku']}: {p['name'][:50]}")
    print(f"  {'❌' if dup_sku else '✅'} מק\"ט כפול   {len(dup_sku)}  {list(dup_sku)[:5]}")
    print(f"  {'⚠️' if dup_name else '✅'} שם כפול     {len(dup_name)}")
    for (c, n), sks in list(dup_name.items())[:6]:
        print(f"        [{c}] '{n[:30]}' {sks}")
    print(f"  {'❌' if unmapped else '✅'} קטגוריה לא בעץ  {unmapped or ''}")
    hard = sum(len(g.get(f, [])) for f in HARD) + len(dup_sku) + len(unmapped)
    print("-" * 56)
    print("  ✅ אפס שגיאות קשות" if hard == 0 else f"  ❌ {hard} שגיאות קשות")


def cmd_export(out="catalog_qa.csv"):
    products = parse_catalog()
    with open(out, "w", newline="", encoding="utf-8-sig") as fh:
        w = csv.writer(fh)
        w.writerow(["sku", "name", "nameEn", "category", "page",
                    "image", "brand", "size", "flags"])
        for p in products:
            w.writerow([p["sku"], p["name"], p["nameEn"], p["category"],
                        p["page"], "Y" if p["image"] else "",
                        p["brand"], size_token(p["name"]),
                        "|".join(flags_for(p))])
    print(f"נכתב {out} ({len(products)} שורות)")


def cmd_pdfmap(pdf):
    import fitz
    doc = fitz.open(pdf)
    for i in range(len(doc)):
        skus = sorted(set(re.findall(r"\b[A-Z0-9]{6,10}\b", doc[i].get_text())))
        skus = [s for s in skus if re.search(r"\d", s)]
        if skus:
            print(f"page {i+1}: {skus}")


def cmd_crosscheck(*pdfs):
    """Semantic check: every product's name vs the source PDF text near its SKU.
    Pass ALL source PDFs. Reports coverage + names that don't match the source."""
    import fitz
    if not pdfs:
        print("usage: crosscheck <pdf1> [pdf2 ...]")
        return
    # global sku -> (pdf, page, page-text)
    pages = []  # (label, text)
    for pdf in pdfs:
        doc = fitz.open(pdf)
        for i in range(len(doc)):
            pages.append((f"{os.path.basename(pdf)}#p{i+1}", doc[i].get_text()))

    def hwords(s):
        return set(re.findall(r"[א-ת]{2,}", s))

    products = parse_catalog()
    checked = 0
    suspects = []
    unverifiable = 0
    for p in products:
        loc = next((t for lbl, t in pages if p["sku"] in t), None)
        if loc is None:
            unverifiable += 1
            continue
        checked += 1
        nw = hwords(p["name"])
        if not nw:
            suspects.append((p["sku"], p["name"], p["category"], 0.0))
            continue
        ratio = len(nw & hwords(loc)) / len(nw)
        if ratio < 0.5:
            suspects.append((p["sku"], p["name"], p["category"], round(ratio, 2)))

    print(f"מוצרים סה\"כ: {len(products)}")
    print(f"ניתנים לאימות מול ה-PDFs: {checked}  "
          f"({checked*100//max(1,len(products))}%)")
    print(f"לא נמצאו במקור (צריך PDF נוסף): {unverifiable}")
    print(f"חשודים (חפיפה <50% למקור): {len(suspects)}\n")
    for sku, nm, cat, r in suspects[:40]:
        print(f"  {sku} (חפיפה {r}) [{cat}]: {nm[:45]}")
    if unverifiable:
        print(f"\n⚠️ {unverifiable} מוצרים לא נבדקו — ספק את ה-PDFs החסרים "
              f"(AQUATEC וכו') לכיסוי מלא.")


def cmd_verify(pdf, *skus):
    import fitz
    doc = fitz.open(pdf)
    want = set(skus)
    for i in range(len(doc)):
        t = doc[i].get_text()
        if any(s in t for s in want):
            png = f"/tmp/verify_p{i+1}.png"
            doc[i].get_pixmap(matrix=fitz.Matrix(2.2, 2.2)).save(png)
            hit = [s for s in want if s in t]
            print(f"page {i+1} → {png}   (skus: {hit})")


# ─── main ────────────────────────────────────────────────────────────────────
def main():
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        return
    cmd, rest = args[0], args[1:]
    if cmd == "audit":
        cmd_audit()
    elif cmd == "export":
        cmd_export(*rest or ["catalog_qa.csv"])
    elif cmd == "pdfmap":
        cmd_pdfmap(*rest)
    elif cmd == "crosscheck":
        cmd_crosscheck(*rest)
    elif cmd == "verify":
        cmd_verify(*rest)
    else:
        print(__doc__)


if __name__ == "__main__":
    main()

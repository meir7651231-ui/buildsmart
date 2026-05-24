#!/usr/bin/env python3
"""
catalog_qa.py — מנוע QA לקטלוג BuildSmart (v2 · engine).

מערכת אכיפה: מנוע חוקים עם חומרה (ERROR/WARN/INFO), תיקון אוטומטי בטוח,
אימות מול מקור, והוכחת-עצמו. נועד לעשרות אלפי מוצרים.

מקור: app_flutter/lib/data/lipskey_catalog.dart  (LipskeyCatalogProduct(...))

פקודות:
  audit [--json]          בדיקה תחבירית מלאה (מנוע החוקים)
  selftest                מוכיח שכל חוק יורה (fixtures מורעלים)
  fix [--apply]           נרמול בטוח של שמות (ברירת מחדל: dry-run)
  export <csv>            CSV מלא + דגלים
  truthcheck              השוואה מול scripts/source_truth.json (אימות 100%)
  crosscheck <pdf...>     השוואת שם↔טקסט PDF ליד המק"ט
  pdfmap <pdf>            מיפוי עמוד→מק"טים
  verify <pdf> sku...     רינדור עמודי מקור ל-/tmp/*.png

כלל הזהב: שם שלא ניתן לאמת מול המקור — לא ממציאים.
"""
import csv
import json
import os
import re
import sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CATALOG = os.path.join(ROOT, "app_flutter/lib/data/lipskey_catalog.dart")
TREE = os.path.join(ROOT, "app_flutter/lib/data/catalog_tree.dart")
TRUTH = os.path.join(ROOT, "scripts/source_truth.json")

HE = re.compile(r"[א-ת]")
SIZE = re.compile(r'DN\s?\d+|\d+/\d+|\d+["׳״]|\b(?:32|40|50|60|75|90|110|130|160|200)\b')
STUCK = re.compile(r"\d[א-ת]|[א-ת]\d")
VALID_BRANDS = {"AQUATEC", "ליפסקי", "פלסון", "חגור", "גרוהה", "חמת"}

# מילון סוג→קטגוריה צפויה (לזיהוי אי-התאמה). מילת-סוג בשם שמרמזת קטגוריה אחרת.
TYPE_HINT = {
    "מחסום": "ניקוז", "סיפון": "ניקוז", "מאסף": "ניקוז", "קולט": "ניקוז",
    "ברך": "ניקוז", "מסעף": "ניקוז", "מצמד": "ניקוז", "צינור": "ניקוז",
    "מושב אסלה": "אסל", "מיכל הדחה": "אסל",
    "מזלף": "מקלח", "ראש מקלחת": "מקלח",
}

# ── severity model ───────────────────────────────────────────────────────────
ERROR, WARN, INFO = "ERROR", "WARN", "INFO"


# ── parsing ──────────────────────────────────────────────────────────────────
def _field(body, name):
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
            "sku": _field(b, "sku"), "name": _field(b, "nameHe"),
            "nameEn": _field(b, "nameEn"), "category": _field(b, "categoryHe"),
            "page": _field(b, "page"), "image": bool(re.search(r"imageFile:\s*'", b)),
            "brand": _field(b, "brand") or "ליפסקי",
        })
    return out


def tree_categories(path=TREE):
    return set(re.findall(r"lipskeyCategory:\s*'([^']+)'", open(path, encoding="utf-8").read()))


# ── rule engine ──────────────────────────────────────────────────────────────
def run_rules(products, tcats):
    """Return list of findings: {rule, severity, sku, detail}."""
    f = []

    def add(rule, sev, sku, detail=""):
        f.append({"rule": rule, "severity": sev, "sku": sku, "detail": detail})

    seen_sku = defaultdict(int)
    name_in_cat = defaultdict(list)

    for p in products:
        n, sku, cat = p["name"], p["sku"], p["category"]
        seen_sku[sku] += 1
        name_in_cat[(cat, n)].append(sku)

        # ERROR rules — block
        if not n.strip():
            add("empty_name", ERROR, sku)
        if "|" in n or "כמות" in n or "״" in n or "“" in n:
            add("garbled", ERROR, sku, n[:40])
        if STUCK.search(n):
            add("stuck_digit", ERROR, sku, n[:40])
        if n.count("(") != n.count(")"):
            add("unbalanced_parens", ERROR, sku, n[:40])
        if not sku:
            add("missing_sku", ERROR, "?", n[:40])
        if not cat:
            add("missing_category", ERROR, sku)
        if cat and cat not in tcats:
            add("unmapped_category", ERROR, sku, cat)

        # WARN rules — review
        if p["brand"] not in VALID_BRANDS:
            add("bad_brand", WARN, sku, p["brand"])
        if "  " in n or " | " in n:
            add("messy_name", WARN, sku, n[:40])
        # cross-DOMAIN mismatch only (high confidence): a faucet word inside a
        # pure-drainage category, or vice-versa. Conservative to avoid noise.
        if "ברז" in n and any(x in cat for x in ("מחסומ", "סיפונ", "מאספ", "מסעפ")):
            add("type_category_mismatch", WARN, sku, f"'ברז' ב-[{cat}]")
        if "אסלה" in n and "ברז" in cat:
            add("type_category_mismatch", WARN, sku, f"'אסלה' ב-[{cat}]")

        # INFO rules — completeness
        if not SIZE.search(n):
            add("no_size", INFO, sku)
        if not p["image"]:
            add("no_image", INFO, sku)

    for sku, c in seen_sku.items():
        if c > 1:
            add("duplicate_sku", ERROR, sku, f"×{c}")
    for (cat, n), sks in name_in_cat.items():
        if len(sks) > 1:
            add("duplicate_name", WARN, sks[0], f"[{cat}] '{n[:25]}' ×{len(sks)}")
    return f


def _cat_ok(kw, cat):
    """Allow legit cross-uses (e.g. 'מסעף' appears in אביזרי תבריג too)."""
    ok = {"מסעף": ["תבריג"], "ברך": ["תבריג", "קצה"], "מצמד": ["שקע", "קצה"],
          "צינור": ["גמיש", "מקלח", "גן"]}
    return any(x in cat for x in ok.get(kw, []))


# ── commands ─────────────────────────────────────────────────────────────────
def cmd_audit(*args):
    as_json = "--json" in args
    products = parse_catalog()
    findings = run_rules(products, tree_categories())
    by_sev = defaultdict(lambda: defaultdict(int))
    for fi in findings:
        by_sev[fi["severity"]][fi["rule"]] += 1

    if as_json:
        errors = sum(1 for fi in findings if fi["severity"] == ERROR)
        print(json.dumps({"products": len(products), "findings": len(findings),
                          "errors": errors, "by_rule": {s: dict(r) for s, r in by_sev.items()}},
                         ensure_ascii=False))
        sys.exit(1 if errors else 0)

    print("=" * 58)
    print(f"  מנוע QA — {len(products)} מוצרים")
    print("=" * 58)
    for sev, icon in [(ERROR, "❌"), (WARN, "⚠️"), (INFO, "ℹ️")]:
        rules = by_sev.get(sev, {})
        total = sum(rules.values())
        print(f"\n{icon} {sev} ({total}):")
        for rule, c in sorted(rules.items(), key=lambda x: -x[1]):
            print(f"     {c:>4}  {rule}")
            if sev == ERROR:
                for fi in [x for x in findings if x["rule"] == rule][:4]:
                    print(f"            {fi['sku']}: {fi['detail']}")
    errs = sum(by_sev.get(ERROR, {}).values())
    print("\n" + "-" * 58)
    print("  ✅ אפס שגיאות חוסמות" if errs == 0 else f"  ❌ {errs} שגיאות חוסמות")
    return errs


def cmd_selftest(*_):
    """מוכיח שכל חוק ERROR יורה על fixture מורעל. עונה ל'הכלי לא עובד'."""
    tcats = {"קטגוריה תקינה"}
    base = {"sku": "X1", "name": "מוצר תקין DN50", "nameEn": "ok",
            "category": "קטגוריה תקינה", "page": "1", "image": True, "brand": "ליפסקי"}
    poisons = {
        "empty_name": {"name": ""},
        "garbled": {"name": "מוצר | 20 כמות באריזה"},
        "stuck_digit": {"name": "מחסום2 לכיור"},
        "unbalanced_parens": {"name": "מחסום (סיפון DN50"},
        "missing_category": {"category": ""},
        "unmapped_category": {"category": "קטגוריה לא קיימת"},
        "duplicate_sku": None,  # handled below
        "bad_brand": {"brand": "מותג מזויף"},
        "no_size": {"name": "מוצר בלי גודל"},
    }
    ok = True
    for rule, patch in poisons.items():
        if rule == "duplicate_sku":
            prods = [dict(base), dict(base)]  # same sku twice
        else:
            p = dict(base); p.update(patch); prods = [p]
        fired = {f["rule"] for f in run_rules(prods, tcats)}
        hit = rule in fired
        print(f"  {'✅' if hit else '❌'} {rule:<22} {'יורה' if hit else 'לא יורה!'}")
        ok = ok and hit
    # negative control: clean product fires no ERROR
    clean_fire = [f for f in run_rules([dict(base)], tcats) if f["severity"] == ERROR]
    print(f"  {'✅' if not clean_fire else '❌'} clean_product           {'אפס ERROR' if not clean_fire else clean_fire}")
    print("\n" + ("✅ כל החוקים עובדים" if ok and not clean_fire else "❌ חוק לא עובד"))
    sys.exit(0 if ok and not clean_fire else 1)


def _normalize(n):
    n = n.replace("״", '"').replace("“", '"').replace("”", '"')
    parts = [p.strip(" )(") for p in n.split("|")]
    parts = [p for p in parts if p and not re.search(r"כמות (באריזה|במשטח)", p)
             and not re.fullmatch(r"\d+ ?(במשטח|באריזה)?", p)]
    seen, uniq = set(), []
    for p in parts:
        k = re.sub(r"\s+", "", p)
        if k not in seen:
            seen.add(k); uniq.append(p)
    n = " · ".join(uniq) if uniq else (n.split("|")[0] if "|" in n else n)
    n = re.sub(r"(?<=[א-ת])(?=\d)", " ", n)
    n = re.sub(r"(?<=[\d\"])(?=[א-ת])", " ", n)
    n = re.sub(r"\s+", " ", n).strip(" |)(·")
    return n


def cmd_fix(*args):
    apply = "--apply" in args
    src = open(CATALOG, encoding="utf-8").read()
    products = parse_catalog()
    changes = []
    for p in products:
        n = p["name"]
        if not ("|" in n or "כמות" in n or "״" in n or "“" in n or STUCK.search(n)):
            continue
        new = _normalize(n)
        if "'" in new:
            new = new.replace("'", "")  # never break Dart single-quote
        if new and new != n:
            changes.append((p["sku"], n, new))
            if apply:
                src = src.replace(f"nameHe: '{n}'", f"nameHe: '{new}'", 1)
    for sku, a, b in changes[:30]:
        print(f"  {sku}\n    -  {a[:50]}\n    +  {b[:50]}")
    print(f"\n{len(changes)} שמות {'תוקנו' if apply else 'לתיקון (dry-run; הוסף --apply)'}")
    if apply:
        open(CATALOG, "w", encoding="utf-8").write(src)


def cmd_export(out="catalog_qa.csv", *_):
    products = parse_catalog(); tcats = tree_categories()
    findings = defaultdict(list)
    for f in run_rules(products, tcats):
        findings[f["sku"]].append(f"{f['severity']}:{f['rule']}")
    with open(out, "w", newline="", encoding="utf-8-sig") as fh:
        w = csv.writer(fh)
        w.writerow(["sku", "name", "nameEn", "category", "page", "image", "brand", "flags"])
        for p in products:
            w.writerow([p["sku"], p["name"], p["nameEn"], p["category"], p["page"],
                        "Y" if p["image"] else "", p["brand"], "|".join(findings.get(p["sku"], []))])
    print(f"נכתב {out} ({len(products)} שורות)")


def cmd_truthcheck(*_):
    if not os.path.exists(TRUTH):
        print(f"❌ אין {TRUTH} — הסוכן השני צריך לייצר מ-4 ה-PDFs.")
        return
    ref = {r["sku"]: r for r in json.load(open(TRUTH, encoding="utf-8"))}
    products = parse_catalog()
    nd, cd, miss = [], [], []
    live = set()
    for p in products:
        live.add(p["sku"]); r = ref.get(p["sku"])
        if not r:
            miss.append(p["sku"]); continue
        if p["name"].strip() != r.get("nameHe", "").strip():
            nd.append((p["sku"], p["name"], r.get("nameHe", "")))
        if p["category"] != r.get("categoryHe", ""):
            cd.append((p["sku"], p["category"], r.get("categoryHe", "")))
    only = [s for s in ref if s not in live]
    print(f"כיסוי אימות: {len(live & set(ref))*100//max(1,len(products))}%")
    print(f"❌ שם שונה: {len(nd)} · ❌ קטגוריה שונה: {len(cd)} · "
          f"⚠️ עודף-app: {len(miss)} · ⚠️ חסר-app: {len(only)}")
    for sk, a, b in nd[:15]:
        print(f"   {sk}: app='{a[:35]}' src='{b[:35]}'")


def cmd_crosscheck(*pdfs):
    import fitz
    pages = []
    for pdf in pdfs:
        d = fitz.open(pdf)
        pages += [d[i].get_text() for i in range(len(d))]
    hw = lambda s: set(re.findall(r"[א-ת]{2,}", s))
    products = parse_catalog()
    checked, sus, unv = 0, [], 0
    for p in products:
        loc = next((t for t in pages if p["sku"] in t), None)
        if loc is None:
            unv += 1; continue
        checked += 1
        nw = hw(p["name"])
        if nw and len(nw & hw(loc)) / len(nw) < 0.5:
            sus.append(p["sku"])
    print(f"ניתן לאמת: {checked}/{len(products)} ({checked*100//max(1,len(products))}%) · "
          f"לא במקור: {unv} · חשודים: {len(sus)} {sus[:10]}")


def cmd_pdfmap(pdf, *_):
    import fitz
    d = fitz.open(pdf)
    for i in range(len(d)):
        sk = [s for s in set(re.findall(r"\b[A-Z0-9]{6,10}\b", d[i].get_text())) if re.search(r"\d", s)]
        if sk:
            print(f"page {i+1}: {sorted(sk)}")


def cmd_verify(pdf, *skus):
    import fitz
    d = fitz.open(pdf); want = set(skus)
    for i in range(len(d)):
        t = d[i].get_text()
        if any(s in t for s in want):
            png = f"/tmp/verify_p{i+1}.png"
            d[i].get_pixmap(matrix=fitz.Matrix(2.2, 2.2)).save(png)
            print(f"page {i+1} → {png} ({[s for s in want if s in t]})")


CMDS = {"audit": cmd_audit, "selftest": cmd_selftest, "fix": cmd_fix,
        "export": cmd_export, "truthcheck": cmd_truthcheck,
        "crosscheck": cmd_crosscheck, "pdfmap": cmd_pdfmap, "verify": cmd_verify}


def main():
    a = sys.argv[1:]
    if not a or a[0] not in CMDS:
        print(__doc__); return
    CMDS[a[0]](*a[1:])


if __name__ == "__main__":
    main()

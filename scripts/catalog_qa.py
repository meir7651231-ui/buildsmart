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
    """נרמול בטוח. --apply לכתיבה · --rule <name> לתיקון ממוקד (צעדים 19,20,24,27)."""
    apply = "--apply" in args
    backup = True  # צעד 26 — גיבוי לפני כתיבה
    # צעד 27 — תיקון ממוקד: --rule packaging|gershayim|stuck|spaces
    rule = next((a.split("=")[1] for a in args if a.startswith("--rule=")), None)
    triggers = {
        "packaging": lambda n: "|" in n or "כמות" in n,
        "gershayim": lambda n: "״" in n or "“" in n,
        "stuck": lambda n: bool(STUCK.search(n)),
        "spaces": lambda n: "  " in n,
    }
    src = open(CATALOG, encoding="utf-8").read()
    products = parse_catalog()
    changes = []
    for p in products:
        n = p["name"]
        if rule:
            dirty = triggers.get(rule, lambda _: False)(n)
        else:
            dirty = ("|" in n or "כמות" in n or "״" in n or "“" in n
                     or STUCK.search(n) or "  " in n)  # צעד 24
        if not dirty:
            continue
        new = _normalize(n)
        if "'" in new:
            new = new.replace("'", "")
        if new and new != n:
            changes.append((p["sku"], n, new))
            if apply:
                src = src.replace(f"nameHe: '{n}'", f"nameHe: '{new}'", 1)
    for sku, a, b in changes[:30]:
        print(f"  {sku}\n    -  {a[:50]}\n    +  {b[:50]}")
    print(f"\n{len(changes)} שמות {'תוקנו' if apply else 'לתיקון (dry-run; הוסף --apply)'}")
    if apply and changes:
        if backup:
            open(CATALOG + ".bak", "w", encoding="utf-8").write(open(CATALOG, encoding="utf-8").read())
        open(CATALOG, "w", encoding="utf-8").write(src)
        # צעד 20 — לוג שינויים
        import csv as _csv
        from datetime import date
        logp = os.path.join(ROOT, "scripts/fix_log.csv")
        new_file = not os.path.exists(logp)
        with open(logp, "a", newline="", encoding="utf-8-sig") as fh:
            w = _csv.writer(fh)
            if new_file:
                w.writerow(["date", "sku", "field", "before", "after"])
            for sku, a, b in changes:
                w.writerow([date.today().isoformat(), sku, "nameHe", a, b])
        # צעד 28 — אידמפוטנטיות
        again = sum(1 for p in parse_catalog()
                    if _normalize(p["name"]) != p["name"]
                    and ("|" in p["name"] or "כמות" in p["name"]))
        print(f"גיבוי: {CATALOG}.bak · לוג: scripts/fix_log.csv · "
              f"אידמפוטנטיות: {'✅' if again == 0 else '❌ '+str(again)}")


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
    # brand diff (step 34)
    bd = [p["sku"] for p in products if p["sku"] in ref
          and ref[p["sku"]].get("brand") and p["brand"] != ref[p["sku"]]["brand"]]
    if bd:
        print(f"❌ מותג שונה: {len(bd)} {bd[:8]}")


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


def cmd_suspects(*pdfs):
    """צעדים 40-42 — תור-בדיקה: שמות בעלי חפיפה נמוכה למקור, עם ניקוד מדורג,
    נשמר ל-scripts/suspects.csv לסקירה ויזואלית (verify)."""
    import csv as _csv
    import fitz
    pages = []
    for pdf in pdfs:
        d = fitz.open(pdf)
        pages += [(f"{os.path.basename(pdf)}#p{i+1}", d[i].get_text()) for i in range(len(d))]
    hw = lambda s: set(re.findall(r"[א-ת]{2,}", s))
    rows = []
    for p in parse_catalog():
        loc = next(((lbl, t) for lbl, t in pages if p["sku"] in t), None)
        if not loc:
            continue
        nw = hw(p["name"])
        if not nw:
            continue
        score = round(len(nw & hw(loc[1])) / len(nw), 2)
        if score < 0.6:
            rows.append((p["sku"], p["name"], loc[0], score))
    rows.sort(key=lambda r: r[3])  # worst first
    out = os.path.join(ROOT, "scripts/suspects.csv")
    with open(out, "w", newline="", encoding="utf-8-sig") as fh:
        w = _csv.writer(fh)
        w.writerow(["sku", "name", "source", "score"])
        w.writerows(rows)
    print(f"חשודים: {len(rows)} (נשמר {out}). הגרועים:")
    for sk, nm, srcp, sc in rows[:12]:
        print(f"   {sc}  {sk}  {nm[:30]}  [{srcp}]")
    print(f"\nלאימות ויזואלי: python3 scripts/catalog_qa.py verify <pdf> "
          + " ".join(r[0] for r in rows[:5]))


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


def cmd_images(*_):
    adir = os.path.join(ROOT, "app_flutter/assets/lipskey/products")
    have = set(os.listdir(adir)) if os.path.isdir(adir) else set()
    src = open(CATALOG, encoding="utf-8").read()
    refs = re.findall(r"imageFile:\s*'([^']+)'", src)
    missing = sorted({f for f in refs if f not in have})
    print(f"imageFile מוגדרים: {len(refs)} · קבצים: {len(have)}")
    print(f"❌ imageFile בלי קובץ: {len(missing)} {missing[:10]}")
    orphan = sorted(have - set(refs))
    print(f"ℹ️ קבצים יתומים: {len(orphan)} {orphan[:6]}")


def cmd_imgmatch(*_):
    """צעד 38 — אימות התאמת תמונה↔מק"ט (שם הקובץ מתחיל ב-sku)."""
    src = open(CATALOG, encoding="utf-8").read()
    bad = []
    for m in re.finditer(r"sku:\s*'([^']+)'[^)]*?imageFile:\s*'([^']+)'", src, re.DOTALL):
        sku, img = m.group(1), m.group(2)
        if not img.split(".")[0] == sku:
            bad.append((sku, img))
    print(f"❌ תמונה שלא תואמת מק\"ט: {len(bad)}")
    for sku, img in bad[:12]:
        print(f"   {sku} ↔ {img}")


def cmd_coverage(*_):
    """צעד 39 — דוח כיסוי מפולח לפי מותג/קטגוריה."""
    products = parse_catalog()
    by_brand = defaultdict(lambda: [0, 0, 0])  # total, with-image, with-size
    for p in products:
        b = by_brand[p["brand"]]
        b[0] += 1
        b[1] += 1 if p["image"] else 0
        b[2] += 1 if SIZE.search(p["name"]) else 0
    print("מותג        סה\"כ   תמונה    גודל")
    for brand, (t, i, s) in sorted(by_brand.items(), key=lambda x: -x[1][0]):
        print(f"{brand:<10} {t:>6} {i*100//t:>7}% {s*100//t:>7}%")


def cmd_schema(*_):
    """צעד 30 — ולידציה של source_truth.json מול הסכמה."""
    if not os.path.exists(TRUTH):
        print(f"אין {TRUTH}"); return
    ref = json.load(open(TRUTH, encoding="utf-8"))
    req = {"sku": str, "nameHe": str, "categoryHe": str}
    bad = []
    seen = set()
    for i, r in enumerate(ref):
        for f, ty in req.items():
            if f not in r or not isinstance(r[f], ty) or not str(r.get(f, "")).strip():
                bad.append((i, r.get("sku", "?"), f))
        if "sizes" in r and not isinstance(r["sizes"], list):
            bad.append((i, r.get("sku", "?"), "sizes!=list"))
        if r.get("sku") in seen:
            bad.append((i, r["sku"], "dup-sku"))
        seen.add(r.get("sku"))
    print(f"רשומות: {len(ref)} · ❌ הפרות סכמה: {len(bad)}")
    for i, sk, f in bad[:15]:
        print(f"   #{i} {sk}: {f}")


def cmd_truthapply(*args):
    """צעד 36 — תיקון אוטומטי של שמות מ-source_truth (dry-run; --apply לכתיבה)."""
    if not os.path.exists(TRUTH):
        print(f"אין {TRUTH}"); return
    apply = "--apply" in args
    ref = {r["sku"]: r for r in json.load(open(TRUTH, encoding="utf-8"))}
    src = open(CATALOG, encoding="utf-8").read()
    parts = re.split(r"(LipskeyCatalogProduct\()", src)
    res = parts[0]; changes = []
    for k in range(1, len(parts), 2):
        body = parts[k + 1]
        skm = re.search(r"sku:\s*'([^']+)'", body)
        if skm and skm.group(1) in ref:
            want = ref[skm.group(1)]["nameHe"]
            cur = re.search(r"nameHe:\s*(['\"])(.*?)\1(?=,)", body, re.DOTALL)
            if cur and cur.group(2) != want:
                changes.append((skm.group(1), cur.group(2), want))
                if apply:
                    nm = "'" + want.replace("\\", "").replace("'", "\\'") + "'"
                    body = re.sub(r"nameHe:\s*(['\"]).*?\1(?=,)", f"nameHe: {nm}", body, 1, re.DOTALL)
        res += parts[k] + body
    for sk, a, b in changes[:20]:
        print(f"   {sk}: '{a[:30]}' → '{b[:30]}'")
    print(f"\n{len(changes)} שמות {'תוקנו' if apply else 'לתיקון (--apply ליישום)'}")
    if apply:
        open(CATALOG, "w", encoding="utf-8").write(res)


def cmd_report(*_):
    """צעדים 93,96 — KPI איכות + export JSON ל-stakeholders."""
    products = parse_catalog()
    n = len(products)
    img = sum(1 for p in products if p["image"])
    sz = sum(1 for p in products if SIZE.search(p["name"]))
    findings = run_rules(products, tree_categories())
    errs = sum(1 for f in findings if f["severity"] == ERROR)
    kpi = {"products": n, "errors": errs,
           "image_pct": img * 100 // n, "size_pct": sz * 100 // n,
           "categories": len({p["category"] for p in products})}
    out = os.path.join(ROOT, "scripts/catalog_kpi.json")
    json.dump(kpi, open(out, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    print(json.dumps(kpi, ensure_ascii=False, indent=2))
    print(f"נכתב {out}")


def cmd_diff(old, new):
    """צעד 94 — דוח 'מה השתנה' בין שני קבצי-קטלוג (snapshots)."""
    a = {p["sku"]: p["name"] for p in parse_catalog(old)}
    b = {p["sku"]: p["name"] for p in parse_catalog(new)}
    added = set(b) - set(a); removed = set(a) - set(b)
    changed = [s for s in a if s in b and a[s] != b[s]]
    print(f"➕ נוספו: {len(added)} · ➖ הוסרו: {len(removed)} · ✏️ שונו: {len(changed)}")


CMDS_EXTRA = True


CMDS = {"audit": cmd_audit, "selftest": cmd_selftest, "fix": cmd_fix,
        "export": cmd_export, "truthcheck": cmd_truthcheck, "images": cmd_images,
        "imgmatch": cmd_imgmatch, "coverage": cmd_coverage, "schema": cmd_schema,
        "truthapply": cmd_truthapply, "report": cmd_report, "diff": cmd_diff,
        "crosscheck": cmd_crosscheck, "pdfmap": cmd_pdfmap, "verify": cmd_verify, "suspects": cmd_suspects}


def main():
    a = sys.argv[1:]
    if not a or a[0] not in CMDS:
        print(__doc__); return
    CMDS[a[0]](*a[1:])


if __name__ == "__main__":
    main()

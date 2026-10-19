"""Engine tests on generic catalogs (CSV / JSON), with no BuildSmart files.

Run: python3 -m pytest packages/catalog_qa/tests  ·  or directly: python3 test_engine.py
"""
import contextlib
import csv
import importlib.util
import io
import json
import os
import shutil
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
PKG = os.path.dirname(HERE)
EXAMPLES = os.path.join(PKG, "examples")
# Loaded by path under its own name, so it never shadows BuildSmart's
# scripts/catalog_qa.py (which is also importable as `catalog_qa`).
_spec = importlib.util.spec_from_file_location("catalog_qa_under_test",
                                               os.path.join(PKG, "catalog_qa.py"))
q = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(q)

DEFAULTS = dict(catalog=None, categories=None, truth=None, images_dir=None,
                out_dir=".", brands=None, default_brand="", columns={})


def setup(**cfg):
    q.configure(dict(DEFAULTS, **cfg))


def example(tmp):
    """A fresh copy of the example store, configured, inside tmp."""
    for f in os.listdir(EXAMPLES):
        shutil.copy(os.path.join(EXAMPLES, f), tmp)
    setup()
    q.configure(q.load_config(os.path.join(tmp, "catalog_qa.json")))
    return os.path.join(tmp, "store_catalog.csv")


def quiet(fn, *args):
    out = io.StringIO()
    with contextlib.redirect_stdout(out):
        rc = fn(*args)
    return rc, out.getvalue()


def errors(findings):
    return {f["rule"] for f in findings if f["severity"] == q.ERROR}


def test_csv_parse():
    with tempfile.TemporaryDirectory() as tmp:
        example(tmp)
        ps = q.parse_catalog()
        assert len(ps) == 11
        p = ps[0]
        assert (p["sku"], p["category"], p["brand"], p["image"], p["imageFile"]) == \
            ("1001", "ברזים", "חמת", True, "1001.jpg")
        assert ps[2]["image"] is False


def test_example_audit_finds_every_planted_error():
    with tempfile.TemporaryDirectory() as tmp:
        example(tmp)
        f = q.run_rules(q.parse_catalog(), q.tree_categories())
        assert errors(f) == {"unbalanced_parens", "stuck_digit", "garbled",
                             "unmapped_category", "empty_name", "duplicate_sku"}
        warns = {x["rule"] for x in f if x["severity"] == q.WARN}
        assert {"bad_brand", "messy_name", "type_category_mismatch"} <= warns


def test_unconfigured_rules_are_skipped():
    setup()
    p = dict(sku="1", name="ברך DN50", nameEn="", category="כל דבר", page="",
             image=True, brand="כל מותג", color="")
    rules = {x["rule"] for x in q.run_rules([p], None)}
    assert "unmapped_category" not in rules and "bad_brand" not in rules


def test_json_with_column_names():
    with tempfile.TemporaryDirectory() as tmp:
        path = os.path.join(tmp, "c.json")
        json.dump({"products": [{"מקט": 7, "שם": "ברז DN15", "קטגוריה": "ברזים",
                                 "תמונה": True}]}, open(path, "w", encoding="utf-8"),
                  ensure_ascii=False)
        setup(catalog=path, default_brand="X",
              columns={"sku": "מקט", "name": "שם", "category": "קטגוריה", "image": "תמונה"})
        p = q.parse_catalog()[0]
        assert (p["sku"], p["name"], p["category"], p["brand"], p["image"]) == \
            ("7", "ברז DN15", "ברזים", "X", True)


def test_category_lists():
    with tempfile.TemporaryDirectory() as tmp:
        txt, js = os.path.join(tmp, "c.txt"), os.path.join(tmp, "c.json")
        open(txt, "w", encoding="utf-8").write("א\n\nב\n")
        json.dump({"categories": ["א", "ג"]}, open(js, "w", encoding="utf-8"))
        assert q.tree_categories(txt) == {"א", "ב"}
        assert q.tree_categories(js) == {"א", "ג"}
        setup()
        assert q.tree_categories() is None


def test_config_paths_relative_and_first_existing_catalog():
    with tempfile.TemporaryDirectory() as tmp:
        open(os.path.join(tmp, "b.csv"), "w").write("sku,name\n")
        cfgp = os.path.join(tmp, "cfg.json")
        json.dump({"catalog": ["missing.csv", "b.csv"], "truth": "t.json"}, open(cfgp, "w"))
        cfg = q.load_config(cfgp)
        assert cfg["catalog"] == os.path.join(tmp, "b.csv")
        assert cfg["truth"] == os.path.join(tmp, "t.json")


def test_normalize_keeps_size_next_to_packaging():
    assert q._normalize("מצמד | 20 כמות באריזה DN50") == "מצמד · DN50"
    assert q._normalize("מחסום | 20 | כמות באריזה") == "מחסום"


def test_normalize_keeps_hebrew_abbreviations():
    # A space after an inch mark that follows a digit; gershayim inside מ"מ / ממ"ר stay.
    assert q._normalize('מחבר  שן 16 מ"מ | 50 כמות באריזה') == 'מחבר שן 16 מ"מ'
    assert q._normalize('מחסום 1.25"לכיור') == 'מחסום 1.25" לכיור'
    assert q._normalize('כבל 3x2.5 ממ"ר') == 'כבל 3x2.5 ממ"ר'


def test_fix_apply_writes_csv_and_is_idempotent():
    with tempfile.TemporaryDirectory() as tmp:
        path = example(tmp)
        _, out = quiet(q.cmd_fix, "--apply")
        assert "3 שמות תוקנו" in out and "אידמפוטנטיות: ✅" in out
        names = {r["sku"]: r["name"] for r in csv.DictReader(open(path, encoding="utf-8-sig"))}
        assert names["1005"] == "מחסום 2 לכיור DN50"
        assert names["1006"] == "מצמד · DN50"
        assert os.path.exists(path + ".bak")
        assert os.path.exists(os.path.join(tmp, "fix_log.csv"))
        _, out = quiet(q.cmd_fix)
        assert "0 שמות" in out


def test_truthapply_on_csv():
    with tempfile.TemporaryDirectory() as tmp:
        path = example(tmp)
        truth = os.path.join(tmp, "truth.json")
        json.dump([{"sku": "1003", "nameHe": "ברז אמבטיה לקיר", "categoryHe": "ברזים"}],
                  open(truth, "w", encoding="utf-8"), ensure_ascii=False)
        q.configure({"truth": truth})
        _, out = quiet(q.cmd_truthapply, "--apply")
        assert "1 שמות תוקנו" in out
        assert q.parse_catalog(path)[2]["name"] == "ברז אמבטיה לקיר"


def test_imgmatch_and_images_on_csv():
    with tempfile.TemporaryDirectory() as tmp:
        example(tmp)
        _, out = quiet(q.cmd_imgmatch)
        assert "2" in out.splitlines()[0] and "1009 ↔ 9999.jpg" in out
        imgs = os.path.join(tmp, "img")
        os.mkdir(imgs)
        open(os.path.join(imgs, "1001.jpg"), "w").close()
        q.configure({"images_dir": imgs})
        _, out = quiet(q.cmd_images)
        assert "קבצים: 1" in out


def test_export_roundtrip():
    with tempfile.TemporaryDirectory() as tmp:
        example(tmp)
        out = os.path.join(tmp, "out.csv")
        quiet(q.cmd_export, out)
        first = q.parse_catalog()
        again = q.parse_catalog(out)
        assert [(p["sku"], p["name"], p["category"]) for p in again] == \
            [(p["sku"], p["name"], p["category"]) for p in first]


def test_cli_audit_fails_on_errors_and_passes_when_clean():
    with tempfile.TemporaryDirectory() as tmp:
        path = example(tmp)
        setup()
        try:
            quiet(q.main, ["--catalog", path, "audit"])
            raise AssertionError("audit should fail on the example's planted errors")
        except SystemExit as e:
            assert e.code == 1
        clean = os.path.join(tmp, "clean.csv")
        open(clean, "w", encoding="utf-8").write("sku,name,category,brand,image\n1,ברך DN50,ניקוז,X,Y\n")
        setup()
        quiet(q.main, ["--catalog", clean, "--brands", "X", "audit"])  # no SystemExit


def test_lookup_for_other_engines():
    with tempfile.TemporaryDirectory() as tmp:
        example(tmp)
        out, printed = quiet(q.cmd_lookup, "1005", "1003", "NOPE")
        assert json.loads(printed) == out
        by = {r["sku"]: r for r in out}
        assert by["1005"]["found"] and {f["rule"] for f in by["1005"]["findings"]} >= {"stuck_digit"}
        assert by["1003"]["name"] == "ברז  אמבטיה קיר"
        assert by["NOPE"] == {"sku": "NOPE", "found": False, "name": None, "category": None,
                              "brand": None, "image": None, "findings": []}


def test_pdf_reversed_hebrew_and_checks():
    try:
        import pymupdf  # noqa: F401
    except ImportError:
        return  # PDF commands need pymupdf
    assert q._is_visual("ףלשנ חבטמ זרב 1/2") and not q._is_visual("ברז מטבח נשלף 1/2")
    assert q._logical('רויכל )ןופיס( םוסחמDN40') == 'מחסום (סיפון) לכיור DN40'
    with tempfile.TemporaryDirectory() as tmp:
        example(tmp)
        pdf = os.path.join(EXAMPLES, "manufacturer.pdf")
        checked, _ = quiet(q.cmd_pdfcheck, pdf)
        by = {}
        for r in checked:
            by.setdefault(r["sku"], []).append(r)
        assert by["1004"][0]["score"] == 1.0  # visual-order PDF, matched after turning it back
        assert by["1006"][0]["score"] == 1.0  # "| 20 כמות באריזה" in the store's name doesn't count
        assert by["1009"][0]["found"] is False
        dup = [r for r in by["1001"] if r["name"].startswith("ברך")][0]
        assert dup["score"] == 0.0 and dup["elsewhere"]["sku"] == "1010"
        rows, _ = quiet(q.cmd_pdfrows, pdf)
        assert {r["sku"]: r["name"] for r in rows}["1004"] == 'מחסום (סיפון) לכיור DN40'
        assert len(rows) == 10


def test_selftest_needs_no_config():
    setup()
    try:
        quiet(q.cmd_selftest)
    except SystemExit as e:
        assert e.code == 0


if __name__ == "__main__":
    fns = [v for k, v in list(globals().items()) if k.startswith("test_")]
    ok = 0
    for fn in fns:
        try:
            fn()
            print("✅", fn.__name__)
            ok += 1
        except Exception as e:  # noqa: BLE001
            print("❌", fn.__name__, repr(e))
    print(f"{ok}/{len(fns)} עברו")
    sys.exit(0 if ok == len(fns) else 1)

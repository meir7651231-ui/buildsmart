"""צעד 98 — בדיקות-יחידה ל-catalog_qa.py (pytest או הרצה ישירה)."""
import catalog_qa as q

def test_parse_nonempty():
    assert len(q.parse_catalog()) > 700

def test_no_hard_errors():
    f = q.run_rules(q.parse_catalog(), q.tree_categories())
    assert [x for x in f if x['severity']==q.ERROR] == []

def test_normalize_strips_packaging():
    assert 'כמות' not in q._normalize('מחסום | 20 כמות באריזה')

def test_normalize_no_word_break():
    assert 'מחסום' in q._normalize('1.5מחסום')

def test_dup_name_differentiator_by_color():
    # שני מוצרים עם שם זהה אך גוון שונה → מסומן כבר-בידול, לא ככפילות-בעיה
    base = dict(sku='', name='ברז לבן', nameEn='', category='ברזים',
                page='1', image=True, brand='ליפסקי', color='')
    a = dict(base, sku='A', color='לבן'); b = dict(base, sku='B', color='שחור')
    rules = {x['rule'] for x in q.run_rules([a, b], {'ברזים'})}
    assert 'dup_name_differentiator' in rules
    assert 'dup_name_unresolved' not in rules

def test_dup_name_unresolved_when_identical():
    base = dict(sku='', name='ברז זהה', nameEn='', category='ברזים',
                page='1', image=True, brand='ליפסקי', color='לבן')
    a = dict(base, sku='A'); b = dict(base, sku='B')
    rules = {x['rule'] for x in q.run_rules([a, b], {'ברזים'})}
    assert 'dup_name_unresolved' in rules

# ── צעד 89 — צינור-ייבוא-אצווה ────────────────────────────────────────────────
import catalog_import as imp

def test_import_strips_packaging():
    assert imp.normalize_name('מחסום | 20 כמות באריזה') == 'מחסום'

def test_import_dart_escapes_apostrophe():
    # גרש בודד חייב לברוח כדי לא לשבור קומפילציית Dart
    assert imp.dart_str("ג'קוזי") == r"'ג\'קוזי'"

def test_import_digit_letter_boundary():
    assert imp.normalize_name('1.5מחסום') == '1.5 מחסום'

def test_import_validate_catches_dup_and_missing():
    rows = [dict(sku='1', nameHe='a'), dict(sku='1', nameHe='b'),
            dict(sku='', nameHe='c')]
    errs = imp.validate(rows)
    assert any('כפול' in e for e in errs) and any('חסר' in e for e in errs)

if __name__ == '__main__':
    import sys
    fns=[v for k,v in globals().items() if k.startswith('test_')]
    ok=0
    for fn in fns:
        try: fn(); print('✅',fn.__name__); ok+=1
        except AssertionError: print('❌',fn.__name__)
    print(f'{ok}/{len(fns)} עברו'); sys.exit(0 if ok==len(fns) else 1)

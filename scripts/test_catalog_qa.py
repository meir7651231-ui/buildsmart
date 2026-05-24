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

if __name__ == '__main__':
    import sys
    fns=[v for k,v in globals().items() if k.startswith('test_')]
    ok=0
    for fn in fns:
        try: fn(); print('✅',fn.__name__); ok+=1
        except AssertionError: print('❌',fn.__name__)
    print(f'{ok}/{len(fns)} עברו'); sys.exit(0 if ok==len(fns) else 1)

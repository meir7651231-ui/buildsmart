# -*- coding: utf-8 -*-
"""מנוע טהור — כל אות מ*קונסטרוקציה הנדסית* (מהשרטוטים). אפס נתונים, אפס fit."""
import math, json, re

SDR = {20: 6.0, 16: 7.4, 10: 11.0}
# עומק-שקע = טבלת הריתוך (DIN 8077) — ידע הנדסי, לא נתוני-קטלוג
DEPTH = {20: 14.5, 25: 16.0, 32: 18.0, 40: 20.5, 50: 23.5, 63: 27.5,
         75: 30.0, 90: 33.0, 110: 37.0, 125: 40.0}

# ===== הקונסטרוקציה האוניברסלית (כל אביזר-ריתוך) =====
def base(od, pn=20):
    wall = od / SDR[pn]
    return {
        'OD': od,
        'wall': round(wall, 1),
        'ID': round(od - 2*wall, 1),          # קדח-זרימה = צינור מבפנים
        'B': round(od * (1 + 2/6), 1),        # קוטר-חוץ = צינור + דופן שקע (PN20)
        'C': round(od * 0.97, 1),             # קדח-שקע ≈ OD (הצינור נכנס)
        'F': DEPTH.get(od),                    # עומק-שקע (ריתוך)
    }

# ===== צורה פר-משפחה — z (מרכז-לפָּנים) מהגיאומטריה =====
def coupler(od):
    b = base(od); F = b['F']
    b['A'] = round(2*F + 2, 1)                 # אורך = 2 שקעים + מעצור מרכז
    return b

def elbow(od, angle=90):
    b = base(od); F = b['F']
    R = 0.52 * od                              # רדיוס-כיפוף (short radius) ≈ 0.52·OD
    z = round(R * math.tan(math.radians(angle/2)), 1)   # z = R·tan(θ/2)  — גיאומטריה
    b['z'] = z
    b['l'] = round(F + z, 1)                    # מרכז-לקצה = עומק + z
    b['D'] = b.pop('B')                          # בברך קוראים לקוטר-החוץ D
    return b

def tee(od):
    b = base(od); F = b['F']
    z = round(b['B']/2, 1)                       # מרכז-לפָּנים ≈ רדיוס-החוץ
    b['E'] = round(2*(z + F), 1)                 # רוחב-הרַץ = 2·(z+עומק)
    b['A'] = round(z + F + b['B']/2, 1)          # גובה-ההסתעפות
    return b

FAM = {'מצמד': coupler, 'ברך 90°': lambda od: elbow(od, 90),
       'ברך 45°': lambda od: elbow(od, 45), 'מסעף (טי)': tee}

if __name__ == '__main__':
    import sys
    print('=== מנוע טהור — כל אות מגיאומטריה ===')
    for fam, od in [('מצמד', 32), ('ברך 90°', 32), ('ברך 45°', 32), ('מסעף (טי)', 50)]:
        g = FAM[fam](od)
        print('  %-9s %g:  %s' % (fam, od, ' · '.join('%s=%g' % (k, v) for k, v in g.items())))

    if len(sys.argv) > 1:
        rows = json.load(open(sys.argv[1], encoding='utf-8'))[1:]
        kp = re.compile(r'(?<![A-Za-z֐-׿])([A-Za-z][0-9]?)\s*:\s*([\d.]+)')
        def dims(o):
            out = {}
            for v in o.values():
                if isinstance(v, str):
                    for m in kp.finditer(v):
                        out.setdefault(m.group(1), float(m.group(2)))
            return out
        # accuracy on COUPLER (all its letters, pure geometry)
        print('\n=== דיוק המנוע הטהור מול הקטלוג (לא ראה אותו) ===')
        for cat, fn, letters, nm in [('מצמדים PPR', coupler, ['B', 'C', 'F', 'A'], 'מצמד'),
                                     ('ברכיים PPR', lambda od: elbow(od, 90), ['D', 'z', 'l'], 'ברך90')]:
            errs = []
            for o in rows:
                if o.get('A') != 'פולירול' or o.get('D') != cat:
                    continue
                if nm == 'ברך90' and '45' in o.get('C', ''):
                    continue
                dm = dims(o); od = dm.get('d')
                if od not in DEPTH:
                    continue
                g = fn(od)
                for L in letters:
                    if L in dm and L in g and g[L] is not None:
                        errs.append(abs(g[L] - dm[L]))
            if errs:
                errs.sort(); n = len(errs)
                print('  %-6s (%s): n=%d | חציון %.2f מ"מ | ≤1מ"מ %.0f%% | ≤2מ"מ %.0f%%' %
                      (nm, ','.join(letters), n, errs[n//2], 100*sum(e <= 1 for e in errs)/n, 100*sum(e <= 2 for e in errs)/n))

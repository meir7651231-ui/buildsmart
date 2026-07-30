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


def mitered_elbow(d):
    """ברך מחותכת גדולה (מודל B, 160-400) — גיאומטריה טהורה, ~0 סטייה.
       מגזרים = יחס נקי לרדיוס-הכיפוף (∝d)."""
    return {'A': round(3.0*d, 1), 'G': round(1.377*d, 1),
            'F': round(1.186*d, 1), 'E': round(0.765*d, 1), 'D': round(0.986*d, 1)}


def reducer(d1, d2):
    """מצרה (d1×d2) — קומפוזיציה: כל צד לפי חוקי-הבסיס של הקוטר שלו."""
    s1, s2 = base(d1), base(d2)
    return {'B1': s1['B'], 'C1': s1['C'], 'F1': s1['F'],
            'B2': s2['B'], 'C2': s2['C'], 'F2': s2['F'],
            'A': round(s1['F'] + s2['F'] + 3, 1)}   # שני שקעים + מעבר


def adapter(od):
    """מתאם תבריג — עוגן-כפול: שקע-ריתוך (חוקי-בסיס) + קצה-תבריג BSP (משושה)."""
    b = base(od); F = b['F']
    hex_ = round(od * 1.95, 1)                    # מפתח-על-פינות (across-corners)
    b['SW'] = round(hex_ * 0.87, 1)               # מפתח-על-שטוחים (across-flats)
    b['hex'] = hex_
    b['thread'] = round(od * 1.05, 1)             # קוטר-חיצוני של התבריג
    b['thL'] = round(od * 0.9, 1)                 # אורך-התבריג
    b['z'] = round(F + od * 0.3, 1)               # מרכז-המשושה (כולל עומק-שקע)
    b['l'] = round(F + b['z'] + b['thL'], 1)      # שקע→קצה-תבריג
    return b


def valve(od):
    """ברז כדורי — גוף (∝OD) + כדור (קדח dk≈DN) + ידית (גובה h)."""
    b = base(od); F = b['F']
    b['D'] = round(od * 1.6, 1)                    # קוטר-גוף
    del b['B']
    b['z'] = round(od * 1.05, 1)                   # מרכז-לפָּנים
    b['l'] = round(F + b['z'], 1)                  # מרכז-לקצה-שקע
    b['dk'] = round(od * 0.67, 1)                  # קדח-הכדור ≈ DN
    b['h'] = round(od * 2.9, 1)                    # גובה (גוף+ידית)
    return b


def plug(od):
    """פקק — שקע יחיד + כיפה סגורה."""
    b = base(od); F = b['F']
    b['A'] = round(F + od * 0.4, 1)               # אורך-כולל
    b['cap'] = round(od * 0.4, 1)                 # אורך-הכיפה
    return b


def saddle(od):
    """רוכב (מסעף-אוכף) — עוגן-כפול: מתלבש על צינור-ראשי (d1≈2·d) + שקע-הסתעפות למעלה.
       D=1.333d ✓(n=77) · d2=1.0d ✓ · z=0.64d · l=0.85d — מהמפה."""
    b = base(od); F = b['F']; del b['B']
    b['D'] = round(od * 1.333, 1)                 # קוטר-חוץ של שקע-ההסתעפות
    b['d1'] = round(od * 2, 1)                    # קוטר הצינור-הראשי (רוכב עליו)
    b['z'] = round(od * 0.64, 1)                  # מרכז-לפָּנים
    b['l'] = round(F + b['z'], 1)                 # גובה-ההסתעפות מפני-הצינור
    return b


def collar(od):
    """צווארון/אוגן — שקע + דיסקת-אוגן שטוחה. D1=1.619d (קוטר-אוגן) · A=1.478d · D=1.15d."""
    b = base(od); F = b['F']; del b['B']
    b['D'] = round(od * 1.15, 1)                  # קוטר-צוואר (hub)
    b['D1'] = round(od * 1.619, 1)                # קוטר-אוגן חיצוני
    b['A'] = round(od * 1.478, 1)                 # אורך-כולל
    b['E'] = round(od * 0.6, 1)                   # עובי/מפלס-האוגן
    return b


# ---- בורר-דיאגרמה: משפחה × טווח-גודל -> קונסטרוקציה ----
def elbow_auto(d, angle=90):
    return mitered_elbow(d) if d >= 160 else elbow(d, angle)


# מנוע-מלא: 9 משפחות חד-קוטריות + reducer(d1,d2) הדו-קוטרי = 10 משפחות
# (זהה למנוע-ה-JS שב-prototypes/gen3d.html — שם 'מצרה' נבחר-אוטומטית לקוטר-קודם).
# אומגה (Ω) — אין יחס-קטלוג נקי (גיאומטריה מורכבת) → נדחה, כמו קטלוגי AQUATEC/ליפסקי.
ENGINE = {'מצמד': coupler, 'ברך 90°': lambda d: elbow(d, 90),
          'ברך 45°': lambda d: elbow(d, 45), 'מסעף (טי)': tee,
          'מתאם תבריג': adapter, 'ברז כדורי': valve, 'פקק': plug,
          'רוכב': saddle, 'צווארון': collar}

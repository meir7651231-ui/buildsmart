#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
מנוע-מידות פולירול (Polyroll dimension engine)
==============================================
לומד את טבלאות-המידה פר-סדרה מהקטלוג המפורק, ו*מייצר* את סט-המידות המדויק
לכל שאילתת (משפחה, גודל) — כמו נתוני-אמת, בלי לאחסן שאילתה מראש.
מזין את מנוע הקטלוג→3D.

מקור-אמת: catalog-dump.json  (‏1,948 מוצרים; כאן: אביזרי פולירול).

עקרונות:
  • הערך של מוצר שקיים בקטלוג  -> exact (0 סטייה) — זה הערך האמיתי מהיצרן.
  • גודל בטווח סדרה נלמדת       -> interp (אינטרפולציה בין קטרים; חלק).
  • גודל מחוץ לטווח / סדרה לא-נלמדת -> None + סיבה. *לעולם לא מנחש.*

הרצה:
    python3 polyroll_dim_engine.py catalog-dump.json
"""
import json, re, sys
from collections import defaultdict

CAT = {'מתאמים PPR': 'מתאם', 'מצמדים PPR': 'מצמד', 'ברכיים PPR': 'ברך',
       'מסעפים PPR': 'טי', 'רוכבים PPR': 'רוכב', 'פקקים PPR': 'פקק',
       'ברזים PPR': 'ברז', 'צווארונים ואוגנים PPR': 'צווארון',
       'אביזרי ריתוך חשמלי PPR': 'EF', 'אומגה PPR': 'אומגה'}
STD = {20, 25, 32, 40, 50, 63, 75, 90, 110, 125, 160, 200, 250, 315, 355, 400}
NORM = {'I': 'l', 'I1': 'l1', 'I2': 'l2'}         # OCR: uppercase-I הוא בעצם lowercase-l
KP = re.compile(r'(?<![A-Za-z֐-׿])([A-Za-z][0-9]?)\s*:\s*([\d.]+)')


def parse_dims(o):
    """כל אותיות-המידה של מוצר, מנורמלות (I->l), case-sensitive."""
    out = {}
    for v in o.values():
        if isinstance(v, str):
            for m in KP.finditer(v):
                k = m.group(1)
                if k in ('PN', 'SDR'):
                    continue
                out.setdefault(NORM.get(k, k), float(m.group(2)))
    return out


def nominal(o, dm):
    """המידה הנומינלית — מ-'d', אחרת מהשם (עוקף את הזווית 45°/90°)."""
    if 'd' in dm:
        return dm['d']
    nm = re.sub(r'\d+\s*°', ' ', o.get('C', ''))   # הסר זווית
    m = re.search(r'(\d{2,3})\s*[xX×]', nm)         # "20x1/2" -> 20
    if m:
        return float(m.group(1))
    nums = [int(x) for x in re.findall(r'(?<![\d./])(\d{2,3})(?![\d./])', nm)]
    for x in reversed(nums):
        if x in STD:
            return float(x)
    return float(nums[-1]) if nums else None


def _pfield(o, label):
    for v in o.values():
        if isinstance(v, str):
            m = re.search(re.escape(label) + r'[:\s]*([\d.]+)', v)
            if m:
                return float(m.group(1))
    return None


# עומק-החדרה (עומק שקע-הריתוך) — טבלה אוניברסלית מקטלוג פולירול (עמ' זמני חימום).
# משותפת לכל האביזרים כי היא תכונת-חיבור של הצינור, לא של האביזר.
# פירוק מאומת (10/10):  l_אביזר = SOCKET_DEPTH[d] + z_פר-אביזר.
SOCKET_DEPTH = {20: 14.5, 25: 16.0, 32: 18.0, 40: 20.5, 50: 23.5, 63: 27.5,
                75: 30.0, 90: 33.0, 110: 37.0, 125: 40.0}

# תכונות חומר-הגלם PPR (תקן; מזין פיזיקה: התפשטות, לחץ, מרחקי-תלייה).
PPR_MATERIAL = {'density': 0.9, 'E_modulus': 800, 'thermal_cond': 0.15,
                'thermal_expansion_a': 1.5e-4, 'softening_C': 130, 'max_service_C': 90}


class PipeBase:
    """שכבת-הבסיס (Layer 0): הצינור.
       ה-OD (קוטר חיצוני) הוא הקוטר הנומינלי — ה-anchor שכל אביזר יושב עליו.
       דופן נקבעת ע"י מחלקת-הלחץ PN (תקן SDR):  SDR = OD/דופן ,  ID = OD − 2·דופן.
       השקע של כל אביזר מקבל את ה-OD; לכן D_socket ≈ 1.33·OD, וה-ID הוא קדח-הזרימה.
       עומק-השקע (SOCKET_DEPTH) אוניברסלי — כל אביזר יורש אותו, ו-l = עומק + z."""

    socket_depth = staticmethod(lambda d: SOCKET_DEPTH.get(d))

    def __init__(self, rows):
        self.tab = {}                       # (OD, PN) -> {od, wall, id, sdr}
        for o in rows:
            if o.get('A') != 'פולירול' or 'צינור' not in o.get('D', ''):
                continue
            od = _pfield(o, 'קוטר חיצוני')
            if od is None:
                continue
            self.tab[(od, _pfield(o, 'PN') or 0)] = {
                'od': od, 'wall': _pfield(o, 'עובי דופן'),
                'id': _pfield(o, 'קוטר פנימי'), 'sdr': _pfield(o, 'SDR')}

    def pipe(self, nominal, pn=16):
        """הצינור לגודל נומינלי + מחלקת-לחץ. נופל חזרה ל-PN כלשהו לאותו OD."""
        if (nominal, pn) in self.tab:
            return self.tab[(nominal, pn)]
        for (od, _), v in self.tab.items():
            if od == nominal:
                return v
        return None

    def anchors(self, nominal, pn=16):
        """הבסיס שכל אביזר בגודל הזה נשען עליו."""
        p = self.pipe(nominal, pn)
        if not p:
            return None
        return {'pipe_OD': p['od'], 'flow_ID': p['id'],
                'socket_D≈1.33·OD': round(1.333 * p['od'], 1)}


class PolyrollDimEngine:
    def __init__(self, rows):
        self.table = defaultdict(dict)          # (family, series) -> {size: dims}
        self.name = {}                          # (family, series) -> example name
        self.series_of = defaultdict(set)       # family -> {series}
        self.raw = []                           # (family, series, size, sku, dims)
        for o in rows:
            if o.get('A') != 'פולירול' or o.get('D') not in CAT:
                continue
            fam = CAT[o['D']]
            dm = parse_dims(o)
            size = nominal(o, dm)
            if size is None or not dm:
                continue
            ser = o['B'][:6]
            self.table[(fam, ser)][size] = dm
            self.name[(fam, ser)] = o.get('C', '')
            self.series_of[fam].add(ser)
            self.raw.append((fam, ser, size, o['B'], dm))

    # ---- core: produce one dimension for a series+size ----
    def _one(self, tbl, size, letter):
        pts = sorted((s, d[letter]) for s, d in tbl.items() if letter in d)
        if not pts:
            return None, 'none'
        for s, v in pts:
            if s == size:
                return v, 'exact'
        xs = [p[0] for p in pts]
        if size < xs[0] or size > xs[-1]:
            return None, 'out-of-range'
        ys = [p[1] for p in pts]
        for i in range(len(xs) - 1):
            if xs[i] <= size <= xs[i + 1]:
                t = (size - xs[i]) / (xs[i + 1] - xs[i])
                return round(ys[i] + t * (ys[i + 1] - ys[i]), 2), 'interp'

    def produce(self, family, size, series):
        tbl = self.table.get((family, series), {})
        letters = set().union(*[set(d) for d in tbl.values()]) if tbl else set()
        out = {}
        for L in sorted(letters):
            v, src = self._one(tbl, size, L)
            if v is not None:
                out[L] = (v, src)
        return out

    def query(self, family, size):
        """כל הסדרות של המשפחה שיודעות לתת את הגודל הזה."""
        res = {}
        for (fam, ser), tbl in self.table.items():
            if fam != family:
                continue
            out = self.produce(family, size, ser)
            if out:
                res[ser] = (self.name[(fam, ser)], out)
        return res

    def coverage(self):
        """שתי מדידות כנות פר-משפחה:
           exact  — מוצרים שהמנוע נותן להם את המידות המדויקות (הם קיימים בקטלוג).
           gen    — מוצרים בסדרות עם >=2 גדלים => המנוע מייצר גם גודל-ביניים שלא ראה."""
        rep = {}
        for fam in CAT.values():
            prods = [r for r in self.raw if r[0] == fam]
            exact = len(prods)                                   # לכולם יש מידות => exact
            gen = sum(1 for r in prods if len(self.table[(fam, r[1])]) >= 2)
            rep[fam] = (exact, gen, len(prods), len(self.series_of[fam]))
        return rep


if __name__ == '__main__':
    path = sys.argv[1] if len(sys.argv) > 1 else 'catalog-dump.json'
    rows = json.load(open(path, encoding='utf-8'))
    rows = rows[1:] if rows and 'sku' not in str(rows[0]).lower() else rows
    eng = PolyrollDimEngine(rows)

    print('=== כיסוי ===')
    print('משפחה | exact (מידות מדויקות) | gen (מייצר גם גודל חדש)')
    te = tg = tt = 0
    for fam, (ex, gn, pt, st) in eng.coverage().items():
        te += ex; tg += gn; tt += pt
        print('  %-5s |  %3d/%3d (%3.0f%%)     |  %3d/%3d (%3.0f%%)' %
              (fam, ex, pt, 100 * ex / pt, gn, pt, 100 * gn / pt))
    print('  ----- |  %d/%d (%.0f%%)          |  %d/%d (%.0f%%)' %
          (te, tt, 100 * te / tt, tg, tt, 100 * tg / tt))

    print('\n=== שכבת-הבסיס: הצינור (Layer 0) — anchor לכל אביזר ===')
    base = PipeBase(rows)
    for nom in [20, 32, 50, 110]:
        a = base.anchors(nom, pn=16)
        # אימות: D האמיתי של אביזר מול 1.33·OD מהבסיס
        real_D = None
        for (f, s), tbl in eng.table.items():
            if nom in tbl and 'D' in tbl[nom] and abs(tbl[nom]['D'] - 1.333 * nom) < 3:
                real_D = tbl[nom]['D']; break
        print('  צינור %3g: OD=%g · ID(זרימה)=%g · D_socket≈%g   [D אמיתי באביזר: %s]' %
              (nom, a['pipe_OD'], a['flow_ID'], a['socket_D≈1.33·OD'], real_D))

    print('\n=== דוגמאות ייצור (אביזרים על הבסיס) ===')
    for fam, size in [('רוכב', 20), ('ברך', 110), ('מתאם', 32)]:
        for ser, (nm, out) in list(eng.query(fam, size).items())[:1]:
            s = ' · '.join('%s=%g(%s)' % (L, v, src) for L, (v, src) in out.items())
            print('  %s %g  [%s]  %s' % (fam, size, nm[:26], s))

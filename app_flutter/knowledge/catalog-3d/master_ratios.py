# -*- coding: utf-8 -*-
"""לולאה על כל המשפחות × כל האותיות — טבלת-אב של היחסים ההנדסיים (אות/d)."""
import json, re, statistics
from collections import defaultdict
rows = json.load(open('zipdump/uploads/catalog-dump.json', encoding='utf-8'))[1:]
CATN = {'מתאמים PPR': 'מתאם', 'מצמדים PPR': 'מצמד', 'ברכיים PPR': 'ברך',
        'מסעפים PPR': 'טי', 'רוכבים PPR': 'רוכב', 'פקקים PPR': 'פקק',
        'ברזים PPR': 'ברז', 'צווארונים ואוגנים PPR': 'צווארון', 'אומגה PPR': 'אומגה'}
kp = re.compile(r'(?<![A-Za-z֐-׿])([A-Za-z][0-9]?)\s*:\s*([\d.]+)')
STD = {20, 25, 32, 40, 50, 63, 75, 90, 110, 125, 160, 200, 250, 315, 355, 400}

def dims(o):
    out = {}
    for v in o.values():
        if isinstance(v, str):
            for m in kp.finditer(v):
                if m.group(1) not in ('PN', 'SDR'):
                    out.setdefault(m.group(1), float(m.group(2)))
    return out

def nominal(o, dm):
    if 'd' in dm:
        return dm['d']
    nm = re.sub(r'\d+\s*°', ' ', o.get('C', ''))
    m = re.search(r'(\d{2,3})\s*[xX×]', nm)
    if m:
        return float(m.group(1))
    nums = [int(x) for x in re.findall(r'(?<![\d./])(\d{2,3})(?![\d./])', nm)]
    for x in reversed(nums):
        if x in STD:
            return float(x)
    return float(nums[-1]) if nums else None

# split family by geometric sub-type (angle) so ratios stay clean
def sub(cat, nm):
    f = CATN[cat]
    if f == 'ברך':
        return 'ברך45' if '45' in nm else 'ברך90'
    return f

pairs = defaultdict(lambda: defaultdict(list))   # subfam -> letter -> [v/d]
for o in rows:
    if o.get('A') != 'פולירול' or o.get('D') not in CATN:
        continue
    dm = dims(o); d = nominal(o, dm)
    if not d or d not in STD:
        continue
    sf = sub(o['D'], o.get('C', ''))
    for L, v in dm.items():
        if L != 'd':
            pairs[sf][L].append(v / d)

MASTER = {}
tot_letters = tot_clean = 0
for sf, letters in sorted(pairs.items()):
    MASTER[sf] = {}
    for L, rr in letters.items():
        if len(rr) < 4:
            continue
        med = statistics.median(rr)
        sp = statistics.median([abs(x - med) for x in rr])
        MASTER[sf][L] = {'ratio': round(med, 3), 'spread': round(sp, 3), 'n': len(rr),
                         'clean': sp < 0.04}
        tot_letters += 1
        tot_clean += sp < 0.04

json.dump(MASTER, open('construction_ratios.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print('=== טבלת-אב: יחס הנדסי לכל אות × כל משפחה ===')
print('משפחות:', len(MASTER), '| אותיות סה"כ:', tot_letters, '| יחס-נקי (spread<4%%):', tot_clean,
      '(%.0f%%)' % (100*tot_clean/tot_letters))
print()
for sf, L in sorted(MASTER.items()):
    if not L:
        continue
    s = ' · '.join('%s=%.3f%s' % (k, v['ratio'], '✓' if v['clean'] else '~')
                   for k, v in sorted(L.items(), key=lambda kv: -kv[1]['n']))
    print('  %-8s %s' % (sf, s[:88]))

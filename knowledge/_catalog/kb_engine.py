#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
kb_engine — knowledge decomposer/cataloger for BuildSmart's knowledge/ base.
Same philosophy as tools/atom/decompose (code→atoms) applied to docs→atoms.
Deterministic · re-runnable. Reads knowledge/, emits REGISTRY.json + INDEX.md
+ a reorg map. Zero mutation of the docs themselves.
"""
import os, re, json, sys

ROOT = sys.argv[1] if len(sys.argv) > 1 else "kb/knowledge"

# ---- type from filename prefix ----
def doc_type(name):
    b = os.path.basename(name)
    if re.match(r'^\d\d-', b): return 'report-numbered'
    for p in ('DIRECTIVE','SPEC','PLAN','LAUNCH','MASTER','MICRO','GUIDE','METHOD',
              'DECOMP','CATALOG','KEYBOARD','MONSTER','MANAGER','AUDIT','START','README',
              'CONTINUITY','COORDINATION','TASKS','POLISH','NORTH','AGENT','DATA','SERVER',
              'GO','V2','VERIFIED','KNOWLEDGE'):
        if b.upper().startswith(p): return p
    if b.endswith('.json'): return 'json-data'
    if b.endswith('.csv'): return 'csv-data'
    if b.endswith('.html'): return 'html'
    return 'other'

# ---- domain lexicons (semantic first-pass) ----
DOMAINS = {
    'catalog-fittings': ['קטלוג','catalog','אביזר','fitting','ברך','מחלק','od','family','3d','engine','מנוע','schema','סכמ','dive','ring','wheel','ppr','צנרת','huliot','lipskey','polyroll'],
    'decomposition':    ['פירוק','decomp','אטום','atom','primitive','פרימיטיב','journey','מסע','async','logic-','data-','contract','חוזה'],
    'north-star':       ['north','צפון','חוזה-הדאטה','קונכייה','wipe','מחק-והעלה','replace','החלפת-הקטלוג'],
    'launch-deploy':    ['השקה','launch','deploy','go-live','firebase','keystore','חשבונ','store','חנות-אפליקציות','gh-pages'],
    'personas-roles':   ['פרסונ','persona','קבלן','מנהל','manager','שליח','courier','עובד','worker','store','חנות','rbac','role'],
    'server-backend':   ['server','שרת','backend','firestore','functions','r2','repositor','sync'],
    'shell-nav-ui':     ['shell','ניווט','nav','dial','tab','טאב','hub','מעטפת','design-system','theme','widget','a11y','ui'],
    'orders-commerce':  ['הזמנ','order','cart','עגל','checkout','b2b','supply','rfq','rma','שילוח','חשבונית','invoice'],
    'keyboard-finder':  ['keyboard','מקלדת','finder','מאתר','super-finder','ring-dive'],
    'process-meta':     ['start-here','audit','knowledge','coordination','tasks-to','continuity','method','governance','multiagent','agent-sources','protocol','spine','gate','tooling','micro-tasks'],
}
def domain_of(text):
    t = text.lower()
    best, score = 'unclassified', 0
    for d, kws in DOMAINS.items():
        s = sum(t.count(k.lower()) for k in kws)
        if s > score: best, score = d, s
    return best

# ---- date signals (freshness) ----
def dates_in(text):
    ds = set(re.findall(r'20\d\d-\d\d-\d\d', text))
    return sorted(ds)

STALE_MARK = re.compile(r'SUPERSEDED|DEPRECATED|מבוטל|הוחלף|היסטורי|superseded|ARCHIV|deprecated|בוצע ✅|✅ בוצע|✅ \*\*בוצע')
DONE_MARK  = re.compile(r'בוצע|הושלם|✅|גמור|סגור|DONE|complete')

# ---- current-era signal (Aug 2026 work) ----
CURRENT = re.compile(r'2026-08|צפון|north-star|NORTH-STAR|decomp|פירוק-לעומק|catalog-config|CATALOG-CONFIG|atom-tooling|DECOMP-DEPTH|CATALOG-SCHEMA|catalog-replace')

def analyze(path):
    rel = os.path.relpath(path, ROOT)
    try:
        text = open(path, encoding='utf-8').read()
    except Exception:
        text = ''
    lines = text.split('\n')
    m = re.search(r'^#\s+(.+)$', text, re.M)
    title = (m.group(1).strip() if m else os.path.basename(path))
    # purpose = first blockquote line, prefer one with מטרה/purpose
    bq = [l[1:].strip() for l in lines if l.strip().startswith('>')]
    purpose = ''
    for l in bq:
        if 'מטרה' in l or 'purpose' in l.lower() or 'הבעיה' in l:
            purpose = l; break
    if not purpose and bq: purpose = bq[0]
    purpose = re.sub(r'\*\*|`', '', purpose)[:180]
    ds = dates_in(text)
    head = '\n'.join(lines[:40])
    refs = sorted(set(re.findall(r'([A-Za-z0-9][A-Za-z0-9\-_]{2,}\.md)', text)) - {os.path.basename(path)})
    return {
        'path': rel,
        'type': doc_type(path),
        'title': title[:120],
        'purpose': purpose,
        'domain': domain_of(title + ' ' + head),
        'lines': len(lines),
        'bytes': len(text.encode('utf-8')),
        'dates': ds,
        'latest_date': ds[-1] if ds else None,
        'stale_signal': bool(STALE_MARK.search(text)),
        'current_signal': bool(CURRENT.search(title + ' ' + head)),
        'refs_out': refs,
        'ref_count_out': len(refs),
    }

# ---- walk ----
records = []
for dp, _, fns in os.walk(ROOT):
    for fn in fns:
        records.append(analyze(os.path.join(dp, fn)))
records.sort(key=lambda r: r['path'])

# ---- inbound ref graph ----
by_base = {}
for r in records: by_base.setdefault(os.path.basename(r['path']), []).append(r['path'])
inbound = {r['path']: 0 for r in records}
for r in records:
    for ref in r['refs_out']:
        for tgt in by_base.get(ref, []):
            if tgt != r['path']: inbound[tgt] += 1
for r in records: r['ref_count_in'] = inbound[r['path']]

# ---- status classification (era/freshness) ----
def status(r):
    if r['stale_signal']: return 'SUPERSEDED'
    if r['current_signal'] or (r['latest_date'] and r['latest_date'] >= '2026-08'): return 'CURRENT'
    ld = r['latest_date']
    if ld and ld >= '2026-07': return 'RECENT'
    if r['type'] == 'report-numbered': return 'REFERENCE'
    if r['type'] in ('json-data','csv-data'): return 'DATA'
    return 'AGING'
for r in records: r['status'] = status(r)

# ---- filename→(status,domain) overrides for known current-era anchors ----
CURR_ANCHORS = {
    'NORTH-STAR-data-contract.md':'north-star','DECOMP-DEPTH-100-STEPS.md':'decomposition',
    'CATALOG-CONFIG-PLAN.md':'catalog-fittings','CATALOG-SCHEMA.md':'catalog-fittings',
    'CATALOG-3D-100-STEPS.md':'catalog-fittings','DIRECTIVE-catalog-replace.md':'catalog-fittings',
    'DIRECTIVE-atom-tooling.md':'decomposition','AGENT-SOURCES.md':'process-meta',
}
META_ANCHORS = {'00-START-HERE.md','KNOWLEDGE_AUDIT.md','COORDINATION-SPEC.md','CONTINUITY.md',
                'TASKS-to-full.md','README.md','AGENT-SOURCES.md','NORTH-STAR-data-contract.md'}
for r in records:
    b = os.path.basename(r['path'])
    if b in CURR_ANCHORS:
        r['status'] = 'CURRENT'; r['domain'] = CURR_ANCHORS[b]
    if b in META_ANCHORS: r['meta'] = True
    else: r['meta'] = False

# ---- proposed folder (the reorg map) ----
def folder(r):
    p = r['path']
    if p.startswith('screens/'): return 'screens/ (keep — already a registry)'
    if p.startswith('monster-finder/'): return 'archive/monster-finder/ (finder shipped)'
    if r['type'] in ('json-data','csv-data','html'): return 'data/'
    if r['meta']: return '. (root — navigation spine)'
    if r['status'] == 'CURRENT': return f'current/{r["domain"]}/'
    if r['status'] == 'REFERENCE': return 'reference/ (00-24 numbered)'
    if r['status'] == 'SUPERSEDED': return 'archive/ (explicit stale marker)'
    if r['status'] in ('RECENT',): return f'current/{r["domain"]}/'
    return 'archive/review/ (aging — verify before final)'
for r in records: r['proposed'] = folder(r)

os.makedirs('kb_out', exist_ok=True)
json.dump(records, open('kb_out/REGISTRY.json','w',encoding='utf-8'), ensure_ascii=False, indent=1)

# ---- human INDEX.md ----
from collections import Counter, defaultdict
md = ['# 📇 knowledge/ — INDEX (מנוע-קטלוג · אוטומטי · re-runnable)','',
      f'> נוצר ע"י `kb_engine.py` — מפרק כל מסמך לאטום-רשומה (סוג · תחום · סטטוס · תאריך · הפניות) ומקטלג.',
      f'> **{len(records)} מסמכים** · re-run: `python3 kb_engine.py knowledge`','','## מצב-על','']
sc = Counter(r['status'] for r in records)
for s in ['CURRENT','RECENT','REFERENCE','AGING','SUPERSEDED','DATA']:
    md.append(f'- **{s}**: {sc.get(s,0)}')
md.append('')
# current
md += ['---','## 🟢 CURRENT — בנה מול אלה','']
cur = [r for r in records if r['status'] in ('CURRENT','RECENT') and r['path'].endswith('.md')]
for r in sorted(cur, key=lambda x:x['domain']):
    md.append(f"- `{r['path']}` · _{r['domain']}_ · in={r['ref_count_in']} — {r['purpose'][:110]}")
# reference
md += ['','## 📚 REFERENCE — סדרה ממוספרת (רקע היסטורי)','']
for r in sorted([r for r in records if r['status']=='REFERENCE'], key=lambda x:x['path']):
    md.append(f"- `{r['path']}` — {r['title'][:80]}")
# archive
arch = [r for r in records if r['status'] in ('SUPERSEDED','AGING')]
md += ['','## 🗄️ ARCHIVE — מוחלף/מתיישן (מוצע לארכיון)', f'סה"כ {len(arch)} · לפי תחום:','']
bd = defaultdict(list)
for r in arch: bd[r['domain']].append(r)
for d in sorted(bd, key=lambda x:-len(bd[x])):
    md.append(f"- **{d}** ({len(bd[d])})")
md += ['','## 🗂️ DATA / SCREENS','',
       f"- `data/` — {sum(1 for r in records if r['type'] in ('json-data','csv-data','html'))} קבצי-דאטה",
       f"- `screens/` — {sum(1 for r in records if r['path'].startswith('screens/'))} (registry קיים)"]
open('kb_out/INDEX.md','w',encoding='utf-8').write('\n'.join(md))

print("\n===== REORG MAP (proposed folder → count) =====")
for f,c in Counter(r['proposed'] for r in records).most_common():
    print(f"  {c:3}  {f}")
print("\n===== 🟢 CURRENT docs (the live spine) =====")
for r in sorted(cur, key=lambda x:x['domain']):
    print(f"  [{r['domain']:16}] {r['path']}")
print("\nemitted: kb_out/REGISTRY.json + kb_out/INDEX.md")

# ---- summary ----
from collections import Counter
print("TOTAL DOCS:", len(records))
print("\nBY STATUS:", dict(Counter(r['status'] for r in records)))
print("\nBY DOMAIN:")
for d,c in Counter(r['domain'] for r in records).most_common(): print(f"  {c:3}  {d}")
print("\nBY TYPE:")
for t,c in Counter(r['type'] for r in records).most_common(): print(f"  {c:3}  {t}")
print("\nORPHANS (0 inbound, non-report, .md):",
      sum(1 for r in records if r['ref_count_in']==0 and r['type']!='report-numbered' and r['path'].endswith('.md')))
print("\nMOST-REFERENCED (top 8):")
for r in sorted(records, key=lambda x:-x['ref_count_in'])[:8]:
    print(f"  in={r['ref_count_in']:2}  {r['path']}")
print("\nSUPERSEDED / stale-signal:", sum(1 for r in records if r['status']=='SUPERSEDED'))
print("CURRENT-era:", sum(1 for r in records if r['status']=='CURRENT'))

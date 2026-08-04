#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
kb_aggregate — merges the mechanical registry (kb_engine) with the semantic
atom-records (the fleet's batch-*.json) into one rich CATALOG + a cross-cutting
INDEX. The payoff: slice the whole KB by ANY atom (all faults · all workarounds
· all pending owner-decisions · all open questions · all capabilities · all vision).
"""
import os, json, glob
from collections import defaultdict, Counter

OUT = "kb_out"
mech = {r['path']: r for r in json.load(open(f"{OUT}/REGISTRY.json", encoding='utf-8'))}

# ---- load semantic batches (tolerant) ----
sem = {}
loaded, failed = 0, []
for f in sorted(glob.glob(f"{OUT}/atoms/batch-*.json")):
    try:
        arr = json.load(open(f, encoding='utf-8'))
        for rec in arr:
            if isinstance(rec, dict) and rec.get('path'): sem[rec['path']] = rec
        loaded += 1
    except Exception as e:
        failed.append((os.path.basename(f), str(e)[:80]))

# ---- merge ----
cat = []
for path, m in mech.items():
    s = sem.get(path, {})
    rec = dict(m)
    for k in ('one_line','vision','mission','capabilities','instructions','faults',
              'workarounds','owner_decisions','contract','dependencies','gating',
              'verification','open_questions','source_anchor'):
        rec[k] = s.get(k, [] if k not in ('one_line','vision','mission','contract') else '')
    if s.get('status'): rec['sem_status'] = s['status']
    rec['decomposed'] = path in sem
    cat.append(rec)
cat.sort(key=lambda r: r['path'])
json.dump(cat, open(f"{OUT}/CATALOG.json",'w',encoding='utf-8'), ensure_ascii=False, indent=1)

def rows(field):
    out=[]
    for r in cat:
        v=r.get(field) or []
        if isinstance(v,str): v=[v] if v else []
        for item in v:
            if item: out.append((r['path'], item))
    return out

# ---- cross-cutting INDEX ----
md=['# 📇 knowledge/ — CATALOG חי (מנוע-פירוק-ידע · re-runnable)','',
    f"> כל מסמך פורק ל-**אטומים** (חזון · משימה · יכולות · הוראות · תקלות · מעקפים · החלטות-בעלים · חוזה · תלויות · גידור · אימות · שאלות-פתוחות · מקור).",
    f"> **{len(cat)} מסמכים** · פורקו סמנטית: **{sum(1 for r in cat if r['decomposed'])}** · re-run: `kb_engine.py` + הנחיל + `kb_aggregate.py`.",'']
sc=Counter(r['status'] for r in cat)
md.append('**מצב-על:** ' + ' · '.join(f"{k}={v}" for k,v in sc.most_common()))
md.append('')

# --- THE PAYOFF: cross-cutting slices ---
def section(title, field, limit=None):
    r=rows(field); md.append(f"\n## {title}  ({len(r)})")
    if not r: md.append('_(ריק)_'); return
    cur=None
    for path,item in (r[:limit] if limit else r):
        if path!=cur: md.append(f"\n**`{path}`**"); cur=path
        md.append(f"- {item}")

section('🛑 החלטות-בעלים — כל מה שדורש/מתעד הכרעה שלך','owner_decisions')
section('🐛 תקלות — כל הבאגים/כשלים בכל הידע','faults')
section('🔀 מעקפים — כל ה-workarounds/bypasses','workarounds')
section('❓ שאלות-פתוחות','open_questions')
section('🎯 חזונות — הצפונות שהידע מכוון אליהם','vision')
section('⚙️ יכולות — כל מה שנבנה/מתואר','capabilities', limit=None)

# --- per-doc compact index by status ---
md.append('\n---\n## 📚 אינדקס-מסמכים לפי סטטוס\n')
for st in ['CURRENT','RECENT','REFERENCE','AGING','SUPERSEDED','DATA']:
    docs=[r for r in cat if r['status']==st]
    if not docs: continue
    md.append(f"\n### {st} ({len(docs)})")
    for r in docs:
        ol=r.get('one_line') or r.get('title','')
        md.append(f"- `{r['path']}` — {ol[:100]}")

open(f"{OUT}/CATALOG-INDEX.md",'w',encoding='utf-8').write('\n'.join(md))

# ---- console summary ----
print(f"loaded batches: {loaded} · failed: {failed}")
print(f"docs in catalog: {len(cat)} · semantically decomposed: {sum(1 for r in cat if r['decomposed'])}")
print("\nCROSS-CUTTING TOTALS:")
for label,field in [('🛑 owner-decisions','owner_decisions'),('🐛 faults','faults'),
                    ('🔀 workarounds','workarounds'),('❓ open-questions','open_questions'),
                    ('⚙️ capabilities','capabilities'),('🎯 visions','vision')]:
    print(f"  {label}: {len(rows(field))}")
print("\nemitted: kb_out/CATALOG.json + kb_out/CATALOG-INDEX.md")

#!/usr/bin/env node
// 🏔️👹 super-monster2 — המחולל כותב חוזה-כוונה לכל חלקיק (נגזר מהשם+דומיין) ומחווט לפי טיפוס+כוונה.
//   ⇒ שרשרת קוהרנטית: כל החלקיקים על *אותו נושא*, מחוברים בסוקטים, מסתיימת בפעולה. לא מרק-סוקטים.
//   חסר-חיבור-בדומיין ⇒ מושך חלקיק-גשר מאותו נושא. נגזרת-מהקטלוג, אפס-הרדקוד.
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
const GEN = path.dirname(fileURLToPath(import.meta.url));
const CAT = JSON.parse(fs.readFileSync(path.join(GEN, 'master-particles.json'), 'utf8')).catalog;
const ALL = Object.entries(CAT).flatMap(([op, arr]) => arr.map((p) => ({ ...p, op })));
const norm = (t) => (t || '').replace(/\?/g, '').replace(/<[^>]*>/g, '').replace(/\b(final|const|required|this\.|static|async|await)\b/g, '').trim().split(/[\s,(]/)[0] || '';
const inTypes = (sig) => { const p = (sig.split('=>')[0] || '').trim(); return p ? p.split(',').map((x) => norm(x.trim().split(/[:\s]+/)[0])).filter(Boolean) : []; };
// חוזה-כוונה: אסימוני-דומיין מהשם (camelCase) + תת-תיקיית-המקור. זה מה שהמחולל "כותב" מהקוד.
const splitName = (n) => n.replace(/([a-z0-9])([A-Z])/g, '$1 $2').replace(/[_-]/g, ' ').toLowerCase().split(/\s+/).filter((w) => w.length > 2 && !/^(the|get|set|build|from|with|for|and|new|out|val|str|num|obj|ctx|def)$/.test(w));
const dirTok = (o) => (o.split(':')[1] || '').split('/').filter((s) => s.length > 2 && !/\.(ts|mjs|js|dart)$/.test(s)).slice(-2);
for (const p of ALL) { p.o = norm(p.sig.split('=>')[1] || ''); p.i = inTypes(p.sig); p.dom = new Set([...splitName(p.name), ...dirTok(p.origin)]); }
const byIn = {}; for (const p of ALL) for (const t of p.i) (byIn[t] ||= []).push(p);
const ours = (p) => !/flutter/.test(p.origin);
const shares = (a, b) => { for (const t of a) if (b.has(t)) return true; return false; };

function coherentMonster(subject, cap = 30) {
  // כל החלקיקים בנושא (חולקי-אסימון עם ה-subject)
  const subj = new Set(subject);
  const inDomain = (p) => shares(p.dom, subj);
  // זרע: חלקיק-בנושא שקלטו טיפוס-נפוץ; מתחילים מטיפוס-הקלט שלו
  const seedP = ALL.filter((p) => inDomain(p) && ours(p) && p.i.length).sort((a, b) => b.dom.size - a.dom.size)[0];
  if (!seedP) return { chain: [], gaps: 0 };
  let cur = seedP.i[0]; const chain = []; const used = new Set(); let gaps = 0;
  for (let i = 0; i < cap; i++) {
    let cand = (byIn[cur] || []).filter((p) => !used.has(p.origin + p.name) && inDomain(p));
    if (!cand.length) {
      gaps++; const produced = new Set(chain.map((c) => c.o).concat(cur));
      const bridge = ALL.filter((p) => !used.has(p.origin + p.name) && inDomain(p) && p.i.some((t) => produced.has(t))).sort((a, b) => (ours(b) - ours(a)) || (byIn[b.o] || []).length - (byIn[a.o] || []).length)[0];
      if (!bridge) break; chain.push({ ...bridge, gap: true }); used.add(bridge.origin + bridge.name); cur = bridge.o; continue;
    }
    const pick = cand.sort((a, b) => (ours(b) - ours(a)) + (b.op !== 'effect') - (a.op !== 'effect') + ((b.o !== cur) - (a.o !== cur)))[0];
    chain.push(pick); used.add(pick.origin + pick.name); cur = pick.o;
    if (pick.op === 'effect' && chain.length > 5) break;
  }
  return { chain, gaps };
}

// המחולל בוחר נושא עשיר מהאימפריה-שלנו (אסימון-דומיין עם הכי-הרבה חלקיקים)
const domCount = {}; for (const p of ALL) if (ours(p)) for (const t of p.dom) domCount[t] = (domCount[t] || 0) + 1;
const subject = process.argv[2] ? [process.argv[2]] : [Object.entries(domCount).filter(([t]) => /hok|donor|sup|cohort|retention|enroll|course|receipt|dial|cash/.test(t)).sort((a, b) => b[1] - a[1])[0]?.[0] || 'sup'];
console.log(`🏔️👹 יכולת-מפלצתית קוהרנטית · נושא="${subject.join(',')}" (${domCount[subject[0]] || 0} חלקיקים בנושא)`);
const { chain, gaps } = coherentMonster(subject, 30);
console.log(`\nהשרשרת (${chain.length} חלקיקים · ${gaps} גשרים · כולם בנושא "${subject[0]}"):`);
let t = chain[0] ? chain[0].i[0] : '?';
for (const c of chain) { console.log(`  ${t} → ${c.name}${c.gap ? ' 🌉' : ''} → ${c.o} [${c.op}] ←${c.origin.split(':')[0]}`); t = c.o; }
const works = chain.length && chain[chain.length - 1].op === 'effect';
console.log(`\n${works ? '✅ קוהרנטית + מסתיימת בפעולה' : '⚠️ לא-סגורה בפעולה'} · אורך ${chain.length}`);

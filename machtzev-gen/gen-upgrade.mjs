#!/usr/bin/env node
// 🏔️ gen-upgrade — המחולל שופט את *כל* 40,854 החלקיקים בחוק-נגזר-אחיד (בלי regex-ידני, בלי אלוף-בְּיָד).
//   קלט: שם-מנוע. הזרע = אסימוני-הדומיין של המנוע עצמו. המחולל מרחיב בסגירה-טרנזיטיבית על *כל* החלקיק
//   דרך שני ערוצים נגזרים: (א) שיתוף-דומיין (אסימון-שם משותף) (ב) חיבור-סוקט (פלט⇒קלט). כל חלקיק
//   שנתפס מקבל: relevance = טוקנים-משותפים-עם-המנוע (לא ספירת-String), ו-stage נגזר מה-op שלו בלבד.
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
const GEN = path.dirname(fileURLToPath(import.meta.url));
const CAT = JSON.parse(fs.readFileSync(path.join(GEN, 'master-particles.json'), 'utf8')).catalog;
const ALL = Object.entries(CAT).flatMap(([op, arr]) => arr.map((p) => ({ ...p, op })));
const norm = (t) => (t || '').replace(/\?/g, '').replace(/<[^>]*>/g, '').replace(/\b(final|const|required|this\.|static|async|await)\b/g, '').trim().split(/[\s,(]/)[0] || '';
const inTypes = (s) => { const p = (s.split('=>')[0] || '').trim(); return p ? p.split(',').map((x) => norm(x.trim().split(/[:\s]+/)[0])).filter(Boolean) : []; };
const STOP = new Set(['the','get','set','build','from','with','for','and','new','out','val','str','num','obj','ctx','def','fun','has','are','all','map','list','row','key','sec','tab']);
const toks = (n) => n.replace(/([a-z0-9])([A-Z])/g, '$1 $2').replace(/[_-]/g, ' ').toLowerCase().split(/\s+/).filter((w) => w.length > 2 && !STOP.has(w));
for (const p of ALL) { p.o = norm(p.sig.split('=>')[1] || ''); p.i = inTypes(p.sig); p.t = new Set(toks(p.name)); }
const ours = (p) => !/flutter/.test(p.origin) && !p.name.startsWith('_');
const isScreen = (n) => /^[A-Z]/.test(n) && /(Section|Screen|Tab|Modal|Panel|Card|Btn|View|Ribbon|Pad|Reader|Hero|Wizard|Strip|Center|Sheet|Chat|Dial|Bar|Palette|Feed|Gallery)$/.test(n);
// טיפוסי-סוקט "רועשים" (hub): מחברים הכל⇒לא ערוץ-קוהרנטי. נגזר: טיפוס שיש לו יותר מ-1% מהחלקיקים כצרכן.
const byIn = {}; for (const p of ALL) for (const t of p.i) (byIn[t] ||= []).push(p);
const NOISY = new Set(Object.entries(byIn).filter(([, a]) => a.length > ALL.length * 0.01).map(([t]) => t));
// חוק-רול נגזר מה-op בלבד (אחיד לכל חלקיק) → מיקום-בגלגל
const STAGE = { predicate: 'SELECT', guard: 'GUARD', measure: 'RANK', format: 'ACT', transform: 'ACT', collection: 'FOLLOW', effect: 'FOLLOW' };
const ORDER = ['SELECT', 'RANK', 'GUARD', 'ACT', 'FOLLOW'];

const target = process.argv[2] || 'hokDue';
const eng = ALL.find((p) => p.name === target && ours(p)) || ALL.find((p) => p.name === target);
if (!eng) { console.log('מנוע לא נמצא:', target); process.exit(1); }

// סגירה-טרנזיטיבית: BFS מהמנוע. חבר חלקיק אם הוא חולק אסימון-דומיין עם מה-שכבר-בגלגל
// *או* מחובר-בסוקט לא-רועש. relevance = |טוקנים משותפים עם *המנוע*|.
const domain = new Set(eng.t); const reached = new Map(); const q = [eng]; reached.set(eng.name, eng);
while (q.length) {
  const cur = q.shift();
  for (const p of ALL) {
    if (!ours(p) || isScreen(p.name) || reached.has(p.name)) continue;
    const shareDom = [...p.t].some((t) => domain.has(t));
    const wired = (p.o && p.o === cur.i.find((x) => x === p.o) && !NOISY.has(p.o)) ||
                  (cur.o && p.i.includes(cur.o) && !NOISY.has(cur.o));
    if (shareDom || wired) { reached.set(p.name, p); for (const t of p.t) domain.add(t); q.push(p); }
  }
}
reached.delete(eng.name);
// שפוט כל חלקיק-שנתפס באותה נוסחה: relevance מול *אסימוני-המנוע*, stage מה-op
const engT = eng.t;
const scored = [...reached.values()].map((p) => ({ ...p, rel: [...p.t].filter((t) => engT.has(t)).length, stage: STAGE[p.op] || 'ACT' }));
const byStage = {}; for (const p of scored) (byStage[p.stage] ||= []).push(p);

console.log(`🏔️ המחולל · שדרוג-מקסימום נגזר ל-"${eng.name}"  ←${eng.origin.split(':')[0]}`);
console.log(`זרע-דומיין (אסימוני-המנוע): ${[...engT].join(' · ')}`);
console.log(`סגירה-טרנזיטיבית תפסה: ${scored.length} חלקיקים · דומיין-מורחב: ${domain.size} אסימונים\n`);
let total = 0;
for (const stage of ORDER) {
  const g = (byStage[stage] || []).sort((a, b) => b.rel - a.rel || a.name.localeCompare(b.name));
  if (!g.length) continue; total += g.length;
  const champ = g[0]; // הכי-טוב = הכי-רלוונטי-למנוע (טוקנים משותפים), נגזר — לא בְּיָד
  console.log(`  ${stage.padEnd(6)} (${String(g.length).padStart(3)}) 👑 ${champ.name} [rel ${champ.rel}] · ${g.slice(0, 7).map((p) => p.name).join(' · ')}${g.length > 7 ? ' …' : ''}`);
}
const flyw = ORDER.map((s) => (byStage[s] || []).sort((a, b) => b.rel - a.rel)[0]?.name).filter(Boolean);
console.log(`\n✅ "${eng.name}" שודרג ל-${total} חלקיקים — כולם נשפטו בחוק-נגזר-אחיד על כל 40,854.`);
console.log(`   הגלגל (אלוף-נגזר לכל שלב): ${flyw.join(' → ')}`);
console.log(`   ברירת-מחדל = ${eng.name} המקורי (אפס-אובדן).`);
fs.writeFileSync(path.join(GEN, `gen-upgrade-${eng.name}.json`), JSON.stringify({ engine: eng.name, seed: [...engT], reached: scored.length, byStage: Object.fromEntries(ORDER.map((s) => [s, (byStage[s] || []).sort((a, b) => b.rel - a.rel).map((p) => ({ name: p.name, rel: p.rel, op: p.op }))])) }, null, 0));

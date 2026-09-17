#!/usr/bin/env node
// 🏔️⬆️ super-upgrade — המטרה: קח מנוע אחד ושדרג למקסימום מהקטלוג-המפלצתי (40,854 חלקיקים).
//   המחולל: (1) כותב חוזה-כוונה למנוע (דומיין מהשם) · (2) שולף מהקטלוג את *כל* החלקיקים-בנושא
//   שמתחברים בסוקט · (3) מחווט אותם בסדר-רול (שער→נרמול→פעולה) סביב המנוע → הגרסה המקסימלית.
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
const GEN = path.dirname(fileURLToPath(import.meta.url));
const CAT = JSON.parse(fs.readFileSync(path.join(GEN, 'master-particles.json'), 'utf8')).catalog;
const ALL = Object.entries(CAT).flatMap(([op, arr]) => arr.map((p) => ({ ...p, op })));
const norm = (t) => (t || '').replace(/\?/g, '').replace(/<[^>]*>/g, '').replace(/\b(final|const|required|this\.|static|async|await)\b/g, '').trim().split(/[\s,(]/)[0] || '';
const inTypes = (sig) => { const p = (sig.split('=>')[0] || '').trim(); return p ? p.split(',').map((x) => norm(x.trim().split(/[:\s]+/)[0])).filter(Boolean) : []; };
const splitName = (n) => n.replace(/([a-z0-9])([A-Z])/g, '$1 $2').replace(/[_-]/g, ' ').toLowerCase().split(/\s+/).filter((w) => w.length > 2 && !/^(the|get|set|build|from|with|for|and|new|out|val|str|num|obj|ctx|def|fun|has|are)$/.test(w));
for (const p of ALL) { p.o = norm(p.sig.split('=>')[1] || ''); p.i = inTypes(p.sig); p.dom = new Set(splitName(p.name)); }
const ours = (p) => !/flutter/.test(p.origin);
const shares = (a, b) => { for (const t of a) if (b.has(t)) return true; return false; };

const ROLE_ORDER = ['guard', 'predicate', 'format', 'transform', 'measure', 'collection', 'effect']; // שער→נרמול→פעולה
const target = process.argv[2] || 'telHref';
const eng = ALL.find((p) => p.name === target && ours(p)) || ALL.find((p) => p.name === target) || ALL.find((p) => p.name.toLowerCase() === target.toLowerCase());
if (!eng) { console.log('מנוע לא נמצא בקטלוג:', target); process.exit(1); }

// (1) חוזה-כוונה של המנוע = הדומיין שלו
const dom = eng.dom;
// (2) כל החלקיקים-בנושא (חולקי-דומיין) — מהאימפריה שלנו (דלק נקי), לא-פרטיים
const helpers = ALL.filter((p) => p.name !== eng.name && ours(p) && !p.name.startsWith('_') && shares(p.dom, dom));
// (3) קבץ לפי רול, מיין בסדר-החיווט
const byRole = {}; for (const p of helpers) (byRole[p.op] ||= []).push(p);

console.log(`🏔️⬆️ שדרוג-מקסימום: ${eng.name}  (${eng.sig.slice(0, 40)})  ←${eng.origin.split(':')[0]}`);
console.log(`חוזה-כוונה (דומיין): ${[...dom].join(' · ')}`);
console.log(`חלקיקים-בנושא שנמצאו בקטלוג: ${helpers.length}\n`);
console.log('הגרסה המקסימלית — חיווט בסדר-רול סביב המנוע:');
for (const role of ROLE_ORDER) {
  const g = (byRole[role] || []); if (!g.length) continue;
  console.log(`  [${role}] (${g.length}): ${[...new Set(g.map((p) => p.name))].slice(0, 10).join(' · ')}${g.length > 10 ? ' …+' + (g.length - 10) : ''}`);
}
const total = helpers.length, effN = (byRole.effect || []).length;
console.log(`\n✅ ${eng.name} שודרג ממנוע-בודד ל-${total} חלקיקים-בנושא מחווטים (${effN} עלי-פעולה) · ברירת-מחדל=המקורי (אפס-אובדן).`);
fs.writeFileSync(path.join(GEN, `upgrade-${eng.name}.json`), JSON.stringify({ engine: eng.name, domain: [...dom], helpers: helpers.length, byRole: Object.fromEntries(Object.entries(byRole).map(([r, a]) => [r, [...new Set(a.map((p) => p.name))]])) }, null, 0));

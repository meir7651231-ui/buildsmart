#!/usr/bin/env node
// 🏔️👹⬆️ max-best — המקסימום *הנקי*: מקפל op-שקילות, מסנן רכיבי-מסך, ובוחר את הכי-טוב בכל שלב.
//   "הכי טוב" = מרכזיות-סוקט (כמה חלקיקים אחרים מתחברים אליו) — החזק שולט, השאר מתקפלים אליו.
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
const GEN = path.dirname(fileURLToPath(import.meta.url));
const CAT = JSON.parse(fs.readFileSync(path.join(GEN, 'master-particles.json'), 'utf8')).catalog;
const ALL = Object.entries(CAT).flatMap(([op, arr]) => arr.map((p) => ({ ...p, op })));
const norm = (t) => (t || '').replace(/\?/g, '').replace(/<[^>]*>/g, '').replace(/\b(final|const|required|this\.|static|async|await)\b/g, '').trim().split(/[\s,(]/)[0] || '';
const inTypes = (sig) => { const p = (sig.split('=>')[0] || '').trim(); return p ? p.split(',').map((x) => norm(x.trim().split(/[:\s]+/)[0])).filter(Boolean) : []; };
for (const p of ALL) { p.o = norm(p.sig.split('=>')[1] || ''); p.i = inTypes(p.sig); }
const byIn = {}; for (const p of ALL) for (const t of p.i) (byIn[t] ||= []).push(p);
const consumers = (p) => (byIn[p.o] || []).length;              // מרכזיות-סוקט = "כמה טוב"
const ours = (p) => !/flutter/.test(p.origin);
// סינון-זבל: לא רכיב-מסך (PascalCase שמסתיים ב-Section/Screen/Tab/Modal/Panel/Card/Btn/View/Ribbon/Pad)
const isScreen = (n) => /^[A-Z]/.test(n) && /(Section|Screen|Tab|Modal|Panel|Card|Btn|View|Ribbon|Pad|Reader|Hero|Wizard|Strip|Center|Sheet|Chat|Dial|Bar|Palette|Feed|Gallery)$/.test(n);
const clean = (p) => ours(p) && !p.name.startsWith('_') && !isScreen(p.name) && p.op !== 'effect' ? true : (ours(p) && !p.name.startsWith('_') && !isScreen(p.name)); // גם effect אמיתי (waHref/dialString) נשאר

const FLOW = { SELECT: /hok|nedarim|(^|[^a-z])due|recurring/i, RANK: /tier|rfm|churn|(^|[^a-z])score|priority/i, GUARD: /shabbat|quiet|classifyday|hebcal|roleOf|allow|valid/i, ACT: /wa(Href|Btn)?|dial|remind|smtp|telHref|payLink|notify|smsHref|mailHref/i, FOLLOW: /addDonation|receipt|logAudit|bulkRecord|recordHok|pushAudit/i };

console.log('🏔️👹⬆️ hokDue — המקסימום הנקי (op-שקילות מקופל · רכיבי-מסך מסוננים)\n');
let total = 0; const best = {};
for (const [stage, re] of Object.entries(FLOW)) {
  const g = ALL.filter((p) => clean(p) && re.test(p.name));
  // קיפול op-שקילות: קבץ לפי (op + סוקט-פלט), שמור רק את החזק (הכי-הרבה צרכנים) מכל קבוצה
  const groups = {}; for (const p of g) { const k = p.op + '|' + p.o; (groups[k] ||= []).push(p); }
  const canon = Object.values(groups).map((arr) => arr.sort((a, b) => consumers(b) - consumers(a) || a.name.length - b.name.length)[0]);
  const names = [...new Map(canon.map((p) => [p.name, p])).values()];
  const champ = names.sort((a, b) => consumers(b) - consumers(a))[0];
  best[stage] = { champ: champ?.name, cons: champ ? consumers(champ) : 0, canon: names.length, raw: g.length, list: names.slice(0, 8).map((p) => p.name) };
  total += names.length;
  console.log(`  ${stage.padEnd(7)} raw ${String(g.length).padStart(3)} ⇒ ${String(names.length).padStart(2)} קנוני · 👑 הכי-טוב: ${champ?.name} (${champ ? consumers(champ) : 0} מתחברים)`);
  console.log(`           ${names.slice(0, 8).map((p) => p.name).join(' · ')}${names.length > 8 ? ' …' : ''}`);
}
console.log(`\n✅ מקסימום-נקי: **${total} חלקיקים קנוניים** (מ-317 הגס — קופלו כפילויות-op ונופו רכיבי-מסך).`);
console.log(`   השדרוג = ${best.SELECT.champ} → ${best.RANK.champ} → ${best.GUARD.champ} → ${best.ACT.champ} → ${best.FOLLOW.champ}`);
fs.writeFileSync(path.join(GEN, 'max-hokDue-clean.json'), JSON.stringify({ total, best }, null, 0));

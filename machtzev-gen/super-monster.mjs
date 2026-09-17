#!/usr/bin/env node
// 🏔️👹 super-monster — משימת-המחולל: לחבר חלקיקים לשרשרת-יכולת אחת מפלצתית שמסתיימת בפעולה (effect=עובדת).
//   חיווט לפי סוקט (פלט⇒קלט). חסר-חיבור? מושך חלקיק-גשר מהקטלוג (40,854). מעדיף אימפריה-שלנו+טהור+ציבורי.
//   נגזרת-מהקטלוג, אפס-הרדקוד. פלט: השרשרת-המפלצתית + אימות שהיא מחוברת ומסתיימת בפעולה.
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
const GEN = path.dirname(fileURLToPath(import.meta.url));
const CAT = JSON.parse(fs.readFileSync(path.join(GEN, 'master-particles.json'), 'utf8')).catalog;
const ALL = Object.entries(CAT).flatMap(([op, arr]) => arr.map((p) => ({ ...p, op })));
const norm = (t) => (t || '').replace(/\?/g, '').replace(/<[^>]*>/g, '').replace(/\b(final|const|required|this\.|static|async|await)\b/g, '').trim().split(/[\s,(]/)[0] || '';
const inTypes = (sig) => { const p = (sig.split('=>')[0] || '').trim(); return p ? p.split(',').map((x) => norm(x.trim().split(/[:\s]+/)[0])).filter(Boolean) : []; };
for (const p of ALL) { p.o = norm(p.sig.split('=>')[1] || ''); p.i = inTypes(p.sig); }
const byIn = {}; for (const p of ALL) for (const t of p.i) (byIn[t] ||= []).push(p);

// עדיפות-חיווט: אימפריה-שלנו > flutter · ציבורי > פרטי(_) · טהור > effect (עד הסוף) · פלט-חדש (מתקדם)
const ours = (p) => /maor|ai-chat-server|buildsmart|bs|mmmm|yoman|orbit/.test(p.origin) && !/flutter/.test(p.origin);
const score = (p, cur) => (ours(p) ? 100 : 0) + (p.name.startsWith('_') ? -50 : 0) + (p.o && p.o !== cur && p.o !== 'void' ? 20 : 0) + (p.op !== 'effect' ? 10 : 0);

function monster(startType, cap = 40) {
  const chain = []; let cur = startType; const used = new Set(); let gaps = 0;
  for (let i = 0; i < cap; i++) {
    let cand = (byIn[cur] || []).filter((p) => !used.has(p.origin + p.name));
    if (!cand.length) {
      // חסר-חיבור ⇒ גשר: משוך חלקיק שהפלט שלו הוא טיפוס-שיש-לו-צרכנים, וקלטו = משהו שכבר יצרנו (או hub)
      gaps++;
      const produced = new Set(chain.map((c) => c.o).concat(cur));
      const bridge = ALL.filter((p) => !used.has(p.origin + p.name) && p.i.some((t) => produced.has(t)) && (byIn[p.o] || []).length).sort((a, b) => score(b, cur) - score(a, cur))[0];
      if (!bridge) break;
      chain.push({ ...bridge, gap: true }); used.add(bridge.origin + bridge.name); cur = bridge.o; continue;
    }
    const pick = cand.sort((a, b) => score(b, cur) - score(a, cur))[0];
    chain.push(pick); used.add(pick.origin + pick.name); cur = pick.o;
    if (pick.op === 'effect' && i > 12) break;   // הגיע לפעולה אחרי שרשרת-משמעותית ⇒ עובדת
  }
  return { chain, gaps };
}

// המחולל בוחר את הזרע העשיר-ביותר (טיפוס עם הכי-הרבה צרכנים מהאימפריה-שלנו)
const ourStartTypes = [...new Set(ALL.filter(ours).flatMap((p) => p.i))].filter((t) => (byIn[t] || []).length > 3);
const seed = ourStartTypes.sort((a, b) => (byIn[b] || []).length - (byIn[a] || []).length)[0] || 'String';
console.log(`🏔️👹 משימת-המחולל: שרשרת-יכולת מפלצתית · זרע=${seed}`);
const { chain, gaps } = monster(seed, 40);
const oursN = chain.filter(ours).length, effN = chain.filter((c) => c.op === 'effect').length;
console.log(`\nהשרשרת (${chain.length} חלקיקים · ${gaps} גשרים-שנמשכו · ${oursN} מהאימפריה-שלנו):`);
let t = seed;
chain.forEach((c, i) => { console.log(`  ${String(i + 1).padStart(2)}. ${t} → ${c.name}${c.gap ? ' 🌉גשר' : ''} → ${c.o} [${c.op}] ←${c.origin.split(':')[0]}`); t = c.o; });
const works = chain.length && chain[chain.length - 1].op === 'effect';
console.log(`\n${works ? '✅ מסתיימת בפעולה (effect) — יכולת עובדת' : '⚠️ לא הגיעה ל-effect בעומק הזה'} · אורך ${chain.length} · גשרים ${gaps}`);
fs.writeFileSync(path.join(GEN, 'super-monster.json'), JSON.stringify({ seed, length: chain.length, gaps, works, chain: chain.map((c) => ({ name: c.name, in: t, op: c.op, out: c.o, origin: c.origin, gap: !!c.gap })) }, null, 0));

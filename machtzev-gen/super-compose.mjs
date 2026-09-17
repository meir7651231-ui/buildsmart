#!/usr/bin/env node
// 🏔️ super-compose — מחצב-העל מרכיב מהקטלוג-המפלצתי (40,854 חלקיקים): מאנדקס לפי סוקט-טיפוס,
//   בונה גרף-חיווט (פלט-חלקיק ⇒ קלט-חלקיק), ומרכיב שרשראות-יכולת לבד. נגזרת-מהקטלוג, אפס-הרדקוד.
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
const GEN = path.dirname(fileURLToPath(import.meta.url));
const CAT = JSON.parse(fs.readFileSync(path.join(GEN, 'master-particles.json'), 'utf8')).catalog;
const ALL = Object.values(CAT).flat();   // 40,854 חלקיקים

// טיפוס-סוקט מנורמל: מסיר גנריות/nullability/שם-פרמטר ⇒ טיפוס-בסיס להתאמה (String/int/bool/List/Map/דומיין)
const norm = (t) => (t || '').replace(/\?/g, '').replace(/<[^>]*>/g, '').replace(/\b(final|const|required|this\.)\b/g, '').trim().split(/[\s,]/)[0] || '';
const inTypes = (sig) => { const p = (sig.split('=>')[0] || '').trim(); if (!p) return []; return p.split(',').map((x) => { const parts = x.trim().split(/[:\s]+/); return norm(parts.length > 1 ? parts[0] : parts[0]); }).filter(Boolean); };
const outType = (sig) => norm((sig.split('=>')[1] || ''));

// אינדקס-סוקטים: טיפוס-פלט ⇒ יצרנים · טיפוס-קלט ⇒ צרכנים
const byOut = {}, byIn = {};
for (const p of ALL) { p.out = outType(p.sig); p.in = inTypes(p.sig); (byOut[p.out] ||= []).push(p); for (const t of p.in) (byIn[t] ||= []).push(p); }

// גרף-חיווט: כמה חלקיקים "מתחברים" (הפלט שלהם הוא קלט של אחר) = משטח-האמרג׳נס
let wireable = 0; const hubs = {};
for (const p of ALL) { const consumers = (byIn[p.out] || []).length; if (consumers > 0 && p.out && p.out !== 'void' && p.out !== 'dynamic') { wireable++; hubs[p.out] = (hubs[p.out] || 0) + 1; } }

// הרכבת-יכולת לדוגמה: שרשרת מ-String → ... → (עלה-אפקט), חמדני לפי סוקט (הוכחת-הרכבה מהקטלוג)
function composeFrom(startType, depth = 5) {
  const chain = []; let cur = startType; const used = new Set();
  for (let i = 0; i < depth; i++) {
    const cand = (byIn[cur] || []).filter((p) => !used.has(p.name) && p.out && p.out !== cur);
    if (!cand.length) break;
    // העדף חלקיק טהור שמזיז לטיפוס חדש (מתקדם בשרשרת)
    const pick = cand.sort((a, b) => (a.op === 'effect' ? 1 : -1) - (b.op === 'effect' ? 1 : -1))[0];
    chain.push(`${pick.name}(${cur})→${pick.out} [${pick.op}]`); used.add(pick.name); cur = pick.out;
    if (pick.op === 'effect') break;
  }
  return chain;
}

const topHubs = Object.entries(hubs).sort((a, b) => b[1] - a[1]).slice(0, 12);
console.log(`🏔️ מחצב-העל · הרכבה מ-${ALL.length} חלקיקים`);
console.log(`חלקיקים בני-חיווט (הפלט שלהם = קלט לאחר): ${wireable} (${(wireable / ALL.length * 100).toFixed(0)}%)`);
console.log(`\nמוקדי-חיווט (טיפוס-סוקט → כמה יצרנים מתחברים):`);
for (const [t, n] of topHubs) console.log(`  ${(t || '∅').padEnd(16)} ${n} יצרנים · ${(byIn[t] || []).length} צרכנים`);
console.log(`\nהרכבת-יכולת לדוגמה (שרשרת נגזרת-מסוקטים):`);
for (const start of ['String', 'int', 'bool']) { const c = composeFrom(start); if (c.length) console.log(`  ${start}: ${c.join('  →  ')}`); }
fs.writeFileSync(path.join(GEN, 'super-compose-graph.json'), JSON.stringify({ particles: ALL.length, wireable, hubs: topHubs }, null, 0));
console.log(`\n✅ גרף-החיווט נשמר · מחצב-העל מרכיב מ-${ALL.length} חלקיקי-יסוד.`);

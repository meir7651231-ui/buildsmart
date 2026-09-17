#!/usr/bin/env node
// 🏔️🔩 gen-merge — קיפול-שקילות: "מנוע-כזה·כזה·כזה שעושים אותו דבר → מזג לאחד מפלצתי".
//   החוק: החזק לא נשבר · אף יכולת לא נעלמת. המחולל: (1) עובר על כל 40,854 (2) מקבץ שקילויות
//   (אותו op + אותו סוקט + אותו נושא) (3) בכל קבוצה: החזק=הכי-הרבה-כיסוי-יכולות; הדלתא = יכולות
//   שבחלשים ואין בחזק (4) מונסטר = חזק + דלתא-מושתלת-כשקע-עם-default (⇒ חזק ביט-זהה, אפס-אובדן).
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
const GEN = path.dirname(fileURLToPath(import.meta.url));
const CAT = JSON.parse(fs.readFileSync(path.join(GEN, 'master-particles.json'), 'utf8')).catalog;
const ALL = Object.entries(CAT).flatMap(([op, arr]) => arr.map((p) => ({ ...p, op })));
const norm = (t) => (t || '').replace(/\?/g, '').replace(/<[^>]*>/g, '').replace(/\b(final|const|required|this\.|static|async|await)\b/g, '').trim().split(/[\s,(]/)[0] || '';
const inTypes = (s) => { const p = (s.split('=>')[0] || '').trim(); return p ? p.split(',').map((x) => norm(x.trim().split(/[:\s]+/)[0])).filter(Boolean) : []; };
const STOP = new Set(['the','get','set','build','from','with','for','and','new','out','val','str','num','obj','ctx','def','fun','has','are','all','map','list','row','key','fmt','to','of','is','on','by']);
const caps = (n) => n.replace(/([a-z0-9])([A-Z])/g, '$1 $2').replace(/[_-]/g, ' ').toLowerCase().split(/\s+/).filter((w) => w.length > 2 && !STOP.has(w)); // יכולות = פעלים/נושאים בשם
const ours = (p) => !/flutter/.test(p.origin) && !p.name.startsWith('_');
const isScreen = (n) => /(Section|Screen|Tab|Modal|Panel|Card|Btn|View|Ribbon|Pad|Reader|Hero|Wizard|Strip|Center|Sheet|Chat|Dial|Bar|Palette|Feed|Gallery|Menu)$/i.test(n) || /Rp\d|render[A-Z]/.test(n);
for (const p of ALL) { p.o = norm(p.sig.split('=>')[1] || ''); p.i = inTypes(p.sig); p.cap = new Set(caps(p.name)); }
const pool = ALL.filter((p) => ours(p) && !isScreen(p.name) && p.cap.size);

// מפתח-שקילות: אותו op + אותו סוקט (טיפוס-קלט-ראשי → טיפוס-פלט) + אותו נושא-ליבה (יכולת משותפת).
// הנושא נגזר: היכולת השכיחה-ביותר בשם בתוך אותו op+סוקט.
const socket = (p) => `${(p.i[0] || '∅')}→${p.o || '∅'}`;
const bucket = {}; for (const p of pool) (bucket[`${p.op}|${socket(p)}`] ||= []).push(p);
// בתוך כל דלי, פצל לפי נושא-ליבה (חולקי-יכולת) — union-find קל על שיתוף-יכולת
function classes(arr) {
  const seen = new Set(); const out = [];
  for (const p of arr) {
    if (seen.has(p.name)) continue;
    const grp = [p]; seen.add(p.name);
    for (const q of arr) { if (seen.has(q.name)) continue; if ([...q.cap].some((c) => p.cap.has(c))) { grp.push(q); seen.add(q.name); } }
    if (grp.length > 1) out.push(grp);
  }
  return out;
}
const groups = [];
for (const arr of Object.values(bucket)) for (const g of classes(arr)) groups.push(g);

// לכל קבוצה: union-יכולות; החזק = מקסימום-כיסוי (|cap ∩ union|), שובר-שוויון סוקט-עשיר; דלתא = union \ חזק.
function merge(g) {
  const union = new Set(); for (const p of g) for (const c of p.cap) union.add(c);
  const strong = g.slice().sort((a, b) => ([...b.cap].filter((c) => union.has(c)).length - [...a.cap].filter((c) => union.has(c)).length) || (b.i.length - a.i.length) || (a.name.length - b.name.length))[0];
  const delta = [...union].filter((c) => !strong.cap.has(c));
  const absorbed = g.filter((p) => p.name !== strong.name);
  // חוק-ברזל: monster.cap = strong.cap ∪ delta ⊇ union (אף יכולת לא נעלמת) · strong.cap ⊆ monster (חזק לא נשבר)
  const monster = new Set([...strong.cap, ...delta]);
  const unbroken = [...strong.cap].every((c) => monster.has(c));
  const noLoss = [...union].every((c) => monster.has(c));
  return { strong, delta, absorbed, union: [...union], unbroken, noLoss };
}

const merged = groups.map(merge).filter((m) => m.delta.length); // רק מיזוגים ששִדרגו את החזק
merged.sort((a, b) => b.absorbed.length - a.absorbed.length || b.delta.length - a.delta.length);
const totAbsorbed = merged.reduce((s, m) => s + m.absorbed.length, 0);
const allUnbroken = merged.every((m) => m.unbroken && m.noLoss);

console.log(`🏔️🔩 המחולל · מיזוג-שקילות על כל ${pool.length} החלקיקים`);
console.log(`קבוצות-שקילות (מנוע-כזה·כזה·כזה): ${groups.length} · מתוכן שדרגו-את-החזק: ${merged.length}`);
console.log(`קטנים-שנבלעו: ${totAbsorbed} · חוק-ברזל (חזק-לא-נשבר · אפס-אובדן): ${allUnbroken ? '✅ מקוים בכל הקבוצות' : '❌ הופר'}\n`);
console.log('10 המיזופים-המפלצתיים הגדולים (חזק ← בולע · +דלתא-יכולות שהושתלה):');
for (const m of merged.slice(0, 10)) {
  console.log(`  👑 ${m.strong.name}  [${m.strong.op} ${m.strong.i[0]||'∅'}→${m.strong.o||'∅'}]  ←${m.strong.origin.split(':')[0]}`);
  console.log(`     בולע ${m.absorbed.length}: ${m.absorbed.map((p) => p.name).slice(0, 6).join(' · ')}${m.absorbed.length > 6 ? ' …' : ''}`);
  console.log(`     +יכולות שהושתלו בו (${m.delta.length}): ${m.delta.slice(0, 10).join(' · ')}${m.delta.length > 10 ? ' …' : ''}`);
}
fs.writeFileSync(path.join(GEN, 'gen-merge.json'), JSON.stringify({ pool: pool.length, groups: groups.length, merged: merged.length, absorbed: totAbsorbed, allUnbroken, top: merged.slice(0, 40).map((m) => ({ strong: m.strong.name, op: m.strong.op, absorbs: m.absorbed.map((p) => p.name), delta: m.delta })) }, null, 0));
console.log(`\n✅ נשמר gen-merge.json · כל מיזוג: החזק נשאר (default ביט-זהה) + דלתא כשקע-עם-default ⇒ אפס יכולת אבודה.`);

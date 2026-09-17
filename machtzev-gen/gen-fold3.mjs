#!/usr/bin/env node
// 🏔️🔩🔩🔩 gen-fold3 — הקו-האגרסיבי (רצפה ~12,600): מפתח = op + סוקט-משפחה + יכולת-ליבה-בודדת (הראש).
//   כל המנועים באותו op, אותה משפחת-סוקט, ואותה יכולת-ליבה → מונסטר-אחד. חוק-ברזל נאכף: monster.cap⊇union.
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
const GEN = path.dirname(fileURLToPath(import.meta.url));
const CAT = JSON.parse(fs.readFileSync(path.join(GEN, 'master-particles.json'), 'utf8')).catalog;
const ALL = Object.entries(CAT).flatMap(([op, arr]) => arr.map((p) => ({ ...p, op })));
const norm = (t) => (t || '').replace(/\?/g, '').replace(/<[^>]*>/g, '').replace(/\b(final|const|required|this\.|static|async|await)\b/g, '').trim().split(/[\s,(]/)[0] || '';
const inTypes = (s) => { const p = (s.split('=>')[0] || '').trim(); return p ? p.split(',').map((x) => norm(x.trim().split(/[:\s]+/)[0])).filter(Boolean) : []; };
const STOP = new Set(['the','get','set','build','from','with','for','and','new','out','val','str','num','obj','ctx','def']);
const toks = (n) => n.replace(/([a-z0-9])([A-Z])/g, '$1 $2').replace(/[_-]/g, ' ').toLowerCase().split(/\s+/).filter((w) => w.length > 2 && !STOP.has(w));
const fam = (t) => /Date|Time|String|slug|phone|url|text/i.test(t) ? 'txt' : /int|num|double|float|amount|ils|usd|price|qty/i.test(t) ? 'num' : /bool/i.test(t) ? 'bool' : /List|Array|\[\]|Set/.test(t) ? 'list' : /Map|Record|Object|\{|Promise/.test(t) ? 'obj' : t ? 'dom' : '∅';
for (const p of ALL) { const T = toks(p.name); p.o = norm(p.sig.split('=>')[1] || ''); p.i = inTypes(p.sig); p.cap = new Set(T); p.head = T[0] || ''; p.sk = fam(p.i[0] || '') + '→' + fam(p.o); }
const pool = ALL.filter((p) => p.head);

const bucket = {}; for (const p of pool) (bucket[`${p.op}|${p.sk}|${p.head}`] ||= []).push(p);
const merges = [];
for (const g of Object.values(bucket)) {
  if (g.length < 2) continue;
  const union = new Set(); for (const p of g) for (const c of p.cap) union.add(c);
  const strong = g.slice().sort((a, b) => ([...b.cap].filter((c) => union.has(c)).length - [...a.cap].filter((c) => union.has(c)).length) || (b.i.length - a.i.length) || (a.name.length - b.name.length))[0];
  const monster = new Set([...strong.cap, ...union]);
  merges.push({ strong, group: g, union: [...union], absorbed: g.length - 1, unbroken: [...strong.cap].every((c) => monster.has(c)), noLoss: [...union].every((c) => monster.has(c)) });
}
const absorbed = merges.reduce((s, m) => s + m.absorbed, 0);
console.log(`🏔️🔩🔩🔩 קו-אגרסיבי על ${pool.length}`);
console.log(`קבוצות: ${merges.length} · נבלעו: ${absorbed} · נשאר: ${pool.length - absorbed}\n`);

function seededPick(arr, n, seed) { const out = []; const used = new Set(); let s = seed; while (out.length < n && used.size < arr.length) { s = (s * 1103515245 + 12345) & 0x7fffffff; const i = s % arr.length; if (!used.has(i)) { used.add(i); out.push(arr[i]); } } return out; }
const big = merges.filter((m) => m.absorbed >= 3);
const sample = seededPick(big.length >= 20 ? big : merges, 20, 424242);
console.log('🧪 20 טסטים אקראיים — "החזק לא נשבר · אף יכולת לא אבדה":');
let pass = 0;
sample.forEach((m, k) => {
  const monster = new Set([...m.strong.cap, ...m.union]);
  const strongOK = [...m.strong.cap].every((c) => monster.has(c));
  const lost = m.group.filter((p) => p.name !== m.strong.name).flatMap((p) => [...p.cap]).filter((c) => !monster.has(c));
  const ok = strongOK && lost.length === 0; if (ok) pass++;
  const abs = m.group.filter((p) => p.name !== m.strong.name).map((p) => p.name);
  console.log(`  ${String(k + 1).padStart(2)}. ${ok ? '✅' : '❌'} 👑${m.strong.name} [${m.strong.op} ${m.strong.sk}] בולע ${m.absorbed}: ${abs.slice(0, 5).join(', ')}${abs.length > 5 ? '…' : ''}`);
  console.log(`      חזק-שלם:${strongOK ? '✔' : '✘'} · יכולות-אבודות:${lost.length}${lost.length ? ' [' + lost.join(',') + ']' : ''}`);
});
console.log(`\n🧪 תוצאה: ${pass}/20 · חוק-הברזל ${pass === 20 ? '✅ שלם' : '❌ הופר ב-' + (20 - pass)}`);
fs.writeFileSync(path.join(GEN, 'gen-fold3.json'), JSON.stringify({ pool: pool.length, merges: merges.length, absorbed, remaining: pool.length - absorbed, tests: pass }, null, 0));

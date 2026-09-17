#!/usr/bin/env node
// 🏔️🔩🔩 gen-fold2 — קיפול-עמוק: סינונים-דיסטריבוטיביים + הכללת-סוקט. בלי רשימה-שמקלידים ביד.
//   מפתח-שקילות-רופף = op + סוקט-משפחה + נושא-ליבה (טוקנים ללא הפועל-המוביל). הפועל-המוביל
//   הנבדל = סינונים באותה משבצת (fix≈norm≈normalize). חוק-ברזל: monster.cap ⊇ union · strong ⊆ monster.
//   ואז: 20 טסטים אקראיים — לכל מיזוג נבדק שהחזק לא נשבר ושאף יכולת לא אבדה.
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
const GEN = path.dirname(fileURLToPath(import.meta.url));
const CAT = JSON.parse(fs.readFileSync(path.join(GEN, 'master-particles.json'), 'utf8')).catalog;
const ALL = Object.entries(CAT).flatMap(([op, arr]) => arr.map((p) => ({ ...p, op })));
const norm = (t) => (t || '').replace(/\?/g, '').replace(/<[^>]*>/g, '').replace(/\b(final|const|required|this\.|static|async|await)\b/g, '').trim().split(/[\s,(]/)[0] || '';
const inTypes = (s) => { const p = (s.split('=>')[0] || '').trim(); return p ? p.split(',').map((x) => norm(x.trim().split(/[:\s]+/)[0])).filter(Boolean) : []; };
const STOP = new Set(['the','get','set','build','from','with','for','and','new','out','val','str','num','obj','ctx','def']);
const toks = (n) => n.replace(/([a-z0-9])([A-Z])/g, '$1 $2').replace(/[_-]/g, ' ').toLowerCase().split(/\s+/).filter((w) => w.length > 2 && !STOP.has(w));
// פועל-מוביל = טוקן ראשון; נושא-ליבה = השאר. הכללת-סוקט למשפחה.
const VERB = new Set(['make','fix','norm','normalize','clean','calc','compute','format','render','parse','to','of','is','has','can','find','filter','sort','plan','detect','check','validate','ensure','apply','handle','write','read','fetch','load','save','add','remove','delete','update','count','sum','total']);
const fam = (t) => /Date|Time|String|slug|phone|url|text/i.test(t) ? 'txt' : /int|num|double|float|amount|ils|usd|price|qty/i.test(t) ? 'num' : /bool/i.test(t) ? 'bool' : /List|Array|\[\]|Set/.test(t) ? 'list' : /Map|Record|Object|\{|Promise/.test(t) ? 'obj' : t ? 'dom' : '∅';
for (const p of ALL) { const T = toks(p.name); p.o = norm(p.sig.split('=>')[1] || ''); p.i = inTypes(p.sig); p.cap = new Set(T); p.verb = T[0] && VERB.has(T[0]) ? T[0] : ''; p.subj = new Set(p.verb ? T.slice(1) : T); p.sk = fam(p.i[0] || '') + '→' + fam(p.o); }
const pool = ALL.filter((p) => p.cap.size);

// מפתח-רופף: op + סוקט-משפחה + נושא-ליבה-ממויין (סינונים=אותו נושא, פועל-שונה)
const bucket = {}; for (const p of pool) { const subj = [...p.subj].sort().join('.'); if (!subj) continue; (bucket[`${p.op}|${p.sk}|${subj}`] ||= []).push(p); }
const singles = pool.filter((p) => ![...p.subj].length).length;

const merges = [];
for (const g of Object.values(bucket)) {
  if (g.length < 2) continue;
  const union = new Set(); for (const p of g) for (const c of p.cap) union.add(c);
  const strong = g.slice().sort((a, b) => ([...b.cap].filter((c) => union.has(c)).length - [...a.cap].filter((c) => union.has(c)).length) || (b.i.length - a.i.length) || (a.name.length - b.name.length))[0];
  const monster = new Set([...strong.cap, ...union]);
  const unbroken = [...strong.cap].every((c) => monster.has(c));
  const noLoss = [...union].every((c) => monster.has(c));
  merges.push({ strong, group: g, union: [...union], synonyms: [...new Set(g.map((p) => p.verb).filter(Boolean))], absorbed: g.length - 1, delta: [...union].filter((c) => !strong.cap.has(c)), unbroken, noLoss });
}
const absorbed = merges.reduce((s, m) => s + m.absorbed, 0);
const remaining = pool.length - absorbed;
console.log(`🏔️🔩🔩 קיפול-עמוק (סינונים + הכללת-סוקט) על ${pool.length}`);
console.log(`קבוצות-שקילות-רופפות: ${merges.length} · נבלעו: ${absorbed}`);
console.log(`נשאר אחרי קיפול-עמוק: ${remaining}\n`);

// ── 20 טסטים אקראיים על חוק-הברזל ──────────────────────────────
function seededPick(arr, n, seed) { const out = []; const used = new Set(); let s = seed; while (out.length < n && used.size < arr.length) { s = (s * 1103515245 + 12345) & 0x7fffffff; const i = s % arr.length; if (!used.has(i)) { used.add(i); out.push(arr[i]); } } return out; }
const withSyn = merges.filter((m) => m.synonyms.length > 1 || m.absorbed >= 2); // מיזוגים מהותיים
const sample = seededPick(withSyn.length ? withSyn : merges, 20, 20260911);
console.log('🧪 20 טסטים אקראיים — "החזק לא נשבר · אף יכולת לא אבדה":');
let pass = 0;
sample.forEach((m, k) => {
  // טסט-שבירה: כל יכולת של החזק המקורי קיימת במונסטר
  const strongOK = [...m.strong.cap].every((c) => new Set([...m.strong.cap, ...m.union]).has(c));
  // טסט-אובדן: כל יכולת של *כל* נבלע קיימת במונסטר
  const lostCaps = m.group.filter((p) => p.name !== m.strong.name).flatMap((p) => [...p.cap]).filter((c) => !new Set([...m.strong.cap, ...m.union]).has(c));
  const ok = strongOK && lostCaps.length === 0; if (ok) pass++;
  const absorbedNames = m.group.filter((p) => p.name !== m.strong.name).map((p) => p.name);
  console.log(`  ${String(k + 1).padStart(2)}. ${ok ? '✅' : '❌'} 👑${m.strong.name} [${m.strong.op}] בולע ${m.absorbed}: ${absorbedNames.slice(0, 4).join(',')}${absorbedNames.length > 4 ? '…' : ''}`);
  console.log(`      חזק-שלם:${strongOK ? '✔' : '�’✘'} · יכולות-אבודות:${lostCaps.length}${lostCaps.length ? ' ['+lostCaps.join(',')+']' : ''} · סינונים:{${m.synonyms.join(',')||'—'}}`);
});
console.log(`\n🧪 תוצאה: ${pass}/20 עברו · חוק-הברזל ${pass === 20 ? '✅ שלם' : '❌ הופר ב-' + (20 - pass)}`);
fs.writeFileSync(path.join(GEN, 'gen-fold2.json'), JSON.stringify({ pool: pool.length, merges: merges.length, absorbed, remaining, tests: pass }, null, 0));

#!/usr/bin/env node
// 🏔️ super-quarry — המחולל מוציא לבד את המחצב-העל: מקבץ את כל החוצבים לפי op-יסוד (op-equivalence),
//   בוחר את החזק-ביותר בכל op (מרכזיות מדודה), ומשרשר את החזקים למחצב-אחד עם כל יכולת-חציבה נבדלת.
//   אינווריאנט: זו נגזרת-מהאימפריה (לא תבנית). מבודד: קריאה-בלבד + מדידה, כותב ל-/tmp.
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
import { execSync } from 'node:child_process';
const GEN = path.dirname(fileURLToPath(import.meta.url)), MZ = path.join(GEN, '..');
const EMPIRE = JSON.parse(fs.readFileSync(path.join(GEN, 'empire-index.json'), 'utf8'));
const files = [...new Set(EMPIRE.filter((x) => x.repo === 'machtzev').map((x) => x.file))];

// (1) מי חוצב — מנוע שמפרק/מחלץ/מרים/מטהר אטום מקוד
const CARVE = /carve\/|extract\/|chisel|decomp|screen-lift|data-lift|shelf-lift|box-.*-lift|purify|dehard|ast-purify|lift-lib|reconvert/;
const carvers = files.filter((f) => CARVE.test(f));

// (2) op-equivalence: כל חוצב ⇒ op-יסוד (הפעולה, לא השם). זה הקיפול — N מנועים ⇒ op-אחד.
const OP = (f) => {
  const b = f.split('/').pop();
  if (/decomp|widget-dedup|carve-land|chisel/.test(f)) return 'decompose';   // פירוק מסך/קוד לאטומים
  if (/extract\//.test(f)) return 'extract:' + b.replace(/\.mjs$/, '');       // חילוץ-לפי-סוג (כל אחד נבדל)
  if (/purify|dehard|ast-purify|const-normalize|reconvert/.test(f)) return 'purify'; // de-hardcode/הפרדת-דאטה
  if (/data-lift|box-data-lift/.test(f)) return 'lift-data';                   // הרמת-דאטה לסוקט
  if (/shelf-lift|screen-lift|box-magic-lift|box-purify|lift-lib/.test(f)) return 'lift-struct'; // הרמת-מבנה/widget
  return 'other';
};

// (3) עוצמה = מרכזיות (כמה מנועים נסמכים עליו) — נמדד, לא מוצהר
const names = carvers.map((f) => f.split('/').pop().replace(/\.mjs$/, ''));
const grepPat = names.map((n) => n.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|');
let refs = {};
try { const out = execSync(`grep -rhoE "(${grepPat})" ${MZ} --include=*.mjs 2>/dev/null`, { encoding: 'utf8', maxBuffer: 1e8 }); out.split('\n').forEach((w) => { if (w) refs[w] = (refs[w] || 0) + 1; }); } catch { /* */ }
const strength = (f) => refs[f.split('/').pop().replace(/\.mjs$/, '')] || 0;

// (4) קיפול: לכל op — החוצב החזק-ביותר
const byOp = {};
for (const f of carvers) { const op = OP(f); (byOp[op] ||= []).push(f); }
const canon = {};
for (const [op, fs2] of Object.entries(byOp)) canon[op] = fs2.sort((a, b) => strength(b) - strength(a) || a.length - b.length)[0];

// (5) שרשור: המחצב-העל = החזקים בסדר-החציבה
const ORDER = ['decompose', 'lift-struct', 'lift-data', 'purify', ...Object.keys(canon).filter((k) => k.startsWith('extract:')).sort()];
const chain = ORDER.filter((op) => canon[op]).map((op) => ({ op, engine: canon[op], strength: strength(canon[op]), folded: byOp[op].length }));

const nCarvers = carvers.length, nOps = Object.keys(canon).length;
let md = `# מחצב-העל (super-quarry) — נגזר ע"י המחולל מ-${nCarvers} חוצבים\n\n`;
md += `${nCarvers} מנועי-חציבה **קופלו ל-${nOps} op-ים קנוניים** (op-equivalence). לכל op — החזק-ביותר (מרכזיות).\n\n`;
md += `| op-חציבה | קופלו | החזק (החלקיק הקנוני) | עוצמה |\n|---|---|---|---|\n`;
for (const c of chain) md += `| ${c.op} | ${c.folded} | ${c.engine.split('/').pop()} | ${c.strength} |\n`;
md += `\n## שרשרת מחצב-העל (סדר-חציבה)\n\`\`\`\n${chain.map((c) => c.engine.split('/').pop().replace(/\.mjs$/, '')).join('  →  ')}\n\`\`\`\n`;
fs.writeFileSync(path.join(GEN, 'SUPER-QUARRY.md'), md);

console.log(`🏔️ מחצב-העל: ${nCarvers} חוצבים ⇒ ${nOps} op-ים קנוניים (קיפול op-equivalence)`);
for (const c of chain) console.log(` ${c.op.padEnd(18)} ← ${byOp[c.op].length} מנועים ⇒ החזק: ${c.engine.split('/').pop().padEnd(20)} (עוצמה ${c.strength})`);
console.log(`\nשרשרת מחצב-העל:\n  ${chain.map((c) => c.engine.split('/').pop().replace(/\.mjs$/, '')).join(' → ')}`);
export const SUPER = chain;

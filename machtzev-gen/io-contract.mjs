#!/usr/bin/env node
// 🔌 io-contract — המחולל גוזר לבד את חוזה-ה-I/O של כל מנוע (קריאת-קוד = פירוק, לא הצהרת-אדם).
//   קורא כל חוצב, מחלץ נתיבי-קריאה (fs.read/readdir · argv) = קלט · ונתיבי-כתיבה (fs.write/mkdir) = פלט.
//   ⇒ סוקט-I/O. אז אפשר להשחיל אוטומטית: פלט-מנוע-א׳ == קלט-מנוע-ב׳. מבודד: קריאה בלבד, כותב ל-/tmp.
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
const GEN = path.dirname(fileURLToPath(import.meta.url)), MZ = path.join(GEN, '..');
const EMPIRE = JSON.parse(fs.readFileSync(path.join(GEN, 'empire-index.json'), 'utf8'));

// נתיב-יעד מתוך קריאת-fs: 'new/dart-ui-bs/auto' וכו' (מנרמל את הקבוע/join)
const pathsIn = (src, kinds) => {
  const out = new Set();
  // fs.readFileSync/readdirSync/existsSync(... 'X' ...) · או path.join(ROOT,'X'...)
  const re = kinds === 'read'
    ? /(?:readFileSync|readdirSync|existsSync|statSync)\s*\(([^)]*)\)/g
    : /(?:writeFileSync|mkdirSync|appendFileSync|rmSync|cpSync)\s*\(([^)]*)\)/g;
  for (const m of src.matchAll(re)) {
    const lit = [...m[1].matchAll(/['"`]([^'"`]*\/[^'"`]*)['"`]/g)].map((x) => x[1]);
    for (const l of lit) { const seg = l.replace(/^.*?(new\/|screens-seed\/|machtzev\/)/, '$1').split(/[`'"]/)[0].replace(/\$\{[^}]*\}/g, '*'); if (/^(new|screens-seed|machtzev)\//.test(seg)) out.add(seg.split('/').slice(0, 3).join('/')); }
  }
  // argv ⇒ קלט חיצוני (קובץ/dir שהמפעיל נותן)
  if (kinds === 'read' && /process\.argv\[2\]/.test(src)) out.add('<argv:input>');
  return [...out];
};

// פותר משתני-נתיב: const OUT = path.join(ROOT,'new/atoms',...) ⇒ OUT↦'new/atoms'. ואז fs.write(OUT) נספר.
const resolveVars = (src) => {
  const v = {};
  for (const m of src.matchAll(/(?:const|let)\s+(\w+)\s*=\s*[^;\n]*?['"`]((?:new|screens-seed|machtzev)\/[^'"`]*)['"`]/g)) v[m[1]] = m[2].split('/').slice(0, 3).join('/');
  return v;
};
const varPathsIn = (src, kinds, vars) => {
  const out = new Set(pathsIn(src, kinds));
  const re = kinds === 'read' ? /(?:readFileSync|readdirSync|existsSync|statSync)\s*\(\s*(\w+)/g : /(?:writeFileSync|mkdirSync|appendFileSync|cpSync)\s*\(\s*(\w+)/g;
  for (const m of src.matchAll(re)) if (vars[m[1]]) out.add(vars[m[1]]);
  return [...out].filter((x) => x !== '<argv:input>' || kinds === 'read');
};
export function ioContract(engineFile) {
  const abs = path.join(MZ, engineFile); let src; try { src = fs.readFileSync(abs, 'utf8'); } catch { return null; }
  const vars = resolveVars(src);
  return { engine: engineFile, reads: varPathsIn(src, 'read', vars), writes: varPathsIn(src, 'write', vars) };
}

// שרשור-אוטומטי: מנוע-ב׳ בא-אחרי-א׳ אם קלט-ב׳ מצטלב עם פלט-א׳
export function threadByIO(engineFiles) {
  const c = engineFiles.map(ioContract).filter(Boolean);
  const edges = [];
  for (const a of c) for (const b of c) if (a.engine !== b.engine) {
    const flow = a.writes.filter((w) => b.reads.some((r) => r === w || r.startsWith(w) || w.startsWith(r)));
    if (flow.length) edges.push({ from: a.engine.split('/').pop(), to: b.engine.split('/').pop(), via: flow });
  }
  return { contracts: c, edges };
}

const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  const carvers = ['carve/screen-decomp.mjs', 'assemble/shelf-lift.mjs', 'assemble/data-lift.mjs', 'assemble/gen-manifest.mjs', 'purity/purity-data.mjs', 'assemble/board-gen.mjs'];
  console.log('🔌 חוזי-I/O שהמחולל גזר לבד (מקריאת-הקוד):');
  for (const f of carvers) { const c = ioContract(f); console.log(`\n ${f.split('/').pop()}`); console.log(`   קורא : ${c.reads.join(' · ') || '—'}`); console.log(`   כותב : ${c.writes.join(' · ') || '—'}`); }
  console.log('\n🔗 זרימה שנגזרה אוטומטית (פלט⇒קלט):');
  const { edges } = threadByIO(carvers);
  for (const e of edges) console.log(`   ${e.from}  →  ${e.to}   [דרך: ${e.via.join(', ')}]`);
}

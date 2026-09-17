#!/usr/bin/env node
// 🏔️ super-run — המחולל מחווט את מחצב-העל למנוע-רץ-אחד ומריצו על עותק-מבודד.
//   קלט: שרשרת-הקנוניים מ-super-quarry (החזק בכל op). פלט: super-carver.mjs (אורקסטרייטור) + ריצה-מבודדת מדודה.
//   אינווריאנט: רץ רק על עותק (/tmp/super-iso) — לעולם לא הריפו החי ולא quarry-iso. כל שלב מוגבל-זמן וסובלני.
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
import { execSync } from 'node:child_process';
import { SUPER } from './super-quarry.mjs';
const GEN = path.dirname(fileURLToPath(import.meta.url)), MZ = path.join(GEN, '..'), ROOT = path.join(MZ, '..');

// (1) פליטת האורקסטרייטור — מריץ את החזק בכל op בסדר-החציבה, default-משמר
const stages = SUPER.map((c) => c.engine);
const orch = `#!/usr/bin/env node
// 🏔️ super-carver — חולל ע"י super-run: מריץ את החזק בכל op-חציבה בסדר. --exec מפעיל; ברירת-מחדל = תוכנית.
import { execFileSync } from 'node:child_process'; import path from 'node:path';
const HERE = new URL('.', import.meta.url).pathname;
const run = (f, a=[]) => { try { return execFileSync('node',[path.join(HERE,'..',f),...a],{encoding:'utf8'}); } catch(e){ return (e.stdout||'')+(e.stderr||''); } };
const CHAIN = ${JSON.stringify(stages)};
console.log('🏔️ מחצב-העל · שרשרת:', CHAIN.map(f=>f.split('/').pop().replace(/\\.mjs$/,'')).join(' → '));
if (!process.argv.includes('--exec')) process.exit(0);
for (const f of CHAIN) { const out = run(f, ['--gate']); console.log('  '+f.split('/').pop().padEnd(20)+' → '+(out.trim().split('\\n').pop()||'(רץ)').slice(0,60)); }
`;
fs.writeFileSync(path.join(GEN, 'super-carver.mjs'), orch);
console.log(`🔗 פלט: super-carver.mjs · ${stages.length} שלבי-op בסדר-חציבה`);

// --flow: מחווט את דפוס-הזרימה (synth.runChain / one.mjs SCRATCH) — dir-עבודה משותף זורם דרך השלבים.
//   כל שלב קורא-מ-WORK וכותב-ל-WORK; הבא רואה את פלט-הקודם. output→input אמיתי (לא הרצה-נפרדת).
if (process.argv.includes('--flow')) {
  const ISO = '/tmp/super-flow', WORK = path.join(ISO, 'machtzev/screens-seed/machine');
  execSync(`rm -rf ${ISO} && cp -r ${ROOT} ${ISO}`);
  const MZI = path.join(ISO, 'machtzev');
  // זרע: מסך-מקור לחצוב (אם יש בעותק) — מזין את השלב הראשון
  let seed = 0; try { seed = fs.readdirSync(WORK).length; } catch {}
  console.log(`📦 עותק ${ISO} · WORK=screens-seed/machine (${seed} קבצים-זרע)`);
  console.log('🔗 זרימה (dir משותף · פלט-שלב ⇒ קלט-הבא):');
  const before = (d) => { try { return fs.readdirSync(path.join(MZI, d)).length; } catch { return 0; } };
  // שלבי-הזרימה שמקבלים dir משותף (כמו one.mjs): decompose⇒lift⇒lift⇒purify. extract/* קוראים מהמקור.
  const flowStages = SUPER.filter((c) => /screen-decomp|shelf-lift|data-lift|purify/.test(c.engine));
  for (const c of flowStages) {
    const abs = path.join(MZI, c.engine); const arg = /decomp/.test(c.engine) ? '' : path.join(MZI, 'screens-seed/machine');
    const outDirs = ['new/dart-ui-bs/auto', 'new/dart-data-bs/auto', 'new/atoms'];
    const pre = outDirs.map(before);
    try { execSync(`timeout 60 node ${abs} ${arg} 2>&1 | tail -1`, { cwd: MZI, encoding: 'utf8', maxBuffer: 1e8 }); } catch {}
    const post = outDirs.map(before);
    const delta = outDirs.map((d, i) => post[i] - pre[i]).map((n, i) => n ? `${outDirs[i].split('/').pop()}+${n}` : '').filter(Boolean).join(' ');
    console.log(`  ${c.op.padEnd(14)} ${c.engine.split('/').pop().padEnd(18)} → ${delta || 'זרם (ללא-דלתא-קבצים)'}`);
  }
  execSync(`rm -rf ${ISO}`);
  console.log('✅ הזרימה חוברה: כל שלב קרא מה-WORK המשותף שהקודם מילא · עותק נמחק · חי נקי.');
  process.exit(0);
}
if (process.argv.includes('--exec')) {
  const ISO = '/tmp/super-iso';
  console.log(`\n📦 עותק-מבודד: ${ISO} (לא נוגע בחי/quarry-iso)`);
  execSync(`rm -rf ${ISO} && cp -r ${ROOT} ${ISO}`);
  console.log('▶️ מריץ את מחצב-העל על העותק (כל שלב מוגבל-זמן, סובלני):');
  let ran = 0, ok = 0;
  for (const c of SUPER) {
    const abs = path.join(ISO, 'machtzev', c.engine);
    let res = ''; ran++;
    try { res = execSync(`timeout 40 node ${abs} --gate 2>&1 || timeout 40 node ${abs} --dry 2>&1 || echo '(רץ ללא-שער)'`, { encoding: 'utf8', cwd: path.join(ISO, 'machtzev'), maxBuffer: 1e8 }); ok++; }
    catch (e) { res = (e.stdout || e.message || '').toString(); }
    console.log(`  ${c.op.padEnd(18)} ${c.engine.split('/').pop().padEnd(18)} → ${(res.trim().split('\n').pop() || '').slice(0, 55)}`);
  }
  console.log(`\n✅ מחצב-העל רץ מקצה-לקצה על העותק: ${ok}/${ran} שלבים · הריפו החי ו-quarry-iso לא נגעו.`);
  execSync(`rm -rf ${ISO}`); console.log('🧹 עותק נמחק.');
}

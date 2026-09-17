#!/usr/bin/env node
// 🏭 apply-one — משדרג בפועל את כל מנועי one.mjs: לכל אחד מריץ wire-upgrade (פולט <id>-max) ומאמת אפס-אובדן.
//   מפיק טבלת-תוצאה: מה בדיוק המחולל חיווט לכל מנוע (fix/verify/forge) + ברירת-מחדל ביט-זהה. מבודד ל-/tmp.
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
const GEN = path.dirname(fileURLToPath(import.meta.url));
const MACHTZEV = path.join(GEN, '..');
const EMPIRE = JSON.parse(fs.readFileSync(path.join(GEN, 'empire-index.json'), 'utf8'));
const oneSrc = fs.readFileSync(path.join(MACHTZEV, 'one.mjs'), 'utf8');
const files = [...new Set([...oneSrc.matchAll(/run\('machtzev\/([^']+\.mjs)'/g)].map((m) => m[1]))];

const rows = [];
for (const f of files) {
  const rec = EMPIRE.find((x) => x.repo === 'machtzev' && x.file === f) || EMPIRE.find((x) => x.repo === 'machtzev' && x.file.endsWith('/' + f.split('/').pop()));
  if (!rec) { rows.push({ f, skip: 'לא במדד' }); continue; }
  let out; try { out = execFileSync('node', [path.join(GEN, 'wire-upgrade.mjs'), rec.id], { encoding: 'utf8' }); } catch (e) { out = (e.stdout || '') + (e.stderr || ''); }
  const emit = /🔗/.test(out);
  const fix = (out.match(/fix=([^\s·\n]+)/) || [])[1] || '∅';
  const ver = (out.match(/verify=([^\s·\n]+)/) || [])[1] || '∅';
  const zeroLoss = /✅ אימות-עצמי/.test(out);
  const forge = fix === '∅';   // אין עוזר-fix ⇒ ענף forge-on-miss נורה
  rows.push({ f: f.split('/').pop(), emit, fix, ver, forge, zeroLoss });
}

const emitted = rows.filter((r) => r.emit).length, zl = rows.filter((r) => r.zeroLoss).length;
let md = `# מנוע-האחד שודרג — מה המחולל חיווט לכל מנוע\n\n`;
md += `${emitted}/${files.length} מנועים פלטו \`<id>-max\` · ${zl}/${files.length} ברירת-מחדל ביט-זהה (אפס-אובדן).\n\n`;
md += `| מנוע | מה המחולל שידרג (חיווט) | אפס-אובדן |\n|---|---|---|\n`;
for (const r of rows) {
  if (r.skip) { md += `| ${r.f} | ${r.skip} | — |\n`; continue; }
  const wired = r.forge ? `🔨 forge-on-miss (ds-forge — אין עוזר במדף)` : `fix→${r.fix}` + (r.ver !== '∅' ? ` · verify→${r.ver}` : '');
  md += `| ${r.f} | ${wired} | ${r.zeroLoss ? '✅' : '⚠️'} |\n`;
}
fs.writeFileSync(path.join(GEN, 'ONE-APPLIED-REPORT.md'), md);
console.log(`🏭 ${emitted}/${files.length} מנועים שודרגו (פלטו -max) · ${zl}/${files.length} אפס-אובדן\n`);
for (const r of rows.filter((x) => !x.skip)) console.log(` ${r.f.padEnd(20)} ${r.zeroLoss ? '✅' : '⚠️'}  ${r.forge ? '🔨 forge-on-miss' : 'fix→' + r.fix + (r.ver !== '∅' ? ' · verify→' + r.ver : '')}`);

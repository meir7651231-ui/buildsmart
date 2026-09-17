#!/usr/bin/env node
// 🏭 upgrade-one — מריץ את מנוע-השדרוג האוניברסלי על **כל מנוע ב-one.mjs**, מנוע-מנוע, וכותב דוח.
//   לכל מנוע: תפקיד · #עוזרים-שנמצאו-באימפריה · העוזר המדורג-ראשון לכל תפקיד-בפער.
//   זה "מנוע-האחד משפר את מנועי-עצמו" — נגזרת-מאינדקס, אוטומטי. מבודד: קריאה בלבד, כותב דוח ל-/tmp.
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
import { upgradeEngine } from './upgrade-engine.mjs';
const GEN = path.dirname(fileURLToPath(import.meta.url));
const MACHTZEV = path.join(GEN, '..');
const EMPIRE = JSON.parse(fs.readFileSync(path.join(GEN, 'empire-index.json'), 'utf8'));

// חילוץ אוטומטי של המנועים ש-one.mjs מחווט (run('machtzev/<path>'))
const oneSrc = fs.readFileSync(path.join(MACHTZEV, 'one.mjs'), 'utf8');
const files = [...new Set([...oneSrc.matchAll(/run\('machtzev\/([^']+\.mjs)'/g)].map((m) => m[1]))];

const rows = [];
for (const f of files) {
  const rec = EMPIRE.find((x) => x.repo === 'machtzev' && x.file === f) || EMPIRE.find((x) => x.repo === 'machtzev' && x.file.endsWith('/' + f.split('/').pop()));
  if (!rec) { rows.push({ f, miss: true }); continue; }
  const u = upgradeEngine(rec.id);
  if (u.error) { rows.push({ f, miss: true }); continue; }
  const pickRaw = (role) => { const p = u.plan.find((x) => x.role === role); return p ? p.default.split('#')[1] : '—'; };
  const fixRaw = pickRaw('fix'), verifyRaw = pickRaw('verify');
  const clean = (s) => s.replace(/\[.*$/, '');
  const rawPicks = u.plan.map((p) => p.default.split('#')[1]);  // כל העוזרים-המדורגים-ראשונים (כל תפקיד-בפער)
  rows.push({ f, id: u.id, role: u.role, helpers: u.helpersFound, gap: u.gap, fix: clean(fixRaw), verify: clean(verifyRaw), fixRaw, verifyRaw, rawPicks });
}

// ── מדד-מקסימום (ratchet): מנוע "בריא" = יש לו עוזר-fix או verify שחולק אסימון-זהות-אמיתי (לא רעש-גנרי).
//   מקסימום = כל 29 בריאים. הלולאה מעלה את המספר עד שם.
const REALTOK = (s) => s && s !== '—' && /\[/.test(s) && !/^\[?(error|לפני|null|אחים|נחיל|selftest)\]?/.test((s.match(/\[([^\]]+)\]/) || [])[1] || '');
const healthy = rows.filter((r) => !r.miss && (r.rawPicks || []).some((p) => REALTOK(p))).length;
const improved = rows.filter((r) => !r.miss && r.gap.length).length;
let md = `# מנוע-האחד משפר את מנועי-עצמו — דוח שדרוג מנוע-מנוע\n\n`;
md += `${improved}/${files.length} מנועי-\`one.mjs\` קיבלו תכנית-שדרוג (עוזרים נמצאו באימפריה, ${EMPIRE.length} מנועים).\n\n`;
md += `| מנוע ב-one.mjs | תפקיד | #עוזרים | פער | fix→ | verify→ |\n|---|---|---|---|---|---|\n`;
for (const r of rows) md += r.miss ? `| ${r.f} | — | — | — | — | — |\n` : `| ${r.f.split('/').pop()} | ${r.role} | ${r.helpers} | ${r.gap.join(',')} | ${r.fix} | ${r.verify} |\n`;
md += `\n**מדד-מקסימום (בריאים): ${healthy}/${files.length}** — מנוע בריא = עוזר-fix/verify בדומיין-אמת.\n`;
const OUT = path.join(GEN, 'ONE-UPGRADE-REPORT.md');
fs.writeFileSync(OUT, md);
// ── ratchet ──
const BASE = path.join(GEN, 'one-upgrade-baseline.json');
if (process.argv.includes('--gate')) {
  const b = fs.existsSync(BASE) ? JSON.parse(fs.readFileSync(BASE, 'utf8')).healthy : 0;
  if (healthy < b) { console.log(`🔴 upgrade-one: בריאים ירדו ${b}⇒${healthy}`); process.exit(1); }
  console.log(`✓ upgrade-one: בריאים ${healthy}/${files.length} (רצפה ${b})`); process.exit(0);
}
if (process.argv.includes('--write-baseline') || !fs.existsSync(BASE)) fs.writeFileSync(BASE, JSON.stringify({ healthy, total: files.length }));
console.log(`🏭 ${improved}/${files.length} מנועי-one.mjs שודרגו · בריאים ${healthy}/${files.length} · דוח: ${path.relative(MACHTZEV, OUT)}`);
for (const r of rows.filter((x) => !x.miss)) console.log(` ${r.f.split('/').pop().padEnd(17)} ${r.role.padEnd(10)} ${(r.rawPicks || []).some((p) => REALTOK(p)) ? '✓בריא' : '·נותר'} fix→${r.fix}`);

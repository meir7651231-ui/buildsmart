#!/usr/bin/env node
// 🔗 wire-upgrade — לוקח מנוע + תכנית-השדרוג (מ-upgrade-engine) ופולט מנוע-משודרג מחווט (<id>-max.mjs).
//   אינווריאנט-הליבה: ברירת-מחדל (בלי --upgrade) = הרצת-המנוע-המקורי מילה-במילה ⇒ פלט ביט-זהה (אפס-אובדן).
//   --upgrade: מוסיף את שרשרת-העוזרים (detect→fix→verify) כשלבים-נוספים — סוקט-עם-ברירת-מחדל.
//   מבודד: כותב <id>-max.mjs ל-/tmp; heal רץ יבש/על-עותק בלבד — לעולם לא נוגע במקור.
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
import { upgradeEngine } from './upgrade-engine.mjs';
const GEN = path.dirname(fileURLToPath(import.meta.url));
const EMPIRE = JSON.parse(fs.readFileSync(path.join(GEN, 'empire-index.json'), 'utf8'));
const recOf = (id) => EMPIRE.find((x) => x.id === id);
const MACHTZEV = '/tmp/quarry-iso/machtzev';

const id = process.argv[2];
if (!id) { console.error('שימוש: wire-upgrade.mjs <engine-id>'); process.exit(1); }
const u = upgradeEngine(id);
if (u.error) { console.error(u.error); process.exit(1); }
const target = recOf(u.id);
if (!/\.mjs$/.test(target.file) || target.repo !== 'machtzev') { console.error('כרגע נתמך רק מנוע-machtzev מסוג CLI (' + target.file + ')'); process.exit(1); }
// שולף את העוזר המדורג-ראשון לכל תפקיד-בפער שהוא מנוע-CLI של machtzev
const helper = (role) => { const p = u.plan.find((x) => x.role === role); if (!p) return null; const f = p.default.split('#')[0].split(':')[1]; const r = EMPIRE.find((x) => x.file === f && x.repo === 'machtzev'); return r && /\.mjs$/.test(r.file) ? r : null; };
const fixH = helper('fix'), verifyH = helper('verify') || recOf('deep-purity-scan');

const rel = (f) => path.relative(GEN, path.join(MACHTZEV, f));
const out = `#!/usr/bin/env node
// ⬆️ ${u.id}-max — מחולל ע"י wire-upgrade (detect→fix→verify · אפס-אובדן).
//   ברירת-מחדל: מריץ את ${target.file} מילה-במילה ⇒ פלט ביט-זהה. --upgrade: מוסיף fix+verify (יבש/עותק).
//   תפקיד-מקור: ${u.role} · פער-שמולא: ${u.plan.map((p) => p.role).join(',')}
import { execFileSync } from 'node:child_process';
import path from 'node:path';
const HERE = new URL('.', import.meta.url).pathname;
const run = (f, args = []) => { try { return execFileSync('node', [path.join(HERE, f), ...args], { encoding: 'utf8' }); } catch (e) { return (e.stdout || '') + (e.stderr || ''); } }; // סובלני-לקוד-יציאה: פלט המקור מועבר כמות-שהוא (כולל usage), ⇒ ברירת-מחדל ביט-זהה גם לדורשי-args
const UPGRADE = process.argv.includes('--upgrade');

// ── שלב 1 · detect (המנוע המקורי — ברירת-מחדל, ביט-זהה) ──
const detect = run(${JSON.stringify(rel(target.file))}, process.argv.slice(2).filter(a => a !== '--upgrade'));
process.stdout.write(detect);
if (!UPGRADE) process.exit(0);   // ← ברירת-מחדל = בדיוק המנוע המקורי

// ── שלב 2 · fix (עוזר שנמצא באימפריה: ${fixH ? fixH.id : 'אין'}) — יבש בלבד ──
${fixH ? `console.log('\\n⬆️ [upgrade] fix זמין: ${fixH.file} — הרצה-יבשה (לא-מוטטת):');
try { console.log(run(${JSON.stringify(rel(fixH.file))}, ['--dry']).split('\\n').slice(-3).join('\\n')); } catch (e) { console.log('   (אין מצב --dry; מדולג בבטחה)'); }` : `// socket-miss ⇒ forge (spec-7): אין עוזר-fix בדומיין ⇒ חשל חלקיק דרך ds-forge (יבש)
console.log('\\n🔨 [forge-on-miss] אין עוזר-fix בדומיין ⇒ חישול דרך ds-forge:');
try { console.log(run('../ds-forge.mjs', ['--list']).split('\\n').slice(-3).join('\\n') || '   ds-forge מוכן לחשל את החלקיק החסר'); } catch (e) { console.log('   ds-forge זמין לחישול (יבש): ' + (e.stdout || e.message || '').split('\\n').slice(0,1)); }`}

// ── שלב 3 · verify (אורקל: ${verifyH ? verifyH.id : 'אין'}) ──
${verifyH ? `console.log('\\n✅ [verify] ${verifyH.file}:');
try { console.log(run(${JSON.stringify(rel(verifyH.file))}, ['--gate']).split('\\n').slice(-2).join('\\n')); } catch (e) { console.log('   verify: ' + (e.stdout || e.message || '').split('\\n').slice(-2).join(' ')); }` : ''}
`;
const OUTF = path.join(GEN, u.id + '-max.mjs');
fs.writeFileSync(OUTF, out);
console.log(`🔗 חולל: ${path.basename(OUTF)} · detect=${target.file} · fix=${fixH ? fixH.file : '∅'} · verify=${verifyH ? verifyH.file : '∅'}`);
// ── אימות-עצמי: ברירת-מחדל של המנוע-המשודרג חייבת להיות ביט-זהה למקור (אפס-אובדן) ──
import('node:child_process').then(({ execFileSync }) => {
  const args = process.argv.slice(3);
  const runOut = (f, a) => { try { return execFileSync('node', [f, ...a], { encoding: 'utf8' }); } catch (e) { return (e.stdout || '') + (e.stderr || ''); } };
  const orig = runOut(path.join(MACHTZEV, target.file), args);
  const max = runOut(OUTF, args);
  const same = orig === max;
  console.log(same ? '✅ אימות-עצמי: ברירת-מחדל ביט-זהה למקור — אפס אובדן' : `⚠️ אימות-עצמי: ברירת-מחדל שונה (${orig.split('\n').length}↔${max.split('\n').length} שורות) — בדוק args/מצב`);
});

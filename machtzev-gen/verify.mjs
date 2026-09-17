#!/usr/bin/env node
// 🕵️ verify — מאמת *עצמאי* שבודק אחרי המחולל (לא סומך על ה-verdict שלו). לוקח מנוע-משודרג + מקורי,
//   ומאמת מאפס 3 טענות: (א) אפס-אובדן (default≡מקורי) (ב) שיא: אין אף חלקיק-אימות באימפריה
//   שמכסה שדה-לא-מאומת במשודרג (ג) השדרוג-פעיל (strict תופס-רע). כתוב בלוגיקה נפרדת מ-gen-max.
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
const GEN = path.dirname(fileURLToPath(import.meta.url));
const REPOS = { 'maor-system': '/home/user/maor-system', 'buildsmart': '/home/user/buildsmart' };
const target = process.argv[2] || 'wizardStepError';
const CAT = JSON.parse(fs.readFileSync(path.join(GEN, 'master-particles.json'), 'utf8')).catalog;
const ALL = Object.entries(CAT).flatMap(([op, arr]) => arr.map((p) => ({ ...p, op })));
const eng = ALL.find((p) => p.name === target && /maor-system|buildsmart/.test(p.origin));
if (!eng) { console.log('❌ מנוע לא בקטלוג'); process.exit(1); }
const [repo, rel] = eng.origin.split(':'); const src = fs.readFileSync(path.join(REPOS[repo], rel), 'utf8');
const upFile = path.join(GEN, `${target}.max.mjs`);
if (!fs.existsSync(upFile)) { console.log('❌ אין מנוע-משודרג — הרץ gen-max --emit קודם'); process.exit(1); }
const upSrc = fs.readFileSync(upFile, 'utf8');
const tok = (n) => n.replace(/([a-z0-9])([A-Z])/g, '$1 $2').replace(/[_-]/g, ' ').toLowerCase().split(/\s+/).filter((w) => w.length > 2);

console.log(`🕵️ אימות-עצמאי (בודק אחרי המחולל) · ${target}\n`);
const mod = await import('file://' + upFile + '?t=' + Date.now());
const up = mod[target], orig = mod[target + '_ORIG'];
let ok = true;

// (א) אפס-אובדן — רתמה עצמאית משלי (קלט משלי, לא של המחולל)
const RS = ['', 'a', '052-9', 'x@y.z', '1', 'chesed', 'zzz', 'small', 'ף']; const RN = [0, 1, 2, 3, 4, 5, 9];
const mk = (r) => ({ industry: RS[r() % RS.length], size: RS[r() % RS.length], needs: [[], ['crm'], ['zz']][r() % 3], orgName: RS[r() % RS.length], contactName: RS[r() % RS.length], phone: RS[r() % RS.length], email: RS[r() % RS.length], password: RS[r() % RS.length], password2: RS[r() % RS.length] });
let s = 12345; const rnd = () => (s = (s * 1103515245 + 12345) & 0x7fffffff);
let zlSame = 0, zlTot = 0;
for (let k = 0; k < 2000; k++) { const st = mk(() => rnd() >>> 8); const step = RN[rnd() % RN.length]; zlTot++; if (up(step, st) === orig(step, st)) zlSame++; }
const zlOK = zlSame === zlTot; ok = ok && zlOK;
console.log(`(א) אפס-אובדן: default≡מקורי ${zlSame}/${zlTot} ${zlOK ? '✅' : '❌ אבד!'}`);

// (ב) שיא — סריקת-אימפריה עצמאית: שדות-הטיפוס × חלקיקי-אימות-קיימים × מה-מאומת-במשודרג
const typeName = (eng.sig.match(/:\s*(\w+)\s*=>/) || [])[1];
const iface = typeName ? (src.match(new RegExp(`interface ${typeName}\\s*{([^}]*)}`)) || [, ''])[1] : '';
const tFields = [...iface.matchAll(/(\w+)\s*:/g)].map((m) => m[1].toLowerCase());
const VAL = /valid|error|norm|check|region|dup|allow|require|ensure|sanit|fix|format/i;
// המנוע-המשודרג = wrapper + _ORIG + deps (signUpError...). שדה מאומת אם *מישהו במודול-כולו* בודק אותו.
const rows = tFields.map((f) => {
  const helper = ALL.find((p) => p.origin.startsWith(repo) && p.name !== target && VAL.test(p.name) && tok(p.name).includes(f));
  const listExists = new RegExp(`(SIZE|NEED|INDUSTR|${f.toUpperCase()})`).test(src) && new RegExp(`\\b${f}\\b`, 'i').test(iface);
  const upgradable = !!helper || listExists;
  // מאומת = יש *שורה* במודול-המשודרג שמזכירה את השדה וגם אופרטור-בדיקה (בכל צד/סדר)
  const CHK = /return|IDS|\.test|\.includes|\.trim|\.length|===|!==|[<>]|\bif\b|!s\.|\?/;
  const validated = upSrc.split('\n').some((ln) => new RegExp(`\\b${f}\\b`, 'i').test(ln) && CHK.test(ln));
  return { f, upgradable, validated };
});
const leftToUpgrade = rows.filter((r) => r.upgradable && !r.validated);
const peakOK = leftToUpgrade.length === 0; ok = ok && peakOK;
console.log(`(ב) שיא-יכולות — סריקה עצמאית פר-שדה:`);
for (const r of rows) console.log(`     ${r.f.padEnd(14)} ניתן-לשדרוג:${r.upgradable ? 'כן' : 'לא '} · מאומת-במשודרג:${r.validated ? '✅' : (r.upgradable ? '❌ פער!' : '—')}`);
console.log(`   ⇒ חלקיקים-שנותרו-לשדרוג: ${leftToUpgrade.length} ${peakOK ? '✅ אין אף חלקיק שיכול לשדרג עוד = שיא' : '❌ [' + leftToUpgrade.map((r) => r.f) + ']'}`);

// (ג) השדרוג-פעיל — strict תופס-רע (עצמאי)
let caught = 0; const bads = [{ industry: 'זבל', size: 'small', needs: [], orgName: 'א', contactName: 'ב', phone: '052-1234567', email: 'a@b.co', password: '123456', password2: '123456' }, { industry: 'chesed', size: 'ענק', needs: [], orgName: 'א', contactName: 'ב', phone: '052-1234567', email: 'a@b.co', password: '123456', password2: '123456' }, { industry: 'chesed', size: 'small', needs: [], orgName: 'א', contactName: 'ב', phone: 'לא', email: 'a@b.co', password: '123456', password2: '123456' }];
for (const b of bads) for (let st = 0; st <= 4; st++) { if (orig(st, b) === null && up(st, b, { strict: true }) !== null) { caught++; break; } }
const actOK = caught === bads.length; ok = ok && actOK;
console.log(`(ג) השדרוג-פעיל: תפס ${caught}/${bads.length} קלטי-רע (תחום/גודל/טלפון) ${actOK ? '✅' : '⚠️'}`);

console.log(`\n${ok ? '🏔️ **אימות-עצמאי אישר: מקסימום — שיא-היכולות**' : '❌ אימות-עצמאי דחה את טענת-המקסימום'}`);
process.exit(ok ? 0 : 1);

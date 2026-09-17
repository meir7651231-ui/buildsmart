#!/usr/bin/env node
// 🚢 ship — "הכל מנוע": regen ⇒ מראה ⇒ אימות ⇒ שערים ⇒ בנייה ⇒ צילום ⇒ gh-pages ⇒ קומיט ⇒ דחיפה — פקודה אחת, סדר קבוע, בלי חפיפה (GENMAX·G13f).
//   הרקע (הכרעת-בעלים 5.9 "הכל מנוע או ידני כל פעם מחדש?"): הליבה הייתה מנוע, אבל המראה ל-buildsmart, הבניות, ה-gh-pages ומחזור-הקומיט הכפול נעשו ביד —
//   וסחף-מראה (העץ זז בזמן שהמשטרה רצה על ה-sha הנדחף) חסם דחיפה. כאן כל שלב רץ באותו סדר, והדחיפה מתחילה רק כשהכל נח.
//   שימוש: node machtzev/generator/ship.mjs --msg "גל G13f · …" [--lesson L77] [--no-build] [--no-deploy] [--no-push] [--no-commit] [--full-verify]
//   ENV: BUILDSMART (ברירת /home/user/buildsmart/app_flutter) · GHP_DIR (worktree של gh-pages; נוצר אם חסר) · SESSION_URL (trailer Claude-Session) · FLUTTER (נתיב flutter/bin)
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, '../..');
const GEN = path.join(ROOT, 'new/dart-gen-bs'), FORGE = path.join(ROOT, 'new/dart-forge-bs'), DS = path.join(ROOT, 'new/dart-ui-bs/ds');
const APP = process.env.BUILDSMART || '/home/user/buildsmart/app_flutter';
const BS = path.resolve(APP, '..');
const LIB = path.join(APP, 'lib/genesis');
const GHP = process.env.GHP_DIR || path.join(BS, '..', 'buildsmart-gh-pages');
const argv = process.argv.slice(2);
const flag = (f) => argv.includes(f);
const opt = (f) => { const i = argv.indexOf(f); return i >= 0 ? argv[i + 1] : null; };
const MSG = opt('--msg'), LESSON = opt('--lesson') || 'הכרעה-24', SESSION = process.env.SESSION_URL || opt('--session');
const AUTHOR = 'Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>';
const env = { ...process.env, PATH: `${process.env.FLUTTER || '/home/user/flutter/bin'}:${process.env.PATH}`, BUILDSMART: APP };
// אתרי-הדמו: תיקייה ב-gh-pages ⇒ נקודת-כניסה (הכרעת-בעלים 5.9: רק תיקיות-דמו חדשות, האתר-החי לא נגע)
const SITES = [['schoolos', 'gen_schoolos_forge.dart'], ['studio', 'gen_main_studio.dart'], ['kehila', 'gen_main_kehila.dart'], ['tzedaka', 'gen_main_tzedaka.dart']];
const t0 = Date.now();
const log = (s) => console.log(`🚢 [${((Date.now() - t0) / 1000).toFixed(0)}s] ${s}`);
function run(cmd, args, cwd = ROOT, { quiet = false, allowFail = false } = {}) {
  const r = spawnSync(cmd, args, { cwd, env, encoding: 'utf8', stdio: quiet ? 'pipe' : ['ignore', 'pipe', 'pipe'], maxBuffer: 64 * 1024 * 1024 });
  if (r.status !== 0 && !allowFail) { console.error(r.stdout?.slice(-4000) || ''); console.error(r.stderr?.slice(-4000) || ''); throw new Error(`✗ ${cmd} ${args.join(' ')} (exit ${r.status}) ב-${cwd}`); }
  return r;
}
const node = (rel, args = [], o) => run('node', [path.join(ROOT, rel), ...args], ROOT, o);

// ── 1 · regen (המחוללים, בסדר) ──
log('regen · ds-forge (מלא) ⇒ skin-golden ⇒ core-from-shape ⇒ core-dart ⇒ app-from-sentences');
node('machtzev/ds-forge.mjs');
node('machtzev/generator/skin-golden.mjs');
node('machtzev/generator/core-from-shape.mjs');   // הגרעין מהסכמה+מונחים (שער core) — L80: מונח חדש ⇒ הרישום נגזר מחדש כאן, לא ביד
node('machtzev/generator/core-dart.mjs');          // gen_core_<entity>.dart ≡ הרישום (שער coredart)
node('machtzev/generator/app-from-sentences.mjs');

// ── 2 · מראה ל-buildsmart (forge: ניקוי+העתקה · gen_*: יתומים מוסרים · ds/: קבצים קיימים בלבד) ──
log('mirror ⇒ ' + LIB);
const rmTree = (d, keep) => { if (!fs.existsSync(d)) return; for (const e of fs.readdirSync(d, { withFileTypes: true })) { const p = path.join(d, e.name); if (e.isDirectory()) { rmTree(p, keep); if (!fs.readdirSync(p).length) fs.rmdirSync(p); } else if (!keep.includes(e.name)) fs.unlinkSync(p); } };
rmTree(path.join(LIB, 'dart-forge-bs'), ['HANDOFF-FORGE.md']);
fs.cpSync(FORGE, path.join(LIB, 'dart-forge-bs'), { recursive: true });
const genDst = path.join(LIB, 'dart-gen-bs'); fs.mkdirSync(genDst, { recursive: true });
for (const f of fs.readdirSync(genDst)) if (/^gen_.*\.dart$/.test(f) && !fs.existsSync(path.join(GEN, f))) fs.unlinkSync(path.join(genDst, f));
for (const f of fs.readdirSync(GEN)) if (/^gen_.*\.dart$/.test(f)) fs.copyFileSync(path.join(GEN, f), path.join(genDst, f));
for (const f of fs.readdirSync(DS)) if (f.endsWith('.dart')) fs.copyFileSync(path.join(DS, f), path.join(LIB, 'dart-ui-bs/ds', f));
for (const f of fs.readdirSync(genDst)) if (/^zz_shot_/.test(f)) fs.unlinkSync(path.join(genDst, f));   // שאריות-ראיה

// ── 3 · אימות: analyze 0 · flutter test genesis_* · שערי-המחולל · אינדקס+אמת ──
log('verify · flutter analyze lib/genesis');
const an = run('flutter', ['analyze', '--no-fatal-infos', '--no-fatal-warnings', 'lib/genesis'], APP, { quiet: true, allowFail: true });
const errs = (an.stdout + an.stderr).split('\n').filter((l) => /^\s+error •/.test(l));
if (errs.length) { console.error(errs.slice(0, 12).join('\n')); throw new Error(`✗ analyze: ${errs.length} errors`); }
const tests = fs.readdirSync(path.join(APP, 'test')).filter((f) => /^genesis_.*_test\.dart$/.test(f)).map((f) => 'test/' + f);
log(`verify · flutter test (${tests.length} קבצי genesis_*)`);
const tr = run('flutter', ['test', ...tests], APP, { quiet: true, allowFail: true });
const summary = (tr.stdout + tr.stderr).split(/\r|\n/).filter((l) => /All tests passed|Some tests failed/.test(l)).pop() || '';
if (tr.status !== 0 || !/All tests passed/.test(summary)) { console.error((tr.stdout + tr.stderr).split(/\r|\n/).filter((l) => /\[E\]|Expected|Actual|thrown/.test(l)).slice(0, 20).join('\n')); throw new Error(`✗ flutter test: ${summary || 'exit ' + tr.status}`); }
log('verify · ' + summary.trim().replace(/^\d\d:\d\d /, ''));
log('gates · retarget · skingolden · appgen');
node('machtzev/generator/retarget.mjs', ['--gate'], { quiet: true });
node('machtzev/generator/skin-golden.mjs', ['--gate'], { quiet: true });
node('machtzev/generator/app-from-sentences.mjs', ['--gate'], { quiet: true });
if (flag('--full-verify')) { log('gen-verify --gate (רנדר-בפועל של כל הפלטים)'); node('machtzev/generator/gen-verify.mjs', ['--gate']); }
node('machtzev/census/atom-index.mjs', [], { quiet: true });
node('machtzev/census/oracle.mjs', ['--write'], { quiet: true });
node('machtzev/truth.mjs', ['--write'], { quiet: true });

// ── 4 · בנייה (אתרים + ראיית-מסך-פנימי) ──
let built = [];
if (!flag('--no-build')) {
  const shotEntry = path.join(genDst, 'zz_shot_students_forge.dart');
  fs.writeFileSync(shotEntry, `// זמני · ראיה בלבד (ship): מסך-התלמידים בעור-forge כאתר לצילום. נמחק אחרי הבנייה.\nimport 'package:flutter/material.dart';\nimport '../dart-ui-bs/ds/ds.dart';\nimport 'gen_schoolos_students_forge.dart';\nvoid main() => runApp(MaterialApp(debugShowCheckedModeBanner: false, title: 'SchoolOS · תלמידים · forge', theme: ThemeData(useMaterial3: true, fontFamily: 'Heebo', scaffoldBackgroundColor: DsTokens.bg, brightness: Brightness.dark, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C8CFF), brightness: Brightness.dark)), home: const Directionality(textDirection: TextDirection.rtl, child: StudentsScreen())));\n`);
  log('build · students evidence');
  run('flutter', ['build', 'web', '--release', '--no-web-resources-cdn', '-t', 'lib/genesis/dart-gen-bs/zz_shot_students_forge.dart', '-o', 'build/web-studentsforge'], APP, { quiet: true });
  fs.unlinkSync(shotEntry);
  for (const [name, entry] of SITES) {
    if (!fs.existsSync(path.join(GEN, entry))) { log(`build · ${name}: אין ${entry} — מדולג`); continue; }
    log(`build · ${name}`);
    run('flutter', ['build', 'web', '--release', '--no-web-resources-cdn', '--base-href', `/buildsmart/${name}/`, '-t', `lib/genesis/dart-gen-bs/${entry}`, '-o', `build/ghp-${name}`], APP, { quiet: true });
    built.push(name);
  }
  log('shot · site-shot studentsforge');
  const sh = node('machtzev/tools/site-shot.mjs', ['studentsforge', 'SchoolOS · תלמידים · forge', '8790'], { quiet: true, allowFail: true });
  log((sh.stdout || sh.stderr || '').trim().split('\n').pop().slice(0, 160));
}

// ── 5 · gh-pages (תיקיות-דמו בלבד) ──
if (!flag('--no-deploy') && built.length) {
  if (!fs.existsSync(GHP)) { log(`deploy · worktree gh-pages ⇒ ${GHP}`); run('git', ['fetch', 'origin', 'gh-pages'], BS, { quiet: true }); run('git', ['worktree', 'add', GHP, 'gh-pages'], BS, { quiet: true }); }
  run('git', ['pull', '--ff-only', 'origin', 'gh-pages'], GHP, { quiet: true, allowFail: true });
  for (const name of built) { fs.rmSync(path.join(GHP, name), { recursive: true, force: true }); fs.cpSync(path.join(APP, `build/ghp-${name}`), path.join(GHP, name), { recursive: true }); }
  run('git', ['add', '-A', ...built], GHP, { quiet: true });
  const st = run('git', ['status', '--porcelain'], GHP, { quiet: true }).stdout.trim();
  if (st) {
    run('git', ['commit', '-q', '-m', `demo · ${built.join(' + ')} — ${MSG || 'ship'} ; תיקיות-הדגמה בלבד, האתר-החי לא נגע\n\n${AUTHOR}${SESSION ? '\nClaude-Session: ' + SESSION : ''}`], GHP, { quiet: true });
    if (!flag('--no-push')) { log('deploy · push gh-pages'); run('git', ['push', 'origin', 'gh-pages'], GHP, { quiet: true }); }
  } else log('deploy · gh-pages ללא שינוי');
}

// ── 6 · קומיט + דחיפה: buildsmart ואז גנסיס (סדר קבוע; הדחיפה מתחילה רק כשהעץ נח — סחף-מראה אינו אפשרי) ──
const commitWith = (cwd, msg) => { const f = path.join(cwd, '.git', 'SHIP_MSG'); fs.writeFileSync(f, msg); try { run('git', ['commit', '-q', '-F', f], cwd, { quiet: true }); } finally { fs.rmSync(f, { force: true }); } };
const pushWith = (cwd, branch) => { for (let k = 0; k < 4; k++) { const r = run('git', ['push', '-u', 'origin', branch], cwd, { quiet: true, allowFail: true }); if (r.status === 0) return true; if (!/could not resolve|connection|timed out|RPC failed|reset/i.test(r.stderr)) { console.error(r.stderr.slice(-3000)); throw new Error(`✗ push ${cwd} ⇒ ${branch}`); } spawnSync('sleep', [String(2 ** (k + 1))]); } throw new Error(`✗ push ${cwd}: רשת`); };
const branchOf = (cwd) => run('git', ['rev-parse', '--abbrev-ref', 'HEAD'], cwd, { quiet: true }).stdout.trim();
if (!flag('--no-commit')) {
  if (!MSG) throw new Error('✗ --msg נדרש לקומיט (או --no-commit)');
  const trailer = `\n\n${AUTHOR}${SESSION ? '\nClaude-Session: ' + SESSION : ''}`;
  // buildsmart — רק מה שהמחולל/המראה כותבים (L74-ז: לא add -A)
  const genTests = fs.readdirSync(path.join(APP, 'test')).filter((f) => /^genesis_.*_test\.dart$/.test(f)).map((f) => 'app_flutter/test/' + f);
  run('git', ['add', 'app_flutter/lib/genesis/dart-forge-bs', 'app_flutter/lib/genesis/dart-gen-bs', 'app_flutter/lib/genesis/dart-ui-bs/ds', 'app_flutter/pubspec.yaml', 'app_flutter/assets/fonts', ...genTests], BS, { quiet: true, allowFail: true });
  let bsCommitted = false;
  if (run('git', ['diff', '--cached', '--name-only'], BS, { quiet: true }).stdout.trim()) { log('commit · buildsmart'); commitWith(BS, `genesis-mirror · ${MSG}${trailer}`); bsCommitted = true; } else log('commit · buildsmart ללא שינוי');
  // genesis — pins ⇒ add -A ⇒ Allow trailers לקבצים נעולים (CLAUDE.md=הכרעה-24 · אחרים=--lesson)
  node('machtzev/pins-check.mjs', ['--write'], { quiet: true });
  run('git', ['add', '-A'], ROOT, { quiet: true });
  const staged = run('git', ['diff', '--cached', '--name-only'], ROOT, { quiet: true }).stdout.trim().split('\n').filter(Boolean);
  let gCommitted = false;
  if (staged.length) {
    const pinned = new Set(fs.readFileSync(path.join(ROOT, 'machtzev/pins.sha256'), 'utf8').split('\n').map((l) => l.split(/\s+/)[1]).filter(Boolean));
    const allows = staged.filter((f) => pinned.has(f)).map((f) => `Allow: pins-write:${f} ${f === 'CLAUDE.md' ? 'הכרעה-24' : LESSON}`);
    log(`commit · genesis (${staged.length} קבצים · ${allows.length} Allow)`);
    commitWith(ROOT, `${MSG}${allows.length ? '\n\n' + allows.join('\n') : ''}${trailer}`);
    gCommitted = true;
  } else log('commit · genesis ללא שינוי');
  if (!flag('--no-push')) {
    if (bsCommitted || run('git', ['status', '-sb'], BS, { quiet: true }).stdout.includes('ahead')) { log('push · buildsmart ' + branchOf(BS)); pushWith(BS, branchOf(BS)); }
    if (gCommitted || run('git', ['status', '-sb'], ROOT, { quiet: true }).stdout.includes('ahead')) { log('push · genesis ' + branchOf(ROOT) + ' (pre-push: המשטרה המלאה)'); pushWith(ROOT, branchOf(ROOT)); }
  }
}
log('✓ ship הסתיים' + (built.length ? ` · אתרים: ${built.join(' · ')}` : ''));

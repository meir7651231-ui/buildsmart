#!/usr/bin/env node
// 🏁 golden-harness — רתמת-הזהב של המחולל (GENMAX · G4 · הכרעה-24): המודול המורכב-מחדש מהקטלוג עובר את **בדיקות-הזהב המקוריות** בלי שינוי-בדיקה.
//   לכל מודול-זהב: assemble(compose+declared, חלקיקי-המודול) ⇒ מוחלף במראה של buildsmart (lib/genesis/dart-gen-bs/<module>) ⇒
//   `flutter test test/genesis_<name>_test.dart` ⇒ שחזור-המראה (git checkout) — תמיד, גם בכשל.
//   מדד: golden-regenerated N/9 · tests K/84 — ראצ׳ט רק-עולה (render-module-baseline.json). מדולג (ledger=skipped) כשאין buildsmart/flutter.
//   ⚠️ אין git ב-genesis כאן; ב-buildsmart רק `checkout -- <file>` לשחזור קובץ שהרתמה עצמה דרסה.
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import * as R from '../root.mjs';
import { assemble, PARTICLE_IDS } from './render-module.mjs';

const ROOT = R.ROOT, GEN = path.join(ROOT, 'machtzev/generator');
const BS = process.env.BUILDSMART || path.resolve(ROOT, '../buildsmart/app_flutter');
const FLUTTER = process.env.FLUTTER || (fs.existsSync('/home/user/flutter/bin/flutter') ? '/home/user/flutter/bin/flutter' : 'flutter');
const BASE = path.join(GEN, 'render-module-baseline.json');
// מודול-זהב ⇒ קובצי-הבדיקה שלו (schoolos.dart = מסך-המלאי + ניווט-ההאב)
const TESTS = { 'schoolos.dart': ['genesis_inventory_states_test.dart', 'genesis_schoolos_nav_test.dart'] };
const testsOf = (m) => TESTS[m] || [`genesis_${m.replace(/^schoolos_/, '').replace(/\.dart$/, '')}_test.dart`];
const particlesOf = (m) => { const k = m.replace(/\.dart$/, ''); const p = { schoolos_students: 'stu.', schoolos_attendance: 'att.', schoolos_courses: 'crs.', schoolos_teachers: 'tch.', schoolos_rooms: 'rm.', schoolos_fees: 'fee.', schoolos_parents: 'par.', schoolos_dashboard: 'dash.' }[k]; return PARTICLE_IDS.filter((id) => (p ? id.startsWith(p) : !id.includes('.'))); };

const gate = process.argv.includes('--gate');
const only = (() => { const i = process.argv.indexOf('--module'); return i > -1 ? [process.argv[i + 1]] : null; })();
if (!fs.existsSync(path.join(BS, 'pubspec.yaml'))) { console.log(`⚪ goldenharness: אין buildsmart ב-${BS} — מדולג`); process.exit(0); }
const modules = only || ['schoolos_attendance.dart', 'schoolos_rooms.dart', 'schoolos_teachers.dart', 'schoolos_parents.dart', 'schoolos_dashboard.dart', 'schoolos_fees.dart', 'schoolos_students.dart', 'schoolos_courses.dart', 'schoolos.dart'];
const rows = []; let regenerated = 0, passed = 0, total = 0;
for (const m of modules) {
  const mirror = path.join(BS, 'lib/genesis/dart-gen-bs', m);
  const r = assemble({ module: m, particles: particlesOf(m), mode: 'compose', declared: true });
  const src = fs.readFileSync(path.join(ROOT, 'new/dart-gen-bs', m), 'utf8');
  const dead = r.unselected.filter((u) => !/^\/\//.test(u.first));
  // סחף-מראה (לקח 4.9: מורים במראה היה 3 גלים לפני genesis — "ביט-זהה ועדיין אדום"): המראה חייב להיות ≡ המקור לפני ההחלפה, אחרת הבדיקות מודדות קובץ אחר
  const drift = fs.existsSync(mirror) && fs.readFileSync(mirror, 'utf8') !== src;
  fs.writeFileSync(mirror, r.code);
  let ok = 0, n = 0, failMsg = '';
  try {
    for (const t of testsOf(m)) {
      const res = spawnSync(FLUTTER, ['test', 'test/' + t, '--reporter', 'compact'], { cwd: BS, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, env: { ...process.env, PATH: path.dirname(FLUTTER) + ':' + process.env.PATH } });
      const out = (res.stdout || '') + (res.stderr || '');
      const last = [...out.matchAll(/\+(\d+)(?:\s+-(\d+))?:/g)].pop();
      const p = last ? +last[1] : 0, f = last && last[2] ? +last[2] : 0;
      ok += p; n += p + f; if (res.status !== 0) failMsg += ` ${t}:${res.status}`;
    }
  } finally { spawnSync('git', ['checkout', '--', 'lib/genesis/dart-gen-bs/' + m], { cwd: BS, encoding: 'utf8' }); }
  const green = n > 0 && ok === n && !failMsg && !drift;
  if (drift) failMsg += ' סחף-מראה(mirror≠genesis)';
  if (green) regenerated++; passed += ok; total += n;
  rows.push({ module: m, fragments: `${r.fragments}/${r.of}`, identical: r.code === src, dead: dead.map((d) => d.cls + '.' + (d.first.match(/(\w+)\s*(?:\(|=>|=|\{)/) || [])[1]), tests: `${ok}/${n}`, green, fail: failMsg.trim() });
  console.log(`${green ? '✓' : '✗'} ${m.padEnd(26)} שברים ${rows.at(-1).fragments.padEnd(8)} ${r.code === src ? 'ביט-זהה' : 'שונה (מת: ' + rows.at(-1).dead.join(',') + ')'}`.padEnd(95) + ` בדיקות ${ok}/${n}${failMsg}`);
}
const summary = { regenerated, modules: modules.length, tests: passed, testsTotal: total };
console.log(`golden-regenerated ${regenerated}/${modules.length} · tests ${passed}/${total}`);
if (!only) fs.writeFileSync(path.join(GEN, 'golden-harness-report.json'), JSON.stringify({ ...summary, rows }, null, 1));
if (gate) {
  const base = fs.existsSync(BASE) ? JSON.parse(fs.readFileSync(BASE, 'utf8')) : { regenerated: 0, tests: 0 };
  if (only) process.exit(0);
  if (regenerated < base.regenerated || passed < base.tests) { console.log(`🔴 goldenharness: נסיגה מ-baseline ${base.regenerated}/${base.tests} ⇒ ${regenerated}/${passed}`); process.exit(1); }
  console.log(`✓ goldenharness: ${regenerated}/${modules.length} מודולי-זהב מורכבים-מחדש עוברים את בדיקותיהם · ${passed}/${total} בדיקות`);
} else if (!only && (process.argv.includes('--write-baseline') || !fs.existsSync(BASE))) fs.writeFileSync(BASE, JSON.stringify(summary));

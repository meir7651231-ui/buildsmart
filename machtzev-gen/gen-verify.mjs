#!/usr/bin/env node
// 🔎 gen-verify — אימות-בפועל של פלטי-המחולל (GENMAX · G5b · הכרעה-24): analyze ירוק ≠ מסך שעובד (L53: `$all` עבר analyze ונפל בקומפילציית-הבדיקה).
//   לכל gen_*.dart ב-new/dart-gen-bs שיש בו `class XScreen extends StatefulWidget` — נכתבת בדיקת-widget **מחוללת** למראה-buildsmart:
//   pump ⇒ אפס-חריגות ⇒ DsScaffold קיים ⇒ ספירת מחלקות-אטום שרונדרו בפועל (מול ops-map: תצוגה) ⇒ שורת GENVERIFY {json} שהרתמה קוראת.
//   מדד: screens-rendered N/M · atoms-rendered (ייחודיים) — ראצ׳ט רק-עולה (gen-verify-baseline.json). מדולג בלי buildsmart/flutter. אין git.
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import * as R from '../root.mjs';

const ROOT = R.ROOT, GEN = path.join(ROOT, 'machtzev/generator'), DIR = path.join(ROOT, 'new/dart-gen-bs');
const BS = process.env.BUILDSMART || path.resolve(ROOT, '../buildsmart/app_flutter');
const FLUTTER = process.env.FLUTTER || (fs.existsSync('/home/user/flutter/bin/flutter') ? '/home/user/flutter/bin/flutter' : 'flutter');
const BASE = path.join(GEN, 'gen-verify-baseline.json');
const MAP = JSON.parse(fs.readFileSync(path.join(GEN, 'ops-map.json'), 'utf8'));
const DISPLAY = new Set(MAP.filter((a) => a.layer === 'display' || a.kind === 'display' || /dart-ui-bs/.test(a.file || a.path || '')).map((a) => a.id.split('@')[0]));
// G15b · L82: אטומי-forge (dart-forge-bs, שכבת-תצוגה באינדקס-האמת) נספרים כאטומי-תצוגה — אחרת החלפת DS⇒forge נראית כ"נסיגה" (KpiTile ירד מהמסך כי StatPlain עלה במקומו)
const IDX_FULL = path.join(GEN, 'atom-index-full.json');
if (fs.existsSync(IDX_FULL)) for (const a of JSON.parse(fs.readFileSync(IDX_FULL, 'utf8'))) if (a.layer === 'display' && /dart-forge-bs/.test(a.file || '')) DISPLAY.add(a.id.split('@')[0]);
const gate = process.argv.includes('--gate');
const only = (() => { const i = process.argv.indexOf('--only'); return i > -1 ? process.argv[i + 1].split(',') : null; })();
if (!fs.existsSync(path.join(BS, 'pubspec.yaml'))) { console.log(`⚪ genverify: אין buildsmart ב-${BS} — מדולג`); process.exit(0); }

// פלטי-מחולל עם מסך ציבורי (subset/composite/retarget) — לא מסכי-הזהב הידניים
const files = fs.readdirSync(DIR).filter((f) => /^gen_.*\.dart$/.test(f) && (!only || only.includes(f))).filter((f) => /^class \w+Screen extends StatefulWidget/m.test(fs.readFileSync(path.join(DIR, f), 'utf8')));
const screens = files.map((f) => ({ file: f, cls: fs.readFileSync(path.join(DIR, f), 'utf8').match(/^class (\w+Screen) extends StatefulWidget/m)[1] }));
if (!screens.length) { console.log('⚪ genverify: אין פלטי-מחולל עם מסך'); process.exit(0); }
// המראה חייב להיות ≡ המקור (סחף-מראה = כשל, כמו ברתמת-הזהב)
const drift = screens.filter((s) => { const m = path.join(BS, 'lib/genesis/dart-gen-bs', s.file); return !fs.existsSync(m) || fs.readFileSync(m, 'utf8') !== fs.readFileSync(path.join(DIR, s.file), 'utf8'); }).map((s) => s.file);
// קפדני = פלטי G4–G9 שלנו (חייבים לעבוד): לפי שם-משפחה, ורכזות-אפליקציה רק לפי חותמת-המחולל בכותרת (L64: 'app_\\w+' לבדו תפס גם gen_app_rec1..6 הישנים של render-ds ⇒ שער אדום שלא נראה)
const STRICT_NAME = /^gen_(?:\w+_subset|composite_\w+|retarget_\w+|core_\w+|opsseed_\w+|schoolos\w*_forge)\.dart$/;   // G12d: בית-הספר בעור-forge — קפדני
const _stampCache = new Map();
const isStrict = (file) => { if (STRICT_NAME.test(file)) return true; if (!/^gen_app_\w+\.dart$/.test(file)) return false; if (!_stampCache.has(file)) { const f = path.join(DIR, file); _stampCache.set(file, fs.existsSync(f) && /app-from-sentences\.mjs/.test(fs.readFileSync(f, 'utf8').split('\n').slice(0, 3).join('\n'))); } return _stampCache.get(file); };
const testPath = path.join(BS, 'test/genesis_gen_verify_test.dart');
// רק קבצים שהמראה שלהם ≡ המקור נכנסים לבדיקה (קובץ-חסר/סחוף היה מפיל את קומפילציית כל הבדיקה ⇒ 0/57); הסחופים מדווחים ✗ בלי לייבא
const live = screens.filter((s) => !drift.includes(s.file));
const dart = [`// מחולל ע"י machtzev/generator/gen-verify.mjs — אל תערוך ידנית · G5b אימות-בפועל של פלטי-המחולל`,
  ...live.map((s, i) => `import 'package:buildsmart/genesis/dart-gen-bs/${s.file}' as g${i};`),
  `import 'package:buildsmart/genesis/dart-ui-bs/ds/ds.dart';`, `import 'package:buildsmart/genesis/dart-ui-bs/premium/actions/soft_button.dart';`, `import 'package:flutter/material.dart';`, `import 'package:flutter_test/flutter_test.dart';`, `import 'dart:convert';`, '',
  'void main() {',
  ...live.flatMap((s, i) => [
    `  testWidgets('gen-verify · ${s.file}', (tester) async {`,
    `    tester.view.physicalSize = const Size(800, 1400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);`,
    `    await tester.pumpWidget(const MaterialApp(home: g${i}.${s.cls}()));`,
    `    await tester.pump(const Duration(milliseconds: 300));`,
    `    expect(tester.takeException(), isNull);`,
    `    expect(find.byType(DsScaffold), findsWidgets);`,
    `    final types = <String, int>{}; for (final w in tester.allWidgets) { final t = w.runtimeType.toString(); types[t] = (types[t] ?? 0) + 1; }`,
    // G7a · סריקת-אינטראקציה (פלטי G4–G6 בלבד): כל טאפ = pumpAndSettle + takeException; חריגה = ממצא (נספר, לא מפיל את הרנדר); מקטע-הגרעין-על-הרשומה מזוהה בטקסט
    ...(isStrict(s.file) ? [
      `    var taps = 0, tapErrors = 0, coreSeen = false; final tapErrorAt = <String>[]; final details = <String>[];`,
      `    final prevOnError = FlutterError.onError; FlutterError.onError = (d) { details.add(d.toString()); prevOnError?.call(d); }; addTearDown(() => FlutterError.onError = prevOnError);`,
      `    // כל טאפ עטוף: חריגה (גם של המסגרת: hit-test/offstage) נספרת ולא מפילה את שאר הסריקה; החזרה מדיאלוג/sheet בטאפ-מחוץ`,
      `    Future<void> sweep(Finder f) async { final n = f.evaluate().length; for (var i = 0; i < n && i < 12; i++) { try { if (i >= f.evaluate().length) break; final ff = f.at(i); await tester.tap(ff, warnIfMissed: false); taps++; await tester.pump(const Duration(milliseconds: 400)); await tester.pump(const Duration(milliseconds: 400)); final ex = tester.takeException(); if (ex != null) { tapErrors++; final w = ff.evaluate().isNotEmpty ? ff.evaluate().first.widget : null; final lbl = w is IconButton ? (w.tooltip ?? w.icon.toString()) : w is SoftButton ? w.label : w.runtimeType.toString(); final exLines = (details.isNotEmpty ? details.last : ex.toString()).split('\\n'); final at = exLines.indexWhere((l) => l.contains('error-causing widget')); tapErrorAt.add('\${w.runtimeType}#\$i "\$lbl": \${ex.toString().split('\\n').first}\${at >= 0 ? ' @ ' + exLines.skip(at + 1).take(3).map((l) => l.trim()).where((l) => l.isNotEmpty).join(' ') : ''}'); } if (find.textContaining('מחזור-חיים · רשומה').evaluate().isNotEmpty) coreSeen = true; await tester.tapAt(const Offset(2, 2)); await tester.pump(const Duration(milliseconds: 400)); tester.takeException(); } catch (_) { tapErrors++; tester.takeException(); } } }`,
      `    await sweep(find.byType(IconButton)); await sweep(find.byType(SoftButton));`,
      `    // ignore: avoid_print`,
      `    print('GENVERIFY ' + jsonEncode({'file': '${s.file}', 'screen': '${s.cls}', 'types': types, 'taps': taps, 'tapErrors': tapErrors, 'tapErrorAt': tapErrorAt, 'coreSeen': coreSeen}));`,
    ] : [
      `    // ignore: avoid_print`,
      `    print('GENVERIFY ' + jsonEncode({'file': '${s.file}', 'screen': '${s.cls}', 'types': types}));`,
    ]),
    `  });`]),
  '}', ''].join('\n');
fs.writeFileSync(testPath, dart);
const res = spawnSync(FLUTTER, ['test', 'test/genesis_gen_verify_test.dart', '--reporter', 'compact'], { cwd: BS, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, env: { ...process.env, PATH: path.dirname(FLUTTER) + ':' + process.env.PATH } });
const out = (res.stdout || '') + (res.stderr || '');
try { fs.unlinkSync(testPath); } catch {}
fs.writeFileSync(path.join(GEN, 'gen-verify-last.log'), out);                       // הלוג הגולמי (לא נעול, לא בקומיט) — לאבחון
const rows = [...out.matchAll(/GENVERIFY (\{.*\})/g)].map((m) => JSON.parse(m[1]));
const last = [...out.matchAll(/\+(\d+)(?:\s+-(\d+))?:/g)].pop();
const passed = last ? +last[1] : 0, failed = last && last[2] ? +last[2] : 0;
const compileErr = [...out.matchAll(/^((?:lib|test)\/[^\n]*Error: [^\n]*)$/gm)].map((m) => m[1].slice(0, 160));
const atomsAll = new Set();
const coreWired = new Set(fs.readdirSync(DIR).filter((f) => /^gen_retarget_/.test(f) && /_coreState/.test(fs.readFileSync(path.join(DIR, f), 'utf8'))));   // מסכי-ישות עם גרעין-על-הרשומה (G6d) — חייבים להראות אותו בסריקה
const report = screens.map((s) => { const r = rows.find((x) => x.file === s.file); const atoms = r ? Object.keys(r.types).filter((t) => DISPLAY.has(t)) : []; atoms.forEach((a) => atomsAll.add(a)); return { file: s.file, screen: s.cls, rendered: !!r, drift: drift.includes(s.file), atoms: atoms.length, widgets: r ? Object.values(r.types).reduce((a, b) => a + b, 0) : 0, atomList: atoms, taps: r ? r.taps ?? null : null, tapErrors: r ? r.tapErrors ?? 0 : 0, coreSeen: r ? !!r.coreSeen : false, coreExpected: coreWired.has(s.file) }; });
for (const r of report) { const row = rows.find((x) => x.file === r.file); if (row && row.tapErrorAt && row.tapErrorAt.length) console.log('   ✗ טאפ שנשבר: ' + row.tapErrorAt.join(' ¦ ').slice(0, 400)); }
for (const r of report) console.log(`${r.rendered && !r.drift && !r.tapErrors ? '✓' : '✗'} ${r.file.padEnd(34)} ${r.screen.padEnd(22)} ${r.rendered ? `אטומים-שרונדרו ${String(r.atoms).padStart(2)} · widgets ${r.widgets}${r.taps !== null ? ` · טאפים ${r.taps}${r.tapErrors ? ' · חריגות-טאפ ' + r.tapErrors : ''}${r.coreExpected ? (r.coreSeen ? ' · גרעין-על-הרשומה ✓' : ' · גרעין-על-הרשומה ✗') : ''}` : ''}` : 'לא רונדר'}${r.drift ? ' · סחף-מראה' : ''}`);
if (compileErr.length) console.log('   קומפילציה: ' + compileErr.slice(0, 3).join(' ¦ '));
const rendered = report.filter((r) => r.rendered && !r.drift).length;
const tapsAll = report.reduce((a, r) => a + (r.taps || 0), 0), tapErrAll = report.reduce((a, r) => a + (r.tapErrors || 0), 0);
const summary = { rendered, screens: screens.length, atoms: atomsAll.size, passed, failed, taps: tapsAll, tapErrors: tapErrAll, coreSeen: report.filter((r) => r.coreSeen).length };
console.log(`gen-verify: ${rendered}/${screens.length} מסכים-מחוללים רונדרו בפועל · ${atomsAll.size} מחלקות-אטום ייחודיות על המסך · סריקת-אינטראקציה ${tapsAll} טאפים · ${tapErrAll} חריגות · גרעין-על-הרשומה נראה ב-${summary.coreSeen} · flutter test ${passed} passed${failed ? ' ' + failed + ' failed' : ''}`);
if (!only) fs.writeFileSync(path.join(GEN, 'gen-verify-report.json'), JSON.stringify({ ...summary, report }, null, 1));
if (gate) {
  const base = fs.existsSync(BASE) ? JSON.parse(fs.readFileSync(BASE, 'utf8')) : { rendered: 0, atoms: 0 };
  if (only) process.exit(rendered === screens.length ? 0 : 1);
  // קפדני לפלטי G4/G5 (מודולי-משנה/הרכבות — שלנו, חייבים לעבוד) · ראצ׳ט לשאר פלטי-המחולל הישן (app-ds: gen_quest/rich/…): כשלים מדווחים, המספר רק-עולה
  const strictFail = report.filter((r) => isStrict(r.file) && (!r.rendered || r.drift || r.tapErrors));   // גרעין-על-הרשומה = מדד (תלוי-ניווט לפאנל), לא קפדני
  if (strictFail.length) { console.log(`🔴 genverify: פלטי-G4/G5 שלא רונדרו/סחפו: ${strictFail.map((r) => r.file).join(', ')} — פלט-מחולל שלא עובד אינו פלט`); process.exit(1); }
  if (rendered < base.rendered || atomsAll.size < base.atoms) { console.log(`🔴 genverify: נסיגה מ-baseline ${base.rendered}/${base.atoms} ⇒ ${rendered}/${atomsAll.size}`); process.exit(1); }
  console.log(`✓ genverify: ${rendered}/${screens.length} פלטי-מחולל רונדרו בפועל · ${atomsAll.size} אטומי-תצוגה על המסך`);
} else if (!only && (process.argv.includes('--write-baseline') || !fs.existsSync(BASE))) fs.writeFileSync(BASE, JSON.stringify(summary));

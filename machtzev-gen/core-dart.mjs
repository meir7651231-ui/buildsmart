#!/usr/bin/env node
// 🧩 core-dart — הגרעין כקוד (GENMAX · G6b · הכרעה-24): core-registry.json ⇒ gen_core_<entity>.dart לכל ישות עם workflow — מסך-Dart מתקמפל ומרונדר (gen-verify)
//   שכבת-הדאטה: `_<E>Core` (מצבים חצובים · יחסים · חוקים · ערוצים) · מעבר-מצב = **אטום-מדף** (advanceStatus · nextStage⊕stageIndex⊕ayinStages) כשקיים, אחרת סדר-הצהרה מוצהר-כהצבה ·
//   שכבת-התצוגה: אטומי-DS בלבד (DsScaffold · DsSection · StatusChip · AlertBanner · SoftButton · DsTable) — אפס ציור-ביד מלבד פריסה (Wrap) · policy = AlertBanner "הכרעת-בעלים" ·
//   אפס Date.now · אפס דאטה-מומצא (הכול מהרג׳יסטרי). --gate: הפלטים המחויבים ≡ טריים.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as R from '../root.mjs';

const ROOT = R.ROOT, GEN = path.join(ROOT, 'machtzev/generator'), DIR = path.join(ROOT, 'new/dart-gen-bs');
const REG = JSON.parse(fs.readFileSync(path.join(GEN, 'core-registry.json'), 'utf8'));
const q = (s) => `'${String(s).replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\$/g, '\\$')}'`;
export function emit(e) {
  const wf = e.workflows.find((w) => w.states && w.states.length); if (!wf) return null;
  const E = e.entity, title = e.term || E, eng = wf.transitions.engine;
  const imports = [`import 'package:flutter/material.dart';`, `import '../dart-ui-bs/ds/ds.dart';`, `import '../dart-ui-bs/ds/ds_table.dart';`, `import '../dart-ui-bs/premium/feedback/status_chip.dart';`, `import '../dart-ui-bs/premium/feedback/alert_banner.dart';`, `import '../dart-ui-bs/premium/actions/soft_button.dart';`];
  if (eng === 'advance-status') imports.push(`import '../dart-maor/advance-status.dart'; // מנוע-מדף: המצב הבא (קדימה בלבד)`);
  if (eng === 'next-stage') imports.push(`import '../dart-maor/next-stage.dart'; // מנוע-מדף: השלב הבא`, `import '../dart-maor/stage-index.dart'; // שקע: אינדקס-שלב`, `import '../dart-maor/ayin-stages.dart'; // דאטה-מדף: סדר-השלבים`);
  const nextBody = eng === 'advance-status' ? `{ final n = advanceStatus(s); return n == s ? null : n; }` : eng === 'next-stage' ? `=> nextStage(s, stageIndex, ayinStages);` : `{ final i = states.indexOf(s); return i < 0 || i + 1 >= states.length ? null : states[i + 1]; } // הצבה: סדר-ההצהרה (אין אטום-מעבר לישות זו) — חוק-7`;
  const rel = e.relations.map((r) => `[${q(r.field)}, ${q(r.target || '∅')}, ${q(r.how)}]`);
  const rules = e.rules.map((r) => `[${q(r.kind)}, ${q(r.field)}, ${q(r.kind === 'enum' ? r.values.join('|') : r.kind === 'ref' ? r.target : '')}]`);
  const chans = e.notification.map((n) => `[${q(n.field)}, ${q(n.channel)}]`);
  const evs = e.events.map((x) => `[${q(x.field)}, ${q(x.event)}]`);
  return [`// 🧠 ${E}CoreScreen — גרעין-מהסכמה (GENMAX·G6b · הכרעה-24) · מחולל דטרמיניסטי: core-dart.mjs (מקור: core-registry.json ⇐ schema-fields + enum-values + entity-terms)`,
    `//   workflow: ${wf.field}:${wf.type} ⇒ ${wf.states.join('→')} · מעבר = ${eng ? 'אטום-מדף ' + eng : 'סדר-הצהרה (הצבה מוצהרת, חוק-7)'} · יחסים ${e.relations.length} · חוקים ${e.rules.length} · ערוצים ${e.notification.length} · policy = הכרעת-בעלים (שקע ריק)`,
    ...imports, '',
    `/// דאטה-הגרעין של ${E} — נגזר, לא מומצא; המצבים בסדר-ההצהרה של domain.ts · ציבורי: מסכי-הישות (retarget) מייבאים ומשתמשים (G6c)`,
    `class ${E}Core {`,
    `  static const term = ${q(title)};`,
    `  static const states = <String>[${wf.states.map(q).join(', ')}];`,
    `  static String? next(String s) ${nextBody}`,
    `  static const relations = <List<String>>[${rel.join(', ')}];`,
    `  static const rules = <List<String>>[${rules.join(', ')}];`,
    `  static const channels = <List<String>>[${chans.join(', ')}];`,
    `  static const events = <List<String>>[${evs.join(', ')}];`,
    `}`, '',
    `class ${E}CoreScreen extends StatefulWidget {`, `  const ${E}CoreScreen({super.key});`, '  @override', `  State<${E}CoreScreen> createState() => ${E}CoreScreenState();`, '}', '',
    `class ${E}CoreScreenState extends State<${E}CoreScreen> {`,
    `  String _state = ${E}Core.states.first;`,
    '  @override',
    '  Widget build(BuildContext context) {',
    `    final next = ${E}Core.next(_state);`,
    `    return DsScaffold(`,
    `      title: '🧠 \${${E}Core.term} · גרעין',`,
    `      subtitle: '\${${E}Core.states.length} מצבים · \${${E}Core.relations.length} יחסים · \${${E}Core.rules.length} חוקים · \${${E}Core.channels.length} ערוצים',`,
    `      icon: '🧠',`,
    `      children: [`,
    `        DsSection(title: 'מחזור-חיים · ${wf.field}', children: [`,
    `          Wrap(spacing: 6, runSpacing: 6, children: [for (final s in ${E}Core.states) StatusChip(label: s, tone: s == _state ? 1 : 0)]),`,
    `          AlertBanner(message: next == null ? 'מצב-סופי: \$_state' : 'הבא אחרי \$_state: \$next', tone: next == null ? 2 : 0, glyph: '➡️'),`,
    `          SoftButton(label: 'קדם מצב', onTap: next == null ? null : () => setState(() => _state = next)),`,
    `        ]),`,
    `        DsSection(title: 'יחסים', children: [${rel.length ? `DsTable(labels: const ['שדה', 'יעד', 'איך'], rows: ${E}Core.relations)` : `const AlertBanner(message: 'אין שדות-יחס בסכמה', tone: 0)`}]),`,
    `        DsSection(title: 'חוקים', children: [DsTable(labels: const ['סוג', 'שדה', 'פרטים'], rows: ${E}Core.rules)]),`,
    `        DsSection(title: 'אירועי-מחזור-חיים', children: [${evs.length ? `DsTable(labels: const ['שדה', 'אירוע'], rows: ${E}Core.events)` : `const AlertBanner(message: 'אין שדות-תאריך של מחזור-חיים', tone: 0)`}]),`,
    `        DsSection(title: 'ערוצים', children: [${chans.length ? `Wrap(spacing: 6, children: [for (final c in ${E}Core.channels) StatusChip(label: '\${c[0]} · \${c[1]}', tone: 1)])` : `const AlertBanner(message: 'אין שדות-ערוץ', tone: 0)`}]),`,
    `        const AlertBanner(message: 'policy-config (שבת/כשרות/הרשאות) = הכרעת-בעלים — שקע מוצהר, ריק', tone: 3, glyph: '🔒'),`,
    `      ],`,
    `    );`,
    '  }',
    '}', ''].join('\n');
}
export const TARGETS = REG.entities.filter((e) => e.workflows.some((w) => w.states && w.states.length)).map((e) => e.entity);
const outName = (E) => `gen_core_${E.toLowerCase()}.dart`;
const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  const errs = []; let n = 0;
  for (const e of REG.entities) { const code = emit(e); if (!code) continue; n++; const f = path.join(DIR, outName(e.entity));
    if (process.argv.includes('--gate')) { if (!fs.existsSync(f) || fs.readFileSync(f, 'utf8') !== code) errs.push(`${path.basename(f)} ≠ פליטה-טרייה`); } else fs.writeFileSync(f, code); }
  if (process.argv.includes('--gate')) { if (errs.length) { console.log('🔴 coredart: ' + errs.join(' · ')); process.exit(1); } console.log(`✓ coredart: ${n} מסכי-גרעין (gen_core_*.dart) ≡ פליטה-דטרמיניסטית מהרג׳יסטרי · הרנדר בשער genverify`); process.exit(0); }
  console.log(`✓ ${n} מסכי-גרעין נכתבו: ${TARGETS.map(outName).join(' ')}`);
}

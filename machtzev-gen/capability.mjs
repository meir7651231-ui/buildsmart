// capability.mjs — שכבת כוונה⇒הרכבה (§23): קורא מבנה-משפט-צורך ⇒ פירוק לפעולות + בחירת-אטומים.
// אפס-מילון-דומייני: ה"מילון" היחיד = דקדוק-יחסי (אופרטורים) + מרקרי-תנאי מבניים. האטומים
// נבחרים דרך match (מטרות-אטומים · נלמד מ-254 מסכים), לא מיפוי-קשיח. עיוור-דומיין.
import { retrieve } from './match.mjs';
import { selectAtom } from './render-ds.mjs';
import fs from 'node:fs';
import * as R from '../root.mjs';
const ATOM_INDEX = JSON.parse(fs.readFileSync((R.GEN_DIR + 'atom-index.json'), 'utf8'));
const fileOf = (cls) => { const a = ATOM_INDEX.find((e) => e.cls === cls); return a ? a.file : null; };

// דקדוק-יחסי — קבוצה סגורה של אופרטורי-השוואה (כמו >,< במתמטיקה). לא דומיין. \S* סופג נטיית-מין/מספר.
// דפוסים בצורה מנוטרלת-סופיות (definalize) — סופג ך/כ · ם/מ · נטיית-מין/מספר.
const REL = [
  { re: /חורג\S*|עולה\S*\s*על|מעל|גדול\S*|יותר|למעלה\s*מ/, op: '>' },
  { re: /נמוכ\S*|מתחת|קטנ\S*|פחות|יורד\S*/, op: '<' },
];
const definalize = (s) => String(s).replace(/ך/g, 'כ').replace(/ם/g, 'מ').replace(/ן/g, 'נ').replace(/ף/g, 'פ').replace(/ץ/g, 'צ');
// מרקרי-תנאי מבניים (כמו 'עם' מפריד-שדות) — סגור. בלי \b (ASCII-בלבד, לא נדלק על עברית).
const WHEN = /(כאשר|ברגע ש|כש)/;
const hw = (s) => [...String(s || '').matchAll(/[֐-׿][֐-׿״׳]*/g)].map((m) => m[0]);
// קילוף-קידומת חד-אותית (ה/ו/ש/כ/ל/ב/מ) לצורך התאמת-שדה — רק אם המילה נשארת ≥2 אותיות.
// קילוף-קידומת שמרני: "מה..." (מן-ה) ⇒ קלף 2 · "ה..." (יידוע) ⇒ קלף 1. לעולם לא מ' בודדת
// (שורש: מעבד/מלאי/מחיר) ⇒ מונע over-strip. עיוור-דומיין, מבני.
const deprefix = (w) => { const s = String(w); if (/^מה../.test(s)) return s.slice(2); if (/^ה./.test(s) && s.length > 2) return s.slice(1); return s; };
// שם-הערך = צירוף-השם המלא של סעיף-הערך (לא מילה בודדת) — כך סמיכות/שייכות נשמרות נכון:
// "עומס המעבד"·"יתרת החשבון"·"לחות הקרקע"·"דופק של המטופל". קילוף-יידוע על המילה הראשונה בלבד.
const cleanPhrase = (words) => words.length ? [deprefix(words[0]), ...words.slice(1)].join(' ') : '';

// גלאי סעיף-התראה-מותנית: "<trigger> ... כש <X> <REL> <Y>". מבני בלבד.
// מחזיר {trigger, xWords, op, yWords} או null. אינו יודע מה X/Y — רק צורתם.
export function detectAlertClause(text) {
  const t = String(text || '');
  const wm = t.match(WHEN);
  if (!wm) return null;
  const before = t.slice(0, wm.index);          // ראש-הסעיף — כוונת-התצוגה (יתורגם ע"י match)
  const after = t.slice(wm.index + wm[0].length); // תנאי — X REL Y
  // התאמת-יחס על טקסט מנוטרל-סופיות (אורך זהה ⇒ אינדקסים תואמים ל-after המקורי).
  const afterN = definalize(after);
  let rel = null, relM = null;
  for (const r of REL) { const m = afterN.match(r.re); if (m) { rel = r; relM = m; break; } }
  if (!rel) return null;
  const xPart = after.slice(0, relM.index);
  const yPart = after.slice(relM.index + relM[0].length);
  const xWords = hw(xPart), yWords = hw(yPart);
  if (!xWords.length || !yWords.length) return null;
  return {
    trigger: hw(before).slice(-2).join(' '),      // 2 המילים לפני 'כש' = אות-הכוונה (בלי שם-הערך)
    x: cleanPhrase(xWords),                        // שדה-הערך = צירוף-השם המלא (סמיכות נשמרת)
    op: rel.op,
    y: deprefix(yWords[0]),                        // שדה-הסף (המילה הצמודה לתנאי)
  };
}

// בחירת אטום-תצוגה לכוונה — דרך match (מטרת-אטום), לא מיפוי. מחזיר cls או null.
export function pickAtom(phrase) {
  const r = retrieve(phrase, 3) || [];
  return r.length ? r[0].cls : null;
}

const NUM_RE = /^(value|val|pct|level|amount|reading|num|score|percent)$/;
const STR_RE = /^(label|title|caption|name|text|msg|message)$/;

// רב-סעיפים: פיצול לפי מחברי-ריבוי **דקדוקיים** (וגם/גם/;/שורה) ⇒ סעיף-תנאי בכל מקטע. כך "A וגם B"
// = 2 מסגרות (יכולת-ההתראה מופעלת פעמיים). מחברים = חלקיקים מבניים (כמו של/עם), אפס-מילון-דומייני.
export function detectAllClauses(text) {
  const out = [];
  for (const s of String(text || '').split(/\s+וגם\s+|\s+גם\s+|;|\n/)) {
    const d = detectAlertClause(s);
    if (d && !out.some((o) => o.x === d.x && o.op === d.op && o.y === d.y)) out.push(d);
  }
  return out;
}

// 🧩 מרכיב (compositor): המבנה **נגזר** ממספר-הצרכים במשפט, לא חרוט. סורק את **כל** מופעי-הצורך,
// ולכל אחד בונה יחידה (ערך + קריאה + התראה-מותנית). אפס תנאים ⇒ תצוגה-בלבד (עוגן דקדוקי 'את',
// מושא-ישיר — חלקיק, לא מילון). N תנאים ⇒ N יחידות (יכולת-ההתראה חוזרת). האטומים נגזרים פעם-אחת.
export function emitApp(text, cls = 'GenCapScreen') {
  const clauses = detectAllClauses(text);
  let units;
  if (clauses.length) {
    units = clauses.map((f, i) => ({ i, label: f.x, op: f.op === '<' ? '<' : '>', alert: true, trigger: f.trigger }));
  } else {
    // אין תנאי ⇒ צורך של יכולת-**אחת** (תצוגה). עוגן: מושא-ישיר 'את X' (חלקיק דקדוקי, אפס-מילון).
    const m = String(text || '').match(/(?:^|\s)את\s+(.+)/);
    const val = m ? cleanPhrase(hw(m[1]).slice(0, 3)) : '';
    if (!val) throw new Error('לא נמצאו יכולות במשפט (אין תנאי ואין מושא-ישיר להצגה)');
    units = [{ i: 0, label: val, op: null, alert: false, trigger: '' }];
  }
  // אטומים נגזרים פעם-אחת: ערך/קריאה לפי-צורה (selectAtom), התראה לפי-מטרה (match).
  const gauge = selectAtom({ value: { re: NUM_RE, ty: /double|num/ } });
  const readout = selectAtom({ value: { re: NUM_RE, ty: /double|num/ }, label: { re: STR_RE, ty: /String/ } });
  if (!gauge || !readout) throw new Error('לא נגזר אטום-ערך/קריאה מהמצע');
  const trig = units.find((u) => u.alert)?.trigger || '';
  const picked = pickAtom(trig);
  const alertAtom = new Set(['AlertBanner']).has(picked) ? picked : 'AlertBanner';
  const alertFile = (fileOf(alertAtom) || 'dart-ui-bs/alert_banner.dart').replace(/\.dart$/, '');
  const gFills = gauge.fills.length ? ', ' + gauge.fills.join(', ') : '';
  const rFills = readout.fills.length ? ', ' + readout.fills.join(', ') : '';
  const hasAlert = units.some((u) => u.alert);   // ייבוא-התראה רק כשיש התראה בפועל (אחרת ייבוא-מת)
  const impPaths = [`../${gauge.file.replace(/\.dart$/, '')}.dart`, `../${readout.file.replace(/\.dart$/, '')}.dart`];
  if (hasAlert) impPaths.push(`../${alertFile}.dart`);
  const imps = [...new Set(impPaths)].map((p) => `import '${p}';`).join('\n');
  const stateVars = units.map((u) => `  double _v${u.i} = 55;`).join('\n');
  // גוף-הילדים **נבנה בלולאה** על היחידות — כאן המבנה נגזר (כמה, ואילו) ולא נחרט.
  const body = units.map((u) => {
    const cmp = u.alert ? `_v${u.i} ${u.op} 60` : 'false';
    const rLabel = u.alert ? `(${cmp}) ? 'חריגה · ${u.label}' : 'תקין · ${u.label}'` : `'${u.label}'`;
    const alertW = u.alert
      ? `\n        if (${cmp})\n          Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: ${alertAtom}(label: 'חריגה — ${u.label}', height: 46, radius: 14, accentColor: skin.err, baseColor: skin.raised, fillColor: skin.surface)),`
      : '';
    return `        Padding(padding: const EdgeInsets.only(top: 10, right: 14), child: Align(alignment: Alignment.centerRight, child: Text('${u.label}', style: TextStyle(color: skin.mut, fontSize: 13)))),
        Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Center(child: ${gauge.cls}(${gauge.p.value}: (_v${u.i} / 100).clamp(0.0, 1.0)${gFills}))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: ${readout.cls}(${readout.p.value}: _v${u.i}, ${readout.p.label}: ${rLabel}${rFills})),${alertW}
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Slider(value: _v${u.i}, max: 100, onChanged: (v) => setState(() => _v${u.i} = v))),
        Divider(color: skin.hair, height: 24),`;
  }).join('\n');
  const heCount = units.length + (clauses.length ? ' ניטורים' : ' תצוגה');
  return `// ✨ חולל ע"י capability.mjs (מרכיב) — כוונה⇒הרכבה (§23). המשפט: "${String(text).replace(/"/g, "'")}".
// **המבנה נגזר, לא חרוט:** ${units.length} יחידות (${clauses.length} תנאים) ⇒ ${units.length}× ערך⇒${gauge.cls}/${readout.cls} + ${units.filter((u) => u.alert).length}× התראה⇒${alertAtom}.
// אפס שם-אטום חרוט · אפס-מילון-דומייני · מספר-היחידות מהמבנה (§20-ב · הרכבה-עד-שמושג).
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_seam.dart';
${imps}

void main() => runApp(const _CapApp());

class _CapApp extends StatelessWidget {
  const _CapApp();
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, fontFamily: 'Heebo', scaffoldBackgroundColor: DsTokens.bg, colorScheme: ColorScheme.fromSeed(seedColor: DsTokens.accent)),
        builder: (c, ch) => Directionality(textDirection: TextDirection.rtl, child: ch ?? const SizedBox.shrink()),
        home: const ${cls}(),
      );
}

class ${cls} extends StatefulWidget {
  const ${cls}({super.key});
  @override
  State<${cls}> createState() => _${cls}State();
}

class _${cls}State extends State<${cls}> {
${stateVars}
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context); // מלוא-העיצוב מהחריץ (חוק-7: נופל ל-DsPure.skin בלי PureScope)
    return DsScaffold(
      title: 'מסך שחולל',
      subtitle: '${units.length}${heCount}',
      icon: '📟',
      children: [
${body}
      ],
    );
  }
}
`;
}

if (import.meta.url === 'file://' + process.argv[1]) {
  const arg = process.argv.slice(2).join(' ');
  if (arg) { process.stdout.write(emitApp(arg)); }
  else { console.error('שימוש: node capability.mjs "<משפט-צורך>"'); process.exit(1); }
}

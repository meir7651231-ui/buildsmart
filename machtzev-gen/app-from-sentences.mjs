#!/usr/bin/env node
// 🏗️ app-from-sentences — משפטים-בעברית ⇒ אפליקציה (GENMAX · G9 · §22 "משפט ⇒ אפליקציה עובדת"): N משפטים ⇒ N מודולי-ישות (sentence⇒entity⇒pickModule⇒retarget: labels·core·columns)
//   + רכזת-ניווט מחוללת (כמו schoolos.dart: DsScaffold + DsNavTile + Navigator.push) + בדיקת-ניווט מחוללת ל-buildsmart (בית ⇒ כל מודול מרונדר וחוזר, אפס-חריגות).
//   קלט: --spec app-golden.json ({name, sentences[]}) או --name X --text "…" (חוזר). פלט: new/dart-gen-bs/gen_app_<name>.dart + מודולים · test/genesis_gen_app_<name>_test.dart (במראה).
//   --gate: הרכזת+המודולים ≡ טריים (דטרמיניזם) · --test: מריץ את בדיקת-הניווט המחוללת ב-buildsmart (push).
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import * as R from '../root.mjs';
import { fromSentence } from './sentence.mjs';
import { termsFor } from './retarget.mjs';
import { normSearch } from '../../new/atoms/norm-search.mjs';
import { NORM_SEARCH_T } from '../../new/atoms/norm-search-strings.mjs';

const ROOT = R.ROOT, GEN = path.join(ROOT, 'machtzev/generator'), DIR = path.join(ROOT, 'new/dart-gen-bs');
const BS = process.env.BUILDSMART || path.resolve(ROOT, '../buildsmart/app_flutter');
const FLUTTER = process.env.FLUTTER || (fs.existsSync('/home/user/flutter/bin/flutter') ? '/home/user/flutter/bin/flutter' : 'flutter');
const pascal = (s) => s.replace(/[^A-Za-z0-9]+(.)?/g, (_, c) => (c ? c.toUpperCase() : '')).replace(/^./, (c) => c.toUpperCase());
const q = (s) => `'${String(s).replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\$/g, '\\$')}'`;
// G12b · עור-forge (חוק-7: דגל-הפיך): הספק מצהיר איזה אטום-forge משחק "אריח-KPI" (הצבה עיצובית של הבעלים); המנוע מאמת מבנית מול forge-manifest.json
//   (seam:fields · ≥2 חריצים · חריץ-מספרי יחיד בתוכן-העיצוב) וממלא: ערך ⇒ החריץ-המספרי · תווית ⇒ חריץ-הטקסט הראשון · שאר החריצים '' (מקום-שמור, לא דמו — §20-ג). בלי skin ⇒ אטומי-DS (ביט-זהה).
const FORGE_MANIFEST = path.join(ROOT, 'new/dart-forge-bs/forge-manifest.json');
const isNumDemo = (t) => /^[\d.,%+\-\s]+$/.test(t) && /\d/.test(t);
export function resolveSkin(skin) {
  if (!skin || !Object.keys(skin).length) return null;
  if (!fs.existsSync(FORGE_MANIFEST)) throw new Error('skin: אין forge-manifest.json — הרץ node machtzev/ds-forge.mjs');
  const m = JSON.parse(fs.readFileSync(FORGE_MANIFEST, 'utf8'));
  // תפקידים והדרישה המבנית של כל אחד (אין מילון: רק צורת-החריצים בתוכן-העיצוב + משפחה)
  const ROLES = {
    kpi:     { need: 'value+label', fam: null,                    desc: 'אריח-KPI ברכזת' },
    hero:    { need: 'value+label', fam: null,                    desc: 'StatHero במודול' },
    stat:    { need: 'value+label', fam: null,                    desc: 'BareStat במודול' },
    navTile: { need: 'text2',       fam: ['card', 'nav', 'list'], desc: 'אריח-ניווט ברכזת (כותרת+משנה)' },
    empty:   { need: 'text2',       fam: ['feedback'],            desc: 'אין-תוצאות ברכזת' },
    // G12e · הפנימי של המודולים (עלים בעלי-טקסט בלבד; מיכלים/טבלאות/קלט נשארים DS)
    button:     { need: 'text1', fam: ['action'],             desc: 'SoftButton(label,onTap) ⇒ כפתור-forge עטוף GestureDetector' },
    statusChip: { need: 'text1', fam: ['status'],             desc: 'StatusChip(label) ⇒ תג-forge' },
    banner:     { need: 'text2', fam: ['feedback', 'status'], desc: 'AlertBanner(message) ⇒ באנר-forge' },
    emptyState: { need: 'text2', fam: ['feedback'],           desc: 'EmptyState(message) במודול ⇒ forge' },
    mediaRow:   { need: 'text2', fam: ['card', 'list'],       desc: 'MediaRow(title,subtitle) ⇒ שורת-forge' },
    // G13b · מיכלים/בוררים/מדדים דרך תפרי-G13a
    section:   { need: 'child+text1',  fam: ['header', 'card', 'composite'],            desc: 'DsSection(title,children) ⇒ מקטע-forge עם התוכן בתוך המסגרת' },
    frame:     { need: 'child',        fam: ['card', 'header', 'composite'],            desc: 'GradientCard(child) ⇒ מסגרת-forge' },
    segmented: { need: 'select',       fam: ['selection', 'nav', 'action', 'composite'], desc: 'SegmentedSwitch(items,selected,onSelect) ⇒ בורר-forge' },
    chip:      { need: 'select',       fam: ['selection', 'composite', 'status'],       desc: 'FilterChipPill(label,selected,onTap) ⇒ צ׳יפ-forge' },
    meter:     { need: 'value+values', fam: ['status', 'dataviz', 'card', 'list'],      desc: 'StatRow(label,value,fraction) ⇒ מדד-forge עם מילוי' },
    glass:     { need: 'text2',        fam: ['card'],                                   desc: 'GlassCard(title,sub) ⇒ כרטיס-forge' },
    timeline:  { need: 'items2',       fam: ['list', 'chat', 'card'],                   desc: 'TimelineItem(title,time,body) ⇒ שורת-רשימה-forge' },
    // G13c · שדות-חיים בתוך ציור-forge (control) + כותרת-המסך
    field:       { need: 'control', fam: ['input', 'composite'], desc: 'DsField(label,hint,value,onChanged) ⇒ אטום-forge עם השדה-החי (bare) בחריץ-ה-control' },
    enumField:   { need: 'control', fam: ['input', 'composite'], desc: 'DsEnumField ⇒ forge+control' },
    numberField: { need: 'control', fam: ['input', 'composite'], desc: 'DsNumberField ⇒ forge+control' },
    dateField:   { need: 'control', fam: ['input', 'composite'], desc: 'DsDateField ⇒ forge+control' },
    search:      { need: 'control', fam: ['input', 'composite'], desc: 'DsSearch ⇒ forge+control' },
    pageHeader:  { need: 'text2',   fam: ['header'],             desc: 'DsScaffold(title,subtitle) ⇒ כותרת-forge בראש המסך (header:false ב-DS)' },
    // G13d · טבלה · בארים
    table: { need: 'table',  fam: ['spatial', 'list'], desc: 'DsTable(labels,rows) ⇒ טבלת-forge (columns + items[i][j])' },
    bars:  { need: 'values', fam: ['dataviz'],          desc: 'NeonBars/DsBars(labels,values) ⇒ גרף-forge (values ⇒ גובה-בארים)' },
    // G14 · לוח-שנה כאטום-דאטה
    board:    { need: 'board',    fam: ['spatial'],             desc: 'DsBoard(stages,records,stageOf,titleOf,onMove) ⇒ קנבן-forge: עמודות כפריטים, כרטיסים כתאים; הקשה=קידום · הקשה-ארוכה=החזרה' },
    calendar: { need: 'calendar', fam: ['temporal', 'spatial'], desc: 'DsCalendar(records,dateOf) ⇒ לוח-forge: כותרת-חודש · 7 עמודות · ימים כפריטים עם וריאנטים (pad/has/today) · onAction ◀▶' },
  };
  const toneMap = (skin && skin.toneMap) || {};   // G13d · גשר-טונים מוצהר: תפקיד ⇒ [טוקן-וריאנט לכל טון-DS 0..3]
  const out = {};
  for (const [role, cls] of Object.entries(skin)) {
    if (role === 'toneMap') continue;
    const R = ROLES[role]; if (!R) throw new Error(`skin: תפקיד לא-מוכר "${role}" (${Object.keys(ROLES).join('/')})`);
    const a = (m.atoms || []).find((x) => x.cls === cls); if (!a) throw new Error(`skin.${role}: אין אטום-forge בשם ${cls}`);
    const numIdx = a.fieldDemo.map((t, i) => (isNumDemo(t) ? i : -1)).filter((i) => i >= 0);
    if (a.states && R.need !== 'control') throw new Error(`skin.${role}: ${cls} רב-מצבי (theater) — לא נכנס לעור`);
    const textIdxOf = () => a.fieldDemo.map((t, i) => (/[a-z֐-׿]/.test(t) ? i : -1)).filter((i) => i >= 0);
    const base = { role, cls: a.cls, family: a.family, slots: a.fieldSlots, demo: a.fieldDemo, barrel: `../dart-forge-bs/${a.family}/${a.family}.dart`, itemSlots: a.items ? a.items.slots : 0, bare: !!a.bare, hasItems: !!a.items, stateIds: a.stateIds || null, variantIds: a.items && a.items.variants ? a.items.variants : null };
    if (R.fam && !R.fam.includes(a.family)) throw new Error(`skin.${role}: ${cls} ממשפחת ${a.family} — נדרש ${R.fam.join('/')}`);
    // G13b · תפרי-G13a (מאומתים מול forge-manifest.atoms: child · items · values)
    if (R.need === 'child' || R.need === 'child+text1') {
      if (!a.child) throw new Error(`skin.${role}: ${cls} בלי תפר-child`);
      const ti = textIdxOf(); if (R.need === 'child+text1' && !ti.length) throw new Error(`skin.${role}: ${cls} — נדרש חריץ-טקסט לכותרת`);
      out[role] = Object.assign(base, { titleIdx: ti[0] ?? 0, subIdx: ti[1] ?? -1 }); continue;
    }
    if (R.need === 'board') {
      if (!a.items || !a.items.cells || a.items.slots < 2) throw new Error(`skin.${role}: ${cls} — נדרש קנבן: עמודות כפריטים (≥2 חריצי-כותרת) עם כרטיסים כתאים — ${JSON.stringify(a.items)}`);
      out[role] = base; continue;
    }
    if (R.need === 'calendar') {
      const v = a.items && a.items.variants || [];
      if (!a.items || !a.columns || !(a.actions >= 2) || !['pad', 'has', 'today'].every((t) => v.includes(t))) throw new Error(`skin.${role}: ${cls} — נדרש לוח: פריטי-ימים עם וריאנטים pad/has/today · columns (ימי-שבוע) · ≥2 פעולות (◀▶) — ${JSON.stringify({ items: a.items, columns: a.columns, actions: a.actions })}`);
      const ti = textIdxOf(); out[role] = Object.assign(base, { titleIdx: ti[0] ?? 0 }); continue;
    }
    if (R.need === 'table') {
      if (!a.items || !a.items.cells || !a.columns) throw new Error(`skin.${role}: ${cls} — נדרשת טבלה: שורות עם תבנית-תא (items.cells) + כותרות-עמודות (columns) — ${JSON.stringify({ items: a.items, columns: a.columns })}`);
      out[role] = base; continue;
    }
    if (R.need === 'values') {
      if (!(a.values >= 3)) throw new Error(`skin.${role}: ${cls} — נדרשת סדרת-בארים (values≥3, יש ${a.values || 0})`);
      const ti = textIdxOf(); out[role] = Object.assign(base, { titleIdx: ti[0] ?? -1, values: a.values }); continue;
    }
    if (R.need === 'control') {
      if (!a.control) throw new Error(`skin.${role}: ${cls} בלי תפר-control (אין <input> בציור)`);
      const ti = textIdxOf();
      out[role] = Object.assign(base, { titleIdx: ti[0] ?? -1, subIdx: -1 }); continue;
    }
    if (R.need === 'select') {
      if (!a.items || !a.items.selectable || !a.items.selected || a.items.slots < 1) throw new Error(`skin.${role}: ${cls} — נדרשת קבוצת-פריטים לחיצה עם selected (${JSON.stringify(a.items)})`);
      out[role] = base; continue;
    }
    if (R.need === 'items2') {
      if (!a.items || a.items.slots < 2) throw new Error(`skin.${role}: ${cls} — נדרשת קבוצת-פריטים עם ≥2 חריצים (${JSON.stringify(a.items)})`);
      out[role] = base; continue;
    }
    if (R.need === 'value+values') {
      if (!(a.values >= 1) || a.fieldSlots < 2 || numIdx.length < 1 || numIdx.length >= a.fieldSlots) throw new Error(`skin.${role}: ${cls} — נדרש מילוי (values≥1) + חריץ-מספרי + חריץ-טקסט (values=${a.values} · slots=${a.fieldSlots})`);
      out[role] = Object.assign(base, { valueIdx: numIdx[0], labelIdx: a.fieldDemo.findIndex((t, i) => i !== numIdx[0]) }); continue;
    }
    // G13c: חריצי-טקסט קיימים בכל seam (G13a) — אין דרישת seam:fields
    if (R.need === 'value+label') {
      if (a.fieldSlots < 2 || numIdx.length < 1 || numIdx.length >= a.fieldSlots) throw new Error(`skin.${role}: ${cls} — נדרש ≥2 חריצים, לפחות חריץ-מספרי אחד ולפחות חריץ-טקסט אחד (יש ${a.fieldSlots} · מספריים ${numIdx.length})`);   // ערך ⇒ החריץ-המספרי הראשון; חריץ-מספרי נוסף (דלתא) נשאר '' — מקום-שמור, לא דמו
      const valueIdx = numIdx[0], labelIdx = a.fieldDemo.findIndex((t, i) => i !== valueIdx);
      out[role] = { role, cls: a.cls, family: a.family, slots: a.fieldSlots, valueIdx, labelIdx, demo: a.fieldDemo, barrel: `../dart-forge-bs/${a.family}/${a.family}.dart` };
    } else {
      const minSlots = R.need === 'text1' ? 1 : 2;
      if (a.fieldSlots < minSlots || numIdx.length) throw new Error(`skin.${role}: ${cls} — נדרש ≥${minSlots} חריצי-טקסט ואפס מספריים (יש ${a.fieldSlots} · מספריים ${numIdx.length})`);
      // כותרת ⇒ החריץ הראשון שתוכן-העיצוב שלו אינו כותרת-קטגוריה (כולו אותיות-גדולות/סימנים = "FLAT"/"ELEVATED" — תג-סוג של הגלריה), משנה ⇒ הבא אחריו
      const textIdx = a.fieldDemo.map((t, i) => (/[a-z֐-׿]/.test(t) ? i : -1)).filter((i) => i >= 0);
      const titleIdx = textIdx[0] ?? 0, subIdx = textIdx[1] ?? (titleIdx + 1 < a.fieldSlots ? titleIdx + 1 : -1);
      out[role] = { role, cls: a.cls, family: a.family, slots: a.fieldSlots, titleIdx, subIdx, demo: a.fieldDemo, barrel: `../dart-forge-bs/${a.family}/${a.family}.dart`, bare: !!a.bare };
      // G13d · אטום-וריאנטים (items.variants, פריט-יחיד) ⇒ הטקסט כפריט; toneMap[role] ממפה טון-DS ⇒ אינדקס-וריאנט (לפי variantIds); חסר ⇒ הראשון
      if (a.items && a.items.variants && a.items.slots >= 1) {
        const ids = a.items.variants; const tm = toneMap[role];
        if (tm) { const bad = tm.filter((t) => !ids.includes(t)); if (bad.length) throw new Error(`skin.toneMap.${role}: ${bad.join(',')} אינם וריאנטים של ${cls} (${ids.join('/')})`); }
        out[role].variantMap = (tm || [ids[0], ids[0], ids[0], ids[0]]).map((t) => ids.indexOf(t));
      }
    }
  }
  return out;
}
const kpiFields = (sk, valueExpr, labelExpr) => `[${Array.from({ length: sk.slots }, (_, i) => (i === sk.valueIdx ? valueExpr : i === sk.labelIdx ? labelExpr : "''")).join(', ')}]`;
const textFields = (sk, titleExpr, subExpr) => `[${Array.from({ length: sk.slots }, (_, i) => (i === sk.titleIdx ? titleExpr : i === sk.subIdx ? subExpr : "''")).join(', ')}]`;
export function buildApp({ name, sentences, skin, aliases = null }) {   // G15 · aliases: כינויי-ישות מוצהרים לפי-אפליקציה (entity.student ⇒ Member)
  const N = pascal(name), mods = [], skipped = [];
  const skins = resolveSkin(skin) || {}; const sk = skins.kpi || null, skNav = skins.navTile || null, skEmpty = skins.empty || null;
  const MOD_ROLES = ['stat', 'hero', 'button', 'statusChip', 'banner', 'emptyState', 'mediaRow', 'section', 'frame', 'segmented', 'chip', 'meter', 'glass', 'timeline', 'field', 'enumField', 'numberField', 'dateField', 'search', 'pageHeader', 'table', 'bars', 'calendar', 'board'];   // G13b · G13c · G13d · G14
  const modSkin = MOD_ROLES.some((r) => skins[r]) ? Object.fromEntries(MOD_ROLES.map((r) => [r, skins[r] || null])) : null;
  for (const text of sentences) {
    const r = fromSentence(text, modSkin, aliases);
    if (!r.entity) { skipped.push({ text, reason: r.reason }); continue; }
    if (mods.some((m) => m.entity === r.entity)) { skipped.push({ text, reason: `ישות חוזרת (${r.entity})` }); continue; }
    const t = termsFor(r.entity);
    mods.push({ text, entity: r.entity, module: r.module, file: path.basename(r.out), screen: `${r.entity.replace(/[^A-Za-z0-9]/g, '')}Screen`, title: t ? (t.plural || t.singular) : r.entity, code: r.code, pick: r.pick, facts: r.facts });
  }
  const hub = [`// 🏗️ ${N}App — אפליקציה ממשפטים (GENMAX·G9 · §22): ${mods.length} מודולים · מחולל דטרמיניסטי: app-from-sentences.mjs (sentence⇒entity⇒pickModule⇒retarget) — כל מודול חצוב מהזהב, לא נכתב`,
    ...mods.map((m) => `//   "${m.text}" ⇒ ${m.entity} ⇐ ${m.module} (${m.pick.strength} · שמות ${m.pick.names}/${m.pick.fields})`),
    ...skipped.map((s) => `//   ⚪ "${s.text}" ⇒ ${s.reason}`),
    `//   G10b-ב · תפר-הזרקה (db) ⇒ בדיקה שמזריקה שדה-סכמה שמור על רשומת-המסך ורואה את העמודה מאירה: ${mods.map((m) => `${m.entity}:${m.facts.seedSeam ? `${m.facts.seedSeam.reserved.length} עמודות` : '∅'}`).join(' · ')}`,
    `//   G12c · תפקידי-עור: ${Object.values(skins).map((x) => `${x.role}=${x.cls}`).join(' · ') || 'DS'}`,
    `//   G12b · עור: ${sk ? `forge — אריח-KPI = ${sk.cls} (${sk.family} · ${sk.slots} חריצים · תוכן-העיצוב ${JSON.stringify(sk.demo)} ⇒ ערך בחריץ ${sk.valueIdx}, תווית בחריץ ${sk.labelIdx}, השאר '') — הצבה של הבעלים ב-app-golden, מאומתת מבנית` : 'DS (KpiTile) — ברירת-מחדל, ביט-זהה'}`,
    `//   G10b · עם הקפיצה נשלח גם initialMetric=heroKey ⇒ הטבלה במודול מסוננת לשורות-המדד (באנר + ביטול): ${mods.map((m) => `${m.entity}:${m.facts.metricSeam ? 'initialMetric' : '∅'}`).join(' · ')}`,
    `//   G10a · אריח-hero ⇒ טאפ פותח את המודול על הרשומה-הראשונה של המדד (<E>Facts.heroFirstId ⇒ <E>Screen(initialPanelId)) — תפר-כניסה חצוב מצורת initialPanel של זהב-המורים: ${mods.map((m) => `${m.entity}:${m.facts.entrySeam || '∅'}`).join(' · ')}`,
    `//   G9b · KPI-רכזת נגזר: כל אריח = ${'<E>'}Facts של המודול (count חי של הזרע · hero = המדד שהזהב הכריז/צבע-סכנה) — אפס ערך מומצא: ${mods.map((m) => `${m.facts.cls}.${m.facts.heroKey}`).join(' · ')}`,
    `import 'package:flutter/material.dart';`, `import '../dart-ui-bs/ds/ds.dart';`, ...[...new Set([sk, skNav, skEmpty].filter(Boolean).map((x) => x.barrel))].map((b) => `import '${b}'; // G12b/c · עור-forge`), ...(sk ? [] : [`import '../dart-ui-bs/premium/dataviz/kpi_tile.dart';`]),
    `import '../dart-ui-bs/ds/ds_search.dart'; // איתור: חיפוש-מבוקר (value+onChanged)`, `import '../dart-ui-bs/premium/feedback/empty_state.dart'; // אין-תוצאות`,
    `import '../dart-maor/smart-filter.dart'; // איתור: סינון+מיון-לפי-ציון (מדף)`, `import '../dart-maor/smart-score.dart'; // איתור: ניקוד רב-מילתי AND (מדף)`,
    `import '../dart-maor/norm-search.dart'; // איתור: נרמול-חיפוש עברי (מדף)`, `import '../dart-data-maor/norm-search-strings.dart'; // NORM_SEARCH_T (אטום-דאטה)`,
    ...mods.map((m) => `import '${m.file}' show ${m.screen}, ${m.facts.cls}; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות`), '',
    `class ${N}App extends StatelessWidget {`, `  const ${N}App({super.key});`, '  @override',
    `  Widget build(BuildContext context) => MaterialApp(title: ${q(name)}, debugShowCheckedModeBanner: false, theme: ThemeData(brightness: Brightness.dark, useMaterial3: true, fontFamily: DsTokens.fontBody), home: const ${N}HubScreen()); // גופן-הגוף של ה-DS (מצורף לחבילה) — לא Roboto-מ-CDN: האתר-המחולל עצמאי גם בלי רשת (L69)`, '}', '',
    `class ${N}HubScreen extends StatefulWidget {`, `  const ${N}HubScreen({super.key});`, '  @override', `  State<${N}HubScreen> createState() => _${N}HubScreenState();`, '}', '',
    `class _${N}HubScreenState extends State<${N}HubScreen> {`,
    `  static void _go(BuildContext c, Widget screen) => Navigator.push(c, MaterialPageRoute(builder: (_) => screen));`,
    `  static const modules = <String>[${mods.map((m) => q(m.title)).join(', ')}]; // ${mods.length} מסכים מחווטים`,
    `  String _q = ''; // חיפוש-רכזת נגזר (G9c): DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch — צורת-האיתור של הזהב (23-ג), לא .contains שטוח`,
    `  static String _norm(dynamic q) => normSearch(q, NORM_SEARCH_T);`,
    `  static Iterable _expand(dynamic q, dynamic norm) => [norm(q)];`,
    `  static num _score(dynamic exp, dynamic term) => _norm(term).contains('${'$'}exp') ? 100 : 0;`,
    `  static num _scoreOf(dynamic q, dynamic terms) => smartScore(q, terms, _norm, _expand, _score) as num;`,
    `  static bool _hasQuery(dynamic q) => (q as String).trim().isNotEmpty;`,
    `  // שורות-החיפוש = נגזרת של תפר-העובדות: כותרת · מונח-הישות · המשפט · תוויות-המדדים — אפס דאטה-חדש`,
    `  static final rows = <Map<String, dynamic>>[`,
    ...mods.map((m, i) => `    {'i': ${i}, 'title': ${q(m.title)}, 'label': ${m.facts.cls}.label, 'text': ${q(m.text)}, 'terms': [for (final d in ${m.facts.cls}.metricDefs) '${'$'}{d['label']}']},`),
    '  ];',
    `  static List<String> termsOf(Map<String, dynamic> r) => ['${'$'}{r['title']}', '${'$'}{r['label']}', '${'$'}{r['text']}', ...(r['terms'] as List).cast<String>()];`,
    `  static List<Map<String, dynamic>> searchModules(List<Map<String, dynamic>> rs, String q) => (smartFilter(q, rs, (it) => termsOf(it as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();`,
    '  @override',
    `  Widget build(BuildContext context) {`,
    `    final vis = searchModules(rows, _q).map((r) => r['i'] as int).toSet();`,
    `    return DsScaffold(title: ${q(name)}, subtitle: '${mods.length} מודולים ממשפטים · כל אחד חצוב מהזהב', icon: '🧬', children: [`,
    `      DsSearch(value: _q, onChanged: (v) => setState(() => _q = v)),`,
    `      const SizedBox(height: 8),`,
    `      Wrap(spacing: 12, runSpacing: 12, children: [ // KPI-רכזת (G9b): עובדות-אמת בלבד — כמו _Home של הזהב (מסכים-מחוברים + הדחוף של כל מודול)`,
    sk ? `        SizedBox(width: 168, child: ${sk.cls}(fields: ${kpiFields(sk, "'${vis.length}/${modules.length}'", "'מסכים מחוברים'")})),` : `        SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: '${'$'}{vis.length}/${'$'}{modules.length}', label: 'מסכים מחוברים')),`,
    ...mods.map((m, i) => m.facts.entrySeam
      ? `        if (vis.contains(${i})) GestureDetector(key: const ValueKey('hero-${m.entity}'), onTap: () { final id = ${m.facts.cls}.heroFirstId; _go(context, id == null ? const ${m.screen}() : ${m.screen}(${m.facts.entrySeam}: id${m.facts.metricSeam ? `, initialMetric: ${m.facts.cls}.heroKey` : ''})); }, child: SizedBox(width: 168, child: ${sk ? `${sk.cls}(fields: ${kpiFields(sk, `${m.facts.cls}.hero`, `${m.facts.cls}.heroLabel`)})` : `KpiTile(glyph: '🧬', value: ${m.facts.cls}.hero, label: ${m.facts.cls}.heroLabel)`})), // ${m.entity} · ${m.facts.heroHow} · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)`
      : `        if (vis.contains(${i})) SizedBox(key: const ValueKey('hero-${m.entity}'), width: 168, child: ${sk ? `${sk.cls}(fields: ${kpiFields(sk, `${m.facts.cls}.hero`, `${m.facts.cls}.heroLabel`)})` : `KpiTile(glyph: '🧬', value: ${m.facts.cls}.hero, label: ${m.facts.cls}.heroLabel)`}), // ${m.entity} · ${m.facts.heroHow} · אין תפר-כניסה (אין זרע/פאנל)`),
    '      ]),', '      const SizedBox(height: 8),',
    `      if (vis.isEmpty) ${skEmpty ? `${skEmpty.cls}(fields: ${textFields(skEmpty, "'אין מודול שתואם לחיפוש'", "'נסה מילה אחרת'")})` : "const EmptyState(glyph: '🔍', message: 'אין מודול שתואם לחיפוש')"} else DsSection(title: 'כלים · ${'$'}{vis.length}', children: [`,
    ...mods.map((m, i) => { const subE = m.facts.count ? `'${'$'}{${m.facts.cls}.count} ${'$'}{${m.facts.cls}.label} · ${q(m.text).slice(1, -1)}'` : q(m.text); return skNav
      ? `        if (vis.contains(${i})) GestureDetector(key: const ValueKey('nav-${m.entity}'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const ${m.screen}()), child: ${skNav.cls}(fields: ${textFields(skNav, q(m.title), subE)})), // אריח-ניווט forge (G12c)`
      : `        if (vis.contains(${i})) DsNavTile(glyph: '🧬', title: ${q(m.title)}, sub: ${subE}, onTap: () => _go(context, const ${m.screen}())),`; }),
    '      ]),', '    ]);', '  }', '}', ''].join('\n');
  const tileType = skNav ? skNav.cls : 'DsNavTile', emptyType = skEmpty ? skEmpty.cls : 'EmptyState';
  const test = [`// מחולל ע"י machtzev/generator/app-from-sentences.mjs — בדיקת-ניווט של ${N}App: בית ⇒ כל מודול מרונדר וחוזר, אפס-חריגות`,
    `import 'package:buildsmart/genesis/dart-gen-bs/gen_app_${name.toLowerCase()}.dart';`, ...mods.map((m) => `import 'package:buildsmart/genesis/dart-gen-bs/${m.file}' show ${m.screen}, ${m.facts.cls};`),
    `import 'package:buildsmart/genesis/dart-ui-bs/ds/ds.dart';`, `import 'package:buildsmart/genesis/dart-ui-bs/premium/feedback/empty_state.dart';`, ...[...new Set([skNav, skEmpty].filter(Boolean).map((x) => x.barrel.replace('../', 'package:buildsmart/genesis/')))].map((b) => `import '${b}';`), `import 'package:flutter/material.dart';`, `import 'package:flutter_test/flutter_test.dart';`, '',
    'void main() {',
    `  testWidgets('${N}App · בית: ${mods.length} אריחים', (tester) async {`,
    `    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);`,
    `    await tester.pumpWidget(const ${N}App()); await tester.pump(const Duration(milliseconds: 300));`,
    `    expect(find.byType(${tileType}), findsNWidgets(${mods.length})); expect(tester.takeException(), isNull);`,
    `    expect(find.text('${mods.length}/${mods.length}'), findsWidgets); // KPI מסכים-מחוברים = עובדה (נראים/כולם)`,
    ...mods.flatMap((m) => [
      `    expect(${m.facts.cls}.metricDefs.length, ${m.facts.cls}.metrics.length); expect(${m.facts.cls}.heroKey == 'count' || ${m.facts.cls}.metrics.containsKey(${m.facts.cls}.heroKey), isTrue); // ${m.entity}: תפר-העובדות עקבי`,
      `    expect(find.text(${m.facts.cls}.hero), findsWidgets); expect(find.text(${m.facts.cls}.heroLabel), findsWidgets); // ה-hero של ${m.entity} מרונדר ברכזת מהביטוי-החי, לא מליטרל`,
      ...(m.facts.count ? [`    expect(find.textContaining('${'$'}{${m.facts.cls}.count} ${'$'}{${m.facts.cls}.label}'), findsOneWidget); // count חי של הזרע-הראשי (${m.facts.count.list} · ${m.facts.count.how})`] : []),
    ]),
    '  });',
    ...(() => { // G9c · חיפוש-רכזת: הצפי מחושב באותו מנוע-מדף (norm-search.mjs = מקור התאום-Dart): שאילתה-חד-מילתית ⇒ מודול נראה אם אחד ממונחיו מכיל אותה מנורמלת
      const nz = (w) => normSearch(w, NORM_SEARCH_T);
      const termsOf = (m) => [m.title, m.facts.label, m.text, ...m.facts.metrics.map((d) => d.label)];
      const probe = mods[0].title, expectN = mods.filter((m) => termsOf(m).some((t) => nz(t).includes(nz(probe)))).length;
      return [`  testWidgets('${N}App · חיפוש-רכזת נגזר: "${probe}" ⇒ ${expectN}/${mods.length} · ג׳יבריש ⇒ EmptyState · ריק ⇒ הכול', (tester) async {`,
        `    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);`,
        `    await tester.pumpWidget(const ${N}App()); await tester.pump(const Duration(milliseconds: 300));`,
        `    await tester.enterText(find.byType(TextField).first, ${q(probe)}); await tester.pump(const Duration(milliseconds: 300));`,
        `    expect(find.byType(${tileType}), findsNWidgets(${expectN})); expect(find.text('${expectN}/${mods.length}'), findsWidgets); expect(tester.takeException(), isNull);`,
        `    await tester.enterText(find.byType(TextField).first, 'zzqqxx'); await tester.pump(const Duration(milliseconds: 300));`,
        `    expect(find.byType(${tileType}), findsNothing); expect(find.byType(${emptyType}), findsOneWidget); expect(find.text('0/${mods.length}'), findsWidgets);`,
        `    await tester.enterText(find.byType(TextField).first, ''); await tester.pump(const Duration(milliseconds: 300));`,
        `    expect(find.byType(${tileType}), findsNWidgets(${mods.length})); expect(find.byType(${emptyType}), findsNothing); expect(tester.takeException(), isNull);`,
        '  });'];
    })(),
    ...mods.filter((m) => m.facts.seedSeam && m.facts.seedSeam.reserved.length).flatMap((m) => [ // G10b-ב · G5h מאומת-בפועל: עמודת-מקום-שמור מאירה רק כשהנתון מוזרם (הזרקה על רשומת-המסך — L66)
      `  testWidgets('${N}App · הזרקת-שורה ⇒ עמודת-מקום-שמור "${m.facts.seedSeam.reserved[0]}" של ${m.entity} מאירה (G5h)', (tester) async {`,
      `    tester.view.physicalSize = const Size(1400, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);`,
      `    final key = ${m.facts.cls}.reservedColumns.first;`,
      `    await tester.pumpWidget(const MaterialApp(home: ${m.screen}())); await tester.pump(const Duration(milliseconds: 300));`,
      `    Future<void> showTable() async { final v = ${m.facts.cls}.tableView; if (v != null) { await tester.tap(find.text(v).first); await tester.pump(const Duration(milliseconds: 300)); } } // המבט שמגלה את הטבלה (מהזהב)`,
      `    await showTable(); expect(find.text(key), findsNothing); // בלי נתון — העמודה כבויה (חוק-7)`,
      `    final db = ${m.facts.cls}.seed(); final seedRow = (db[${m.facts.cls}.seedList] as List).first as Map<String, dynamic>;`,
      `    final row = ${m.facts.cls}.rowList == null ? seedRow : (seedRow[${m.facts.cls}.rowList!] as List).first as Map<String, dynamic>;`,
      `    row[key] = 'מוזרק-${'$'}key';`,
      `    await tester.pumpWidget(MaterialApp(home: ${m.screen}(db: db))); await tester.pump(const Duration(milliseconds: 300)); await showTable();`,
      `    expect(find.text(key), findsWidgets); // כותרת-העמודה = שם-השדה (G5h) — מאירה כשהנתון זרם`,
      `    expect(find.text('מוזרק-${'$'}key'), findsWidgets); expect(tester.takeException(), isNull);`,
      '  });']),
    ...mods.filter((m) => m.facts.entrySeam).flatMap((m) => [
      `  testWidgets('${N}App · אריח-hero ⇒ ${m.title} (${m.entity}) נפתח על רשומת-ה-hero${m.facts.coreWired ? ' + מקטע-הגרעין על הרשומה' : ''}', (tester) async {`,
      `    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);`,
      `    await tester.pumpWidget(const ${N}App()); await tester.pump(const Duration(milliseconds: 300));`,
      `    await tester.tap(find.byKey(const ValueKey('hero-${m.entity}'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));`,
      `    expect(find.byType(${m.screen}), findsOneWidget); expect(tester.takeException(), isNull);`,
      `    final id = ${m.facts.cls}.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח`,
      `    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); ${m.facts.coreWired ? "expect(find.textContaining('מחזור-חיים · רשומה'), findsWidgets); " : ''}${m.facts.metricSeam ? `expect(find.textContaining('מסונן למדד'), findsOneWidget); expect(find.textContaining('· ${'$'}{${m.facts.cls}.heroRows(${m.facts.cls}.heroKey).length} מתוך'), findsOneWidget); ` : ''}}`,
      `    // ignore: avoid_print`,
      `    print('hero-jump ${m.entity}: id=${'$'}id rows=${'$'}{${m.facts.cls}.heroRows(${m.facts.cls}.heroKey).length} panel=${'$'}{find.byType(BottomSheet).evaluate().length}');`,
      '  });']),
    ...mods.flatMap((m) => [
      `  testWidgets('${N}App · בית ⇒ ${m.title} (${m.entity}) מרונדר וחוזר', (tester) async {`,
      `    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);`,
      `    await tester.pumpWidget(const ${N}App()); await tester.pump(const Duration(milliseconds: 300));`,
      `    await tester.tap(find.text(${q(m.title)}).last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));`,
      `    expect(find.byType(${m.screen}), findsOneWidget); expect(tester.takeException(), isNull);`,
      `    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(${tileType}), findsNWidgets(${mods.length})); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack`,
      '  });']),
    '}', ''].join('\n');
  // G11b · נקודת-כניסה לאתר/אפליקציה (§22 "אפליקציה+אתר"): קובץ main נפרד ⇒ `flutter build web -t <file>` בונה את האפליקציה-המחוללת כאתר עצמאי; אין main() ברכזת (הרכזת נשארת ווידג׳ט לבדיקות)
  const entry = [`// 🌐 ${N}App · נקודת-כניסה (GENMAX·G11b): flutter build web -t lib/genesis/dart-gen-bs/gen_main_${name.toLowerCase()}.dart — האפליקציה-ממשפטים כאתר. מחולל: app-from-sentences.mjs`,
    `import 'package:flutter/material.dart';`, `import 'gen_app_${name.toLowerCase()}.dart';`, '', `void main() => runApp(const ${N}App());`, ''].join('\n');
  return { name, N, mods, skipped, hub, test, entry, hubFile: `gen_app_${name.toLowerCase()}.dart`, entryFile: `gen_main_${name.toLowerCase()}.dart`, testFile: `genesis_gen_app_${name.toLowerCase()}_test.dart` };
}
const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
const arg = (k) => { const i = process.argv.indexOf(k); return i > -1 ? process.argv[i + 1] : null; };
const args = (k) => process.argv.flatMap((a, i) => (a === k ? [process.argv[i + 1]] : []));
const SPECS = fs.readdirSync(GEN).filter((f) => /^app-golden(?:-\d+)?\.json$/.test(f)).sort().map((f) => path.join(GEN, f)); // G9c: כל אפליקציות-הזהב (app-golden.json · app-golden-2.json …)
if (isMain) {
  const specs = arg('--spec') ? [arg('--spec')] : arg('--name') ? [null] : SPECS;
  const results = [];
  for (const spec of specs) {
  const req = spec ? JSON.parse(fs.readFileSync(spec, 'utf8')) : { name: arg('--name'), sentences: args('--text') };
  const app = buildApp(req); results.push(app);
  const write = !process.argv.includes('--gate') || process.argv.includes('--write');
  const errs = [];
  for (const m of app.mods) { const f = path.join(DIR, m.file); if (write) fs.writeFileSync(f, m.code); else if (!fs.existsSync(f) || fs.readFileSync(f, 'utf8') !== m.code) errs.push(`${m.file} ≠ טרי`); }
  const hf = path.join(DIR, app.hubFile); if (write) fs.writeFileSync(hf, app.hub); else if (!fs.existsSync(hf) || fs.readFileSync(hf, 'utf8') !== app.hub) errs.push(`${app.hubFile} ≠ טרי`);
  const ef = path.join(DIR, app.entryFile); if (write) fs.writeFileSync(ef, app.entry); else if (!fs.existsSync(ef) || fs.readFileSync(ef, 'utf8') !== app.entry) errs.push(`${app.entryFile} ≠ טרי`);
  const tf = path.join(BS, 'test', app.testFile); if (write && fs.existsSync(path.join(BS, 'pubspec.yaml'))) fs.writeFileSync(tf, app.test);
  if (process.argv.includes('--gate')) {
    if (errs.length) { console.log('🔴 appgen: ' + errs.join(' · ') + ' (הרץ app-from-sentences.mjs --gate --write)'); process.exit(1); }
    if (process.argv.includes('--test') && fs.existsSync(path.join(BS, 'pubspec.yaml'))) {
      for (const m of app.mods) fs.copyFileSync(path.join(DIR, m.file), path.join(BS, 'lib/genesis/dart-gen-bs', m.file));
      fs.copyFileSync(hf, path.join(BS, 'lib/genesis/dart-gen-bs', app.hubFile)); fs.writeFileSync(tf, app.test);
      const res = spawnSync(FLUTTER, ['test', 'test/' + app.testFile, '--reporter', 'compact'], { cwd: BS, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, env: { ...process.env, PATH: path.dirname(FLUTTER) + ':' + process.env.PATH } });
      const out = (res.stdout || '') + (res.stderr || ''); const last = [...out.matchAll(/\+(\d+)(?:\s+-(\d+))?:/g)].pop(); const p = last ? +last[1] : 0, f = last && last[2] ? +last[2] : 0;
      if (res.status !== 0 || f) { console.log(`🔴 appgen: בדיקת-הניווט של ${app.N}App נכשלה (${p} passed · ${f} failed)`); console.log(out.split('\n').filter((l) => /Error|Exception|Expected|Actual/.test(l)).slice(0, 6).join('\n')); process.exit(1); }
      app.tested = p;
    }
    if (process.argv.includes('--build') && fs.existsSync(path.join(BS, 'pubspec.yaml'))) { // G11b · ראיית-אתר: build web של האפליקציה-המחוללת (כבד — ידני/ראיה, לא בטבעת-push)
      fs.copyFileSync(ef, path.join(BS, 'lib/genesis/dart-gen-bs', app.entryFile));
      const out = `build/web-${app.name.toLowerCase()}`;
      const res = spawnSync(FLUTTER, ['build', 'web', '--release', '-t', 'lib/genesis/dart-gen-bs/' + app.entryFile, '-o', out], { cwd: BS, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, env: { ...process.env, PATH: path.dirname(FLUTTER) + ':' + process.env.PATH } });
      const js = path.join(BS, out, 'main.dart.js');
      if (res.status !== 0 || !fs.existsSync(js)) { console.log(`🔴 appgen: build web של ${app.N}App נכשל`); console.log(((res.stdout || '') + (res.stderr || '')).split('\n').filter((l) => /Error|error/.test(l)).slice(0, 6).join('\n')); process.exit(1); }
      app.web = { out, bytes: fs.statSync(js).size };
    }
    continue;
  }
  console.log(`✓ ${app.N}App ⇒ ${app.hubFile} · ${app.mods.length} מודולים: ${app.mods.map((m) => `${m.title}(${m.entity}⇐${m.module.replace('schoolos_', '').replace('.dart', '')})`).join(' · ')} · בדיקה: test/${app.testFile}${app.skipped.length ? ' · ⚪ ' + app.skipped.map((s) => `"${s.text}": ${s.reason}`).join(' · ') : ''}`);
  }
  // G15b · יתומי-עור: מודול-מעורר (_sk<tag>) שאף gen_app_*.dart לא מייבא = שריד של עור-קודם ⇒ נמחק (רק בכתיבה על כל הספקים; המראה ב-ship מסירה יתומים ב-buildsmart)
  if (!arg('--spec') && !arg('--name') && !process.argv.includes('--gate')) {
    const apps = fs.readdirSync(DIR).filter((f) => /^gen_app_\w+\.dart$/.test(f)).map((f) => fs.readFileSync(path.join(DIR, f), 'utf8')).join('\n');
    const orphans = fs.readdirSync(DIR).filter((f) => /^gen_retarget_\w+_sk[0-9a-f]+\.dart$/.test(f) && !apps.includes(`'${f}'`));
    for (const f of orphans) fs.unlinkSync(path.join(DIR, f));
    if (orphans.length) console.log(`🧹 appgen: ${orphans.length} מודולי-עור יתומים הוסרו (${[...new Set(orphans.map((f) => f.replace(/.*_sk/, 'sk').replace('.dart', '')))].join(' · ')})`);
  }
  if (process.argv.includes('--gate')) { console.log(`✓ appgen: ${results.map((a) => `${a.N}App ${a.mods.length} מודולים${a.tested != null ? ` · flutter test ${a.tested}/${a.tested}` : ''}${a.web ? ` · אתר ${a.web.out} (${(a.web.bytes / 1048576).toFixed(1)} MB)` : ''}`).join(' · ')} — רכזות+מודולים ≡ מחולל-טרי${process.argv.includes('--test') ? ' · ניווט+חיפוש-רכזת עוברים בפועל' : ''} (${results.reduce((n, a) => n + a.skipped.length, 0)} משפטים בלי-ישות מדווחים)`); process.exit(0); }
}

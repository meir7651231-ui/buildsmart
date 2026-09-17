#!/usr/bin/env node
// 🧬 render-module — הרכבה דטרמיניסטית של מודול מחלקיקי-הזהב (GENMAX · G4 · הכרעה-24 · "חוצבים ומרכיבים, לא כותבים").
//   קלט: קטלוג-השברים golden-fragments.json (quarry-golden · 432 שברים · round-trip 9/9) + בקשה:
//     --module <file>            מודול-מקור (למשל schoolos_attendance.dart)
//     --all                      כל השברים ⇒ חייב להיות הקובץ המקורי ביט-לביט (הוכחת-המכניקה)
//     --particles a,b,c          חלקיקי compose-engine (ids) ⇒ אטומי-היעד ⇒ שברים ⇒ סגירת-תלויות ⇒ מודול-משנה מתקמפל
//     --atoms A,B,C              אטומי-יעד ישירות
//     --out <path>               קובץ-פלט (ברירת-מחדל new/dart-gen-bs/gen_<module>.dart)
//   סגירת-תלויות: שבר נבחר ⇒ כל שבר שמגדיר מזהה שהוא צורך (defs מהחציבה) · ראש/סוגר-המחלקה · preamble;
//   build() מקורי נשמר ב---all; במודול-משנה נבנה build() מינימלי מבוני-התצוגה חסרי-הארגומנטים שנבחרו.
//   imports מחושבים-מחדש מהקוד הסופי (סמל-import מופיע בקוד) — אפס import מיותר, אפס import חסר.
//   --gate: (א) --all ≡ מקור 9/9 · (ב) מודול-משנה פר-מודול מחלקיקיו הרשומים ⇒ נכתב ל-gen_*_subset.dart (המראה ל-buildsmart + analyze = בשער-הקומפילציה).
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as R from '../root.mjs';

const ROOT = R.ROOT;
const GEN = path.join(ROOT, 'machtzev/generator');
const DIR = path.join(ROOT, 'new/dart-gen-bs');
const CAT = JSON.parse(fs.readFileSync(path.join(GEN, 'golden-fragments.json'), 'utf8'));
// הקטלוג נושא טווחים בלבד; הבייטים נקראים מהמקור (ה-fixture) — שבר = lines[range[0]..range[1])
{ const srcCache = new Map(); for (const f of CAT.fragments) { if (!srcCache.has(f.module)) srcCache.set(f.module, fs.readFileSync(path.join(DIR, f.module), 'utf8').split('\n')); f.lines = srcCache.get(f.module).slice(f.range[0], f.range[1]); f._src = srcCache.get(f.module); } }
const CE = fs.readFileSync(path.join(ROOT, 'machtzev/compose-engine.mjs'), 'utf8');

// חלקיק ⇒ אטומים (מטבלת-ATOM ו-ops() של compose-engine — אותו מקור-אמת של הזהב)
const ATOM = Object.fromEntries([...CE.matchAll(/^\s*(\w+):\s*\{\s*atom:\s*'([^']+)'/gm)].map((m) => [m[1], m[2]]));
const KIND_OPS = Object.fromEntries([...CE.matchAll(/if \(f\.kind === '([^']+)'\)[^\n]*?\n?[^\n]*?return \[([\s\S]*?)\];/g)].map((m) => [m[1], [...m[2].matchAll(/op:\s*'(\w+)'/g)].map((x) => x[1])]));
const PARTICLES = Object.fromEntries([...CE.matchAll(/\{ id: '([^']+)',\s*name: '(?:[^'\\]|\\.)*',\s*f: \{ kind: '([^']+)'/g)].map((m) => [m[1], m[2]]));
const pascal = (s) => s.replace(/(^|_)([a-z0-9])/g, (_, __, c) => c.toUpperCase());
export const PARTICLE_IDS = Object.keys(PARTICLES);
export const atomsOfParticle = (id) => (KIND_OPS[PARTICLES[id]] || []).map((op) => ATOM[op]).filter(Boolean).map((a) => (/^[a-z]/.test(a) && /_/.test(a) ? pascal(a) : a));

const idsIn = (code) => new Set([...code.matchAll(/\b([A-Za-z_][A-Za-z0-9_]*)\b/g)].map((m) => m[1]));
// שורת-הקוד הראשונה של שבר (הערות-כותרת ו-@override דבוקים לפניה — חוקי-הדבק של החציבה)
const codeLine = (f) => f.lines.find((l) => l.trim().length && !/^\s*\/\//.test(l) && !/^\s*@override\s*$/.test(l)) || '';
const classLine = (f) => f.lines.find((l) => /^(abstract\s+)?class\s+\w+/.test(l)) || '';
// ── G5a · שקעי-בונים = replay של הזהב: הפתיח (prelude) של build המקורי + אתר-הקריאה המקורי של כל בונה (§20-ג: אפס ערך-מומצא)
const DART_KNOWN = new Set(['context', 'setState', 'widget', 'mounted', 'true', 'false', 'null', 'const', 'final', 'var', 'new', 'as', 'is', 'in', 'if', 'else', 'for', 'await', 'async', 'this', 'super', 'return', 'String', 'int', 'double', 'bool', 'num', 'List', 'Map', 'Set', 'Object', 'dynamic', 'void', 'print']);
const preludeLocals = (lines) => new Set(lines.flatMap((l) => [...l.matchAll(/^\s+(?:final|var|late|const)\s+(?:[\w<>?, ]+?\s+)?(\w+)\s*=/g)].map((m) => m[1]).concat([...l.matchAll(/^\s+(?:final|var)\s+\(?(\w+)(?:,\s*(\w+))*\)?\s*=/g)].flatMap((m) => m.slice(1).filter(Boolean)))));
const declaredInside = (site) => new Set([...site.matchAll(/\((\w+(?:,\s*\w+)*)\)\s*(?:=>|\{)/g)].flatMap((m) => m[1].split(/,\s*/)).concat([...site.matchAll(/for \(final (\w+) in/g)].map((m) => m[1])));
function siteResolvable(site, known, defIndex, importNames) {
  const local = declaredInside(site);
  for (const id of idsIn(site.replace(/'(?:[^'\\]|\\.)*'/g, "''"))) {              // מחרוזות לא נספרות (אינטרפולציה ${…} נשארת — טוב: היא צורכת מזהים)
    if (/^[A-Z]/.test(id) || /^\d/.test(id) || DART_KNOWN.has(id) || local.has(id) || known.has(id) || defIndex.has(id) || importNames.has(id)) continue;
    return false;
  }
  return true;
}
const importNamesOf = (frags) => { const out = new Set(); for (const f of frags) if (f.cls === '(preamble)' || f.cls === '(top)') for (const l of f.lines) { const m = l.match(/^import '([^']+)'/); if (m && !/^package:|^dart:/.test(m[1])) for (const n of declaredNames(m[1])) out.add(n); } return out; };
// לכל מחלקת-State: הפתיח + אתרי-הקריאה הפתירים של הבונים הנבחרים ⇒ {preludeLines, sites:[{name, site, spread}], unresolved:[…]}
// G8e · גיזום-פתיח לפי-שימוש: משפטי-הפתיח (רב-שורתיים, לפי סוגריים מאוזנים) ⇒ נשמרים רק אלה שמגדירים מקומי שנצרך ע"י אתרי-הקריאה/משפטים-שנשמרו, וכל משפט שאינו הגדרה (if/return/השמה) — אחורה עד נקודת-שבת
function preludeStatements(lines) {
  const out = []; let cur = [], depth = 0;
  for (const l of lines) { cur.push(l); for (const ch of l.replace(/'(?:[^'\\]|\\.)*'/g, '')) { if ('([{'.includes(ch)) depth++; else if (')]}'.includes(ch)) depth--; } if (depth <= 0 && /;\s*(\/\/.*)?$/.test(l) || (depth <= 0 && /^\s*\/\//.test(l) && cur.length === 1)) { out.push(cur); cur = []; depth = 0; } }
  if (cur.length) out.push(cur);
  return out;
}
export function prunePrelude(preludeLines, usedText) {
  const stmts = preludeStatements(preludeLines).map((ls) => ({ ls, defs: [...preludeLocals(ls)], ids: idsIn(ls.join('\n').replace(/'(?:[^'\\]|\\.)*'/g, "''")), decl: ls.some((l) => /^\s+(?:final|var|late|const)\s/.test(l)) }));
  const need = new Set([...idsIn(usedText)]); const keep = new Set();
  let grew = true; while (grew) { grew = false; stmts.forEach((st, i) => { if (keep.has(i)) return; if (!st.decl || st.defs.some((d) => need.has(d))) { keep.add(i); st.ids.forEach((x) => need.add(x)); grew = true; } }); }
  return { lines: stmts.filter((st, i) => keep.has(i)).flatMap((st) => st.ls), dropped: stmts.filter((st, i) => !keep.has(i)).flatMap((st) => st.defs) };
}
function socketPlan(frags, chosenSet, cls, defIndex, importNames, prune = false) {
  const build = frags.find((f) => f.cls === cls && f.role === 'build');
  const src = frags[0]._src;
  const preludeLinesAll = build && build.prelude ? src.slice(build.prelude[0], build.prelude[1]) : [];
  let preludeLines = preludeLinesAll;
  const known = preludeLocals(preludeLines);
  const sites = [], unresolved = [];
  const candidates = frags.filter((f) => f.cls === cls && chosenSet.has(f.id) && (f.role === 'builder' || (f.role === 'member' && /^\s+List<Widget>\s+_\w+\(/.test(codeLine(f)))));
  const pool = {}; for (const f of frags) if (f.cls === cls && f.callSites && (f.role === 'build' || chosenSet.has(f.id))) for (const [k, v] of Object.entries(f.callSites)) (pool[k] ??= []).push(...v);
  for (const f of candidates) {
    const cl = codeLine(f); const m = cl.match(/(?:Widget|List<Widget>)\s+(_\w+)\(([^)]*)\)/); if (!m) continue;
    const name = m[1], spread = /^\s+List<Widget>/.test(cl);
    if (!m[2].trim()) { sites.push({ name, site: `${name}()`, spread }); continue; }
    const hit = (pool[name] || []).find((st) => siteResolvable(st, known, defIndex, importNames));
    if (hit) sites.push({ name, site: hit, spread }); else unresolved.push(name);
  }
  // בונה בלי אתר-פתיר ברמת-המסך אך נקרא מתוך בונה/חבר נבחר אחר = **פנימי** (כבר מורכב דרך הקורא שלו: `_table⇒_row`, `_tabView⇒_overview`) — לא מקום-שמור
  const chosenText = frags.filter((f) => f.cls === cls && chosenSet.has(f.id) && f.role !== 'build').map((f) => f.lines.join('\n')).join('\n');
  const internal = unresolved.filter((n) => new RegExp(`(?<![\\w.])${n}\\(`).test(chosenText.replace(new RegExp(`(?:Widget|List<Widget>)\\s+${n}\\(`), '')));
  const reserved = unresolved.filter((n) => !internal.includes(n));
  let pruned = [];
  if (prune && preludeLinesAll.length) { const pr = prunePrelude(preludeLinesAll, sites.map((x) => x.site).join('\n')); preludeLines = pr.lines; pruned = pr.dropped; }
  return { preludeLines, sites, unresolved: reserved, internal, pruned };
}
// שמות-מוצהרים בקובץ-מדף מיובא (top-level): class/enum/typedef/extension · פונקציות · const/final/getter — כולל export-ים של ספריית-ds (export '…')
const _declCache = new Map();
function declaredNames(importPath) {
  if (_declCache.has(importPath)) return _declCache.get(importPath);
  const names = new Set();
  const visit = (p, depth) => {
    if (depth > 3 || !fs.existsSync(p)) return;
    const src = fs.readFileSync(p, 'utf8');
    for (const m of src.matchAll(/^(?:abstract\s+)?(?:class|enum|typedef|extension|mixin)\s+(\w+)/gm)) names.add(m[1]);
    for (const m of src.matchAll(/^[A-Za-z_][\w<>, ?\[\]]*\s+(get\s+)?([a-zA-Z_]\w*)\s*(?:\(|=>|=|;)/gm)) names.add(m[2]);
    for (const m of src.matchAll(/^(?:const|final|var|late)\s+(?:[\w<>, ?\[\]]+\s+)?([a-zA-Z_]\w*)\s*=/gm)) names.add(m[1]);
    for (const m of src.matchAll(/^export\s+'([^']+)'/gm)) visit(path.resolve(path.dirname(p), m[1]), depth + 1);
    for (const m of src.matchAll(/^part\s+'([^']+)'/gm)) visit(path.resolve(path.dirname(p), m[1]), depth + 1);
  };
  visit(path.resolve(DIR, importPath), 0);
  const out = [...names].filter((n) => !/^(void|return|if|else|for|while|import|export|part|static|final|const|var|late)$/.test(n));
  _declCache.set(importPath, out);
  return out;
}

// מצבי-הרכבה (שניהם דטרמיניסטיים):
//   minimal — build() של State לא נזרע (נבנה סינתטי) ⇒ מודול-משנה מינימלי סביב אטומי-היעד (רתמת-הקומפילציה)
//   compose — build() = חיווט-ההרכבה הוא שבר ככל שבר: נזרע אם משתמש באטום-יעד ⇒ המסך-השלם מורכב-מחדש מהקטלוג (רתמת-הזהב: הבדיקות המקוריות)
//   declared=true ⇒ אטומי-היעד כוללים גם את הצהרות-ה-⊕ של המודול עצמו (`// ═══ מטרה = A ⊕ B` — שפת-ההצהרה של הזהב, לא טבלה חיצונית)
// G8c · זריעה לפי פעולות-היסוד של ישות (L49): entityOpsSeed = שם-ישות ⇒ שברים שה-G2-ops שלהם (frag-ops.json, מהמפתחות שהם קוראים) חופפים ≥ minOverlap ל-entityOps(E)
let _FO = null; const fragOps = () => { if (_FO === null) { const p = path.join(GEN, 'frag-ops.json'); _FO = fs.existsSync(p) ? JSON.parse(fs.readFileSync(p, 'utf8')).fragments : {}; } return _FO; };
let _EO = null; const entityOpsOf = async (e) => { if (_EO === null) _EO = (await import('./shape-ops.mjs')).entityOps; return new Set(_EO(e).ops); };
export function select({ module, all = false, particles = [], atoms = [], mode = 'minimal', declared = false, opsSeed = null, minOverlap = 2, prune = false, seedBuildersOnly = false }) {
  const frags = CAT.fragments.filter((f) => f.module === module);
  if (!frags.length) throw new Error('unknown module ' + module);
  const target = new Set([...atoms, ...particles.flatMap(atomsOfParticle), ...(declared ? frags.flatMap((f) => f.declaredAtoms) : [])]);
  // G8e · seedBuildersOnly: זורעים רק בוני-תצוגה (מה שהמשתמש רואה); שברי-דאטה מגיעים דרך סגירת-התלויות בלבד — לא נזרעים ישירות (אחרת כל member שנוגע בתאריך/מספר נבחר)
  const opsSeedIds = opsSeed ? new Set(Object.entries(fragOps()).filter(([id, x]) => x.module === module && x.role !== 'build' && (!seedBuildersOnly || x.role === 'builder') && x.g2.filter((o) => opsSeed.has(o)).length >= minOverlap).map(([id]) => id)) : null;
  const byId = new Map(frags.map((f) => [f.id, f]));
  const defIndex = new Map();                                  // מזהה ⇒ שברים שמגדירים אותו
  for (const f of frags) for (const d of f.defs) { if (!defIndex.has(d)) defIndex.set(d, []); defIndex.get(d).push(f.id); }
  const sel = new Set();
  if (all) frags.forEach((f) => sel.add(f.id));
  else {
    for (const f of frags) if ((f.role === 'member' || f.role === 'builder' || (mode === 'compose' && f.role === 'build')) && (f.atomsUsed.some((a) => target.has(a)) || (opsSeedIds && opsSeedIds.has(f.id)))) sel.add(f.id);
    // אזור-הפתיח (לפני המחלקה הראשונה): הפתיח עצמו + כל שבר שנושא import — גם כשתת-כותרת (// ───) פיצלה את גוש-ה-imports (לקח: fees ⇒ 42 imports אבדו)
    sel.add(frags[0].id);
    for (const f of frags) if (f.cls === '(preamble)' && f.lines.some((l) => /^import '/.test(l))) sel.add(f.id);
    const headOf = new Map(frags.filter((f) => f.role === 'class-head').map((f) => [f.cls, f]));
    const importNames = importNamesOf(frags);
    const isWidgetCls = (c) => headOf.has(c) && /extends (StatefulWidget|StatelessWidget)\b/.test(classLine(headOf.get(c)));
    const stateOf = (c) => { const m = headOf.has(c) && classLine(headOf.get(c)).match(/extends State<(\w+)>/); return m ? m[1] : null; };
    // סגירת-תלויות עד נקודת-שבת: (א) מזהה-בשימוש ⇒ השבר שמגדיר אותו (בלי build של State — נבנה סינתטי) ·
    // (ב) מחלקת-ווידג׳ט שנבחרה ⇒ כל שבריה (constructor/createState/build הם מבנה, לא תוכן) · (ג) State<X> נבחר ⇒ X נבחר
    let grew = true;
    while (grew) {
      grew = false;
      for (const id of [...sel]) {
        const f = byId.get(id);
        for (const used of idsIn(f.lines.join('\n'))) {
          if (f.defs.includes(used)) continue;
          for (const did of defIndex.get(used) || []) { const g = byId.get(did); if (!sel.has(did) && g.role !== 'build') { sel.add(did); grew = true; } }
        }
      }
      const classes = new Set([...sel].map((id) => byId.get(id).cls));
      // (ה) G5a: הפתיח ואתרי-הקריאה שה-build הסינתטי ישחזר צורכים חברים/דאטה ⇒ נכנסים לסגירה כטקסט-פסאודו
      for (const c of classes) {
        if (!stateOf(c) || [...sel].some((id) => byId.get(id).cls === c && byId.get(id).role === 'build')) continue;
        const plan = socketPlan(frags, sel, c, defIndex, importNames, prune);
        const text = plan.preludeLines.join('\n') + '\n' + plan.sites.map((x) => x.site).join('\n');
        for (const used of idsIn(text)) for (const did of defIndex.get(used) || []) { const g = byId.get(did); if (!sel.has(did) && g.role !== 'build') { sel.add(did); grew = true; } }
      }
      for (const c of classes) { const w = stateOf(c); if (w && headOf.has(w) && !sel.has(headOf.get(w).id)) { sel.add(headOf.get(w).id); grew = true; } }
      for (const f of frags) if (classes.has(f.cls) && isWidgetCls(f.cls) && !sel.has(f.id)) { sel.add(f.id); grew = true; }
      // (ג׳) חיבורי-מסגרת של State שנבחר: initState/dispose/didUpdateWidget/didChangeDependencies — Flutter קורא להם, לא הקוד ⇒ מבנה, לא תוכן
      for (const f of frags) if (classes.has(f.cls) && stateOf(f.cls) && !sel.has(f.id) && /^\s+(?:@override\s*\n\s+)?void\s+(initState|dispose|didUpdateWidget|didChangeDependencies)\s*\(/.test(f.lines.join('\n'))) { sel.add(f.id); grew = true; }
      // (ד) build() המקורי של State = חיווט-ההרכבה של הבונים; נבחר רק כשכל מה שהוא צורך מתוך מחלקתו כבר נבחר (אז הוא הרכבה-שלמה, לא שבר-תלוי)
      for (const f of frags) {
        if (f.role !== 'build' || sel.has(f.id) || !classes.has(f.cls) || !stateOf(f.cls)) continue;
        const needs = [...idsIn(f.lines.join('\n'))].filter((u) => !f.defs.includes(u)).flatMap((u) => (defIndex.get(u) || []).filter((did) => byId.get(did).cls === f.cls));
        if (needs.length && needs.every((did) => sel.has(did))) { sel.add(f.id); grew = true; }
      }
    }
    // ראש/סוגר של כל מחלקה שיש לה שבר נבחר
    const classes = new Set([...sel].map((id) => byId.get(id).cls));
    for (const f of frags) if (classes.has(f.cls) && (f.role === 'class-head' || f.role === 'class-close')) sel.add(f.id);
  }
  const chosen = frags.filter((f) => sel.has(f.id));
  return { frags, chosen, sel, target, defIndex, importNames: importNamesOf(frags) };
}
// build סינתטי (G5a): פתיח-הזהב + DsScaffold עם אתרי-הקריאה המקוריים של הבונים הנבחרים (spread לבוני-List<Widget>); לא-פתיר ⇒ מקום-שמור מדווח (חוק-7)
function syntheticBuild({ title, subtitle, plan, rename = (l) => l }) {
  const out = ['  @override', '  Widget build(BuildContext context) {'];
  out.push(...plan.preludeLines.map(rename));
  out.push(`    return DsScaffold(title: '${title}', subtitle: '${subtitle}', icon: '🧬', children: [`);
  for (const x of plan.sites) out.push('      ' + (x.spread ? '...' : '') + rename(x.site) + ',');
  if (plan.internal.length) out.push(`      // בונים-פנימיים (מורכבים דרך הקורא שלהם, לא ברמת-המסך): ${plan.internal.join(', ')}`);
  if (plan.unresolved.length) out.push(`      // מקום-שמור (חוק-7): בונים בלי שקע-פתיר במודול-המשנה — ${plan.unresolved.join(', ')}`);
  out.push('    ]);', '  }');
  return out;
}

export async function assembleByOps({ module, entity, minOverlap = 2, opsOverride = null, prune = false, seedBuildersOnly = false }) {
  const opsSeed = opsOverride || await entityOpsOf(entity);
  const res = assemble({ module, opsSeed, minOverlap, mode: 'minimal', prune, seedBuildersOnly });
  // G8e · בונים-בלבד שלא הניבו אף אתר-קריאה פתיר ⇒ מסך ריק ⇒ נסיגה מוצהרת לזריעת-חברים (מדווח ב-seedMode)
  const sites = Object.values(res.plans).reduce((a, p) => a + p.sites.length, 0);
  if (seedBuildersOnly && sites === 0) { const wide = assemble({ module, opsSeed, minOverlap, mode: 'minimal', prune }); return { ...wide, seedMode: 'members(fallback: builders-only gave 0 sites)' }; }
  return { ...res, seedMode: seedBuildersOnly ? 'builders-only' : 'members' };
}
export function assemble(req) {
  const { module, all = false } = req;
  const { frags, chosen, sel, target, defIndex, importNames } = select(req);
  const plans = {};
  // הרכבה בסדר-המקור; build() סינתטי למחלקות-State בלי build נבחר
  const out = [];
  const stateClasses = new Set(chosen.filter((f) => f.role === 'class-head' && /extends State</.test(classLine(f))).map((f) => f.cls));
  const hasBuild = new Set(chosen.filter((f) => f.role === 'build').map((f) => f.cls));
  const widgetClasses = new Set(chosen.filter((f) => f.role === 'class-head' && /extends StatefulWidget|extends StatelessWidget/.test(classLine(f))).map((f) => f.cls));
  for (const f of chosen) {
    if (f.role === 'class-close' && stateClasses.has(f.cls) && !hasBuild.has(f.cls)) {
      const nm = f.cls.replace(/^_|State$/g, '');
      const plan = plans[f.cls] = socketPlan(frags, sel, f.cls, defIndex, importNames, !!req.prune);
      out.push(...syntheticBuild({ title: nm, subtitle: `${nm} · מודול-משנה מחולל · ${plan.sites.length} בונים מחווטים-לשקעי-הזהב`, plan }));
    }
    if (f.role === 'class-close' && widgetClasses.has(f.cls) && !hasBuild.has(f.cls) && !stateClasses.has(f.cls)) {
      // StatefulWidget בלי createState (השבר שלו לא נבחר) — לא ייתכן בפועל כי createState נמצא בראש-המחלקה; שומר-מבנה בלבד
    }
    out.push(...f.lines);
  }
  let code = out.join('\n');
  // imports: **כל** ה-imports של המקור נשמרים (import-לא-בשימוש = info לאנלייזר, לא error ⇒ בטוח-קומפילציה);
  // גיזום-imports הוא קוסמטיקה ונעשה רק לפי שמות-מוצהרים בבייטים של הקובץ-המיובא (declaredNames), לעולם לא לפי ניחוש-בסיס-קובץ.
  if (!all && process.env.RENDER_PRUNE_IMPORTS === '1') {
    const used = idsIn(code.replace(/^import .*$/gm, ''));
    code = code.split('\n').filter((l) => {
      const m = l.match(/^import '([^']+)'(?:\s+as\s+(\w+))?/);
      if (!m) return true;
      if (/^package:flutter|^dart:core/.test(m[1])) return true;
      if (m[2]) return used.has(m[2]);
      if (/^dart:math/.test(m[1])) return used.has('math');
      const names = declaredNames(m[1]);
      return names.length === 0 || names.some((n) => used.has(n));
    }).join('\n');
  }
  return { code, fragments: chosen.length, of: frags.length, target: [...target], plans, ids: chosen.map((f) => f.id), unselected: frags.filter((f) => !sel.has(f.id)).map((f) => ({ id: f.id, cls: f.cls, role: f.role, first: (f.lines.find((l) => l.trim()) || '').trim().slice(0, 90), atomsUsed: f.atomsUsed, lines: f.lines.length })) };
}


// ── G4b · הרכבה חוצת-מודולים: שברים מ-2+ מודולי-זהב ⇒ מודול חדש אחד (מסך סינתטי) — דטרמיניסטי, אפס-LLM
//   imports: איחוד (dedupe לפי הצהרה) · הצהרות-עליונות: dedupe כשהקוד זהה, התנגשות-קוד = שגיאה מדווחת ·
//   מחלקות-דאטה (לא ווידג׳ט/State): כמו במודול-יחיד · חברי-State של כל המודולים מורמים ל-State סינתטי אחד:
//   שם שמוגדר ב-2+ מודולים עם קוד זהה ⇒ עותק אחד משותף; קוד שונה ⇒ שינוי-שם פר-מודול (`_q` ⇒ `_q_att`) בגבולות-מילה ·
//   חיבורי-מסגרת (initState…) ו-build מקוריים לא מורמים (מדווחים 'dropped') · build סינתטי = DsScaffold מבוני-אפס-ארגומנטים.
export const TAG = { 'schoolos.dart': 'inv', schoolos_students: 'stu', schoolos_attendance: 'att', schoolos_courses: 'crs', schoolos_teachers: 'tch', schoolos_rooms: 'rm', schoolos_fees: 'fee', schoolos_parents: 'par', schoolos_dashboard: 'dash' };
const tagOf = (m) => TAG[m] || TAG[m.replace(/\.dart$/, '')] || m.replace(/\W/g, '');
const normCode = (lines) => lines.map((l) => l.replace(/\s*\/\/.*$/, '').trim()).filter(Boolean).join('\n');
const isLifecycle = (f) => /^\s+(?:@override\s*\n\s+)?void\s+(initState|dispose|didUpdateWidget|didChangeDependencies)\s*\(/.test(f.lines.join('\n'));
export function assembleMulti({ modules, particles = [], atoms = [], name = 'Gen', declared = false }) {
  if (!modules || modules.length < 2) throw new Error('assembleMulti: נדרשים 2+ מודולים');
  const parts = modules.map((m) => ({ module: m, tag: tagOf(m), ...select({ module: m, particles: particles.filter((id) => (TAG[m.replace(/\.dart$/, '')] ? id.startsWith({ stu: 'stu.', att: 'att.', crs: 'crs.', tch: 'tch.', rm: 'rm.', fee: 'fee.', par: 'par.', dash: 'dash.' }[tagOf(m)] || '∅') : !id.includes('.'))), atoms, mode: 'minimal', declared }) }));
  const report = { modules: modules.length, imports: 0, topDedup: 0, sharedMembers: [], renamed: [], dropped: [], conflicts: [] };
  const out = [];
  out.push(`// 🧬 ${name} — הרכבה חוצת-מודולים (GENMAX·G4b · הכרעה-24): ${modules.join(' ⊕ ')} · מחולל דטרמיניסטי: render-module.mjs --modules ${modules.join(',')}`);
  out.push('//   כל שבר כאן חצוב מהזהב (golden-fragments.json) — לא נכתב; חברי-State שהתנגשו קיבלו סיומת-מודול; אין Date.now במנוע.');
  // imports — איחוד
  const seenImp = new Set();
  for (const p of parts) for (const f of p.chosen) if (f.cls === '(preamble)' || f.cls === '(top)') for (const l of f.lines) {
    const m = l.match(/^(import '([^']+)'(?:\s+as\s+\w+)?;)/); if (!m) continue;
    if (/^schoolos/.test(m[2])) continue;                                 // הרכזת מייבאת את המודולים עצמם — לא בתוך הרכבה
    if (seenImp.has(m[1])) continue; seenImp.add(m[1]); out.push(l);
  }
  report.imports = seenImp.size;
  // הצהרות-עליונות (לא-import, לא-הערה, לא main)
  const topSeen = new Map();
  for (const p of parts) for (const f of p.chosen) if (f.cls === '(preamble)' || f.cls === '(top)') {
    const code = f.lines.filter((l) => !/^import '/.test(l) && !/^\s*\/\//.test(l) && l.trim() && !/^void main\(/.test(l));
    for (const l of code) { const k = l.replace(/\s*\/\/.*$/, '').trim(); if (topSeen.has(k)) { report.topDedup++; continue; } topSeen.set(k, p.tag); out.push(l); }
  }
  // מחלקות-דאטה (לא ווידג׳ט/State) — כמו במודול-יחיד
  for (const p of parts) {
    const heads = new Map(p.chosen.filter((f) => f.role === 'class-head').map((f) => [f.cls, classLine(f)]));
    const dataCls = new Set([...heads].filter(([c, l]) => !/extends (StatefulWidget|StatelessWidget|State<)/.test(l)).map(([c]) => c));
    for (const f of p.chosen) if (dataCls.has(f.cls)) out.push(...f.lines);
  }
  // הרמת חברי-State ⇒ State סינתטי אחד
  const hoisted = parts.map((p) => {
    const heads = new Map(p.chosen.filter((f) => f.role === 'class-head').map((f) => [f.cls, classLine(f)]));
    const stateCls = new Set([...heads].filter(([c, l]) => /extends State</.test(l)).map(([c]) => c));
    const members = p.chosen.filter((f) => stateCls.has(f.cls) && (f.role === 'member' || f.role === 'builder'));
    const keep = [];
    for (const f of members) {
      if (isLifecycle(f)) { report.dropped.push(`${p.tag}:${f.id} (חיבור-מסגרת)`); continue; }
      if (/\bwidget\./.test(f.lines.join('\n'))) { report.dropped.push(`${p.tag}:${f.id} (widget.*)`); continue; }
      keep.push(f);
    }
    return { ...p, members: keep };
  });
  const defOwners = new Map();                                            // שם ⇒ [{tag, code, frag}]
  for (const p of hoisted) for (const f of p.members) for (const d of f.defs) { if (!defOwners.has(d)) defOwners.set(d, []); defOwners.get(d).push({ tag: p.tag, code: normCode(f.lines), id: f.id }); }
  const renameFor = new Map(hoisted.map((p) => [p.tag, new Map()]));
  const skipFrag = new Set();
  for (const [d, owners] of defOwners) {
    const tags = [...new Set(owners.map((o) => o.tag))]; if (tags.length < 2) continue;
    const codes = new Set(owners.map((o) => o.code));
    if (codes.size === 1) { report.sharedMembers.push(d); for (const o of owners.slice(1)) skipFrag.add(o.id); continue; }   // זהה ⇒ עותק אחד
    for (const t of tags) { renameFor.get(t).set(d, `${d}_${t}`); }
    report.renamed.push(`${d}⇒${tags.map((t) => `${d}_${t}`).join('/')}`);
  }
  const N = name.replace(/[^A-Za-z0-9]/g, '');
  out.push('', `class ${N}Screen extends StatefulWidget {`, `  const ${N}Screen({super.key});`, '  @override', `  State<${N}Screen> createState() => _${N}ScreenState();`, '}', '', `class _${N}ScreenState extends State<${N}Screen> {`);
  // G5a: תוכנית-שקעים פר-מודול (פתיח + אתרי-קריאה); מקומיים-של-פתיח שמתנגשים בין מודולים ⇒ סיומת-מודול
  const plansM = hoisted.map((p) => { const heads = new Map(p.chosen.filter((f) => f.role === 'class-head').map((f) => [f.cls, classLine(f)])); const sc = [...heads].filter(([c, l]) => /extends State</.test(l)).map(([c]) => c); return { tag: p.tag, plans: sc.map((c) => socketPlan(p.frags, p.sel, c, p.defIndex, p.importNames)) }; });
  const localOwners = new Map(); for (const pm of plansM) for (const pl of pm.plans) for (const v of preludeLocals(pl.preludeLines)) (localOwners.has(v) ? localOwners.get(v) : localOwners.set(v, new Set()).get(v)).add(pm.tag);
  for (const [v, tags] of localOwners) if (tags.size > 1) for (const t of tags) renameFor.get(t).set(v, `${v}_${t}`);
  // גבולות-מילה: לא אחרי אות/ספרה/נקודה (‏`EdgeInsets.all(` אינו המקומי `all`; ‏`_X._row` אינו החבר `_row`) ולא לפני אות/ספרה
  // (‏`$all` באינטרפולציה הוא המשתנה עצמו ⇒ `$` אינו גבול-שלילי; רק אות/ספרה/נקודה)
  // (‏`...all` (spread) הוא המשתנה ⇒ נשלל רק `.` של גישה-לחבר: אות/`)`/`]` ואחריהם `.`)
  const applyFor = (tag) => { const ren = renameFor.get(tag); return (l) => { for (const [a, b] of ren) l = l.replace(new RegExp(`(?<![\\w])(?<![\\w)\\]]\\.)${a.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}(?![\\w])`, 'g'), b); return l; }; };
  let sitesN = 0;
  for (const p of hoisted) {
    const apply = applyFor(p.tag);
    out.push(`  // ── ${p.tag} · ${p.module} ──`);
    for (const f of p.members) { if (skipFrag.has(f.id)) continue; out.push(...f.lines.map(apply)); }
  }
  out.push('  @override', '  Widget build(BuildContext context) {');
  for (const pm of plansM) { const apply = applyFor(pm.tag); for (const pl of pm.plans) { out.push(`    // ── פתיח-הזהב · ${pm.tag} ──`); out.push(...pl.preludeLines.map(apply)); } }
  out.push(`    return DsScaffold(title: '${N}', subtitle: '${modules.map(tagOf).join(' ⊕ ')} · הרכבה חוצת-מודולים מחוללת', icon: '🧬', children: [`);
  for (const pm of plansM) { const apply = applyFor(pm.tag); for (const pl of pm.plans) { for (const x of pl.sites) { out.push('      ' + (x.spread ? '...' : '') + apply(x.site) + ','); sitesN++; } if (pl.unresolved.length) { out.push(`      // מקום-שמור (חוק-7) · ${pm.tag}: ${pl.unresolved.join(', ')}`); report.dropped.push(...pl.unresolved.map((u) => `${pm.tag}:${u} (שקע-לא-פתיר)`)); } } }
  out.push('    ]);', '  }', '}');
  return { code: out.join('\n') + '\n', report, builders: sitesN };
}

// ── CLI / gate — רץ רק כשהקובץ הוא נקודת-הכניסה (import מ-golden-harness לא מפעיל CLI — לקח: --module של הרתמה כתב gen_teachers.dart בטעות)
const arg = (k) => { const i = process.argv.indexOf(k); return i > -1 ? process.argv[i + 1] : null; };
const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain && process.argv.includes('--gate')) {
  const modules = [...new Set(CAT.fragments.map((f) => f.module))];
  const errs = []; let subsets = 0;
  for (const m of modules) {
    const full = assemble({ module: m, all: true }).code;
    const src = fs.readFileSync(path.join(DIR, m), 'utf8');
    if (full !== src) errs.push(`${m}: --all ≠ מקור`);
    const ids = Object.keys(PARTICLES).filter((id) => (m === 'schoolos.dart' ? !id.includes('.') : id.startsWith({ schoolos_students: 'stu.', schoolos_attendance: 'att.', schoolos_courses: 'crs.', schoolos_teachers: 'tch.', schoolos_rooms: 'rm.', schoolos_fees: 'fee.', schoolos_parents: 'par.', schoolos_dashboard: 'dash.' }[m.replace(/\.dart$/, '')] || '∅')));
    if (ids.length) {
      const sub = assemble({ module: m, particles: ids }), outF = path.join(DIR, 'gen_' + m.replace(/^schoolos_?/, '').replace(/\.dart$/, '').replace(/^$/, 'inventory') + '_subset.dart');
      // השער לא כותב (L14: פסק-דין על עץ נח) — משווה לפלט המחויב; `--write` מחדש את הפלט
      if (process.argv.includes('--write')) fs.writeFileSync(outF, sub.code);
      else if (!fs.existsSync(outF) || fs.readFileSync(outF, 'utf8') !== sub.code) errs.push(`${path.basename(outF)} ≠ הרכבה-טרייה (הרץ --gate --write)`);
      subsets++;
    }
  }
  // G4b — הרכבות חוצות-מודולים מחויבות (דטרמיניזם: הפלט המחויב ≡ הרכבה-טרייה); הקומפילציה במראה-buildsmart
  const COMPOSITES = [{ modules: ['schoolos_attendance.dart', 'schoolos_fees.dart'], name: 'AttFee' }, { modules: ['schoolos_students.dart', 'schoolos_attendance.dart', 'schoolos_fees.dart'], name: 'Student360', declared: true }];
  let composites = 0;
  for (const c of COMPOSITES) {
    const res = assembleMulti({ ...c, particles: PARTICLE_IDS });
    const outF = path.join(DIR, `gen_composite_${c.modules.map(tagOf).join('_')}.dart`);
    if (process.argv.includes('--write')) fs.writeFileSync(outF, res.code);
    else if (!fs.existsSync(outF) || fs.readFileSync(outF, 'utf8') !== res.code) errs.push(`${path.basename(outF)} ≠ הרכבה-חוצת-מודולים-טרייה (הרץ --gate --write)`);
    if (res.report.conflicts.length) errs.push(`${c.name}: התנגשויות ${res.report.conflicts.join(',')}`);
    composites++;
  }
  if (errs.length) { console.log('🔴 rendermodule: ' + errs.join(' · ')); process.exit(1); }
  console.log(`✓ rendermodule: --all ≡ מקור ${modules.length}/${modules.length} · ${subsets} מודולי-משנה (gen_*_subset.dart) + ${composites} הרכבות-חוצות-מודולים (gen_composite_*.dart) ≡ הרכבה-דטרמיניסטית · הקומפילציה בשער-buildsmart`); process.exit(0);
}
const opsEntity = isMain ? arg('--entity-ops') : null;
if (opsEntity && arg('--module')) {
  const res = await assembleByOps({ module: arg('--module'), entity: opsEntity, minOverlap: +(arg('--min-overlap') || 2), prune: process.argv.includes('--prune'), seedBuildersOnly: process.argv.includes('--builders-only') });
  const out = arg('--out') || path.join(DIR, `gen_opsseed_${opsEntity.toLowerCase()}_from_${TAG[arg('--module').replace(/\.dart$/, '')] || 'x'}.dart`);
  fs.writeFileSync(out, res.code);
  console.log(`✓ זריעה-לפי-ops: ${opsEntity} @ ${arg('--module')} ⇒ ${path.basename(out)} · שברים ${res.fragments}/${res.of} · ${res.code.split('\n').length} שורות · בונים מחווטים ${Object.values(res.plans).reduce((a, p) => a + p.sites.length, 0)} · מצב-זריעה ${res.seedMode}`);
}
const modulesArg = isMain ? arg('--modules') : null;
if (modulesArg) {
  const modules = modulesArg.split(',').filter(Boolean), name = arg('--name') || 'Composite';
  const res = assembleMulti({ modules, name, particles: (arg('--particles') || (modules.every((m) => TAG[m.replace(/\.dart$/, '')] || TAG[m]) ? PARTICLE_IDS.join(',') : '')).split(',').filter(Boolean), atoms: (arg('--atoms') || '').split(',').filter(Boolean), declared: process.argv.includes('--declared') });
  const out = arg('--out') || path.join(DIR, `gen_composite_${modules.map(tagOf).join('_')}.dart`);
  fs.writeFileSync(out, res.code);
  console.log(`✓ ${modules.join(' ⊕ ')} ⇒ ${out} · imports ${res.report.imports} · בונים ${res.builders} · משותפים ${res.report.sharedMembers.length} · שונו-שם ${res.report.renamed.length} · הושמטו ${res.report.dropped.length} · ${res.code.split('\n').length} שורות`);
  if (res.report.renamed.length) console.log('   renamed: ' + res.report.renamed.join(' · '));
  if (res.report.dropped.length) console.log('   dropped: ' + res.report.dropped.join(' · '));
}
const module = isMain && !opsEntity ? arg('--module') : null;   // --entity-ops מטפל ב---module בעצמו
if (module) {
  const res = assemble({ module, all: process.argv.includes('--all'), particles: (arg('--particles') || '').split(',').filter(Boolean), atoms: (arg('--atoms') || '').split(',').filter(Boolean) });
  const out = arg('--out') || path.join(DIR, 'gen_' + module.replace(/^schoolos_?/, '').replace(/\.dart$/, '').replace(/^$/, 'inventory') + '.dart');
  fs.writeFileSync(out, res.code);
  console.log(`✓ ${module} ⇒ ${out} · שברים ${res.fragments}/${res.of} · אטומי-יעד ${res.target.length} · ${res.code.split('\n').length} שורות`);
}

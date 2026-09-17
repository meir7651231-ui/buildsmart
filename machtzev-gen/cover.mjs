#!/usr/bin/env node
// 🧩 cover — כיסוי-שקעים = הרכבה (GENMAX · G3 · PLAN-GENERATOR-MAX §2 ציר-3 · §20-ב "אין-יחיד ⇒ משלב כמה").
//   בקשה: { op, need:[שקעים-נדרשים], goal:'משפט-מטרה' } ⇒ אטומים (1 או כמה) שמכסים את השקעים:
//     · תצוגה: מועמדים = אטומי ops-map.json באותו op (+משפחות-שכנות) · ניקוד = כיסוי-שקעים − קנס-מילויים
//       + דירוג-מטרה מ-match.retrieve (נלמד מ-254 מסכים, אפס-מילון) · אין-יחיד ⇒ חמדני עד כיסוי-מלא.
//     · לוגיקה: מועמדים = משפחת-ה-op (predicate/measure/format/collection/summary…) ∩ match.retrieveLogic(goal)
//       (שם-הפונקציה לעולם אינו ראיה; המטרה-בעברית של האטום כן — הכרעה 23-ב).
//   פער-כיסוי ⇒ מדווח כן (§20-ג), לא מזויף.
//   --gate: שחזור טבלת-ATOM הידנית של compose-engine (op⇒אטום) — כמה מהבחירות-ביד המנוע מגיע אליהן לבד; רק-עולה.
import fs from 'node:fs';
import path from 'node:path';
import { retrieve, retrieveLogic } from './match.mjs';
import * as R from '../root.mjs';

const ROOT = R.ROOT;
const GEN = path.join(ROOT, 'machtzev/generator');
const MAP = JSON.parse(fs.readFileSync(path.join(GEN, 'ops-map.json'), 'utf8'));
const byId = new Map(MAP.map((a) => [a.id, a]));
// מזייפים מוצהרים (FAKERS של compose-engine = SSOT לשער no-fakers) — לעולם לא נבחרים (§20-ג), גם אם יש להם שקע.
const FAKERS = (() => { const src = fs.readFileSync(path.join(ROOT, 'machtzev/compose-engine.mjs'), 'utf8'); const m = src.match(/const FAKERS = new Set\(\[([^\]]*)\]\)/); const raw = m ? [...m[1].matchAll(/'([^']+)'/g)].map((x) => x[1]) : []; const pascal = (s) => s.replace(/(^|_)([a-z])/g, (_, __, c) => c.toUpperCase()); return new Set(raw.flatMap((s) => [s, pascal(s)])); })();

// משפחות-op שכנות (צורה): בקשה ל-op מקבלת גם מועמדים ממשפחה-שכנה כשאין כיסוי.
const NEAR = { stat: ['trend', 'ratio', 'fact'], ratio: ['stat', 'bars'], fact: ['stat', 'text'], action: ['field', 'filter'], identity: ['group', 'expand'], group: ['panel', 'identity'], panel: ['group'], alert: ['empty', 'fact'], empty: ['alert', 'fact'], field: ['search', 'switch'], search: ['field'], filter: ['switch', 'action'], table: ['board', 'bars'], timeline: ['identity', 'expand'] };
const LOGIC_OPS = new Set(['predicate', 'measure', 'aggregate', 'format', 'collection', 'lines', 'summary', 'selection', 'temporal', 'effect', 'transform']);

// דרגת-מדף (מקור-מבני, לא דומייני): ds/ = מערכת-העיצוב המאוצרת · premium/ = מדף-הרכבה · שורש · auto/ ומסכים-מפורקים = חומר-גלם.
const tier = (file) => /^dart-ui-bs\/ds\//.test(file) ? 2 : /^dart-ui-bs\/premium\//.test(file) ? 1.5 : /^dart-ui-bs\/(auto|screens__)/.test(file) ? 0 : 1;
function scoreDisplay(a, need, goalRank) {
  const prov = new Set(a.sockets);
  const hit = need.filter((n) => prov.has(n)).length;
  const extra = a.sockets.filter((s) => !need.includes(s)).length;
  const gr = goalRank.get(a.id) ?? goalRank.get(a.id.split('@')[0]);
  return hit * 10 - extra * 1.5 + (gr != null ? Math.max(0, 6 - gr) : 0) + tier(a.file) - (a.unindexed ? 0.1 : 0);
}

export function cover({ op, need = [], goal = '' }) {
  if (LOGIC_OPS.has(op)) return coverLogic({ op, need, goal });
  const goalRank = new Map();
  if (goal) retrieve(goal, 12).forEach((r, i) => goalRank.set(r.cls, i));
  const pool = (ops) => MAP.filter((a) => a.layer === 'display' && ops.includes(a.op) && !FAKERS.has(a.id.split('@')[0]));
  let cands = pool([op]);
  if (!cands.length) cands = pool(NEAR[op] || []);
  const ranked = cands.map((a) => ({ a, s: scoreDisplay(a, need, goalRank) })).sort((x, y) => y.s - x.s || x.a.sockets.length - y.a.sockets.length || x.a.id.localeCompare(y.a.id));
  const chosen = [], covered = new Set();
  for (const { a } of ranked) {
    const adds = need.filter((n) => !covered.has(n) && a.sockets.includes(n));
    if (!chosen.length || adds.length) { chosen.push(a.id); adds.forEach((n) => covered.add(n)); a.sockets.forEach((s) => need.includes(s) && covered.add(s)); }
    if (need.every((n) => covered.has(n))) break;
    if (chosen.length >= 4) break;                                   // עומק-הרכבה מקסימלי (כמו synth)
  }
  const missing = need.filter((n) => !covered.has(n));
  // ── מקסימום-חיווט (אפס-אובדן): כל החלקיקים תקפי-הצורה — כל אטום שמכסה ≥1 שקע-נדרש (או כולם כשאין need) —
  //   כווריאנטים-עם-ברירת-מחדל (default=top-1). חיווט-טהור ⇒ שמירת-כולם בחינם; הבורר בוחר בסוף.
  const variants = ranked.filter(({ a }) => !need.length || need.some((n) => a.sockets.includes(n))).map((x) => x.a.id);
  return { op, need, atoms: chosen, alts: ranked.slice(0, 3).map((x) => x.a.id), variants, default: ranked[0]?.a.id || null, composed: chosen.length > 1, missing, ok: chosen.length > 0 && missing.length === 0 };
}

// ── אינדקס-מטרה למנועי-לוגיקה: העברית מכותרת-הקובץ של האטום עצמו (הצהרת-האטום, לא מילון) + atlas.he אם קיים.
//   IDF על גזמים (match.stem דרך heToks) ⇒ ניקוד-מטרה דטרמיניסטי. מכסה גם מנועים שאינם ב-atlas (למשל buildSlots).
import { stem } from './match.mjs';
const heToks = (s) => [...String(s || '').matchAll(/[֐-׿]{2,}/g)].map((m) => stem(m[0])).filter((t) => t.length > 1);
const LOGIC = MAP.filter((a) => a.layer === 'logic').map((a) => {
  let head = '';
  try { head = fs.readFileSync(path.join(ROOT, 'new', a.file), 'utf8').split('\n').slice(0, 10).filter((l) => /^\s*\/\//.test(l)).join(' '); } catch { /* חסר ⇒ ריק */ }
  return { ...a, st: [...new Set(heToks(head))] };
});
const LDF = new Map(); for (const a of LOGIC) for (const t of a.st) LDF.set(t, (LDF.get(t) || 0) + 1);
const STOP = new Set([...LDF].filter(([, n]) => n > LOGIC.length * 0.08).map(([t]) => t));   // מילים-שכיחות (>8% מהמנועים) = רעש (אטום/מקור/חוק…)
const lidf = (t) => STOP.has(t) ? 0 : Math.log((LOGIC.length + 1) / ((LDF.get(t) || 0) + 1)) + 1;

// ── רול-לפי-טיפוס-פלט (lens-B: הממד שהדירוג התעלם ממנו): משפחת-ה-op מכתיבה טיפוס-ret צפוי.
//   אטום ש-ret שלו סותר את התפקיד (collection שמחזיר bool · measure שמחזיר String) — מודח. זה עקביות-טיפוס, לא הקלדה.
const OP_RET = {
  collection: /(List|Iterable|Map|Set|Rows|Lines|\[\])/i, selection: /(List|Iterable|Map|Set)/i, lines: /(List|String|\[\])/i,
  predicate: /\bbool\b/i, measure: /\b(int|double|num)\b/i, aggregate: /\b(int|double|num)\b/i,
  format: /\bString\b/i, summary: /(String|Record|Map|\(|Summary|Stat)/i,
};
// רול-לפי-ret מותנה-מטרה: קנס-סתירה תמיד (מדיח type-שגוי); בונוס-התאמה **רק** כשהאטום גם רלוונטי-למטרה
//   ⇒ type-נכון-אך-מטרה-לא-רלוונטי לא מזנק מעל הבחירה-הנכונה-למטרה, אבל type-נכון+מטרה-רלוונטי כן עולה.
const retMatch = (op, ret) => { const re = OP_RET[op]; return re ? re.test(ret || '') : null; };
export function coverLogic({ op, need = [], goal = '' }) {
  const q = [...new Set(heToks(goal))];
  const flagsNeed = need.filter((n) => ['temporal', 'ho', 'listIn'].includes(n));
  const ranked = LOGIC.map((a) => {
    let g = 0; for (const t of q) if (a.st.includes(t)) g += lidf(t);   // אות-המטרה (לפני נרמול)
    let s = g / Math.sqrt(Math.max(4, a.st.length));                   // נרמול-אורך: כותרת-מילולית לא זוכה בגלל אורכה
    if (a.op === op) s += 0.4;                                       // משפחת-הצורה = בונוס, לא סינון-קשיח (הסיווג גס: ret dynamic ⇒ transform)
    const rm = retMatch(op, a.ret);                                 // רול-לפי-ret (lens-B): הממד שהדירוג התעלם ממנו
    if (rm === true) s += (g > 0 ? 0.5 : 0.05);                       // התאמת-תפקיד: בונוס-מלא רק אם רלוונטי-למטרה, אחרת זעיר
    else if (rm === false) s -= 0.45;                               // סתירת-תפקיד (collection⇒bool · measure⇒String): הדחה תמיד
    if (flagsNeed.every((f) => (a.flags || []).includes(f))) s += 0.5;
    return { a, s: +s.toFixed(2) };
  }).filter((x) => x.s > 0.6).sort((x, y) => y.s - x.s || x.a.id.localeCompare(y.a.id));
  // atlas.he (אם יש) כעד-שני: מעלה מועמד שגם match.retrieveLogic מדרג
  const atl = goal ? new Map(retrieveLogic(goal, 12, false).map((r, i) => [r.name, i])) : new Map();
  ranked.forEach((x) => { if (atl.has(x.a.id)) x.s += Math.max(0, 1.2 - atl.get(x.a.id) * 0.2); });
  ranked.sort((x, y) => y.s - x.s || x.a.id.localeCompare(y.a.id));
  const chosen = ranked.slice(0, 1).map((x) => x.a.id);
  return { op, need, atoms: chosen, alts: ranked.slice(0, 3).map((x) => x.a.id), composed: false, missing: chosen.length ? [] : ['אין מנוע שמטרתו תואמת'], ok: chosen.length > 0 };
}

// ── התֶּפֶר (seam · PLAN §2 ציר-3): בחירת-cover ⇒ מניפסט תקין ל-gen-screen ⇒ קוד-Dart מתקמפל.
//   קורא את חתימת-הבנאי האמיתית של כל אטום-שנבחר (positional+required+types — בדיוק כמו gen-screen),
//   וממלא כל prop-חובה בשקע-מוקלד-נכון: פונקציה⇒@: · Color/מידה⇒#: · אחר⇒?:type. אפס-המצאה — הכל מהחתימה.
const SHELF_ROOT = path.join(ROOT, 'new');
function ctorSig(atomId) {
  const a = byId.get(atomId) || byId.get(atomId.split('@')[0]); if (!a) return null;
  let src; try { src = fs.readFileSync(path.join(SHELF_ROOT, a.file), 'utf8'); } catch { return null; }
  const cm = src.match(/class\s+([A-Za-z0-9]+)\s+extends\s+(?:StatelessWidget|StatefulWidget)/); if (!cm) return null;
  const types = new Map();  // תומך בהצהרה רב-שמית: `final String a, b, c;` ⇒ כל שם⇒טיפוס
  for (const mm of src.matchAll(/final\s+((?:\([^)]*\)\s*(?:Function\([^)]*\))?\??|[A-Za-z_][\w<>,?]*(?:\s+Function\([^)]*\))?\??))\s+([a-zA-Z0-9_]+(?:\s*,\s*[a-zA-Z0-9_]+)*)\s*;/g)) {
    const type = mm[1].trim(); for (const nm of mm[2].split(',').map((s) => s.trim())) types.set(nm, type);
  }
  const codeOnly = src.split('\n').filter((l) => !l.trim().startsWith('//')).join('\n');
  const ctm = codeOnly.match(new RegExp('(?:const\\s+)?' + cm[1] + '\\s*\\(([^)]*)\\)', 's'));
  let positional = [], requiredNamed = [];
  if (ctm) { const [posPart, namedPart = ''] = ctm[1].split('{'); positional = [...posPart.matchAll(/this\.(\w+)/g)].map((x) => x[1]); requiredNamed = [...namedPart.matchAll(/required\s+this\.(\w+)/g)].map((x) => x[1]); }
  return { className: cm[1], types, positional, requiredNamed };
}
const isFnType = (t) => /Function|VoidCallback|Callback$/.test(t || '');
const isTokenType = (t, n) => t === 'Color' || (/^double$/.test(t) && /radius|size|width|height|space|pill|gap|elev/i.test(n));
function slotFor(name, type) {
  const t = (type || 'String').replace(/\?$/, '');
  if (isFnType(t)) return `@:${name}|${t}`;              // callback — הלוח מזרים
  if (isTokenType(t, name)) return `#:${name}`;          // טוקן-עיצוב — מקטלוג-הטוקנים
  return `?:${t}`;                                        // חור-נתון-ריצה מוקלד — הלוח מזרים
}
// סקציה מכל אטום-שהוא (ברירת-מחדל או וריאנט): קורא חתימה, ממלא כל prop-חובה בשקע-מוקלד. null אם אין-חתימה (לוגי/לא-מדף).
export function sectionFor(atomId, title) {
  const sig = ctorSig(atomId); if (!sig) return null;
  const reqProps = [...new Set([...sig.positional, ...sig.requiredNamed])].filter((p) => p !== 'key');
  const props = {}; for (const p of reqProps) props[p] = slotFor(p, sig.types.get(p));
  const section = { atom: sig.className, props }; if (title) section.title = title;
  return section;
}
// requests = [{op, need, goal, title?}] · screen · content · max=true ⇒ כל שקע נושא variants (כל תקפי-הצורה, ברירת-מחדל+כולם).
export function coverManifest({ screen, content = [], requests, max = false }) {
  const sections = [], picks = [];
  for (const req of requests) {
    const c = cover(req);
    if (!c.atoms.length) { picks.push({ req: req.op, atom: null, missing: c.missing }); continue; }
    for (const atomId of c.atoms) {
      const section = sectionFor(atomId, req.title);
      if (!section) { picks.push({ req: req.op, atom: atomId, skip: 'אין-חתימה (לוגי/לא-מדף)' }); continue; }
      if (max) {  // מקסימום-חיווט: כל וריאנט תקף-צורה זמין; ברירת-המחדל = top-1 (אפס-אובדן — הבורר בוחר)
        section.default = section.atom;
        section.variants = (c.variants || [c.atoms[0]]).map((v) => v.split('@')[0]);
      }
      sections.push(section); picks.push({ req: req.op, atom: section.atom, variants: max ? section.variants.length : undefined });
    }
  }
  return { screen, content, sections, _picks: picks };
}
// --emit <screen>: הרכבה חיה של מניפסט-הדגמה ⇒ קורא ל-gen-screen ⇒ פולט .g.dart מתקמפל.
if (process.argv.includes('--emit')) {
  const screen = process.argv[process.argv.indexOf('--emit') + 1] || 'demo_cover';
  // בקשות-הדגמה: יכולות אוניברסליות (מדד · פעולה · טבלה · התראה) — כל אחת נבחרת ע"י cover מהצורה
  const requests = [
    { op: 'stat', need: ['value', 'label'], goal: 'מדד מספרי גדול עם תווית' },
    { op: 'action', need: ['label', 'onTap'], goal: 'כפתור פעולה ראשי' },
    { op: 'alert', need: ['title'], goal: 'התראת-מצב' },
  ];
  const man = coverManifest({ screen, requests, max: process.argv.includes('--max') });
  const MANP = path.join(GEN, screen + '.manifest.json');
  fs.writeFileSync(MANP, JSON.stringify({ screen: man.screen, content: man.content, sections: man.sections }, null, 1));
  console.log('picks:', JSON.stringify(man._picks));
  console.log('manifest →', path.relative(ROOT, MANP));
  process.exit(0);
}
// --provemax <op> <need,need> "<goal>": מוכיח אפס-אובדן — כל וריאנט תקף-צורה מתקמפל דרך gen-screen (בחר-כל-אחד).
if (process.argv.includes('--provemax')) {
  const i = process.argv.indexOf('--provemax');
  const op = process.argv[i + 1], need = (process.argv[i + 2] || '').split(',').filter(Boolean), goal = process.argv[i + 3] || '';
  const c = cover({ op, need, goal });
  const vars = (c.variants || []).map((v) => v.split('@')[0]);
  console.log(`op=${op} · ${vars.length} וריאנטים תקפי-צורה · ברירת-מחדל=${(c.default || '').split('@')[0]}`);
  const { execSync } = await import('node:child_process');
  const OUT = path.join(ROOT, 'machtzev/generator/.provemax-out');
  let pass = 0;
  for (const v of vars) {
    const sec = sectionFor(v); if (!sec) { console.log(`  ${v}  ⊘ אין-חתימה`); continue; }
    const MANP = path.join(GEN, '.provemax.manifest.json');
    fs.writeFileSync(MANP, JSON.stringify({ screen: 'pm_' + v.toLowerCase(), sections: [sec] }));
    try { execSync(`node ${path.join(ROOT, 'machtzev/assemble/gen-screen.mjs')} ${MANP} ${OUT}`, { stdio: 'pipe' }); console.log(`  ${v}  ✓ מתקמפל`); pass++; }
    catch (e) { console.log(`  ${v}  ✗ ${String(e.stderr || e).split('\n')[0].slice(0, 80)}`); }
    fs.rmSync(MANP, { force: true });
  }
  fs.rmSync(OUT, { recursive: true, force: true });
  console.log(`\nמקסימום-חיווט: ${pass}/${vars.length} וריאנטים מתקמפלים — כל אחד בר-בחירה, אפס-אובדן.`);
  process.exit(0);
}
// ── שער: שחזור טבלת-ATOM הידנית של compose-engine
function parseAtomTable() {
  const src = fs.readFileSync(path.join(ROOT, 'machtzev/compose-engine.mjs'), 'utf8');
  const body = src.slice(src.indexOf('const ATOM = {'), src.indexOf('};', src.indexOf('const ATOM = {')));
  // המטרה-בעברית של כל op = (א) ה-`why` ב-ops() · (ב) **שמות-החלקיקים ונוסחאותיהם** (PARTICLES · name/expr) של כל סוג-הרכבה
  //   שמתפרק ל-op הזה — כלומר ניסוח-המטרה של הבנאי ("גבייה·יתרה", "נוכחות·חג/שבת"), לא שם-האטום.
  const whys = {};
  for (const m of src.matchAll(/\{\s*op:\s*'(\w+)'[^}]*?why:\s*'((?:[^'\\]|\\.)*)'/g)) whys[m[1]] = (whys[m[1]] || '') + ' ' + m[2];
  const kindOps = {};
  for (const m of src.matchAll(/if \(f\.kind === '([^']+)'\)[^\n]*?\n?[^\n]*?return \[([\s\S]*?)\];/g)) kindOps[m[1]] = [...m[2].matchAll(/op:\s*'(\w+)'/g)].map((x) => x[1]);
  const particles = [...src.matchAll(/\{ id: '([^']+)',\s*name: '((?:[^'\\]|\\.)*)',\s*f: \{ kind: '([^']+)'[^}]*?expr: '((?:[^'\\]|\\.)*)'/g)].map((m) => ({ id: m[1], name: m[2], kind: m[3], expr: m[4] }));
  const goalsByOp = {};
  for (const p of particles) for (const op of (kindOps[p.kind] || [])) goalsByOp[op] = (goalsByOp[op] || '') + ' ' + p.name + ' ' + p.expr;
  const heOnly = (s) => (s || '').replace(/[A-Za-z0-9_./:()+⊕§·—\-\[\]{}]+/g, ' ').replace(/\s+/g, ' ').trim();
  const rows = [];
  for (const line of body.split('\n')) {
    const m = line.match(/^\s*(\w+):\s*\{\s*atom:\s*'([^']+)',\s*seam:\s*'([^']*)'\s*\}\s*,?\s*(?:\/\/\s*(.*))?$/);
    if (!m) continue;
    const [, op, atom, seam, comment = ''] = m;
    const sockets = [...seam.matchAll(/\b(?:this\.)?([a-z][A-Za-z]{2,})\b/g)].map((x) => x[1]).filter((s) => !/^(dart|maor|premium|ds|required|screens|dashboard|screen|lists|feedback|actions|dataviz|surfaces|int|num)$/.test(s) && !/\.dart$/.test(s));
    rows.push({ op, atom, seam, goal: heOnly((goalsByOp[op] || '') + ' ' + (whys[op] || '') + ' ' + comment + ' ' + seam), sockets: [...new Set(sockets)].slice(0, 5) });
  }
  return rows;
}
const OPFAM = { magnitude: 'stat', headline: 'stat', hero: 'stat', ratio: 'ratio', compare: 'bars', diff: 'stat', fact: 'fact', group: 'group', identity: 'identity', action: 'action', search: 'field', filter: 'filter', switch: 'switch', alert: 'alert', table: 'table', panel: 'panel', timeline: 'timeline', empty: 'empty', trend: 'trend', ring: 'stat', gauge: 'stat', bars: 'bars', avatar: 'identity', expand: 'expand', field: 'field', enumfield: 'field', board: 'board', primary: 'action',
  match: 'transform', predicate: 'predicate', serialize: 'transform', role: 'format', grant: 'predicate', expiry: 'collection', capital: 'measure', queue: 'collection', progress: 'summary', sheet: 'transform', makeup: 'collection', balance: 'measure', paidstatus: 'format', hok: 'collection', clash: 'format', slots: 'collection', block: 'format', holiday: 'format', weekly: 'collection', sessions: 'collection', enrol: 'measure', wait: 'collection', byteacher: 'collection', whoami: 'format', cert: 'format', contact: 'format', recipients: 'collection', template: 'format', parse: 'collection', trendengine: 'summary' };

if (process.argv.includes('--gate') || process.argv.includes('--report')) {
  const rows = parseAtomTable();
  const res = rows.map((r) => {
    const fam = OPFAM[r.op] || r.op;
    const atomEntry = byId.get(r.atom) || [...byId.values()].find((a) => a.id.split('@')[0] === r.atom);
    const isLogic = atomEntry ? atomEntry.layer === 'logic' : LOGIC_OPS.has(fam);
    const need = isLogic ? [] : r.sockets.filter((s) => atomEntry ? atomEntry.sockets.includes(s) : true);
    const c = cover({ op: fam, need, goal: r.goal });
    const got = c.atoms.map((x) => x.split('@')[0]);
    const alts = (c.alts || []).map((x) => x.split('@')[0]);
    return { ...r, fam, got, alts, hit: got.includes(r.atom), hit3: alts.includes(r.atom), composed: c.composed, missing: c.missing };
  });
  const hits = res.filter((x) => x.hit).length, hits3 = res.filter((x) => x.hit3).length;
  const nD = res.filter((x) => !LOGIC_OPS.has(x.fam)).length, nL = res.length - nD;
  let md = `# כיסוי-שקעים (cover · G3) — שחזור טבלת-ATOM הידנית\n\n**top-1: ${hits}/${res.length}** (תצוגה ${res.filter((x) => x.hit && !LOGIC_OPS.has(x.fam)).length}/${nD} · לוגיקה ${res.filter((x) => x.hit && LOGIC_OPS.has(x.fam)).length}/${nL}) · **top-3: ${hits3}/${res.length}** (תצוגה ${res.filter((x) => x.hit3 && !LOGIC_OPS.has(x.fam)).length}/${nD} · לוגיקה ${res.filter((x) => x.hit3 && LOGIC_OPS.has(x.fam)).length}/${nL})\n\n| op | ביד | המנוע (top-1) | top-3 | ✓ |\n|---|---|---|---|---|\n`;
  for (const x of res) md += `| ${x.op}→${x.fam} | ${x.atom} | ${x.got.join(' + ') || '—'}${x.missing.length ? ' ⚠' + x.missing.join(',') : ''} | ${x.alts.join(' · ')} | ${x.hit ? '✓' : x.hit3 ? '≈' : '✗'} |\n`;
  const REPORT = path.join(GEN, 'cover-report.md'), BASE = path.join(GEN, 'cover-baseline.json');
  if (process.argv.includes('--gate')) {
    const base = fs.existsSync(BASE) ? JSON.parse(fs.readFileSync(BASE, 'utf8')) : { hits: 0, hits3: 0 };
    if (hits < base.hits || hits3 < (base.hits3 || 0)) { console.log(`🔴 cover: שחזור-ATOM ירד top1 ${base.hits}⇒${hits} · top3 ${base.hits3}⇒${hits3}`); process.exit(1); }
    console.log(`✓ cover: שחזור-ATOM top-1 ${hits}/${res.length} · top-3 ${hits3}/${res.length} (רצפה ${base.hits}/${base.hits3 || 0})`); process.exit(0);
  }
  fs.writeFileSync(REPORT, md);
  if (process.argv.includes('--write-baseline') || !fs.existsSync(BASE)) fs.writeFileSync(BASE, JSON.stringify({ hits, hits3, total: res.length }));
  process.stdout.write(md);
}

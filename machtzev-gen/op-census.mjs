#!/usr/bin/env node
// 🧭 op-census — סנסוס-פעולות-היסוד (GENMAX · G1 · PLAN-GENERATOR-MAX §2 ציר-2).
//   כל אטום באורקל (atom-index-full.json · 1402) + כל אטום-דאטה (new/dart-data-maor) ממופה
//   ל-**פעולת-יסוד (op)** — דטרמיניסטית, **מצורת-השקעים** בלבד (§20-ד: אפס-מילון-דומייני):
//     · תצוגה: קבוצת-השקעים של הבנאי (`this.X`) ⇒ op לפי חוקי-צורה (rows+labels⇒table · value+fraction⇒ratio …)
//     · לוגיקה: צורת-החתימה מ-logic-census (ret · params · Function-params · DateTime) ⇒ op-משפחה
//     · דאטה: סוג-הקובץ (terms/sockets/strings/table)
//   תפר-zero (אין שקע-דאטה) ⇒ `zero` = מזייף-אוטומטי (§20-ג) — לא נכנס לבחירה.
//   פלט: ops-map.json (SSOT ל-compose-engine/render-module) + ops-census-report.md.
//   --gate: 0 לא-ממופים · zero ⊆ display · ספירות לא-יורדות (ops-census-baseline.json · grow).
import fs from 'node:fs';
import path from 'node:path';
import * as R from '../root.mjs';

const ROOT = R.ROOT;
const GEN = path.join(ROOT, 'machtzev/generator');
const IDX = JSON.parse(fs.readFileSync(path.join(GEN, 'atom-index-full.json'), 'utf8'));
const LC = JSON.parse(fs.readFileSync(path.join(GEN, 'logic-census.json'), 'utf8'));
const lcByName = new Map(LC.map((e) => [e.name, e]));

// ── שקעים שאינם-דאטה (סגנון/מסגרת) — לא נחשבים תפר-דאטה. רשימה מבנית (שמות-props של Flutter), לא דומיינית.
const STYLE = new Set(['tone', 'size', 'color', 'colour', 'glyph', 'icon', 'emoji', 'accent', 'seed', 'width', 'height', 'padding', 'margin',
  'radius', 'dense', 'compact', 'elevated', 'grad', 'fillAlpha', 'fontWeight', 'verticalPadding', 'align', 'animate', 'duration', 'key', 'trailing', 'leading']);

// שקעי-הבנאי של **המחלקה עצמה** (קובץ-רב-מחלקות כמו ds/ds.dart ⇒ חותכים מ-`class <Id>` עד המחלקה הבאה).
// שקע-סגנון גם לפי צורת-השם (…Color/Radius/Alpha/Weight/Padding/Size/Style) — מבני, לא דומייני.
const isStyle = (x) => STYLE.has(x) || /(Color|Colour|Radius|Alpha|Weight|Padding|Size|Style|Opacity|Elevation)$/.test(x);
function sockets(file, cls) {
  const src = fs.readFileSync(path.join(ROOT, 'new', file), 'utf8');
  let region = src;
  const m = src.match(new RegExp(`\\bclass\\s+${cls}\\b[\\s\\S]*?(?=\\n(?:abstract\\s+)?class\\s+|$)`));
  if (m) region = m[0];
  const s = new Set([...region.matchAll(/\bthis\.([a-zA-Z_][a-zA-Z0-9_]*)/g)].map((m) => m[1]));
  return [...s].sort();
}

// ── חוקי-צורה לתצוגה: קבוצת-שקעים ⇒ op (סדר = עדיפות; הראשון שמתאים). כל חוק = צורה, לא מילת-דומיין.
const has = (S, ...xs) => xs.every((x) => S.has(x));
const anyOf = (S, ...xs) => xs.some((x) => S.has(x));
const DISPLAY_RULES = [
  // (S = כל השקעים · D = שקעי-הדאטה בלבד; בדיקות-גודל על D)
  ['table',    (S, D) => has(S, 'rows') && anyOf(S, 'labels', 'columns', 'headers')],
  ['board',    (S, D) => has(S, 'stages') && anyOf(S, 'records', 'items')],
  ['switch',   (S, D) => has(S, 'items') && anyOf(S, 'selected', 'onSelect', 'value')],
  ['filter',   (S, D) => has(S, 'selected') && anyOf(S, 'onTap', 'onChanged') && !S.has('items')],
  ['search',   (S, D) => has(S, 'onChanged', 'value') && anyOf(S, 'hint', 'placeholder')],
  ['field',    (S, D) => has(S, 'onChanged')],
  ['bars',     (S, D) => anyOf(S, 'values', 'series', 'points') && !S.has('rows')],
  ['trend',    (S, D) => has(S, 'value') && anyOf(S, 'delta', 'change', 'dir')],
  ['ratio',    (S, D) => anyOf(S, 'fraction', 'progress', 'pct', 'percent') || has(S, 'value', 'max')],
  ['ring',     (S, D) => has(S, 'value') && D.size <= 2 && !anyOf(S, 'label', 'title', 'onTap')],
  ['alert',    (S, D) => has(S, 'message') && anyOf(S, 'tone', 'severity', 'level')],
  ['empty',    (S, D) => has(S, 'message') && !anyOf(S, 'title', 'value', 'onTap')],
  ['timeline', (S, D) => has(S, 'title') && anyOf(S, 'time', 'when', 'date') && anyOf(S, 'body', 'subtitle')],
  ['action',   (S, D) => anyOf(S, 'onTap', 'onPressed') && anyOf(S, 'label', 'title', 'text')],
  ['stat',     (S, D) => has(S, 'value') && anyOf(S, 'label', 'title')],
  ['identity', (S, D) => has(S, 'title') && anyOf(S, 'subtitle', 'initials', 'name', 'avatar')],
  ['expand',   (S, D) => has(S, 'title') && anyOf(S, 'body', 'content', 'details')],
  ['fact',     (S, D) => anyOf(S, 'label', 'status') && D.size <= 2],
  ['group',    (S, D) => anyOf(S, 'title', 'header')],
  ['panel',    (S, D) => anyOf(S, 'child', 'children', 'body', 'content')],
  ['text',     (S, D) => anyOf(S, 'text', 'value', 'name', 'label')],
];
function classifyDisplay(a) {
  const all = sockets(a.file, a.id);
  const data = all.filter((x) => !isStyle(x));
  const structural = all.filter((x) => /^(child|children|body|content)$/.test(x));
  // zero = אין שקע-דאטה ואין שקע-מבני (child) — או שהאורקל סימן תפר-אפס. מיכל-עם-child = panel (הרכבה), לא מזייף.
  if (a.seam === 'zero' || (data.length === 0 && structural.length === 0)) return { op: 'zero', sockets: all, why: 'אין שקע-דאטה ⇒ מזייף (§20-ג)' };
  // חוקי-הצורה רואים את **כל** השקעים (tone/glyph הם ראיה-לצורה); בדיקות-גודל על שקעי-הדאטה.
  const S = new Set(all), D = new Set(data.length ? data : structural);
  for (const [op, test] of DISPLAY_RULES) if (test(S, D)) return { op, sockets: [...D], why: 'צורת-שקעים' };
  return { op: 'container', sockets: [...D], why: 'שקעי-דאטה ללא צורה-מוכרת' };
}

// ── חוקי-צורה ללוגיקה: חתימה ⇒ op-משפחה (ret ראשון, ואז צורת-params). שם-הפונקציה אינו ראיה (אפס-מילון).
function classifyLogic(a) {
  const e = lcByName.get(a.id) || {};
  const ret = String(e.ret || a.ret || 'dynamic');
  const params = Array.isArray(e.params) ? e.params : (a.params ? String(a.params).replace(/^\[|\]$/g, '').split(/', '/).map((s) => s.replace(/^'|'$/g, '')) : []);
  const ho = params.some((p) => /Function/.test(p));
  const temporal = params.some((p) => /DateTime/.test(p)) || /DateTime/.test(ret);
  const listIn = params.some((p) => /^List|^Iterable/.test(p));
  const flags = [ho && 'ho', temporal && 'temporal', listIn && 'listIn'].filter(Boolean);
  let op;
  if (/^bool/.test(ret)) op = 'predicate';
  else if (/^(num|int|double)\b/.test(ret)) op = listIn ? 'aggregate' : 'measure';
  else if (/^String/.test(ret)) op = 'format';
  else if (/^List<Map/.test(ret)) op = 'collection';
  else if (/^List<String/.test(ret)) op = 'lines';
  else if (/^List/.test(ret)) op = 'collection';
  else if (/^Map/.test(ret)) op = 'summary';
  else if (/^Set/.test(ret)) op = 'selection';
  else if (/^DateTime/.test(ret)) op = 'temporal';
  else if (/^void/.test(ret)) op = 'effect';
  else op = 'transform';
  return { op, sockets: params, ret, flags, why: 'צורת-חתימה' };
}

// ── דאטה (dart-data-maor): סוג-קובץ ⇒ op
function dataAtoms() {
  const dir = path.join(ROOT, 'new/dart-data-maor');
  if (!fs.existsSync(dir)) return [];
  return fs.readdirSync(dir).filter((f) => f.endsWith('.dart') && !f.endsWith('_test.dart')).map((f) => {
    const kind = /-terms\.dart$/.test(f) ? 'terms' : /-sockets\.dart$/.test(f) ? 'sockets' : /-strings\.dart$/.test(f) ? 'strings' : 'table';
    return { id: f.replace(/\.dart$/, ''), layer: 'data', file: 'dart-data-maor/' + f, op: 'data:' + kind, sockets: [], why: 'סוג-קובץ' };
  });
}

// ── השלמת-אורקל (ממצא G1 · L50): האינדקס מפתח לפי שם-מחלקה ⇒ כפילי-שם בין מדפים (alert_banner.dart מול
//   premium/feedback/alert_banner.dart) משאירים קבצים בלי אטום. כאן כל קובץ-תצוגה שאינו באינדקס נסרק ונרשם
//   כ-`Class@dir` — כדי ש-0 אטומים יפלו (§21). התיקון-השורשי (מפתח = מחלקה+קובץ) שייך ל-census/atom-index.mjs.
function unindexedDisplay() {
  const dir = path.join(ROOT, 'new/dart-ui-bs');
  const indexed = new Set(IDX.filter((a) => a.layer === 'display').map((a) => a.file));
  const outx = [];
  const walk = (d) => { for (const f of fs.readdirSync(d)) { const p = path.join(d, f); if (fs.statSync(p).isDirectory()) walk(p); else if (f.endsWith('.dart') && !f.endsWith('_test.dart')) { const rel = path.relative(path.join(ROOT, 'new'), p); if (!indexed.has(rel)) outx.push(rel); } } };
  walk(dir);
  const res = [];
  for (const rel of outx) {
    const src = fs.readFileSync(path.join(ROOT, 'new', rel), 'utf8');
    const classes = [...src.matchAll(/^\s*class\s+([A-Z]\w*)\s+extends\s+Stat(?:eless|eful)Widget/gm)].map((m) => m[1]);
    for (const cls of classes) {
      const a = { id: `${cls}@${path.dirname(rel).replace('dart-ui-bs/', '')}`, layer: 'display', file: rel, seam: 'fields', purpose: '(לא-באורקל · כפל-שם)' };
      res.push({ ...a, ...classifyDisplay({ ...a, id: cls }), unindexed: true });
    }
  }
  return res;
}

const out = [];
for (const a of IDX) {
  const c = a.layer === 'display' ? classifyDisplay(a) : classifyLogic(a);
  out.push({ id: a.id, layer: a.layer, file: a.file, purpose: a.purpose, ...c });
}
out.push(...unindexedDisplay());
out.push(...dataAtoms());

const unmapped = out.filter((x) => !x.op);
const byOp = {};
for (const x of out) byOp[x.op] = (byOp[x.op] || 0) + 1;
const zero = out.filter((x) => x.op === 'zero');
const badZero = zero.filter((x) => x.layer !== 'display');

// ── דוח
let md = `# סנסוס-פעולות-היסוד (op-census · G1)\n\n**${out.length}** אטומים ממופים (תצוגה ${out.filter((x) => x.layer === 'display').length} · לוגיקה ${out.filter((x) => x.layer === 'logic').length} · דאטה ${out.filter((x) => x.layer === 'data').length}) · לא-ממופים **${unmapped.length}** · zero (מזייפים-אוטומטית) **${zero.length}**\n\n`;
md += '| op | # | דוגמאות |\n|---|---|---|\n';
for (const [op, n] of Object.entries(byOp).sort((a, b) => b[1] - a[1])) md += `| ${op} | ${n} | ${out.filter((x) => x.op === op).slice(0, 5).map((x) => x.id).join(' · ')} |\n`;
md += `\n## zero (תפר-אפס ⇒ לא-נבחרים · §20-ג)\n${zero.map((x) => '`' + x.id + '`').join(' · ')}\n`;
md += `\nהחוקים = צורת-שקעים/חתימה בלבד (ראה op-census.mjs). אין מילת-דומיין באף חוק.\n`;

const MAP = path.join(GEN, 'ops-map.json');
const REPORT = path.join(GEN, 'ops-census-report.md');
const BASE = path.join(GEN, 'ops-census-baseline.json');
const summary = { total: out.length, unmapped: unmapped.length, zero: zero.length, ops: Object.keys(byOp).length, byOp };

if (process.argv.includes('--gate')) {
  const base = fs.existsSync(BASE) ? JSON.parse(fs.readFileSync(BASE, 'utf8')) : null;
  const errs = [];
  if (unmapped.length) errs.push(`לא-ממופים: ${unmapped.length}`);
  if (badZero.length) errs.push(`zero מחוץ לתצוגה: ${badZero.map((x) => x.id).join(',')}`);
  if (base && out.length < base.total) errs.push(`ספירה ירדה ${base.total}⇒${out.length}`);
  if (base && Object.keys(byOp).length < base.ops) errs.push(`אוצר-ops ירד ${base.ops}⇒${Object.keys(byOp).length}`);
  if (errs.length) { console.log('🔴 opcensus: ' + errs.join(' · ')); process.exit(1); }
  console.log(`✓ opcensus: ${out.length} אטומים ⇒ ${Object.keys(byOp).length} ops · 0 לא-ממופים · zero ${zero.length} (תצוגה בלבד)`);
  process.exit(0);
}
fs.writeFileSync(MAP, JSON.stringify(out, null, 1));
fs.writeFileSync(REPORT, md);
if (process.argv.includes('--write-baseline') || !fs.existsSync(BASE)) fs.writeFileSync(BASE, JSON.stringify(summary, null, 1));
process.stdout.write(md.split('\n').slice(0, 30).join('\n') + '\n');

#!/usr/bin/env node
// 🧬 shape-ops — סכמה ⇒ פעולות-יסוד (GENMAX · G2 · PLAN-GENERATOR-MAX §2 ציר-1).
//   קלט: סכמת-האמת `new/atoms/schema-fields.mjs` (FIELDS: {e,n,o,t}) — 54 ישויות · 492 שדות · 100 טיפוסים.
//   פלט: לכל ישות רשימת-ops **נגזרת מצורת-השדות בלבד** (§20-ד): טיפוס ⇒ op, אפס מילת-דומיין.
//     Id/Id[] ⇒ relation/identity · number ⇒ measure/aggregate/stat · boolean ⇒ flag/partition
//     IsoDate ⇒ temporal/calendar/expiry/holidayGuard · IsoDate+IsoDate או IsoDate+TimeHM ⇒ range/clash
//     TimeHM ⇒ slot/weekly · enum (A|B|C או Enum-בשם) ⇒ partition/lifecycle/workflow/filter
//     Sub[] (מערך-ישויות) ⇒ collection/table/log · Record<string,boolean> ⇒ flags
//     string ⇒ text; string ששמו בצורת-ערוץ (phone/tel/mail/email/wa) ⇒ channel (חוק-6: מוזרק) — רמז-צורה יחיד על שם-שדה, מוצהר.
//   ישות = תמיד גם: table · search · filter · form · panel · export · perm · states (ריק/טעינה/שגיאה) · kpi(count).
//   שער (--gate): coverage מול רתמת-הזהב — `golden-modules.json` (fixture: מודול ⇒ ישויות) מול סוגי-ההרכבה
//   הרשומים ב-compose-engine (PARTICLES); היחס רק-עולה (shape-ops-baseline.json · grow).
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as R from '../root.mjs';

const ROOT = R.ROOT;
const GEN = path.join(ROOT, 'machtzev/generator');
const src = fs.readFileSync(path.join(ROOT, 'new/atoms/schema-fields.mjs'), 'utf8');
const FIELDS = JSON.parse(src.slice(src.indexOf('['), src.lastIndexOf(']') + 1));

const ENTITIES = [...new Set(FIELDS.map((f) => f.e))];
const isEntity = (t) => ENTITIES.includes(t.replace(/\[\]$/, ''));
const isEnum = (t) => /\|/.test(t) && /'[^']*'/.test(t) || (/^[A-Z][A-Za-z]+$/.test(t) && !isEntity(t) && !['Id', 'IsoDate', 'TimeHM', 'Weekday'].includes(t) && t !== 'Record');
const isChannel = (n) => /(^|[_-])(phone|tel|mobile|mail|email|wa|whatsapp)([_-]|$)|phone|email/i.test(n);

// שדה ⇒ ops (צורה בלבד)
export function fieldOps(f) {
  const t = f.t.replace(/\s*\|\s*''$/, '');   // אופציונליות ('' ) אינה משנה צורה
  const ops = [];
  if (/^Id\[\]$/.test(t)) ops.push('relation-many');
  else if (/^Id$/.test(t)) ops.push(f.n === 'id' ? 'identity' : 'relation');
  else if (/\[\]$/.test(t) && isEntity(t)) ops.push('collection', 'table', /Date|Log|Entry|Session|Absence|Payment/.test(t) ? 'log' : 'list');
  else if (/^(string|IsoDate|number)\[\]$/.test(t)) ops.push('list');
  else if (/^number$/.test(t)) ops.push('measure', 'aggregate', 'stat');
  else if (/^boolean$/.test(t)) ops.push('flag', 'partition');
  else if (/^IsoDate$/.test(t)) ops.push('temporal', 'calendar', 'expiry', 'holidayGuard');
  else if (/^TimeHM$/.test(t)) ops.push('slot', 'weekly');
  else if (/^Weekday$/.test(t)) ops.push('slot', 'weekly');
  else if (/^Record</.test(t)) ops.push('flags');
  else if (isEnum(t)) ops.push('partition', 'lifecycle', 'workflow', 'filter');
  else if (/^string$/.test(t)) ops.push(isChannel(f.n) ? 'channel' : 'text');
  else ops.push('text');
  return ops;
}

// ישות ⇒ ops (שדות + ops-קבועים + ops-מצירופים)
export function entityOps(e) {
  const fs_ = FIELDS.filter((f) => f.e === e);
  const per = fs_.map((f) => ({ field: f.n, type: f.t, ops: fieldOps(f) }));
  const set = new Set(['table', 'search', 'filter', 'form', 'panel', 'export', 'perm', 'states', 'kpi']);
  per.forEach((p) => p.ops.forEach((o) => set.add(o)));
  const types = fs_.map((f) => f.t.replace(/\s*\|\s*''$/, ''));
  const nDates = types.filter((t) => t === 'IsoDate').length, nTime = types.filter((t) => t === 'TimeHM' || t === 'Weekday').length;
  if (nDates >= 2 || (nDates >= 1 && nTime >= 1)) set.add('range'), set.add('clash');           // טווח ⇒ התנגשות
  if (types.some((t) => t === 'number') && nDates >= 1) set.add('trend'), set.add('balance');       // מספר+זמן ⇒ מגמה/יתרה
  if (types.some((t) => /\[\]$/.test(t) && isEntity(t))) set.add('roster'), set.add('makeups');     // תת-ישויות ⇒ גיליון/השלמות
  if (set.has('channel')) set.add('contact'), set.add('broadcast');                                  // ערוץ ⇒ קשר/שידור
  if (set.has('workflow')) set.add('triage'), set.add('pipeline');                                   // מכונת-מצבים ⇒ טריאז׳/לוח
  if (set.has('relation')) set.add('details'), set.add('load');                                      // FK ⇒ כרטיס-הקשר/עומס
  if (types.some((t) => t === 'IsoDate') && set.has('flag')) set.add('certs');                      // תאריך+דגל ⇒ תוקף
  if (set.has('measure') && set.has('partition')) set.add('risk'), set.add('enrollment');           // מדד+חלוקה ⇒ סיכון/תפוסה
  if (set.has('collection')) set.add('import'), set.add('attendance');                              // אוסף ⇒ ייבוא/יחס
  if (set.has('measure') && fs_.some((f) => /^number$/.test(f.t) && /^(paid|amount|price|sum|total|balance|cost|due)/i.test(f.n))) set.add('hok');
  return { entity: e, fields: per.length, ops: [...set].sort(), perField: per };
}

const all = ENTITIES.map(entityOps);

// ── שער-הזהב: מודול ⇒ ישויות (fixture) מול סוגי-ההרכבה הרשומים ב-compose-engine (PARTICLES · kind)
const GOLD = JSON.parse(fs.readFileSync(path.join(GEN, 'golden-modules.json'), 'utf8'));
const ce = fs.readFileSync(path.join(ROOT, 'machtzev/compose-engine.mjs'), 'utf8');
const particles = [...ce.matchAll(/\{ id: '([^']+)',\s*name: '(?:[^'\\]|\\.)*',\s*f: \{ kind: '([^']+)'/g)].map((m) => ({ id: m[1], kind: m[2] }));
// שקילות סוג-הרכבה ⇒ op-משפחות (מבנית: שם-הסוג במנוע = שם-ה-op או אחת ממשפחותיו)
const KIND_TO_OPS = { raw: ['text', 'stat'], vs: ['trend', 'balance'], '/': ['measure'], '−': ['measure', 'balance'], '×': ['measure'], count: ['kpi'], sum: ['aggregate'], partition: ['partition'], name: ['identity'], act: ['form', 'panel'],
  search: ['search'], filter: ['filter'], table: ['table'], log: ['log'], panel: ['panel'], empty: ['states'], export: ['export'], perm: ['perm'], auto: ['expiry', 'holidayGuard', 'certs'], life: ['lifecycle', 'flag'],
  triage: ['triage'], trend: ['trend'], roster: ['roster'], attendance: ['attendance'], makeups: ['makeups'], holidayGuard: ['holidayGuard'], clash: ['clash'], weekly: ['weekly'], enrollment: ['enrollment'], balance: ['balance'], hok: ['hok'], contact: ['contact'], broadcast: ['broadcast'], import: ['import'], form: ['form'], load: ['load'], certs: ['certs'], pipeline: ['pipeline'], risk: ['risk'], details: ['details'] };
const prefixOf = (id) => id.includes('.') ? id.split('.')[0] : 'inv';
const cov = {};
for (const [mod, ents] of Object.entries(GOLD)) {
  const ops = new Set(ents.flatMap((e) => (all.find((a) => a.entity === e) || { ops: [] }).ops));
  const mine = particles.filter((p) => prefixOf(p.id) === mod);
  const hit = mine.filter((p) => (KIND_TO_OPS[p.kind] || [p.kind]).some((o) => ops.has(o)));
  cov[mod] = { particles: mine.length, derivable: hit.length, missing: mine.filter((p) => !hit.includes(p)).map((p) => p.id + ':' + p.kind) };
}
const totP = Object.values(cov).reduce((s, c) => s + c.particles, 0), totH = Object.values(cov).reduce((s, c) => s + c.derivable, 0);

let md = `# סכמה ⇒ פעולות-יסוד (shape-ops · G2)\n\n**${ENTITIES.length}** ישויות · **${FIELDS.length}** שדות ⇒ ops נגזרים מצורת-הטיפוס בלבד.\n\n## כיסוי רתמת-הזהב (חלקיקי compose-engine שנגזרים מהצורה)\n| מודול | ישויות | חלקיקים | נגזרים | חסרים |\n|---|---|---|---|---|\n`;
for (const [mod, c] of Object.entries(cov)) md += `| ${mod} | ${GOLD[mod].join(', ')} | ${c.particles} | ${c.derivable} | ${c.missing.join(' · ') || '—'} |\n`;
md += `\n**סה"כ ${totH}/${totP} (${Math.round(100 * totH / totP)}%)**\n\n## ops פר-ישות\n| ישות | שדות | ops |\n|---|---|---|\n`;
for (const a of all) md += `| ${a.entity} | ${a.fields} | ${a.ops.join(' · ')} |\n`;

const OUT = path.join(GEN, 'shape-ops.json'), REPORT = path.join(GEN, 'shape-ops-report.md'), BASE = path.join(GEN, 'shape-ops-baseline.json');
const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);   // L52-7: CLI רק בנקודת-הכניסה (frag-ops/op-bridge מייבאים)
if (isMain && process.argv.includes('--gate')) {
  const base = fs.existsSync(BASE) ? JSON.parse(fs.readFileSync(BASE, 'utf8')) : { derivable: 0, particles: 0 };
  if (totH < base.derivable) { console.log(`🔴 shapeops: כיסוי-הזהב ירד ${base.derivable}⇒${totH}`); process.exit(1); }
  console.log(`✓ shapeops: ${ENTITIES.length} ישויות · ${FIELDS.length} שדות ⇒ כיסוי-זהב ${totH}/${totP}`); process.exit(0);
}
if (isMain) {
fs.writeFileSync(OUT, JSON.stringify({ entities: all, coverage: cov }, null, 1));
fs.writeFileSync(REPORT, md);
if (process.argv.includes('--write-baseline') || !fs.existsSync(BASE)) fs.writeFileSync(BASE, JSON.stringify({ derivable: totH, particles: totP }));
process.stdout.write(md.split('\n').slice(0, 20).join('\n') + '\n');
}

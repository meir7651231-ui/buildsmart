#!/usr/bin/env node
// 🧠 core-from-shape — שכבת-הגרעין נגזרת מהסכמה (GENMAX · G6a · הכרעה-24 · §20-ד): Registry · Relations · Workflow · Events · Rules · Notification
//   קלט: schema-fields (54 ישויות/492 שדות) · enum-values.data.json (ערכי-טיפוסים חצובים מ-domain.ts) · entity-terms.data.json (מונחים) · אטומי-מדף למעברי-מצב.
//   כל שורה = עובדה-מבנית או הצבה-מוצהרת: יחס = שדה `xId` ⇒ ישות (שם/סיומת/תחילית באותו מרחב-שמות; אחרת reserved) ·
//   workflow = שדה-enum בשם status/stage/outcome ⇒ מצבים בסדר-ההצהרה; מעברים = אטום-מדף כשקיים (advanceStatus · nextStage), אחרת 'declared' (סדר-ההצהרה כברירת-מחדל — הצבה, לא אמת) ·
//   events = שדות-IsoDate של מחזור-חיים (…At/…Date/start/end/expiry/due) · rules = חובה (o:false), תחום-enum, שלמות-יחסים, ייחודיות-id · notification = שדות-ערוץ (phone/email).
//   policy-config (שבת/כשרות/הרשאות) = הכרעת-בעלים ⇒ שקע-מוצהר ריק, לא מומצא. פלט: core-registry.json + core-registry-report.md · --gate: ≡ טרי.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as R from '../root.mjs';
import { FIELDS } from '../../new/atoms/schema-fields.mjs';

const ROOT = R.ROOT, GEN = path.join(ROOT, 'machtzev/generator'), SHELF = path.join(ROOT, 'new/dart-maor');
const ENUMS = JSON.parse(fs.readFileSync(path.join(GEN, 'enum-values.data.json'), 'utf8')).enums;
const TERMS = fs.existsSync(path.join(GEN, 'entity-terms.data.json')) ? JSON.parse(fs.readFileSync(path.join(GEN, 'entity-terms.data.json'), 'utf8')).terms : [];
const EXCLUDE = /^(Db|UiPrefs|NotifPrefs|ReportPrefs|SecurityCfg)$/;
export const ENTITIES = [...new Set(FIELDS.map((f) => f.e))].filter((e) => !EXCLUDE.test(e));
const chanKind = (n) => /(^|[_-])(mail|email)([_-]|$)|mail/i.test(n) ? 'email' : /(^|[_-])(phone|tel|mobile|wa|whatsapp)([_-]|$)|phone/i.test(n) ? 'phone' : null;
const cap = (s) => s.charAt(0).toUpperCase() + s.slice(1);
const nsOf = (e) => (e.match(/^(Tz|Shop|Ayin|Course|Family|Dial)/) || [null])[0];
// מנועי-מעבר על המדף (עובדה: הקובץ קיים) — לפי שם-ה-enum
const SHELF_WORKFLOW = { DeliveryStatus: 'advance-status.dart', AyinStage: 'next-stage.dart' };
export function relationTarget(entity, field) {
  const base = field.replace(/Id$/, ''); if (!base) return { target: null, how: 'reserved' };
  const B = cap(base), lb = base.toLowerCase();
  const exact = ENTITIES.find((x) => x === B || x.toLowerCase() === lb); if (exact) return { target: exact, how: 'name' };
  const ns = nsOf(entity);
  const suffix = ENTITIES.filter((x) => x.endsWith(B)); const sameNs = suffix.find((x) => ns && x.startsWith(ns)); if (sameNs) return { target: sameNs, how: 'suffix+ns' };
  if (suffix.length === 1) return { target: suffix[0], how: 'suffix' };
  if (suffix.length > 1) { const org = suffix.find((x) => x.startsWith('Org')); return org ? { target: org, how: 'suffix(Org)' } : { target: null, how: `ambiguous(${suffix.join('/')})` }; }
  // תחילית (fam⇒Family · sp⇒Supporter): מועמדים שמתחילים בבסיס — הקצר-ביותר הוא הישות-האם (Family, לא FamilyCred/FamilyDoc); תחילית של 2 תווים רק כשהיא ייחודית
  const pre = ENTITIES.filter((x) => x.toLowerCase().startsWith(lb)).sort((a, b) => a.length - b.length);
  if (pre.length && (lb.length >= 3 || pre.length === 1)) return { target: pre[0], how: pre.length > 1 ? 'prefix(shortest)' : 'prefix' };
  // מילה-אחרונה של הבסיס (dueEvent⇒Event · mainEvent⇒Event): סיומת באותו מרחב-שמות, אחרת Org
  const last = (base.match(/[A-Z][a-z0-9]*$/) || [])[0];
  // מוקדם+מילה (mainEvent/dueEvent/nextEvent): המוקדם מסמן קישור חוצה-מרחב ⇒ ישות-השורש (Org*) קודמת לאותו מרחב-שמות (ShopEvent.mainEventId⇒OrgEvent, כמו בלגאסי)
  if (last && last !== B) { const sfx = ENTITIES.filter((x) => x.endsWith(last)); const pick = sfx.find((x) => x.startsWith('Org')) || sfx.find((x) => ns && x.startsWith(ns)) || (sfx.length === 1 ? sfx[0] : null); if (pick) return { target: pick, how: `suffix(${last})` }; }
  if (/^(prev|renewed|next|parent)/i.test(base)) return { target: entity, how: 'self?' };
  return { target: null, how: 'reserved' };
}
export function core(entity) {
  const fields = FIELDS.filter((f) => f.e === entity);
  const term = TERMS.find((t) => t.entity === entity);
  const relations = fields.filter((f) => /^Id/.test(f.t) && /Id$/.test(f.n) && f.n !== 'id').map((f) => ({ field: f.n, optional: f.o, ...relationTarget(entity, f.n) }));
  const workflows = fields.filter((f) => /^(status|stage|outcome)$/.test(f.n)).map((f) => {
    const states = ENUMS[f.t] || (/'/.test(f.t) ? [...f.t.matchAll(/'([^']*)'/g)].map((m) => m[1]) : null);
    const engine = SHELF_WORKFLOW[f.t] && fs.existsSync(path.join(SHELF, SHELF_WORKFLOW[f.t])) ? SHELF_WORKFLOW[f.t].replace(/\.dart$/, '') : null;
    return { field: f.n, type: f.t, states, transitions: states ? (engine ? { engine, note: 'מעברים מאטום-המדף' } : { order: 'declared', note: 'סדר-ההצהרה כברירת-מחדל — הצבה, לא אמת (חוק-7)' }) : { note: 'אין ערכים חצובים — מקום-שמור' } };
  });
  const events = fields.filter((f) => /IsoDate/.test(f.t) && /(At|Date|date|start|end|expiry|due)$/i.test(f.n)).map((f) => ({ field: f.n, event: f.n.replace(/(At|Date)$/, '').replace(/^date$/, 'recorded') || 'recorded', optional: f.o }));
  const rules = [
    ...fields.filter((f) => !f.o && f.n !== 'id' && !/\[\]$/.test(f.t)).map((f) => ({ kind: 'required', field: f.n })),
    ...fields.filter((f) => ENUMS[f.t] || /'\s*\|\s*'/.test(f.t)).map((f) => ({ kind: 'enum', field: f.n, values: ENUMS[f.t] || [...f.t.matchAll(/'([^']*)'/g)].map((m) => m[1]) })),
    ...relations.filter((r) => r.target).map((r) => ({ kind: 'ref', field: r.field, target: r.target })),
    ...(fields.some((f) => f.n === 'id') ? [{ kind: 'unique', field: 'id' }] : []),
  ];
  const notification = fields.filter((f) => chanKind(f.n)).map((f) => ({ field: f.n, channel: chanKind(f.n) }));
  return { entity, term: term ? term.forms[0] : null, fields: fields.length, id: fields.some((f) => f.n === 'id'), relations, workflows, events, rules, notification, policy: { note: 'policy-config (שבת/כשרות/הרשאות) = הכרעת-בעלים — שקע מוצהר, ריק' } };
}
export const registry = () => ({ source: 'schema-fields + enum-values.data.json + entity-terms.data.json + new/dart-maor (מעברים)', entities: ENTITIES.map(core) });
const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  const reg = registry(); const json = JSON.stringify(reg, null, 1);
  const OUT = path.join(GEN, 'core-registry.json'), REPORT = path.join(GEN, 'core-registry-report.md');
  const tot = (k) => reg.entities.reduce((a, e) => a + e[k].length, 0);
  const rel = reg.entities.flatMap((e) => e.relations), resolved = rel.filter((r) => r.target).length;
  const wf = reg.entities.flatMap((e) => e.workflows), wfEngine = wf.filter((w) => w.transitions.engine).length;
  const summary = `${reg.entities.length} ישויות · יחסים ${resolved}/${rel.length} פתורים · workflows ${wf.length} (${wfEngine} עם אטום-מעבר · ${wf.length - wfEngine} סדר-הצהרה) · אירועים ${tot('events')} · חוקים ${tot('rules')} · ערוצים ${tot('notification')}`;
  if (process.argv.includes('--gate')) {
    if (!fs.existsSync(OUT) || fs.readFileSync(OUT, 'utf8') !== json) { console.log('🔴 core: core-registry.json ≠ נגזרת-טרייה מהסכמה (הרץ core-from-shape.mjs)'); process.exit(1); }
    console.log(`✓ core: ${summary} ≡ סכמה`); process.exit(0);
  }
  fs.writeFileSync(OUT, json);
  let md = `# שכבת-הגרעין מהסכמה (core-from-shape · G6a)\n\n${summary}\n\n| ישות | מונח | שדות | יחסים | workflow | אירועים | חוקים | ערוצים |\n|---|---|---|---|---|---|---|---|\n`;
  for (const e of reg.entities) md += `| ${e.entity} | ${e.term || '—'} | ${e.fields} | ${e.relations.map((r) => `${r.field}⇒${r.target || '∅(' + r.how + ')'}`).join(' ') || '—'} | ${e.workflows.map((w) => `${w.field}:${(w.states || []).join('→')}${w.transitions.engine ? ' [' + w.transitions.engine + ']' : ''}`).join(' ') || '—'} | ${e.events.map((x) => x.event).join(' ') || '—'} | ${e.rules.length} | ${e.notification.map((n) => n.field).join(' ') || '—'} |\n`;
  fs.writeFileSync(REPORT, md);
  console.log(`✓ core-registry.json · ${summary}`);
}

#!/usr/bin/env node
// 🔬 frag-ops — ייחוס פעולות-יסוד (G2-ops) **פר-שבר** מהמפתחות שהשבר קורא (GENMAX · G8b · L60): הדרך שהמדידה השלילית הצביעה עליה.
//   שבר-זהב קורא מפתחות (`r['date']`, `s['phone']`) ⇒ טיפוס-המפתח מרשימות-הזרע של המודול (quarry: guess מהערך) ⇒ `fieldOps({n,t})` של G2 (צורה+רמז-ערוץ)
//   ⇒ G2-ops של השבר (איחוד). זה ייחוס מצורת-הדאטה (§20-ד), לא מילון — ומבחין (שבר-תאריכים ≠ שבר-כסף ≠ שבר-ערוצים).
//   שימוש: fragmentsForEntity(E, module) = שברי-member/builder שחופפים ל-entityOps(E) (משוקלל) — זריעה לפי פעולות-היסוד (L49) במקום חלקיקי-יד.
//   פלט: frag-ops.json (id ⇒ {keys, g2}) + report · --gate: ≡ טרי · מדד: הסכמת-מודול (Σ-חפיפה פר-מודול מול בורר-השמות, ישויות חזקות).
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as R from '../root.mjs';
import { entityOps, fieldOps } from './shape-ops.mjs';
import { seedLists, pickModule, ENTITIES, MODULES } from './retarget.mjs';

const ROOT = R.ROOT, GEN = path.join(ROOT, 'machtzev/generator'), DIR = path.join(ROOT, 'new/dart-gen-bs');
const FR = JSON.parse(fs.readFileSync(path.join(GEN, 'golden-fragments.json'), 'utf8')).fragments;
const guess = (v) => /^'\d{4}-\d{2}-\d{2}'$/.test(v) ? 'IsoDate' : /^'\d{2}:\d{2}'$/.test(v) ? 'TimeHM' : /^'[a-z]{1,3}\d+'$/.test(v) ? 'Id' : /^'/.test(v) ? 'string' : /^(true|false)$/.test(v) ? 'boolean' : /^-?\d/.test(v) ? 'number' : /^\[/.test(v) ? 'list' : /^\{/.test(v) ? 'map' : '?';
// טיפוסי-המפתחות של מודול: מכל רשימות-הזרע (const + seed()); מפתח בכמה רשימות ⇒ הטיפוס הראשון שאינו '?'
const keyTypes = (module) => { const src = fs.readFileSync(path.join(DIR, module), 'utf8'); const t = {}; for (const l of seedLists(src)) for (const kv of l.body.matchAll(/'([a-zA-Z_]\w*)':\s*((?:'(?:[^'\\]|\\.)*'|[^,}\]]+))/g)) { const g = guess(kv[2].trim()); if (!t[kv[1]] || t[kv[1]] === '?') t[kv[1]] = g; } return t; };
const G2T = { Id: 'Id', string: 'string', number: 'number', boolean: 'boolean', IsoDate: 'IsoDate', TimeHM: 'TimeHM', list: 'string[]', map: 'Record<string, string>' };
export function attribute() {
  const src = {}, kt = {};
  for (const m of MODULES) { src[m] = fs.readFileSync(path.join(DIR, m), 'utf8').split('\n'); kt[m] = keyTypes(m); }
  const out = {};
  for (const f of FR) {
    if (f.role !== 'member' && f.role !== 'builder' && f.role !== 'build') continue;
    const text = src[f.module].slice(f.range[0], f.range[1]).join('\n');
    const keys = [...new Set([...text.matchAll(/\['([a-zA-Z_]\w*)'\]/g)].map((m) => m[1]))].filter((k) => kt[f.module][k] && kt[f.module][k] !== '?');
    const g2 = new Set(); for (const k of keys) for (const op of fieldOps({ n: k, t: G2T[kt[f.module][k]] || 'string', o: false })) g2.add(op);
    if (keys.length) out[f.id] = { module: f.module, cls: f.cls, role: f.role, keys, g2: [...g2].sort() };
  }
  return out;
}
export function fragmentsForEntity(entity, module, fo) {
  const ops = new Set(entityOps(entity).ops);
  return Object.entries(fo).filter(([id, x]) => x.module === module && x.role !== 'build').map(([id, x]) => ({ id, overlap: x.g2.filter((o) => ops.has(o)).length, g2: x.g2 })).filter((x) => x.overlap).sort((a, b) => b.overlap - a.overlap);
}
const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  const fo = attribute();
  const perMod = {}; for (const [id, x] of Object.entries(fo)) { (perMod[x.module] ??= { n: 0, ops: new Set() }); perMod[x.module].n++; x.g2.forEach((o) => perMod[x.module].ops.add(o)); }
  // מדד: בורר-מודול לפי Σ-חפיפת-שברים (מנורמל במספר-השברים) מול בורר-השמות על ישויות חזקות
  const strong = ENTITIES.map((e) => pickModule(e)).filter((p) => p.strength === 'strong');
  const pickByFrag = (e) => MODULES.map((m) => { const fs_ = fragmentsForEntity(e, m, fo); return { m, score: +(fs_.reduce((a, x) => a + x.overlap, 0) / (perMod[m]?.n || 1)).toFixed(3), n: fs_.length }; }).sort((a, b) => b.score - a.score);
  const agree1 = strong.filter((p) => pickByFrag(p.entity)[0].m === p.module).length, agree2 = strong.filter((p) => pickByFrag(p.entity).slice(0, 2).some((x) => x.m === p.module)).length;
  const summary = { fragments: Object.keys(fo).length, modules: Object.keys(perMod).length, strong: strong.length, agreeTop1: agree1, agreeTop2: agree2 };
  const json = JSON.stringify({ summary, fragments: fo }, null, 0), OUT = path.join(GEN, 'frag-ops.json');
  if (process.argv.includes('--gate')) { if (!fs.existsSync(OUT) || fs.readFileSync(OUT, 'utf8') !== json) { console.log('🔴 fragops: frag-ops.json ≠ ייחוס-טרי'); process.exit(1); }
    // G8c · הפלט המחויב של זריעה-לפי-ops (Volunteer @ rooms) ≡ הרכבה-טרייה — דטרמיניזם של המסלול
    const { assembleByOps } = await import('./render-module.mjs'); const seeded = await assembleByOps({ module: 'schoolos_rooms.dart', entity: 'Volunteer' }); const sf = path.join(ROOT, 'new/dart-gen-bs/gen_opsseed_volunteer_from_rm.dart');
    if (!fs.existsSync(sf) || fs.readFileSync(sf, 'utf8') !== seeded.code) { console.log('🔴 fragops: gen_opsseed_volunteer_from_rm.dart ≠ זריעה-טרייה (render-module --module schoolos_rooms.dart --entity-ops Volunteer)'); process.exit(1); }
    // G8d · זריעה לפי שדות-המשפט: הפלט המחויב ≡ subsetFromSentence(המשפט)
    const { subsetFromSentence } = await import('./sentence.mjs'); const sub = await subsetFromSentence('ניהול מתנדבים עם טלפון, אזור ותאריך הצטרפות'); const subf = path.join(ROOT, 'new/dart-gen-bs/gen_opsseed_volunteer_from_fee_sub.dart');
    if (!sub.code || !fs.existsSync(subf) || fs.readFileSync(subf, 'utf8') !== sub.code) { console.log('🔴 fragops: gen_opsseed_volunteer_from_fee_sub.dart ≠ זריעה-לפי-שדות-המשפט טרייה (sentence --text … --subset)'); process.exit(1); } console.log(`✓ fragops: ${summary.fragments} שברים עם G2-ops ממפתחות · הסכמת-מודול (חזקות ${summary.strong}): top-1 ${summary.agreeTop1} · top-2 ${summary.agreeTop2} · זריעה-לפי-ops/שדות-המשפט ≡ (2 פלטים)`); process.exit(0); }
  fs.writeFileSync(OUT, json);
  let md = `# ייחוס-ops פר-שבר (frag-ops · G8b)\n\n${summary.fragments} שברים עם מפתחות-דאטה ⇒ G2-ops · הסכמת-מודול על ${summary.strong} ישויות חזקות: top-1 ${summary.agreeTop1} · top-2 ${summary.agreeTop2}\n\n| מודול | שברים-מיוחסים | G2-ops |\n|---|---|---|\n`;
  for (const [m, v] of Object.entries(perMod)) md += `| ${m} | ${v.n} | ${[...v.ops].sort().join(' ')} |\n`;
  md += `\n## בורר-לפי-שברים מול בורר-לפי-שמות\n| ישות | שמות ⇒ | שברים ⇒ (score·n) | הסכמה |\n|---|---|---|---|\n`;
  for (const p of strong) { const o = pickByFrag(p.entity); md += `| ${p.entity} | ${p.module.replace('schoolos_', '').replace('.dart', '') || 'inv'} | ${o[0].m.replace('schoolos_', '').replace('.dart', '') || 'inv'} (${o[0].score}·${o[0].n}) · ${o[1].m.replace('schoolos_', '').replace('.dart', '') || 'inv'} (${o[1].score}·${o[1].n}) | ${o[0].m === p.module ? '✓' : o[1].m === p.module ? '~' : '✗'} |\n`; }
  fs.writeFileSync(path.join(GEN, 'frag-ops-report.md'), md);
  console.log(`✓ frag-ops.json · ${summary.fragments} שברים מיוחסים · הסכמת-מודול top-1 ${agree1}/${strong.length} · top-2 ${agree2}/${strong.length}`);
  const ex = fragmentsForEntity('Volunteer', 'schoolos_rooms.dart', fo).slice(0, 5); console.log('  Volunteer@rooms:', ex.map((x) => `${x.id.split('#')[1]}(${x.overlap}:${x.g2.join('/')})`).join(' '));
}

#!/usr/bin/env node
// 🌉 op-bridge — גשר-אוצרות-ops נלמד מהזהב (GENMAX · G8a · חוב L56): G2-ops (צורת-הישות: aggregate/balance/calendar…) ⇄ G1-ops (מה האטום עושה: table/summary/format…)
//   לא טבלת-יד (כמו OPFAM ב-G3) אלא **שכיחות-משותפת ב-9 מודולי-הזהב**: מודול m מממש ישויות E(m) ⇒ G2(m)=∪entityOps; שבריו נושאים G1-ops (golden-fragments).
//   affinity[g2][g1] = Σ_m [g2∈G2(m)]·tf(g1,m) / df(g2) · idf(g1)  — tf = חלק-השברים-במודול עם g1 · idf מנחית ops גנריים (format/transform בכל מודול).
//   שימוש: expectedOps(E) = דירוג G1-ops מ-G2-ops של E · pickByOps(E) = המודול הקרוב בקוסינוס (מדד-הסכמה מול הבורר-לפי-שמות, G5e).
//   פלט: op-bridge.json + report · --gate: ≡ נלמד-טרי.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as R from '../root.mjs';
import { entityOps } from './shape-ops.mjs';
import { pickModule, ENTITIES } from './retarget.mjs';

const ROOT = R.ROOT, GEN = path.join(ROOT, 'machtzev/generator');
const GOLDEN = JSON.parse(fs.readFileSync(path.join(GEN, 'golden-modules.json'), 'utf8'));
const TAG2MOD = { inv: 'schoolos.dart', stu: 'schoolos_students.dart', par: 'schoolos_parents.dart', att: 'schoolos_attendance.dart', crs: 'schoolos_courses.dart', tch: 'schoolos_teachers.dart', rm: 'schoolos_rooms.dart', fee: 'schoolos_fees.dart', dash: 'schoolos_dashboard.dart' };
const FR = JSON.parse(fs.readFileSync(path.join(GEN, 'golden-fragments.json'), 'utf8')).fragments;
const r3 = (x) => +x.toFixed(4);
export function learn() {
  const mods = Object.keys(GOLDEN).map((tag) => {
    const g2 = new Set(GOLDEN[tag].flatMap((e) => entityOps(e).ops));
    const frs = FR.filter((f) => f.module === TAG2MOD[tag]); const tf = {}; let n = 0;
    for (const f of frs) for (const op of new Set(f.ops)) { tf[op] = (tf[op] || 0) + 1; n++; }
    for (const k of Object.keys(tf)) tf[k] = tf[k] / (n || 1);
    return { tag, g2: [...g2].sort(), tf };
  });
  const g1All = [...new Set(mods.flatMap((m) => Object.keys(m.tf)))].sort(), g2All = [...new Set(mods.flatMap((m) => m.g2))].sort();
  const df = Object.fromEntries(g2All.map((g) => [g, mods.filter((m) => m.g2.includes(g)).length]));
  const idf = Object.fromEntries(g1All.map((g) => [g, Math.log(1 + mods.length / mods.filter((m) => m.tf[g]).length)]));
  const affinity = {};
  for (const g2 of g2All) { affinity[g2] = {}; for (const g1 of g1All) { let s = 0; for (const m of mods) if (m.g2.includes(g2) && m.tf[g1]) s += m.tf[g1]; affinity[g2][g1] = r3(s / df[g2] * idf[g1]); } }
  const top = Object.fromEntries(g2All.map((g2) => [g2, Object.entries(affinity[g2]).sort((a, b) => b[1] - a[1]).slice(0, 6).map(([k, v]) => `${k}:${v}`)]));
  return { source: 'golden-modules.json × shape-ops.entityOps × golden-fragments.ops (9 מודולי-זהב)', modules: mods.map((m) => ({ tag: m.tag, g2: m.g2.length, g1: Object.keys(m.tf).length })), g2: g2All, g1: g1All, affinity, top };
}
export function expectedOps(entity, bridge) {
  const ops = entityOps(entity).ops; const score = {};
  for (const g2 of ops) for (const [g1, v] of Object.entries(bridge.affinity[g2] || {})) score[g1] = (score[g1] || 0) + v;
  return Object.entries(score).sort((a, b) => b[1] - a[1]);
}
const cos = (a, b) => { const ks = new Set([...Object.keys(a), ...Object.keys(b)]); let d = 0, na = 0, nb = 0; for (const k of ks) { d += (a[k] || 0) * (b[k] || 0); na += (a[k] || 0) ** 2; nb += (b[k] || 0) ** 2; } return na && nb ? d / Math.sqrt(na * nb) : 0; };
export function pickByOps(entity, bridge, mods) {
  const exp = Object.fromEntries(expectedOps(entity, bridge));
  return mods.map((m) => ({ tag: m.tag, module: TAG2MOD[m.tag], sim: r3(cos(exp, m.tf)) })).sort((a, b) => b.sim - a.sim);
}
const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  const bridge = learn();
  const mods = Object.keys(GOLDEN).map((tag) => { const frs = FR.filter((f) => f.module === TAG2MOD[tag]); const tf = {}; let n = 0; for (const f of frs) for (const op of new Set(f.ops)) { tf[op] = (tf[op] || 0) + 1; n++; } for (const k of Object.keys(tf)) tf[k] = tf[k] / (n || 1); return { tag, tf }; });
  // מדד-הסכמה: בורר-לפי-ops מול בורר-לפי-שמות (G5e) על הישויות ה"חזקות" (≥4 שמות) — לא אמת-מוחלטת, עד-שני
  const strong = ENTITIES.map((e) => pickModule(e)).filter((p) => p.strength === 'strong');
  const agree = strong.filter((p) => pickByOps(p.entity, bridge, mods)[0].module === p.module);
  const agreeTop2 = strong.filter((p) => pickByOps(p.entity, bridge, mods).slice(0, 2).some((x) => x.module === p.module));
  const summary = { g2: bridge.g2.length, g1: bridge.g1.length, strong: strong.length, agreeTop1: agree.length, agreeTop2: agreeTop2.length };
  const json = JSON.stringify({ ...bridge, summary }, null, 1), OUT = path.join(GEN, 'op-bridge.json');
  if (process.argv.includes('--gate')) {
    if (!fs.existsSync(OUT) || fs.readFileSync(OUT, 'utf8') !== json) { console.log('🔴 opbridge: op-bridge.json ≠ למידה-טרייה מהזהב (הרץ op-bridge.mjs)'); process.exit(1); }
    console.log(`✓ opbridge: ${summary.g2} G2-ops ⇄ ${summary.g1} G1-ops נלמדו מ-9 מודולי-זהב · הסכמה עם בורר-השמות (חזקות ${summary.strong}): top-1 ${summary.agreeTop1} · top-2 ${summary.agreeTop2} ≡`); process.exit(0);
  }
  fs.writeFileSync(OUT, json);
  let md = `# גשר-ops נלמד מהזהב (op-bridge · G8a)\n\n${summary.g2} G2-ops ⇄ ${summary.g1} G1-ops · הסכמה עם בורר-השמות על ${summary.strong} ישויות חזקות: top-1 ${summary.agreeTop1} · top-2 ${summary.agreeTop2}\n\n| G2-op | G1-ops הקרובים (affinity) |\n|---|---|\n`;
  for (const g2 of bridge.g2) md += `| ${g2} | ${bridge.top[g2].join(' · ')} |\n`;
  md += `\n## בורר-לפי-ops מול בורר-לפי-שמות (ישויות חזקות)\n| ישות | שמות ⇒ | ops ⇒ (sim) | הסכמה |\n|---|---|---|---|\n`;
  for (const p of strong) { const o = pickByOps(p.entity, bridge, mods); md += `| ${p.entity} | ${p.module.replace('schoolos_', '').replace('.dart', '') || 'inv'} | ${o[0].tag} (${o[0].sim}) · ${o[1].tag} (${o[1].sim}) | ${o[0].module === p.module ? '✓' : o[1].module === p.module ? '~' : '✗'} |\n`; }
  fs.writeFileSync(path.join(GEN, 'op-bridge-report.md'), md);
  console.log(`✓ op-bridge.json · ${summary.g2} G2-ops ⇄ ${summary.g1} G1-ops · הסכמה top-1 ${summary.agreeTop1}/${summary.strong} · top-2 ${summary.agreeTop2}/${summary.strong}`);
  for (const g2 of ['channel', 'calendar', 'balance', 'export', 'kpi', 'table']) if (bridge.top[g2]) console.log('  ', g2.padEnd(9), bridge.top[g2].slice(0, 5).join(' '));
}

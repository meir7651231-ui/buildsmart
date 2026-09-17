#!/usr/bin/env node
// 🗣️ sentence — משפט-בעברית ⇒ ישות ⇒ מודול-זהב ⇒ retarget ⇒ מסך (GENMAX · G5f · §22 צפון-המחולל · הכרעה-24): צינור-אחד, אפס-LLM, אפס-מילון-במנוע.
//   1. מילים-בעברית מהמשפט ⇒ התאמה לצורות-המונחים מ-`entity-terms.data.json` (אטום-דאטה חצוב מ-TERM_DEFS + נרדפות-ורטיקל):
//      מילה≡צורה · מילה בלי אות-שימוש אחת (ה/ו/ל/ב/מ/ש/כ)≡צורה · צורה(≥3) מוכלת במילה (רבים/נטייה) — ניקוד: 3/2/1.
//   2. הישות המנצחת (תיקו ⇒ סדר-המונחים) ⇒ `pickModule` (G5e) ⇒ `retarget` (G5c/d) ⇒ new/dart-gen-bs/gen_retarget_<e>_from_<tag>.dart.
//   3. אין מונח ⇒ **מקום-שמור**: מדווח "אין ישות בסכמה למשפט" — לא ממציא (§20-ג). (השלמה עתידית: התאמת-צורה של השדות שבמשפט מול פרופילי-הישויות.)
//   --gate: sentence-golden.json (משפטים ⇒ ישות צפויה, fixture) — הפותר מחזיר בדיוק אותן; דטרמיניזם.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as R from '../root.mjs';
import { normSearch } from '../../new/atoms/norm-search.mjs';          // L65 · נרמול-חיפוש עברי מהמדף (סופיות⇒רגילות) — לא טבלת-אותיות משלנו
import { NORM_SEARCH_T } from '../../new/atoms/norm-search-strings.mjs'; // אטום-הדאטה התאום של norm-search (מקור ה-Dart)
import { pickModule, retarget } from './retarget.mjs';
import { createHash } from 'node:crypto';
const skinTag = (skin) => createHash('sha1').update(JSON.stringify(Object.fromEntries(Object.entries(skin).filter(([, v]) => v).map(([k, v]) => [k, v.cls])))).digest('hex').slice(0, 6);   // תג-עור דטרמיניסטי מתפקידי-העור

const ROOT = R.ROOT, GEN = path.join(ROOT, 'machtzev/generator'), DIR = path.join(ROOT, 'new/dart-gen-bs');
const ALL_TERMS = JSON.parse(fs.readFileSync(path.join(GEN, 'entity-terms.data.json'), 'utf8')).terms;
const TERMS = ALL_TERMS.filter((t) => t.entity);
// G15 · כינויי-ישות מוצהרים (spec.aliases: 'entity.student' ⇒ 'Member'): מונח-TERM_DEFS בלי ישות-סכמה מקבל ישות מהבעלים — הכרעת-דומיין בהצהרה, לא במנוע
const termsWith = (aliases) => aliases && Object.keys(aliases).length ? ALL_TERMS.map((t) => (t.entity ? t : aliases[t.key] ? { ...t, entity: aliases[t.key] } : null)).filter(Boolean) : TERMS;
const heWords = (s) => [...(s || '').matchAll(/[֐-׿][֐-׿״׳\-\/]*/g)].map((m) => m[0]);
const nz = (w) => normSearch(w, NORM_SEARCH_T); // L65: 'תורם'+'ים' = 'תורםים' ≠ 'תורמים' — הריבוי חייב אות-רגילה; normSearch של המדף עושה בדיוק את זה
const PREFIX = /^[הולבמשכ]/;
// מורפולוגיה מינימלית (כלל-שפה, לא דומיין): ריבוי ־ים · ריבוי ־ה⇒־ות · ־ות — צורות-נגזרות מצורת-המונח (כמו match.stem)
const variants = (fw) => new Set([fw, nz(fw + 'ים'), nz(fw.endsWith('ה') ? fw.slice(0, -1) + 'ות' : fw + 'ות')]); // הצורות-הנגזרות מנורמלות גם הן (L65: 'רכז'+'ים' מסתיים ב-ם סופית, המילה המנורמלת לא)
const strip = (w) => PREFIX.test(w) ? w.slice(1) : w;
// G15 · כלל-שפה (לא דומיין): במשפט-רשימה "X לפי Y" / "X עם Y" — הנושא הוא לפני מילת-היחס; מילים אחריה הן לוואי ומשקלן 0.6 ("מסירות לפי מתנדב" ⇒ Delivery, לא Volunteer)
const PREPS = new Set(['לפי', 'עם', 'של', 'על', 'עבור', 'מול', 'אל', 'בתוך', 'ללא', 'בלי']);
export function resolve(text, aliases = null) {
  const TERMS = termsWith(aliases);
  const rawWords = heWords(text); const words = rawWords.map(nz);
  const firstPrep = rawWords.findIndex((w) => PREPS.has(w)); const isMod = (k) => firstPrep >= 0 && k > firstPrep;
  const votes = new Map();
  // ניקוד פר-צורה: הטוב-ביותר לכל מילת-הצורה, משוקלל בשלמות-הצורה (צורה דו-מילתית 'בן/בת משפחה' שרק חציה תאם ≠ 'משפחה' שלמה); לישות — המקסימום על צורותיה
  // צורה עם '/' בתוך מילה = חלופות ("בן/בת משפחה" ⇒ "בן משפחה" · "בת משפחה") — כלל-פורמט של TERM_DEFS, לא מילון (L68)
  const altForms = (f) => { const ws = f.split(' '); const i = ws.findIndex((w) => w.includes('/')); if (i < 0) return [f]; return ws[i].split('/').flatMap((a) => altForms([...ws.slice(0, i), a, ...ws.slice(i + 1)].join(' '))); };
  for (const t of TERMS) for (const form of t.forms.flatMap(altForms)) {
    const fws = heWords(form).map(nz); if (!fws.length) continue;
    let sum = 0, hit = 0;
    for (const fw of fws) {
      const vs = variants(fw); let best = 0;
      words.forEach((w, k) => { let s = 0; if (w === fw) s = 3; else if (vs.has(w) || vs.has(strip(w))) s = 2; else if (fw.length >= 3 && w.includes(fw)) s = 1; if (isMod(k)) s *= 0.6; if (s > best) best = s; });
      if (best) { sum += best; hit++; }
    }
    // ספציפיות (L68): בשוויון-ציון, הצורה הארוכה-יותר שתאמה במלואה מנצחת ("בני משפחה" ⇒ Member, לא "משפחה" ⇒ Family)
    if (hit) { const score = +(sum / fws.length).toFixed(2), prev = votes.get(t.entity); if (!prev || score > prev.score || (score === prev.score && fws.length > prev.len)) votes.set(t.entity, { score, len: fws.length }); }
  }
  const ranked = [...votes.entries()].map(([e, v]) => [e, v.score, v.len]).sort((a, b) => b[1] - a[1] || b[2] - a[2] || TERMS.findIndex((t) => t.entity === a[0]) - TERMS.findIndex((t) => t.entity === b[0])).map(([e, sc]) => [e, sc]);
  return { text, words, entity: ranked.length ? ranked[0][0] : null, score: ranked.length ? ranked[0][1] : 0, ranked: ranked.slice(0, 4) };
}
export function fromSentence(text, skin = null, aliases = null) {
  const r = resolve(text, aliases);
  if (!r.entity) return { ...r, module: null, out: null, reason: 'אין מונח-ישות במשפט — מקום-שמור (אין המצאה)' };
  const p = pickModule(r.entity);
  const g = retarget({ module: p.module, entity: r.entity, skin });
  const out = path.join(DIR, `gen_retarget_${r.entity.toLowerCase()}_from_${{ 'schoolos.dart': 'inv', schoolos_students: 'stu', schoolos_attendance: 'att', schoolos_courses: 'crs', schoolos_teachers: 'tch', schoolos_rooms: 'rm', schoolos_fees: 'fee', schoolos_parents: 'par', schoolos_dashboard: 'dash' }[p.module.replace(/\.dart$/, '')] || 'x'}${skin ? '_sk' + skinTag(skin) : ''}.dart`);   // G12c: מודול-מעורר-עור מקבל קובץ נפרד — אותו מודול בלי-עור משמש אפליקציה אחרת (התנגשות-קבצים חוצת-אפליקציות נתפסה בבדיקות)
  return { ...r, pick: p, module: p.module, out, code: g.code, counts: g.counts, facts: g.facts };
}
// G8d · שדות-המשפט ⇒ פעולות-יסוד: "עם טלפון, אזור, תאריך הצטרפות" ⇒ interpret(text).schema (טיפוס מרמזי-השפה + rule מהמדף) ⇒ fieldOps (G2) ⇒ ops מבוקשים ⇒ זריעה ממוקדת (assembleByOps)
const T2 = { date: 'IsoDate', num: 'number', bool: 'boolean', text: 'string', multiline: 'string' };
export async function fieldOpsOfSentence(text) {
  const { interpret } = await import('./entity.mjs'); const { fieldOps } = await import('./shape-ops.mjs');
  const schema = interpret(text).schema || []; const ops = new Set(); const fields = [];
  for (const f of schema) { const n = /phone|tel|טלפון/i.test(f.rule || '') || /טלפון|נייד/.test(f.label) ? 'phone' : /mail|מייל|אימייל/i.test((f.rule || '') + f.label) ? 'email' : 'f'; const fo = fieldOps({ n, t: T2[f.type] || 'string', o: false }); fo.forEach((o) => ops.add(o)); fields.push({ label: f.label, type: f.type, ops: fo }); }
  return { fields, ops: [...ops] };
}
export async function subsetFromSentence(text) {
  const r = resolve(text); if (!r.entity) return { ...r, reason: 'אין מונח-ישות במשפט' };
  const p = pickModule(r.entity); const fo = await fieldOpsOfSentence(text);
  const { assembleByOps } = await import('./render-module.mjs');
  const minOverlap = Math.max(1, Math.min(3, fo.ops.length - 1));
  const res = await assembleByOps({ module: p.module, entity: r.entity, minOverlap, opsOverride: new Set(fo.ops) });
  return { ...r, pick: p, module: p.module, fields: fo.fields, ops: fo.ops, minOverlap, fragments: res.fragments, of: res.of, code: res.code, sites: Object.values(res.plans).reduce((a, x) => a + x.sites.length, 0) };
}
const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
const arg = (k) => { const i = process.argv.indexOf(k); return i > -1 ? process.argv[i + 1] : null; };
const GOLDEN = path.join(GEN, 'sentence-golden.json');
if (isMain && process.argv.includes('--gate')) {
  const gold = JSON.parse(fs.readFileSync(GOLDEN, 'utf8'));
  const bad = gold.filter((g) => resolve(g.text).entity !== g.entity).map((g) => `"${g.text}" ⇒ ${resolve(g.text).entity} ≠ ${g.entity}`);
  if (bad.length) { console.log('🔴 sentence: ' + bad.join(' · ')); process.exit(1); }
  console.log(`✓ sentence: ${gold.length}/${gold.length} משפטי-זהב נפתרים לישות הצפויה (${TERMS.length} מונחי-ישות · אפס-LLM)`); process.exit(0);
}
if (isMain && arg('--text') && process.argv.includes('--subset')) {           // G8d: מודול-משנה סביב שדות-המשפט
  const r = await subsetFromSentence(arg('--text'));
  if (!r.entity) { console.log(`⚪ "${r.text}" ⇒ ${r.reason}`); process.exit(0); }
  const out = arg('--out') || path.join(DIR, `gen_opsseed_${r.entity.toLowerCase()}_from_${{ 'schoolos.dart': 'inv', schoolos_students: 'stu', schoolos_attendance: 'att', schoolos_courses: 'crs', schoolos_teachers: 'tch', schoolos_rooms: 'rm', schoolos_fees: 'fee', schoolos_parents: 'par', schoolos_dashboard: 'dash' }[r.module.replace(/\.dart$/, '')] || 'x'}_sub.dart`);
  if (!process.argv.includes('--dry')) fs.writeFileSync(out, r.code);
  console.log(`🗣️ "${r.text}" ⇒ ${r.entity} ⇒ ${r.module} · שדות-המשפט: ${r.fields.map((f) => `${f.label}(${f.type}:${f.ops.join('/')})`).join(' · ')} ⇒ ops ${r.ops.join(',')} · minOverlap ${r.minOverlap} ⇒ ${path.basename(out)} · שברים ${r.fragments}/${r.of} · בונים מחווטים ${r.sites}`);
} else if (isMain && arg('--text')) {
  const r = fromSentence(arg('--text'));
  if (!r.entity) { console.log(`⚪ "${r.text}" ⇒ ${r.reason}`); process.exit(0); }
  if (!process.argv.includes('--dry')) fs.writeFileSync(r.out, r.code);
  console.log(`🗣️ "${r.text}" ⇒ ${r.entity} (ניקוד ${r.score} · חלופות ${r.ranked.slice(1).map((x) => x[0] + ':' + x[1]).join(',') || '—'}) ⇒ ${r.module} (${r.pick.strength} · שמות ${r.pick.names}/${r.pick.fields}) ⇒ ${path.basename(r.out)} · שם ${r.counts.name} · ערוץ ${r.counts.chan} · טיפוס-יחיד ${r.counts.unique} · מקום-שמור ${r.counts.reserved}`);
}

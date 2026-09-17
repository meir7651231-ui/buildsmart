#!/usr/bin/env node
// 🎯 retarget — שבר-זהב ⇒ ישות אחרת מהסכמה (GENMAX · G5c+G5d · הכרעה-24): הופך את המנוע מ"מרכיב" ל"מחולל".
//   קלט: מודול-זהב M (למשל schoolos_rooms.dart) + ישות E מ-`new/atoms/schema-fields.mjs` (54 ישויות · 492 שדות).
//   1. הישות-הראשית של M = רשימת-המפות (const או בתוך seed()) שמפתחותיה **הנצרכים** בקוד הם הרבים ביותר (roleDefs מוחרג; תיקו ⇒ שם≡גזע-המודול ⇒ שורות) ⇒ מפתחות + טיפוס-משוער מהערך (§20-ד).
//   2. מיפוי מפתח⇒שדה-E דטרמיניסטי, בלי מילון (L55): (א) שם-זהה · (ב) **ערוץ-מוצהר** (phone/email — רמז-הצורה של G2 על שם-השדה) · (ג) **צורת-טיפוס יחידה** (בדיוק שדה פנוי אחד בקטגוריה — לא "הראשון-הפנוי") · (ד) מקום-שמור (חוק-7).
//   3. שכתוב: ליטרלי `'srcKey'` ⇒ `'dstKey'` מחוץ להערות · שמות-מחלקות · מפתח-מונח `'entity.<גזע>'` ⇒ `'entity.<e>'` עם ערך = שם-הישות (הצבה גלויה, לא עברית-שגויה) · ערכי-הזרע נשמרים כזרע-הצבה מוצהר.
//   4. הרכבה compose+declared ⇒ new/dart-gen-bs/gen_retarget_<e>_from_<tag>.dart ⇒ analyze + gen-verify (G5b) הם השער.
//   CLI: --module <file> --entity <E> [--out] · --gate: ההרכבות-המחויבות ≡ טריות.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as R from '../root.mjs';
import { assemble, PARTICLE_IDS, TAG } from './render-module.mjs';
import { FIELDS } from '../../new/atoms/schema-fields.mjs';

const ROOT = R.ROOT, DIR = path.join(ROOT, 'new/dart-gen-bs');
// G5g · מונחי-ישות (אטום-דאטה חצוב מ-TERM_DEFS — entity-terms.mjs): ישות ⇒ {יחיד, רבים, נרדפות}; ישות בלי מונח ⇒ null (תוויות נשארות של המקור, מדווח)
const TERMS_FILE = path.join(ROOT, 'machtzev/generator/entity-terms.data.json');
const TERMS = fs.existsSync(TERMS_FILE) ? JSON.parse(fs.readFileSync(TERMS_FILE, 'utf8')).terms : [];
export function termsFor(entity) {
  const rows = TERMS.filter((t) => t.entity === entity); if (!rows.length) return null;
  const sing = rows.find((t) => !/s$/.test(t.key) && !/Of$/.test(t.key)) || rows[0], plur = rows.find((t) => /s$/.test(t.key));
  return { singular: sing.forms[0], plural: plur ? plur.forms[0] : null, forms: [...new Set(rows.flatMap((t) => t.forms))] };
}
// מונחי-המקור של מודול: (א) מפתח-מונח ≡ גזע-שם-הקובץ (rooms⇒entity.room(s) · teachers⇒entity.teacher · students⇒entity.student(s) גם בלי ישות-סכמה) — עובדה-מבנית;
//   (ב) אחרת ישות-הסכמה עם ≥5 שמות-שדה זהים לזרע (fees⇒Supporter 11); (ג) אחרת null — אין החלפה, מדווח. (זרע-חלש כמו items⇒Course(3) לא מחליף תוויות בטעות)
export function sourceTerms(module) {
  const stem = stemOf(module).toLowerCase(), sing = stem.replace(/s$/, '');
  const rows = TERMS.filter((t) => t.key === 'entity.' + sing || t.key === 'entity.' + stem);
  if (rows.length) { const s1 = rows.find((t) => t.key === 'entity.' + sing) || rows[0], p1 = rows.find((t) => t.key === 'entity.' + stem && stem !== sing); return { by: 'stem', name: sing, singular: s1.forms[0], plural: p1 ? p1.forms[0] : null }; }
  const pk = primaryKeys(fs.readFileSync(path.join(DIR, module), 'utf8'), module);
  const ents = [...new Set(FIELDS.map((f) => f.e))];
  const best = ents.map((e) => ({ e, n: pk.keys.filter((k) => FIELDS.some((f) => f.e === e && f.n === k.key)).length })).sort((a, b) => b.n - a.n)[0];
  if (best && best.n >= 5) { const t = termsFor(best.e); if (t) return { by: 'seed', name: best.e, ...t }; }
  return null;
}
// החלפת מונחים בתוך ליטרלי-מחרוזת בלבד (לא מזהים, לא הערות): מילה-שלמה בעברית עם אות-שימוש אופציונלית — 'חדרים'⇒'מתנדבים' · 'לחדר'⇒'למתנדב'
const HEB = '[\\u0590-\\u05FF]';
function swapTerms(code, src, dst) {
  if (!src || !dst) return { code, swaps: 0 };
  const pairs = [[src.plural, dst.plural], [src.singular, dst.singular]].filter(([a, b]) => a && b && a !== b);
  let swaps = 0;
  const out = code.split('\n').map((l) => {
    const i = l.indexOf('//'); const head = i >= 0 ? l.slice(0, i) : l, tail = i >= 0 ? l.slice(i) : '';
    const h = head.replace(/'(?:[^'\\]|\\.)*'/g, (lit) => { let x = lit; for (const [a, b] of pairs) x = x.replace(new RegExp(`(?<!${HEB})([הולבמשכ]?)${a}(?!${HEB})`, 'g'), (m, pre) => { swaps++; return pre + b; }); return x; });
    return h + tail;
  }).join('\n');
  return { code: out, swaps };
}
const cat = (t) => /^Id/.test(t) ? 'Id' : /IsoDate/.test(t) ? 'IsoDate' : /TimeHM/.test(t) ? 'TimeHM' : /^number/.test(t) ? 'number' : /^boolean/.test(t) ? 'boolean' : /^string/.test(t) ? 'string' : /\[\]$/.test(t) ? 'list' : /^Record</.test(t) ? 'map' : (/'/.test(t) || /^[A-Z]\w+$/.test(t)) ? 'enum' : 'other';
const guess = (v) => /^'\d{4}-\d{2}-\d{2}'$/.test(v) ? 'IsoDate' : /^'\d{2}:\d{2}'$/.test(v) ? 'TimeHM' : /^'[a-z]{1,3}\d+'$/.test(v) ? 'Id' : /^'/.test(v) ? 'string' : /^(true|false)$/.test(v) ? 'boolean' : /^-?\d/.test(v) ? 'number' : /^\[/.test(v) ? 'list' : /^\{/.test(v) ? 'map' : /^null$/.test(v) ? 'null' : '?';
// ערוץ מוצהר משם-השדה (אותו רמז-צורה של shape-ops G2 — מקטע-שם, לא תת-מחרוזת: `waits` אינו `wa`)
const chanKind = (n) => /(^|[_-])(mail|email)([_-]|$)|mail/i.test(n) ? 'email' : /(^|[_-])(phone|tel|mobile|wa|whatsapp)([_-]|$)|phone/i.test(n) ? 'phone' : null;
const tagOf = (m) => TAG[m] || TAG[m.replace(/\.dart$/, '')] || 'x';
const stemOf = (m) => m.replace(/^schoolos_?/, '').replace(/\.dart$/, '') || 'inventory';

// כל רשימות-הזרע: `static const NAME = <Map<String, dynamic>>[` וגם `'NAME': [`/`'NAME': <Map…>[` בתוך seed() — לפי סוגריים-מאוזנים
export function seedLists(src) {
  const out = [];
  const re = /(?:static const (\w+) = <Map<String, dynamic>>\[|'(\w+)': (?:<Map<String, dynamic>>)?\[)\s*\n(\s*)\{/g;
  for (const m of src.matchAll(re)) {
    const name = m[1] || m[2]; let d = 0, i = m.index + m[0].lastIndexOf('[');
    for (let j = i; j < src.length; j++) { if (src[j] === '[') d++; else if (src[j] === ']') { d--; if (d === 0) { out.push({ name, body: src.slice(i + 1, j), depth: m[3].length }); break; } } }
  }
  return out.filter((l) => l.name !== 'roleDefs');
}
export function primaryKeys(src, module = '') {
  const lists = seedLists(src).map((l) => {
    const seen = new Map();
    for (const row of l.body.split('\n')) for (const kv of row.matchAll(/'([a-zA-Z_]\w*)':\s*((?:'(?:[^'\\]|\\.)*'|[^,}\]]+))/g)) { const t = guess(kv[2].trim()); if (!seen.has(kv[1]) || seen.get(kv[1]) === 'null') seen.set(kv[1], t); }
    const keys = [...seen].map(([key, type]) => ({ key, type }));
    const refd = keys.filter((k) => new RegExp(`\\['${k.key}'\\]`).test(src)).length;
    const rows = l.body.split('\n').filter((x) => /^\s*\{/.test(x)).length;
    return { name: l.name, keys, refd, rows };
  }).filter((l) => l.keys.length);
  if (!lists.length) return { name: null, keys: [] };
  const stem = stemOf(module).toLowerCase();
  lists.sort((a, b) => b.refd - a.refd || (b.name.toLowerCase() === stem) - (a.name.toLowerCase() === stem) || b.rows - a.rows);
  return { name: lists[0].name, keys: lists[0].keys, candidates: lists.map((l) => `${l.name}(${l.refd}/${l.keys.length})`) };
}
// חוזה-מנוע (G9 · נתפס בבדיקת-הניווט): מפתח שמנוע-מדף מיובא קורא (`s['amount']` בתוך ../dart-maor/*.dart) הוא חוזה של המנוע — לא משנים לו שם (המנוע לא נכתב-מחדש) ⇒ 'engine-contract'
export function engineKeys(module) {
  const src = fs.readFileSync(path.join(DIR, module), 'utf8'); const keys = new Set();
  for (const m of src.matchAll(/^import '(\.\.\/dart-maor\/[^']+)'/gm)) { const f = path.resolve(DIR, m[1]); if (!fs.existsSync(f)) continue; for (const k of fs.readFileSync(f, 'utf8').matchAll(/\['([a-zA-Z_]\w*)'\]/g)) keys.add(k[1]); }
  return keys;
}
export function mapKeys(keys, entity, locked = new Set()) {
  const fields = FIELDS.filter((f) => f.e === entity).map((f) => ({ n: f.n, cat: cat(f.t), t: f.t, chan: chanKind(f.n) }));
  if (!fields.length) throw new Error(`ישות לא בסכמה: ${entity}`);
  const used = new Set(), map = [];
  const take = (k, f, how) => { used.add(f.n); map.push({ src: k.key, dst: f.n, how, srcType: k.type, dstType: f.t }); };
  for (const k of keys) { const f = fields.find((x) => x.n === k.key && !used.has(x.n)); if (f) take(k, f, 'name'); }   // שם-זהה תמיד בטוח (אין שינוי-שם)
  for (const k of keys) { if (map.some((x) => x.src === k.key)) continue; if (locked.has(k.key)) { map.push({ src: k.key, dst: null, how: 'engine-contract', srcType: k.type, dstType: null }); continue; } const ck = chanKind(k.key); if (!ck) continue; const f = fields.find((x) => x.chan === ck && !used.has(x.n)); if (f) take(k, f, 'chan'); }
  for (const k of keys) {
    if (map.some((x) => x.src === k.key)) continue;
    const cands = fields.filter((x) => x.cat === k.type && !used.has(x.n) && !x.chan);
    if (cands.length === 1) take(k, cands[0], 'unique'); else map.push({ src: k.key, dst: null, how: cands.length ? `reserved(${cands.length} מועמדים)` : 'reserved', srcType: k.type, dstType: null });
  }
  return { map, unusedFields: fields.filter((f) => !used.has(f.n)).map((f) => f.n) };
}
// G12c · מעבר-עור במודול: קריאות DS (BareStat/StatHero) ⇒ אטום-forge עם fields לפי תפקידי-החריצים (ערך⇒חריץ-מספרי · תווית⇒טקסט-ראשון). פרסר-ארגומנטים מאוזן (סוגריים · מחרוזות · אינטרפולציה).
export function callArgs(src, open) {   // src[open] === '(' ⇒ { end, args: [{name, expr}] } (end = index of ')')
  let i = open + 1, depth = 0, cur = '', args = [], inStr = null, brace = [];
  const push = () => { const t = cur.trim(); if (t) { const m = /^([a-zA-Z_]\w*):\s*([\s\S]*)$/.exec(t); args.push(m ? { name: m[1], expr: m[2] } : { name: null, expr: t }); } cur = ''; };
  for (; i < src.length; i++) {
    const ch = src[i];
    if (inStr) { cur += ch; if (ch === '\\') { cur += src[++i]; continue; } if (ch === '$' && src[i + 1] === '{') { brace.push(0); cur += src[++i]; continue; } if (brace.length) { if (ch === '{') brace[brace.length - 1]++; else if (ch === '}') { if (brace[brace.length - 1] === 0) brace.pop(); else brace[brace.length - 1]--; } continue; } if (ch === inStr) inStr = null; continue; }
    if (ch === "'" || ch === '"') { inStr = ch; cur += ch; continue; }
    if (ch === '(' || ch === '[' || ch === '{') { depth++; cur += ch; continue; }
    if (ch === ')' || ch === ']' || ch === '}') { if (depth === 0 && ch === ')') { push(); return { end: i, args }; } depth--; cur += ch; continue; }
    if (ch === ',' && depth === 0) { push(); continue; }
    cur += ch;
  }
  return null;
}
// הווידג׳ט-האב של קריאה: סריקה-לאחור עד ה-'[' הפתוח (רשימת-children), ואז שם-הווידג׳ט שלפני ה-'(' הפתוח של אותה רשימת-ארגומנטים. מחרוזות מדולגות.
function parentWidget(code, idx) {
  let depthB = 0, depthP = 0, i = idx - 1;
  const skipStrBack = (k) => { const q = code[k]; for (let j = k - 1; j >= 0; j--) { if (code[j] === q && code[j - 1] !== '\\') return j; } return 0; };
  for (; i >= 0; i--) {
    const ch = code[i];
    if (ch === "'" || ch === '"') { i = skipStrBack(i); continue; }
    if (ch === ']') depthB++; else if (ch === '[') { if (depthB === 0) break; depthB--; }
    else if (ch === ')') depthP++; else if (ch === '(') { if (depthP === 0) return null; depthP--; }
  }
  if (i < 0) return null;
  if (!/children:\s*$/.test(code.slice(Math.max(0, i - 40), i))) return null;
  // ה-'(' הפתוח של רשימת-הארגומנטים שמכילה את children
  let d = 0; for (let j = i - 1; j >= 0; j--) { const ch = code[j]; if (ch === "'" || ch === '"') { j = skipStrBack(j); continue; } if (ch === ')' || ch === ']') d++; else if (ch === '(' || ch === '[') { if (d === 0) { const m = /(\w+)\s*$/.exec(code.slice(Math.max(0, j - 40), j)); return m ? m[1] : null; } d--; } }
  return null;
}
// G13c · helper-צ׳יפ מודולרי: `Widget NAME(params) => FilterChipPill(label: …, selected: …, onTap: …, …)` ⇒ {params, label, selected, onTap}. גוף-בלוק/האצלה ⇒ לא נפתר (נשאר DS, מדווח)
function balancedClose(s, open) { let d = 0; for (let k = open; k < s.length; k++) { if (s[k] === '(') d++; else if (s[k] === ')') { d--; if (d === 0) return k; } } return -1; }
function chipHelpers(code) {
  const out = {}; const re = /Widget\s+(\w+)\(([^)]*)\)\s*=>\s*FilterChipPill\(/g; let m;
  const paramsOf = (ps) => ps.split(',').map((x) => x.trim()).filter(Boolean).map((x) => x.split(/\s+/).pop());
  while ((m = re.exec(code))) {
    const c = callArgs(code, m.index + m[0].length - 1); if (!c) continue;
    const by = Object.fromEntries(c.args.filter((a) => a.name).map((a) => [a.name, a.expr]));
    if (!by.label || !by.selected || !by.onTap) continue;
    out[m[1]] = { params: paramsOf(m[2]), label: by.label, selected: by.selected, onTap: by.onTap };
  }
  // G13d · גוף-בלוק: `Widget NAME(params) { final x = …; … return FilterChipPill(…); }` ⇒ המקומיים מוחלפים בביטוייהם
  const reB = /Widget\s+(\w+)\(([^)]*)\)\s*\{([\s\S]*?)\n  \}/g;
  while ((m = reB.exec(code))) {
    const body = m[3]; const r = body.indexOf('return FilterChipPill('); if (r < 0 || out[m[1]]) continue;
    const c = callArgs(body, r + 'return FilterChipPill'.length); if (!c) continue;
    const by = Object.fromEntries(c.args.filter((a) => a.name).map((a) => [a.name, a.expr]));
    if (!by.label || !by.selected || !by.onTap) continue;
    const locals = [...body.slice(0, r).matchAll(/final\s+(?:\w+\s+)?(\w+)\s*=\s*([^;]+);/g)].map((x) => [x[1], x[2].trim()]);
    if (/\b(if|for|while|switch)\b/.test(body.slice(0, r).replace(/final[^;]+;/g, ''))) continue;   // זרימת-בקרה בגוף ⇒ לא פותרים (אין ניחוש)
    const subL = (e) => locals.reduceRight((acc, [n, v]) => acc.replace(new RegExp(`(?<![\\w.$])${n}(?![\\w])`, 'g'), `(${v})`), e);
    out[m[1]] = { params: paramsOf(m[2]), label: subL(by.label), selected: subL(by.selected), onTap: subL(by.onTap) };
  }
  // G13d · האצלה: `Widget NAME(params) => OTHER(args)` כאשר OTHER helper-צ׳יפ פתור ⇒ הרכבה
  const reD = /Widget\s+(\w+)\(([^)]*)\)\s*=>\s*(\w+)\(/g;
  for (let pass = 0; pass < 2; pass++) while ((m = reD.exec(code))) {
    if (out[m[1]] || !out[m[3]]) continue;
    const rec = chipRecord(code.slice(m.index + m[0].length - m[3].length - 1, balancedClose(code, m.index + m[0].length - 1) + 1), out);
    if (rec) out[m[1]] = { params: paramsOf(m[2]), ...rec };
  }
  return out;
}
function splitTopArgs(s) { const parts = []; let d = 0, start = 0; for (let k = 0; k < s.length; k++) { const ch = s[k]; if ('([{'.includes(ch)) d++; else if (')]}'.includes(ch)) d--; else if (ch === ',' && d === 0) { parts.push(s.slice(start, k)); start = k + 1; } } if (s.slice(start).trim()) parts.push(s.slice(start)); return parts.map((x) => x.trim()); }
function chipRecord(call, helpers) {
  if (/^FilterChipPill\(/.test(call)) { const cc = callArgs(call, 'FilterChipPill'.length); const by = cc ? Object.fromEntries(cc.args.filter((a) => a.name).map((a) => [a.name, a.expr])) : {}; return by.label && by.selected && by.onTap ? { label: by.label, selected: by.selected, onTap: by.onTap } : null; }
  const m = /^(\w+)\(/.exec(call); const h = m && helpers[m[1]]; if (!h) return null;
  const close = balancedClose(call, m[0].length - 1); if (close !== call.length - 1) return null;
  const args = splitTopArgs(call.slice(m[0].length, close)); if (args.length !== h.params.length) return null;
  const sub = (expr) => h.params.reduce((acc, pn, k) => acc.replace(new RegExp(`(?<![\\w.$])${pn}(?![\\w])`, 'g'), `(${args[k]})`), expr);   // החלפת-פרמטר במחרוזת-הארגומנט (גבולות-מילה, לא אחרי '.')
  return { label: sub(h.label), selected: sub(h.selected), onTap: sub(h.onTap) };
}
export function skinPass(code, skin) {
  const stats = { stat: 0, hero: 0 }, barrels = new Set();   // G13b: גם section/segmented/meter/glass/frame/timeline/chip
  // G13b · שורת-צ׳יפים: Wrap/Row שכל ילדיו FilterChipPill(label, selected, onTap) ⇒ אטום-אוסף אחד (items · selected={i אם התנאי} · onSelect⇒onTap[i]) — צ׳יפ-בודד באטום-קבוצה נראה כקופסה ריקה (נתפס בצילום)
  if (skin && skin.chip) {
    const sk = skin.chip; let out = '', i = 0;
    const helpers = chipHelpers(code);
    // G13e · helpers-עטיפה: `Widget NAME(List<Widget> kids) => Wrap(` ⇒ NAME([...]) נסרק כמו Wrap
    // G15b · גם `_wrap(List<Widget> kids, {double top = 6}) => Padding(…, child: Wrap(…children: kids))` — הגוף (עד ה-; ברמה-0) חייב להכיל Wrap( עם children: <הפרמטר>
    const wrapHelpers = {}; for (const mm of code.matchAll(/Widget\s+(\w+)\(List<Widget>\s+(\w+)(?:,\s*\{[^}]*\})?\)\s*=>/g)) {
      let k = mm.index + mm[0].length, d = 0; for (; k < code.length; k++) { const ch = code[k]; if ('([{'.includes(ch)) d++; else if (')]}'.includes(ch)) d--; else if (ch === ';' && d === 0) break; }
      const body = code.slice(mm.index + mm[0].length, k);
      if (/\bWrap\(/.test(body) && new RegExp(`children:\\s*${mm[2]}\\b`).test(body)) wrapHelpers[mm[1]] = true;
    }
    const wrapRe = new RegExp(`\\b(Wrap|Row${Object.keys(wrapHelpers).map((k) => '|' + k).join('')})\\(`, 'g');
    for (;;) {
      const m = wrapRe; m.lastIndex = i; const hit = m.exec(code); if (!hit) { out += code.slice(i); break; }
      const j = hit.index; const c = callArgs(code, j + hit[1].length); if (!c) { out += code.slice(i, j + 1); i = j + 1; continue; }
      const isHelper = !!wrapHelpers[hit[1]];   // G13e · helper-עטיפה מודולרי `_wrap([...])` ⇒ הרשימה היא הארגומנט-הפוזיציוני
      const cm0 = /const\s+$/.exec(code.slice(i, j)); const j0 = cm0 ? j - cm0[0].length : j;   // const Wrap(…) ⇒ Builder אינו קבוע
      const ch = isHelper ? c.args.find((a) => !a.name) : c.args.find((a) => a.name === 'children');
      const list = ch && /^\[[\s\S]*\]$/.test(ch.expr.trim()) ? ch.expr.trim().slice(1, -1) : null;
      let ok = false, recs = [], others = [];
      if (list) {   // פירוק הרשימה (מאוזן-סוגריים): כל פריט = FilterChipPill(...) · או קריאה ל-helper שגופו => FilterChipPill (G13c: _fchip(...)) · או for (...) <אחד מהם>
        let k = 0, depth = 0, start = 0, parts = [];
        for (; k < list.length; k++) { const chr = list[k]; if (chr === '(' || chr === '[' || chr === '{') depth++; else if (chr === ')' || chr === ']' || chr === '}') depth--; else if (chr === ',' && depth === 0) { parts.push(list.slice(start, k)); start = k + 1; } }
        if (list.slice(start).trim()) parts.push(list.slice(start));
        parts = parts.map((p) => p.trim()).filter(Boolean);
        ok = true;
        // G13e · פריט ⇒ רשומה: שרשרת for/if · `...[a, b]` (spread) רקורסיבי · קריאה ל-FilterChipPill/helper
        const toRec = (p) => {
          let head = '', call = p.trim();
          while (/^(for|if)\s*\(/.test(call)) { const o = call.indexOf('('); const e = balancedClose(call, o); if (e < 0) return null; head += call.slice(0, e + 1) + ' '; call = call.slice(e + 1).trim(); }
          if (/^\.\.\.\[/.test(call) && call.endsWith(']')) { const inner = splitTopArgs(call.slice(4, -1)).map(toRec); if (inner.some((x) => x == null)) return null; return `${head}...[${inner.join(', ')}]`; }
          const rec = chipRecord(call, helpers); if (!rec) return null;
          return `${head}(${rec.label}, ${rec.selected}, ${rec.onTap})`;
        };
        for (const p of parts) { const r = toRec(p); if (r == null) others.push(p); else recs.push(r); }   // G13e · ילדים-לא-צ׳יפים (כפתור-ניקוי בתוך ה-Wrap) נשארים כפי-שהם לצד אטום-הצ׳יפים
        ok = recs.length >= 2 || (recs.length === 1 && /^(for|if)\s*\(|\.\.\./.test(recs[0]));
      }
      if (!ok) { if (process.env.SKIN_DEBUG && list && /_fchip|FilterChipPill|_bchip|_vchip/.test(list)) console.error('chipRow-skip:', list.replace(/\s+/g, ' ').slice(0, 220)); out += code.slice(i, j + 1); i = j + 1; continue; }
      // רשומות (label, selected, onTap) — גם מ-for — ⇒ אטום-אוסף אחד; Builder כדי להחזיק את הרשימה כביטוי
      const chipsW = `Builder(builder: (_) { final chips = <(String, bool, VoidCallback)>[${recs.join(', ')}]; return ${sk.cls}(${sk.bare ? 'bare: true, ' : ''}items: [for (final ch in chips) [ch.$1]], selected: <int>{for (final (k, ch) in chips.indexed) if (ch.$2) k}, onSelect: (k) => chips[k].$3()); })`;
      const named = isHelper ? c.args.filter((a) => a.name).map((a) => `, ${a.name}: ${a.expr}`).join('') : '';   // G15b · `_wrap([...], top: 0)` — הארגומנטים-הנקובים של helper-העטיפה נשמרים
      if (isHelper) out += code.slice(i, j0) + `${hit[1]}([${chipsW}${others.length ? ', ' + others.join(', ') : ''}]${named})`;   // helper-העטיפה נשאר (ריפוד/ריווח שלו = פריסה, לא צ׳יפ)
      else if (!others.length) out += code.slice(i, j0) + chipsW;
      else out += code.slice(i, j0) + `${hit[1]}(${c.args.filter((a) => a.name !== 'children').map((a) => `${a.name}: ${a.expr}`).join(', ')}${c.args.length > 1 ? ', ' : ''}children: [${chipsW}, ${others.join(', ')}])`;
      i = c.end + 1;
      stats.chipRow = (stats.chipRow || 0) + 1; stats.chip = (stats.chip || 0) + recs.length; barrels.add(sk.barrel);
    }
    code = out;
  }
  for (const [ds, role] of [['BareStat', 'stat'], ['StatHero', 'hero'], ['KpiTile', 'kpi'], ['DsNavTile', 'navTile'], ['SoftButton', 'button'], ['StatusChip', 'statusChip'], ['AlertBanner', 'banner'], ['EmptyState', 'emptyState'], ['MediaRow', 'mediaRow'],
    ['DsSection', 'section'], ['SegmentedSwitch', 'segmented'], ['StatRow', 'meter'], ['GlassCard', 'glass'], ['GradientCard', 'frame'], ['TimelineItem', 'timeline'], ['FilterChipPill', 'chip'],
    ['DsField', 'field'], ['DsEnumField', 'enumField'], ['DsNumberField', 'numberField'], ['DsDateField', 'dateField'], ['DsSearch', 'search'], ['DsScaffold', 'pageHeader'],
    ['DsTable', 'table'], ['NeonBars', 'bars'], ['DsBars', 'bars'], ['DsChip', 'statusChip'], ['DsPrimaryButton', 'button'], ['DsCalendar', 'calendar'], ['DsBoard', 'board']]) {   // G14 · לוח-שנה · קנבן   // G13e · זנב: DsChip(label,tone) כתג · DsPrimaryButton(label,onTap) ככפתור   // G13c · שדות-חיים בחריץ-control + כותרת-המסך · G13d · טבלה (columns+items[i][j]) · בארים (values)   // G13b · מיכלים/בוררים/מדדים דרך תפרי-G13a (child · items/selected/onSelect · values)
    const sk = skin && skin[role]; if (!sk) continue;
    let out = '', i = 0;
    for (;;) {
      const j = code.indexOf(ds + '(', i); if (j < 0) { out += code.slice(i); break; }
      if (/[\w.]/.test(code[j - 1] || '')) { out += code.slice(i, j + ds.length + 1); i = j + ds.length + 1; continue; }   // חלק משם-אחר / member
      const c = callArgs(code, j + ds.length); if (!c) { out += code.slice(i, j + ds.length + 1); i = j + ds.length + 1; continue; }
      const byName = Object.fromEntries(c.args.filter((a) => a.name).map((a) => [a.name, a.expr]));
      // G13d · `const Ds…(…)` ⇒ ההחלפה אינה קבועה (אינדקס-וריאנט/רשומות) ⇒ מסירים את ה-const שלפני הקריאה (124 invalid_constant)
      const cm = /const\s+$/.exec(code.slice(i, j)); const j0 = cm ? j - cm[0].length : j;
      // G12e · עלי-טקסט פנימיים: תפקידי text1/text2 — הטקסט הראשי ⇒ חריץ-הכותרת, משני ⇒ חריץ-המשנה, השאר ''. onTap (כפתור) נשמר ב-GestureDetector; tone/glyph של ה-DS לא מועברים (האטום לובש את החריץ)
      // G13b · תפקידי-תפר (child · items/selected/onSelect · values) — ההתנהגות (onSelect/onTap/children) נשמרת, הציור מהספרייה
      const skip = () => { out += code.slice(i, c.end + 1); i = c.end + 1; };
      const done = (w) => { out += code.slice(i, j0) + w; i = c.end + 1; stats[role] = (stats[role] || 0) + 1; barrels.add(sk.barrel); };
      const blank = (n) => Array.from({ length: n }, () => "''");
      const parentW = () => parentWidget(code, j);
      const flexIfRow = (w) => (parentW() === 'Row' ? `Flexible(child: ${w})` : w);
      if (role === 'section') {   // DsSection(title, children, trailing?, tone?) ⇒ מקטע-forge: כותרת בחריץ, הילדים בתוך המסגרת (child), trailing כשורה-ראשונה
        if (!byName.title || !byName.children) { skip(); continue; }
        const f = blank(sk.slots); f[sk.titleIdx] = byName.title;
        const kids = `[${byName.trailing ? `Align(alignment: Alignment.centerLeft, child: ${byName.trailing}), ` : ''}...${byName.children}]`;
        done(`${sk.cls}(fields: [${f.join(', ')}], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: ${kids}))`); continue;
      }
      if (role === 'segmented') {   // SegmentedSwitch(items, selected, onSelect) ⇒ בורר-forge: פריט-לכל-מחרוזת, selected={i}, אותו onSelect
        if (!byName.items || !byName.selected || !byName.onSelect) { skip(); continue; }
        done(flexIfRow(`${sk.cls}(${sk.bare ? 'bare: true, ' : ''}items: [for (final s in ${byName.items}) [s]], selected: {${byName.selected}}, onSelect: ${byName.onSelect})`)); continue;   // bare: הבורר בלי כרטיס-הגלריה
      }
      if (role === 'meter') {   // StatRow(label, value, fraction) ⇒ מדד-forge: תווית+ערך בחריצים, המילוי מ-values
        if (!byName.label || !byName.value || !byName.fraction) { skip(); continue; }
        const f = blank(sk.slots); f[sk.labelIdx] = byName.label; f[sk.valueIdx] = byName.value;
        done(`${sk.cls}(fields: [${f.join(', ')}], values: [${byName.fraction}])`); continue;
      }
      if (role === 'glass') {   // GlassCard(title, sub, height, radius, colors…) ⇒ כרטיס-forge (כותרת+משנה); הצבעים/הגובה של ה-DS לא מועברים (האטום לובש את החריץ)
        if (byName.child && !byName.title && skin.frame) {   // GlassCard(child) של הזהב (מיכל-KPI/כרטיס-רשומה) = מסגרת ⇒ תפקיד frame
          const fr = skin.frame; out += code.slice(i, j0) + `${fr.cls}(${fr.slots ? `fields: [${blank(fr.slots).join(', ')}], ` : ''}child: ${byName.child})`; i = c.end + 1; stats.frame = (stats.frame || 0) + 1; barrels.add(fr.barrel); continue;
        }
        if (!byName.title || !byName.sub) { skip(); continue; }
        const f = blank(sk.slots); f[sk.titleIdx] = byName.title; if (sk.subIdx >= 0) f[sk.subIdx] = byName.sub;
        done(flexIfRow(`${sk.cls}(fields: [${f.join(', ')}])`)); continue;
      }
      if (role === 'frame') {   // GradientCard(child) ⇒ מסגרת-forge: כל חריצי-הטקסט ריקים (נעלמים ב-_hide), התוכן בתוך המסגרת
        if (!byName.child) { skip(); continue; }
        done(`${sk.cls}(${sk.slots ? `fields: [${blank(sk.slots).join(', ')}], ` : ''}child: ${byName.child})`); continue;
      }
      if (role === 'timeline') {   // TimelineItem(title, time, body?) ⇒ שורת-רשימה-forge כפריט-יחיד: [title, time, body]
        if (!byName.title || !byName.time) { skip(); continue; }
        const cells = [byName.title, byName.time, byName.body ? `(${byName.body}) ?? ''` : null].filter(Boolean).slice(0, sk.itemSlots);
        done(`${sk.cls}(items: [[${cells.join(', ')}]])`); continue;
      }
      // G13c · שדה-DS ⇒ אטום-forge שמצייר תווית+מסגרת, והשדה-החי (אותו DS, bare:true) בחריץ-ה-control. ההתנהגות (value/onChanged) זהה, הציור מהספרייה.
      if (['field', 'enumField', 'numberField', 'dateField', 'search'].includes(role)) {
        if (!byName.onChanged || (role !== 'search' && !byName.label)) { skip(); continue; }
        if (code.slice(c.end + 1, c.end + 20).includes('bare: true')) { skip(); continue; }
        const inner = code.slice(j, c.end + 1).replace(/\)$/, ', bare: true)');
        const f = sk.slots ? `fields: [${Array.from({ length: sk.slots }, (_, k) => (k === sk.titleIdx && byName.label ? byName.label : "''")).join(', ')}], ` : '';
        const st = sk.stateIds && sk.stateIds.includes('empty') && sk.stateIds.includes('filled') && byName.value ? `state: (${byName.value}).toString().trim().isEmpty ? ${sk.cls}State.empty : ${sk.cls}State.filled, ` : '';
        done(`${sk.cls}(${st}${f}control: ${inner})`); continue;
      }
      if (role === 'board') {   // DsBoard(stages, records, stageOf, titleOf, onMove) ⇒ קנבן-forge: עמודות=פריטים [שלב, מונה, ...כרטיסים]; הקשה על כרטיס=קידום (onMove col+1) · הקשה-ארוכה=החזרה (col-1) — אותו onMove
        if (!byName.stages || !byName.records || !byName.stageOf || !byName.titleOf || !byName.onMove) { skip(); continue; }
        done(`Builder(builder: (_) { final kS = ${byName.stages}; final kR = ${byName.records}; final kF = ${byName.stageOf}; final kT = ${byName.titleOf}; final kM = ${byName.onMove}; final kCols = [for (var c = 0; c < kS.length; c++) [for (final r in kR) if (kF(r).clamp(0, kS.length - 1) == c) r]]; return ${sk.cls}(${sk.bare ? 'bare: true, ' : ''}items: [for (var c = 0; c < kS.length; c++) [kS[c], '\${kCols[c].length}', for (final r in kCols[c]) kT(r).isEmpty ? (r['__id'] ?? '') : kT(r)]], onCell: (i, j) { if (i < kS.length - 1 && j < kCols[i].length) kM(kCols[i][j]['__id'] ?? '', i + 1); }, onCellLong: (i, j) { if (i > 0 && j < kCols[i].length) kM(kCols[i][j]['__id'] ?? '', i - 1); }); })`); continue;
      }
      if (role === 'calendar') {   // DsCalendar(records, dateOf, titleOf) ⇒ לוח-forge: DsCalendar.grid (אותו חישוב-חודש) ⇒ items/variants/columns; ◀▶ דרך DsMonthOffset
        if (!byName.records || !byName.dateOf) { skip(); continue; }
        const ids = sk.variantIds || [];
        const f = Array.from({ length: sk.slots }, (_, k) => (k === sk.titleIdx ? 'g.title' : "''"));
        done(`DsMonthOffset(builder: (ctx, off, shift) { final g = DsCalendar.grid(${byName.records}, ${byName.dateOf}, off); return ${sk.cls}(${sk.bare ? 'bare: true, ' : ''}fields: [${f.join(', ')}], columns: DsCalendar.dows, items: [for (final c in g.cells) [c.$1, c.$3]], variants: [for (final c in g.cells) const <String>[${ids.map((x) => `'${x}'`).join(', ')}].indexOf(c.$2).clamp(0, ${Math.max(0, ids.length - 1)})], onAction: (k) => shift(k == 0 ? -1 : 1)); })`); continue;
      }
      if (role === 'table') {   // DsTable(labels, rows) ⇒ טבלת-forge: columns=labels · items=rows (כל מספר-עמודות · תבנית-תא)
        if (!byName.labels || !byName.rows) { skip(); continue; }
        done(`${sk.cls}(${sk.bare ? 'bare: true, ' : ''}columns: ${byName.labels}, items: ${byName.rows})`); continue;
      }
      if (role === 'bars') {   // NeonBars/DsBars(labels, values, title?) ⇒ גרף-forge: values מנורמלים לגבוה (0..1); הבארים בעיצוב = ${sk.values} — עודף מדולג, חסר ⇒ 0
        if (!byName.values) { skip(); continue; }
        const f = sk.slots ? `fields: [${Array.from({ length: sk.slots }, (_, k) => (k === sk.titleIdx && byName.title ? byName.title : "''")).join(', ')}], ` : '';
        done(`${sk.cls}(${f}values: (() { final _vs = ${byName.values}; final _m = _vs.fold<double>(0.0, (a, b) => a > b ? a : b); return [for (final v in _vs) _m == 0 ? 0.0 : v / _m]; })())`); continue;
      }
      if (role === 'pageHeader') {   // DsScaffold(title, subtitle, icon, children, bottomBar) ⇒ header:false + כותרת-forge כילד-ראשון
        if (!byName.title || !byName.subtitle || !byName.children || byName.header) { skip(); continue; }
        const f = Array.from({ length: sk.slots }, (_, k) => (k === sk.titleIdx ? byName.title : k === sk.subIdx ? byName.subtitle : "''"));
        const hdr = `${sk.cls}(fields: [${f.join(', ')}]${sk.hasItems ? ', items: const <List<String>>[]' : ''})`;
        const rest = c.args.filter((a) => a.name !== 'children').map((a) => (a.name ? `${a.name}: ${a.expr}` : a.expr));
        done(`DsScaffold(${rest.join(', ')}, header: false, children: [${hdr}, ...${byName.children}])`); continue;
      }
      if (role === 'chip') { skip(); continue; }   // צ׳יפ-בודד נשאר DS — אטום-הקבוצה נראה כקופסה ריקה סביב צ׳יפ-אחד; שורות-צ׳יפים הוחלפו למעלה
      const textRole = { button: ['label', null, true], statusChip: ['label', null, false], banner: ['message', null, false], emptyState: ['message', null, false], mediaRow: ['title', 'subtitle', false] }[role];
      if (textRole) {
        const [mainK, subK, tap] = textRole;
        if (!byName[mainK]) { out += code.slice(i, c.end + 1); i = c.end + 1; continue; }
        const f = Array.from({ length: sk.slots }, (_, k) => (k === sk.titleIdx ? byName[mainK] : (k === sk.subIdx && subK && byName[subK]) ? byName[subK] : "''"));
        // G13d · אטום-וריאנטים (tone-*): הטקסט כפריט-יחיד, הטון של ה-DS (int) ⇒ אינדקס-וריאנט דרך toneMap של העור (גשר-אוצר-מילים מוצהר, לא מילון-דומייני)
        const forgedT = sk.variantMap && byName.tone != null
          ? `${sk.cls}(${sk.bare ? 'bare: true, ' : ''}items: [[${byName[mainK]}]], variants: ${/^\d+$/.test(byName.tone.trim()) ? `const <int>[${sk.variantMap[(+byName.tone) % sk.variantMap.length]}]` : `[const <int>[${sk.variantMap.join(', ')}][(${byName.tone}) % ${sk.variantMap.length}]]`})`   // טון-ליטרלי ⇒ אינדקס בזמן-חילול (נשאר const-תקין בתוך const Align(…))
          : sk.variantMap ? `${sk.cls}(${sk.bare ? 'bare: true, ' : ''}items: [[${byName[mainK]}]])` : `${sk.cls}(fields: [${f.join(', ')}])`;
        const parentT = parentWidget(code, j);
        const inner = tap ? `GestureDetector(behavior: HitTestBehavior.opaque, onTap: ${byName.onTap || 'null'}, child: ${forgedT})` : forgedT;
        const boxed = parentT === 'Row' ? `Flexible(child: ${inner})` : inner;   // ב-Row: חולק רוחב (טקסט-forge אלסטי) ולא גולש · Flexible חייב להיות ילד-ישיר של ה-Row (מעל ה-GestureDetector, לא מתחתיו — ParentData)
        out += code.slice(i, j0) + boxed; i = c.end + 1; stats[role] = (stats[role] || 0) + 1; barrels.add(sk.barrel); continue;
      }
      if (role === 'navTile') {   // DsNavTile(glyph, title, sub, onTap) ⇒ אריח-forge (text2) עטוף GestureDetector עם אותו onTap — ההתנהגות נשמרת, הציור מהספרייה
        if (!byName.title || !byName.sub || !byName.onTap) { out += code.slice(i, c.end + 1); i = c.end + 1; continue; }
        const f2 = Array.from({ length: sk.slots }, (_, k) => (k === sk.titleIdx ? byName.title : k === sk.subIdx ? byName.sub : "''"));
        out += code.slice(i, j0) + `GestureDetector(behavior: HitTestBehavior.opaque, onTap: ${byName.onTap}, child: ${sk.cls}(fields: [${f2.join(', ')}]))`; i = c.end + 1; stats[role] = (stats[role] || 0) + 1; barrels.add(sk.barrel); continue;
      }
      if (!byName.value || !byName.label) { out += code.slice(i, c.end + 1); i = c.end + 1; continue; }
      const fields = Array.from({ length: sk.slots }, (_, k) => (k === sk.valueIdx ? byName.value : k === sk.labelIdx ? byName.label : "''"));
      // אטומי-forge נמתחים ל-double.infinity (SizedBox של הגלריה) ⇒ ב-Row/Wrap = אילוצים אינסופיים (נתפס בבדיקות). stat: רוחב-אריח של הזהב (168, _Home של schoolos) · hero: תקרת-רוחב
      const forged = `${sk.cls}(fields: [${fields.join(', ')}])`;
      // stat ב-Row (רצועת-KPI בעלת-מספר-קבוע, ~4 באותה שורה) — אריח-forge ברוחב-עיצוב לא נכנס ⇒ נשאר BareStat של ה-DS (מדווח); ב-Wrap ⇒ אריח-forge ברוחב-אריח של הזהב (168)
      const parent = parentWidget(code, j);
      if (role === 'stat' && parent === 'Row') { out += code.slice(i, j0) + `Expanded(child: ${forged})`; i = c.end + 1; stats.statRow = (stats.statRow || 0) + 1; barrels.add(sk.barrel); continue; }   // G12e · ברצועת-Row: חלוקת-רוחב שווה (Expanded) — הטקסט הפנימי אלסטי (Flexible+ellipsis במנוע-החישול)
      out += code.slice(i, j0) + (role === 'stat' ? `SizedBox(width: 168, child: ${forged})` : role === 'kpi' ? forged : `ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: ${forged})`); i = c.end + 1; stats[role] = (stats[role] || 0) + 1; barrels.add(sk.barrel);
    }
    code = out;
  }
  if (barrels.size) {
    const lines = code.split('\n'); const li = lines.reduce((a, l, k) => (/^import '/.test(l) ? k : a), -1);
    lines.splice(li + 1, 0, ...[...barrels].map((b) => `import '${b}'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)`));
    code = lines.join('\n');
  }
  return { code, stats };
}
export function retarget({ module, entity, skin = null }) {
  const src = fs.readFileSync(path.join(DIR, module), 'utf8');
  const pk = primaryKeys(src, module);
  const { map, unusedFields } = mapKeys(pk.keys, entity, engineKeys(module));
  const tag = tagOf(module), k = module.replace(/\.dart$/, '');
  const ids = PARTICLE_IDS.filter((id) => (TAG[k] && TAG[k] !== 'inv' ? id.startsWith(tag + '.') : !id.includes('.')));
  const res = assemble({ module, particles: ids, mode: 'compose', declared: true });
  let code = res.code;
  const ren = map.filter((x) => x.dst && x.dst !== x.src);
  const E = entity.replace(/[^A-Za-z0-9]/g, ''), eLower = E.toLowerCase();
  const stemSing = stemOf(module).replace(/s$/, '').toLowerCase();
  code = code.split('\n').map((l) => {
    const i = l.indexOf('//'); const head = i >= 0 ? l.slice(0, i) : l, tail = i >= 0 ? l.slice(i) : ''; let h = head;
    for (const x of ren) h = h.replace(new RegExp(`'${x.src}'`, 'g'), `'${x.dst}'`);
    h = h.replace(new RegExp(`'entity\\.${stemSing}':\\s*'[^']*'`, 'g'), `'entity.${eLower}': '${(termsFor(entity) || {}).singular || E}'`);   // מונח-הישות מהדאטה (או הצבה גלויה כשאין מונח)
    return h + tail;
  }).join('\n');
  const classes = [...new Set([...code.matchAll(/^(?:abstract\s+)?class\s+(\w+)/gm)].map((m) => m[1]))];
  const pub = classes.find((c) => /Screen$/.test(c) && !/^_/.test(c));
  const stem = pub ? pub.replace(/Screen$/, '') : null;
  const clsMap = stem ? classes.filter((c) => c.includes(stem)).map((c) => [c, c.replace(stem, E)]) : [];
  for (const [a, b] of clsMap) code = code.replace(new RegExp(`\\b${a}\\b`, 'g'), b);
  // G5g · תוויות: מונחי ישות-המקור (מהזרע) ⇒ מונחי ישות-היעד, בליטרלי-מחרוזת בלבד; אין מונח ליעד ⇒ תוויות נשארות ומדווח
  const srcT = sourceTerms(module), srcE = srcT ? srcT.name : null, dstT = termsFor(entity);
  const sw = swapTerms(code, srcT, dstT); code = sw.code;
  // G6c · הגרעין-בשימוש: כשקיים מסך-גרעין לישות (gen_core_<e>.dart, G6b) — מסך-הישות מייבא את <E>Core ומציג מקטע-מחזור-חיים חי (מצבים חצובים · המעבר מאטום-המדף · חוקים/ערוצים) מיד אחרי children: [ של ה-DsScaffold הראשי
  const coreFile = `gen_core_${eLower}.dart`, coreWired = fs.existsSync(path.join(DIR, coreFile));
  if (coreWired) {
    const lines = code.split('\n');
    const lastImp = lines.reduce((a, l, i) => (/^import '/.test(l) ? i : a), -1);
    const need = [`import '${coreFile}'; // G6c · הגרעין-מהסכמה של ${E} (מצבים · מעבר · חוקים · ערוצים)`];
    if (!lines.some((l) => /premium\/feedback\/status_chip\.dart/.test(l))) need.push(`import '../dart-ui-bs/premium/feedback/status_chip.dart';`);
    if (!lines.some((l) => /premium\/feedback\/alert_banner\.dart/.test(l))) need.push(`import '../dart-ui-bs/premium/feedback/alert_banner.dart';`);
    lines.splice(lastImp + 1, 0, ...need);
    const ret = lines.findIndex((l) => /^\s+return DsScaffold\(/.test(l));
    const ch = ret >= 0 ? lines.findIndex((l, i) => i > ret && /^\s+children: \[/.test(l)) : -1;
    if (ch >= 0) {
      const ind = (lines[ch].match(/^\s+/) || [''])[0] + '  ';
      lines.splice(ch + 1, 0,
        `${ind}// ═══ הגרעין-מהסכמה (G6c): ${E}Core — מצבים חצובים ⊕ מעבר מאטום-המדף ⊕ חוקים/ערוצים — לא מומצא, לא מצויר-ביד ═══`,
        `${ind}DsSection(title: '🧠 מחזור-חיים · \${${E}Core.term} (גרעין)', children: [`,
        `${ind}  Wrap(spacing: 6, runSpacing: 6, children: [for (final s in ${E}Core.states) StatusChip(label: s, tone: s == ${E}Core.states.first ? 1 : 0)]),`,
        `${ind}  AlertBanner(message: 'הבא אחרי \${${E}Core.states.first}: \${${E}Core.next(${E}Core.states.first) ?? 'סופי'} · \${${E}Core.rules.length} חוקים · \${${E}Core.channels.length} ערוצים · \${${E}Core.relations.length} יחסים', tone: 0, glyph: '🧠'),`,
        `${ind}]),`);
    }
    // G6d · על הרשומה: פנקס-מצבים לפי id (overlay — הזרע const, לא כותבים אליו) + מקטע בפאנל-הרשומה (_openPanel) שמציג את מצב-הרשומה, המעבר מאטום-המדף וכפתור-קידום שכותב לפנקס
    const stHead = lines.findIndex((l) => new RegExp(`^class _${E}ScreenState extends State<${E}Screen> \\{`).test(l));
    if (stHead >= 0) lines.splice(stHead + 1, 0, `  final Map<String, String> _coreState = {}; // G6d · פנקס-מצבי-הגרעין לפי id — overlay על הזרע (הזרע const; אין כתיבה אליו)`);
    const pn = lines.findIndex((l) => /^\s+void _openPanel\(Map<String, dynamic> \w+\) \{/.test(l));
    if (pn >= 0) {
      const pv = lines[pn].match(/Map<String, dynamic> (\w+)\)/)[1];
      const hasAct = lines.slice(pn, pn + 14).some((l) => /void act\(/.test(l));
      const ch = lines.findIndex((l, i) => i > pn && i < pn + 60 && /children: \[/.test(l));
      if (ch >= 0) {
        const ind = (lines[ch].match(/^\s+/) || [''])[0] + '  ';
        const apply = hasAct ? `act(() => _coreState['\${${pv}['id']}'] = nx)` : `setState(() => _coreState['\${${pv}['id']}'] = nx)`;
        lines.splice(ch + 1, 0,
          `${ind}// ═══ הגרעין על הרשומה (G6d): מצב-הרשומה ⊕ ${E}Core.next ⊕ פנקס-overlay — מצב שאינו במחזור-החיים החצוב מדווח כפער, לא מתוקן בשקט ═══`,
          `${ind}Builder(builder: (_) {`,
          `${ind}  final cur = _coreState['\${${pv}['id']}'] ?? '\${${pv}['status'] ?? ${E}Core.states.first}';`,
          `${ind}  if (!${E}Core.states.contains(cur)) return AlertBanner(message: 'מצב הרשומה "\$cur" אינו במחזור-החיים החצוב (\${${E}Core.states.join('→')}) — פער זרע/סכמה, מקום-שמור', tone: 3, glyph: '🧠');`,
          `${ind}  final nx = ${E}Core.next(cur);`,
          `${ind}  return DsSection(title: '🧠 מחזור-חיים · רשומה (גרעין)', children: [`,
          `${ind}    Wrap(spacing: 6, runSpacing: 6, children: [for (final st in ${E}Core.states) StatusChip(label: st, tone: st == cur ? 1 : 0)]),`,
          `${ind}    AlertBanner(message: nx == null ? 'מצב-סופי: \$cur' : 'הבא אחרי \$cur: \$nx', tone: 0, glyph: '🧠'),`,
          `${ind}    SoftButton(label: nx == null ? 'אין מעבר' : 'קדם מצב ⇒ \$nx', onTap: nx == null ? null : () => ${apply}),`,
          `${ind}  ]);`,
          `${ind}}),`);
        if (!lines.some((l) => /premium\/actions\/soft_button\.dart/.test(l))) { const li = lines.reduce((a, l, i) => (/^import '/.test(l) ? i : a), -1); lines.splice(li + 1, 0, `import '../dart-ui-bs/premium/actions/soft_button.dart';`); }
      }
    }
    code = lines.join('\n');
  }
  // G5h · חוזה-העמודות של הישות (חוק-7): שדות-הישות שלא קיבלו מקור נוספים ל-columnDefs כ-{'key','label'} — עמודה שמאירה רק כשהנתון מגיע (colShown); תווית = שם-השדה (הצבה גלויה — אין מונחי-שדה על המדף)
  let columnsAdded = 0, reservedKeys = [];
  {
    const q = (v) => `'${String(v).replace(/\\/g, '\\\\').replace(/'/g, "\\'")}'`;
    const lines = code.split('\n');
    const ci = lines.findIndex((l) => /^\s+static final List<Map<String, Object\?>> columnDefs = <Map<String, Object\?>>\[/.test(l));
    if (ci >= 0 && unusedFields.length) {
      const ind = (lines[ci].match(/^\s+/) || [''])[0] + '  ';
      const mappedDst = new Set(map.filter((x) => x.dst).map((x) => x.dst));
      const add = unusedFields.filter((f) => !mappedDst.has(f) && !/\[\]$/.test(FIELDS.find((x) => x.e === entity && x.n === f)?.t || '')).map((f) => `${ind}{'key': ${q(f)}, 'label': ${q(f)}}, // G5h · מקום-שמור: שדה-${entity} מהסכמה (${FIELDS.find((x) => x.e === entity && x.n === f)?.t || '?'}) — מאיר כשהנתון מוזרם`);
      if (add.length) { lines.splice(ci + 1, 0, `${ind}// ═══ חוזה-העמודות של ${entity} (G5h · חוק-7): ${add.length} שדות-סכמה בלי מקור בזרע — עמודות-מקום-שמור, לא מזויפות ולא מושמטות ═══`, ...add); columnsAdded = add.length; reservedKeys = unusedFields.filter((f) => !mappedDst.has(f) && !/\[\]$/.test(FIELDS.find((x) => x.e === entity && x.n === f)?.t || '')); }
    }
    code = lines.join('\n');
  }
  // G9b · תפר-עובדות ציבורי: <E>Facts — נגזרות-אמת של דאטה-המודול לרכזת-האפליקציה (§20-ג: כל ערך = ביטוי חי על הזרע/המנועים, אפס ליטרל-מומצא):
  //   count = אורך הזרע-הראשי (static-const · seed-db · nested-arg — לפי צורת-ההצהרה; לא נמצא ⇒ אין count, מדווח) · metrics = כל BareStat/StatHero של הזהב שערכו getter-סטטי מספרי של מחלקת-הדאטה (מפתח·תווית·טון, אחרי החלפת-מונחים)
  //   hero = המדד הראשון שהזהב צובע-סכנה כשאינו-אפס (inkColor: X > 0 ? _danger) — עובדת-מבנה מהקוד, לא מילון; אין כזה ⇒ המדד הראשון; אין מדדים ⇒ count.
  let facts = null;
  {
    const lines = code.split('\n');
    const clsAt = (i) => { for (let j = i; j >= 0; j--) { const m = /^(?:abstract\s+)?class\s+(\w+)/.exec(lines[j]); if (m) return m[1]; } return null; };
    const pn = pk.name; let countExpr = null, countHow = null;
    if (pn) {
      const a = lines.findIndex((l) => new RegExp(`^\\s+static const ${pn} = <Map<String, dynamic>>\\[`).test(l));
      if (a >= 0) { countExpr = `${clsAt(a)}.${pn}.length`; countHow = 'static-const'; }
      else {
        const b = lines.findIndex((l) => new RegExp(`^\\s+'${pn}': (?:<Map<String, dynamic>>)?\\[`).test(l));
        if (b >= 0) {
          const c = clsAt(b), dbi = lines.findIndex((l) => /^\s+static Map<String, dynamic> db = seed\(\);/.test(l));
          if (dbi >= 0 && clsAt(dbi) === c) { countExpr = `((${c}.db['${pn}'] as List?)?.length ?? 0)`; countHow = 'seed-db'; }
          else {
            let arg = null, inst = null;
            for (let j = b; j >= 0; j--) { const m1 = /^\s+(\w+): \[$/.exec(lines[j]); if (m1 && !arg) arg = m1[1]; const m2 = /^\s+static const (\w+) = (\w+)\($/.exec(lines[j]); if (m2) { inst = m2; break; } }
            if (arg && inst && lines.some((l) => new RegExp(`^\\s+final List<Map<String, dynamic>> ${arg};`).test(l))) { countExpr = `${inst[2]}.${inst[1]}.${arg}.fold<int>(0, (n, m) => n + ((m['${pn}'] as List?)?.length ?? 0))`; countHow = 'nested-arg'; }
          }
        }
      }
    }
    const numGetters = new Set([...code.matchAll(/^\s+static (?:int|double|num) get (\w+)/gm)].map((m) => m[1]));
    const metrics = [], byKey = new Map();
    for (const m of code.matchAll(/(BareStat|StatHero)\(value: '(\$\{(_\w+)\.(\w+)\}[^'\n]*)', label: '([^'\n]*)'(, inkColor: \3\.\4 > 0 \? _danger)?/g)) {
      if (!numGetters.has(m[4])) continue;
      const row = { key: m[4], value: m[2], label: m[5], tone: m[6] ? 'danger' : 'plain', atom: m[1], isHero: m[1] === 'StatHero' };
      const prev = byKey.get(m[4]);
      if (!prev) { byKey.set(m[4], row); metrics.push(row); }
      else { if (prev.atom === 'StatHero' && row.atom === 'BareStat') { prev.label = row.label; prev.tone = row.tone; prev.value = row.value; } if (row.isHero) prev.isHero = true; if (row.tone === 'danger') prev.tone = 'danger'; }
    }
    // הזהב הכריז על ה-hero שלו (StatHero = "המטרה") ⇒ הוא ה-hero; אחרת המדד הראשון שנצבע-סכנה כשאינו-אפס; אחרת הראשון; אחרת count
    const hero = metrics.find((x) => x.isHero) || metrics.find((x) => x.tone === 'danger') || metrics[0] || null;
    const heroHow = !hero ? 'אין מדדים ⇒ count' : hero.isHero ? 'ה-StatHero של הזהב (המטרה המוצהרת)' : hero.tone === 'danger' ? 'המדד הראשון שהזהב צובע-סכנה כשאינו-אפס' : 'אין StatHero/מדד-סכנה ⇒ המדד הראשון';
    const qd = (v) => `'${String(v).replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\$/g, '\\$')}'`;
    const dt = termsFor(entity), label = dt ? (dt.plural || dt.singular) : E;
    // G10a · שורות-המדד: getter בצורת `X.where(P).length` (where יחיד, בלי חיבור/חיסור) ⇒ `rowsOf_<key>` = אותו ביטוי עם toList — נשתל ליד ה-getter (אותו scope, P מילה-במילה); הרכזת קופצת לרשומה-הראשונה של ה-hero
    const rowsOfKeys = [];
    {
      const ls = code.split('\n');
      for (const mt of metrics) {
        const gi = ls.findIndex((l) => new RegExp(`^\\s+static int get ${mt.key} => `).test(l));
        if (gi < 0) continue;
        const body = ls[gi].replace(/^\s+static int get \w+ => /, '').replace(/;\s*(\/\/.*)?$/, '');
        const m = /^(.+)\.where\((.+)\)\.length$/.exec(body);
        if (!m || (body.match(/\.where\(/g) || []).length !== 1 || /\.length\s*[+\-*\/]/.test(body) || /[+\-*\/]\s*\S+\.where\(/.test(body)) continue;
        const ind = (ls[gi].match(/^\s+/) || [''])[0];
        ls.splice(gi + 1, 0, `${ind}static List<Map<String, dynamic>> get rowsOf_${mt.key} => ${m[1]}.where(${m[2]}).cast<Map<String, dynamic>>().toList(); // G10a · שורות-המדד ${mt.key} (מהצורה של ה-getter, לא מילון)`);
        rowsOfKeys.push({ key: mt.key, cls: clsAt(gi) });
      }
      code = ls.join('\n');
    }
    const idKey = (map.find((x) => x.src === 'id') || {}).dst || 'id';
    let seedSeam = null;
    if (countHow === 'seed-db' && new RegExp(`^\\s+const ${E}Screen\\(\\{[^)]*this\\.db\\b`, 'm').test(code) && /static Map<String, dynamic> seed\(\) =>/.test(code)) {
      const ls = code.split('\n'); const di = ls.findIndex((l) => /^\s+static Map<String, dynamic> db = seed\(\);/.test(l));
      const bi = ls.findIndex((l) => /^\s+static List<Map<String, dynamic>> _build\(\) \{/.test(l));
      let rowList = null;
      if (bi >= 0) { for (let j = bi + 1; j < Math.min(ls.length, bi + 12) && !/^\s+\}\s*$/.test(ls[j]); j++) { const m = /for \(final \w+ in \((\w+)\['(\w+)'\] as List\)/.exec(ls[j]); if (m && m[1] !== 'db') { rowList = m[2]; break; } } }
      // בורר-המבט שמגלה את הטבלה: `if (_mode == N)` לפני `_table(` + ה-SegmentedSwitch שבוחר `_mode` ⇒ תווית-המבט (עובדת-מבנה של הזהב; הבדיקה מקישה עליה לפני שהיא מחפשת עמודות)
      let tableLabel = null;
      const ti = ls.findIndex((l, k) => /_table\(/.test(l) && k > 0 && /_mode == (\d+)\)/.test(ls[k - 1]));
      if (ti > 0) { const n = +/_mode == (\d+)\)/.exec(ls[ti - 1])[1]; const sw = ls.find((l) => /SegmentedSwitch\(items: const \[([^\]]+)\], selected: _mode/.test(l)); if (sw) { const items = [...(/SegmentedSwitch\(items: const \[([^\]]+)\], selected: _mode/.exec(sw)[1]).matchAll(/'([^']*)'/g)].map((m) => m[1]); tableLabel = items[n] || null; } }
      seedSeam = { cls: clsAt(di), list: pn, rowList, tableLabel };
    }
    const rowsExpr = !countExpr ? null : countHow === 'static-const' ? countExpr.replace(/\.length$/, '')
      : countHow === 'seed-db' ? countExpr.replace(/^\(\((.+) as List\?\)\?\.length \?\? 0\)$/, '(($1 as List?) ?? const []).cast<Map<String, dynamic>>()')
      : countExpr.replace(/\.fold<int>\(0, \(n, m\) => n \+ \(\(m\['(\w+)'\] as List\?\)\?\.length \?\? 0\)\)$/, ".expand((m) => ((m['$1'] as List?) ?? const []).cast<Map<String, dynamic>>()).toList()");

    const F = `${E}Facts`;
    const out = ['', `// ═══ תפר-עובדות ציבורי (G9b · לרכזת-האפליקציה): ${F} — נגזרות-אמת של דאטה-המודול; כל ערך = ביטוי חי על הזרע/המנועים (§20-ג), אפס ליטרל-מומצא. מחולל: retarget.mjs ═══`,
      `class ${F} {`, `  static const String entity = ${qd(entity)};`,
      `  static const String label = ${qd(label)}; // ${dt ? 'מונח-הישות מ-entity-terms (דאטה)' : 'אין מונח ב-TERM_DEFS ⇒ שם-הישות (הצבה גלויה)'}`,
      countExpr ? `  static int get count => ${countExpr}; // רשומות הזרע-הראשי "${pn}" (${countHow})` : `  // count: הזרע-הראשי "${pn || '—'}" לא נמצא בצורת-הצהרה מוכרת — אין count (לא מומצא)`,
      `  static const List<Map<String, String>> metricDefs = <Map<String, String>>[${metrics.map((x) => `{'key': ${qd(x.key)}, 'label': ${qd(x.label)}, 'tone': ${qd(x.tone)}}`).join(', ')}]; // ${metrics.length} מדדים חצובים משורת-ה-KPI של הזהב (BareStat/StatHero ⇐ getter-סטטי מספרי)${metrics.length ? '' : ' — אין getter-סטטי בשורת-ה-KPI ⇒ ריק, לא מומצא'}`,
      `  static Map<String, String> get metrics => <String, String>{${metrics.map((x) => `${qd(x.key)}: '${x.value}'`).join(', ')}};`,
      `  static const String heroKey = ${qd(hero ? hero.key : 'count')}; // ${heroHow}`,
      `  static String get hero => metrics[heroKey] ?? ${countExpr ? "'$count'" : "'—'"};`,
      `  static String get heroLabel => ${hero ? qd(hero.label) : 'label'};`,
      ...(rowsExpr ? [`  static const String idKey = ${qd(idKey)}; // מפתח-המזהה בזרע (אחרי retarget)`,
        `  static List<Map<String, dynamic>> get rows => ${rowsExpr}; // כל רשומות הזרע-הראשי (${countHow})`,
        `  static Map<String, dynamic>? byId(String id) { for (final r in [for (final k in const <String>[${rowsOfKeys.map((x) => qd(x.key)).join(', ')}]) ...heroRows(k), ...rows]) { if ('${'$'}{r[idKey] ?? r['id']}' == id) return r; } return null; } // שורות-המדד קודם (הן מסוג-הרשומה שהפאנל צורך — בזהב-התלמידים הפאנל פותח תלמיד, הזרע-הראשי-לפי-מפתחות הוא families), ואז הזרע-הראשי`] : [`  // rows/byId: אין זרע-ראשי בצורה מוכרת ⇒ אין תפר-כניסה לפי מזהה`]),
      `  static List<Map<String, dynamic>> heroRows(String key) { switch (key) { ${rowsOfKeys.map((x) => `case ${qd(x.key)}: return ${x.cls}.rowsOf_${x.key};`).join(' ')} default: return const []; } } // G10a · ${rowsOfKeys.length} מדדים עם שורות (צורת X.where(P).length)`,
      rowsExpr ? `  static String? get heroFirstId { final r = heroRows(heroKey); return r.isEmpty ? null : '${'$'}{r.first[idKey]}'; } // הרשומה-הראשונה של ה-hero — יעד-הקפיצה מהרכזת` : `  static String? get heroFirstId => null;`,
      ...(seedSeam ? [`  // G10b-ב · תפר-הזרקה (חוק-6: הדאטה מוזרקת, לא מומצאת): seed() = זרע-ההצבה של הזהב · seedList/rowList = היכן רשומת-המסך חיה (מצורת _build()) · reservedColumns = עמודות-מקום-שמור של G5h`,
        `  static Map<String, dynamic> seed() => ${seedSeam.cls}.seed();`,
        `  static const String seedList = ${qd(seedSeam.list)};`,
        `  static const String? rowList = ${seedSeam.rowList ? qd(seedSeam.rowList) : 'null'}; // null ⇒ רשומת-המסך = רשומת-הזרע עצמה`,
        `  static const List<String> reservedColumns = <String>[${reservedKeys.map(qd).join(', ')}];`,
        `  static const String? tableView = ${seedSeam.tableLabel ? qd(seedSeam.tableLabel) : 'null'}; // תווית-המבט שמגלה את הטבלה (null ⇒ הטבלה תמיד גלויה)`] : []),
      '}', ''];
    // G10a · תפר-כניסה: `<E>Screen(initialPanelId: id)` ⇒ הכרטיס נפתח אחרי הפריים-הראשון — צורת initialPanel של זהב-המורים; מודול שכבר נושא initialPanel (מהזהב) שומר אותו
    let entrySeam = null;
    if (rowsExpr && /void _openPanel\(Map<String, dynamic> \w+/.test(code)) {
      const ls = code.split('\n');
      const ci = ls.findIndex((l) => new RegExp(`^\\s+const ${E}Screen\\(\\{`).test(l));
      if (ci >= 0 && /this\.initialPanel\b/.test(ls[ci])) entrySeam = 'initialPanel';
      else if (ci >= 0) {
        ls[ci] = ls[ci].replace(`const ${E}Screen({`, `const ${E}Screen({this.initialPanelId, `);
        ls.splice(ci + 1, 0, `  final String? initialPanelId; // G10a · תפר-כניסה: מזהה-רשומה שכרטיסה נפתח אחרי הפריים-הראשון (צורת initialPanel של זהב-המורים; הרכזת קופצת לרשומת-ה-hero)`);
        const si = ls.findIndex((l) => new RegExp(`^class _${E}ScreenState extends State<${E}Screen>`).test(l));
        if (si >= 0) {
          const open = [`    final p0 = widget.initialPanelId == null ? null : ${F}.byId(widget.initialPanelId!); // G10a`,
            `    if (p0 != null) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _openPanel(p0); });`];
          let ii = -1; for (let j = si + 1; j < ls.length && !/^class /.test(ls[j]); j++) if (/^\s+void initState\(\) \{/.test(ls[j])) { ii = j; break; }
          if (ii >= 0) { const sup = ls.findIndex((l, k) => k > ii && /^\s+super\.initState\(\);/.test(l)); ls.splice(sup + 1, 0, ...open); }
          else ls.splice(si + 1, 0, '  @override', '  void initState() {', '    super.initState();', ...open, '  }');
          entrySeam = 'initialPanelId';
        }
      }
      code = ls.join('\n');
    }
    // G10b · סינון-לפי-מדד: `<E>Screen(initialMetric: key)` ⇒ הטבלה מסוננת לשורות-המדד (rowsOf_<key>) + AlertBanner "מסונן למדד" עם N/כולל + כפתור-ביטול — נשתל על שורת `final visible = …;` היחידה של build (צורה אחידה ב-9 הזהבים) ואחרי `children: [` של ה-DsScaffold הראשי (העוגן של G6c)
    let metricSeam = false;
    if (rowsOfKeys.length && /^\s+final visible = .+;\s*(\/\/.*)?$/m.test(code) && /import '\.\.\/dart-ui-bs\/premium\/feedback\/alert_banner\.dart'/.test(code)) {
      const ls = code.split('\n');
      const ci = ls.findIndex((l) => new RegExp(`^\\s+const ${E}Screen\\(\\{`).test(l));
      const si = ls.findIndex((l) => new RegExp(`^class _${E}ScreenState extends State<${E}Screen>`).test(l));
      const vi = ls.findIndex((l) => /^\s+final visible = .+;\s*(\/\/.*)?$/.test(l));
      const stHead = si >= 0 ? ls.findIndex((l, k) => k > si && /^\s+(void initState\(\) \{|@override)/.test(l)) : -1;
      if (ci >= 0 && si >= 0 && vi > si && stHead > si) {
        ls[ci] = ls[ci].replace(`const ${E}Screen({`, `const ${E}Screen({this.initialMetric, `);
        ls.splice(ci + 1, 0, `  final String? initialMetric; // G10b · תפר-סינון: מפתח-מדד (${F}.metricDefs) ⇒ הטבלה מסוננת לשורות-המדד; null ⇒ ביט-זהה`);
        // state field + init (initState exists by now — G10a created it when missing; if the module carried its own, splice after super.initState())
        const ii = ls.findIndex((l, k) => k > si && /^\s+void initState\(\) \{/.test(l));
        const sup = ii >= 0 ? ls.findIndex((l, k) => k > ii && /^\s+super\.initState\(\);/.test(l)) : -1;
        if (sup >= 0) ls.splice(sup + 1, 0, `    _metric = widget.initialMetric != null && ${F}.heroRows(widget.initialMetric!).isNotEmpty ? widget.initialMetric : null; // G10b · מדד בלי שורות ⇒ אין סינון (לא טבלה-ריקה בשקט)`);
        else ls.splice(si + 1, 0, '  @override', '  void initState() {', '    super.initState();', `    _metric = widget.initialMetric != null && ${F}.heroRows(widget.initialMetric!).isNotEmpty ? widget.initialMetric : null; // G10b`, '  }');
        ls.splice(si + 1, 0, `  String? _metric; // G10b · המדד הנעול (null = ללא סינון-מדד)`);
        const vi2 = ls.findIndex((l) => /^\s+final visible = .+;\s*(\/\/.*)?$/.test(l));
        const vl = ls[vi2], ind = (vl.match(/^\s+/) || [''])[0];
        ls[vi2] = vl.replace(/final visible = /, 'final visibleAll = ');
        ls.splice(vi2 + 1, 0, `${ind}final visible = _metric == null ? visibleAll : visibleAll.where((r) => ${F}.heroRows(_metric!).any((h) => '${'$'}{h[${F}.idKey] ?? h['id']}' == '${'$'}{r[${F}.idKey] ?? r['id']}')).toList(); // G10b · סינון-לפי-מדד (זהות לפי מזהה — שורות-המדד וטבלת-המסך אותו סוג-רשומה, L66)`);
        // banner after the main DsScaffold children: [ (first `children: [` after the `return DsScaffold(` that follows visible)
        const ri = ls.findIndex((l, k) => k > vi2 && /^\s+return DsScaffold\($/.test(l));
        const chi = ri >= 0 ? ls.findIndex((l, k) => k > ri && /^\s+children: \[\s*$/.test(l)) : -1;
        if (chi >= 0) {
          const bind = (ls[chi].match(/^\s+/) || [''])[0] + '  ';
          ls.splice(chi + 1, 0,
            `${bind}// ═══ סינון-לפי-מדד (G10b): הרכזת שלחה מדד ⇒ הטבלה מוגבלת לשורותיו; הבאנר = עובדת-הסינון, הכפתור מסיר ═══`,
            `${bind}if (_metric != null) AlertBanner(glyph: '🎯', tone: 1, message: 'מסונן למדד: ${'$'}{${F}.metricDefs.firstWhere((d) => d['key'] == _metric, orElse: () => const {'label': ''})['label']} · ${'$'}{visible.length} מתוך ${'$'}{visibleAll.length}'),`,
            `${bind}if (_metric != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: SoftButton(label: '✖ בטל סינון-מדד', tone: 2, onTap: () => setState(() => _metric = null))),`);
          metricSeam = true;
        } else { ls[vi2] = vl; ls.splice(vi2 + 1, 1); } // אין עוגן ⇒ מחזירים את visible המקורי (בלי סינון חלקי)
        if (!metricSeam) { /* undo constructor/state splices is complex; keep seam inert (no filtering) */ }
      }
      code = ls.join('\n');
    }
    if (metricSeam && !/import '\.\.\/dart-ui-bs\/premium\/actions\/soft_button\.dart'/.test(code)) {
      const ls = code.split('\n'); const li = ls.reduce((a, l, i) => (/^import '/.test(l) ? i : a), -1);
      ls.splice(li + 1, 0, `import '../dart-ui-bs/premium/actions/soft_button.dart'; // G10b · כפתור-ביטול סינון-מדד`); code = ls.join('\n');
    }
    code = code.replace(/\n*$/, '\n') + out.join('\n');
    facts = { cls: F, label, count: countExpr ? { expr: countExpr, how: countHow, list: pn } : null, metrics: metrics.map(({ key, label, tone }) => ({ key, label, tone })), heroKey: hero ? hero.key : 'count', heroHow, rowsOf: rowsOfKeys.map((x) => x.key), entrySeam, metricSeam, coreWired, seedSeam: seedSeam ? { list: seedSeam.list, rowList: seedSeam.rowList, reserved: reservedKeys, tableLabel: seedSeam.tableLabel } : null };
  }
  const skinned = skin ? skinPass(code, skin) : null; if (skinned) code = skinned.code;   // G12c
  const n = (how) => map.filter((x) => x.how.startsWith(how)).length;
  const header = [`// 🎯 ${E}Screen — retarget של ${module} לישות ${entity} (GENMAX·G5c/G5d · הכרעה-24) · מחולל דטרמיניסטי: retarget.mjs --module ${module} --entity ${entity}`,
    `//   זרע-ראשי: ${pk.name} (מועמדים: ${(pk.candidates || []).join(' ')}) · מיפוי שם ${n('name')} · ערוץ ${n('chan')} · טיפוס-יחיד ${n('unique')} · מקום-שמור ${n('reserved')} · חוזה-מנוע (לא משתנה) ${n('engine-contract')}`,
    `//   ${map.map((x) => `${x.src}⇒${x.dst || '∅'}(${x.how})`).join(' · ')}`,
    ...(skinned ? [`//   עור-forge (G12c/e): BareStat⇒${skin.stat ? `${skin.stat.cls} ×${skinned.stats.stat || 0} (ב-Wrap) · ×${skinned.stats.statRow || 0} (ב-Row, Expanded)` : '—'} · פנימיים: ${['button', 'statusChip', 'banner', 'emptyState', 'mediaRow'].map((r) => `${r}×${skinned.stats[r] || 0}`).join(' ')} · StatHero⇒${skin.hero ? `${skin.hero.cls} ×${skinned.stats.hero || 0}` : '—'} · KpiTile⇒${skin.kpi ? `${skin.kpi.cls} ×${skinned.stats.kpi || 0}` : '—'} · DsNavTile⇒${skin.navTile ? `${skin.navTile.cls} ×${skinned.stats.navTile || 0}` : '—'} — fields לפי תפקידי-חריצים; צבעי-מצב-DS לא מועברים`] : []),
    `//   תפר-עובדות (G9b): ${facts.cls} · count=${facts.count ? `${facts.count.list}.length (${facts.count.how})` : '∅'} · מדדים ${facts.metrics.length} · hero=${facts.heroKey} · שורות-מדד (G10a) ${facts.rowsOf.length ? facts.rowsOf.join('/') : '∅'} · תפר-כניסה ${facts.entrySeam || '∅'} · תפר-סינון-מדד ${facts.metricSeam ? 'initialMetric' : '∅'} · תפר-הזרקה ${facts.seedSeam ? `db (${facts.seedSeam.list}${facts.seedSeam.rowList ? '/' + facts.seedSeam.rowList : ''} · ${facts.seedSeam.reserved.length} עמודות-שמורות)` : '∅'}`,
    `//   שדות-${entity} בלי מקור (מקום-שמור, יאירו כשיוזרם נתון): ${unusedFields.join(', ') || '—'} · תוויות: ${dstT && srcT ? `מונחי ${srcE} (${srcT.singular}/${srcT.plural || '—'}) ⇒ ${entity} (${dstT.singular}/${dstT.plural || '—'}) · ${sw.swaps} החלפות` : `אין מונח ל-${entity} ב-TERM_DEFS — תוויות של המקור (הצבה)`} · הזרע = זרע-הצבה של המקור, לא ערך-אמת של ${entity}`];
  code = header.join('\n') + '\n' + code;
  return { code, map, unusedFields, primary: pk.name, classes: clsMap, fragments: res.fragments, of: res.of, counts: { name: n('name'), chan: n('chan'), unique: n('unique'), reserved: n('reserved') }, terms: { src: srcE, dst: dstT ? dstT.singular : null, swaps: sw.swaps }, coreWired, columnsAdded, facts };
}

// ── G5e · module-picker: ישות ⇒ מודול-הזהב הקרוב ביותר — לפי עובדות-מבנה בלבד (§20-ד): (א) מספר שמות-שדה זהים בין הזרע-הראשי לסכמה · (ב) דמיון-פרופיל-טיפוסים (קוסינוס על ספירת-קטגוריות)
//   ניסוי-מדידה 4.9: G2-ops מול ops-הזהב אינם מבחינים (אוצרות-ops שונים, 20–40% אחיד, "students" תמיד) — שמות+צורה מבחינים (Family⇒students 19 · Course⇒courses 23 · Room⇒rooms 11 · Supporter⇒fees 11).
export const MODULES = ['schoolos.dart', 'schoolos_students.dart', 'schoolos_attendance.dart', 'schoolos_courses.dart', 'schoolos_teachers.dart', 'schoolos_rooms.dart', 'schoolos_fees.dart', 'schoolos_parents.dart', 'schoolos_dashboard.dart'];
const _seedCache = new Map();
const seedOf = (m) => { if (!_seedCache.has(m)) _seedCache.set(m, primaryKeys(fs.readFileSync(path.join(DIR, m), 'utf8'), m)); return _seedCache.get(m); };
const profile = (arr) => { const p = {}; for (const c of arr) p[c] = (p[c] || 0) + 1; return p; };
const cosine = (a, b) => { const ks = new Set([...Object.keys(a), ...Object.keys(b)]); let d = 0, na = 0, nb = 0; for (const k of ks) { d += (a[k] || 0) * (b[k] || 0); na += (a[k] || 0) ** 2; nb += (b[k] || 0) ** 2; } return na && nb ? d / Math.sqrt(na * nb) : 0; };
export function pickModule(entity) {
  const fields = FIELDS.filter((f) => f.e === entity); if (!fields.length) throw new Error(`ישות לא בסכמה: ${entity}`);
  const names = new Set(fields.map((f) => f.n)), ep = profile(fields.map((f) => cat(f.t)));
  const rows = MODULES.map((m) => { const pk = seedOf(m); return { module: m, seed: pk.name, names: pk.keys.filter((k) => names.has(k.key)).length, sim: +cosine(ep, profile(pk.keys.map((k) => k.type))).toFixed(3) }; })
    .sort((a, b) => b.names - a.names || b.sim - a.sim || MODULES.indexOf(a.module) - MODULES.indexOf(b.module));
  const best = rows[0];
  return { entity, module: best.module, seed: best.seed, names: best.names, sim: best.sim, fields: fields.length, confidence: +(best.names / fields.length).toFixed(2), strength: best.names >= 4 ? 'strong' : best.names >= 2 ? 'medium' : 'weak', alternatives: rows.slice(1, 3) };
}
export const ENTITIES = [...new Set(FIELDS.map((f) => f.e))].filter((e) => !/^(Db|UiPrefs|NotifPrefs|ReportPrefs|SecurityCfg)$/.test(e));   // ישויות-דומיין (לא הגדרות/מסד)
export const picksTable = () => ENTITIES.map((e) => { const p = pickModule(e); return { entity: e, module: p.module, seed: p.seed, names: p.names, sim: p.sim, fields: p.fields, confidence: p.confidence, strength: p.strength }; });

const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
const arg = (k) => { const i = process.argv.indexOf(k); return i > -1 ? process.argv[i + 1] : null; };
// 1–4: זוגות-יד (G5c/d) · 5–6: הבורר (G5e) · 7–8: מהמשפט (G5f): "מעקב חדרים ושעות"⇒Room (retarget-זהות: rooms על Room — 0 מקום-שמור) · "קופות צדקה"⇒TzBox
export const COMMITTED = [{ module: 'schoolos_rooms.dart', entity: 'Volunteer' }, { module: 'schoolos_teachers.dart', entity: 'Supporter' }, { module: 'schoolos_courses.dart', entity: 'ShopItem' }, { module: 'schoolos_students.dart', entity: 'Family' }, { module: 'schoolos_dashboard.dart', entity: 'WorkTask' }, { module: 'schoolos_fees.dart', entity: 'Donation' }, { module: 'schoolos_rooms.dart', entity: 'Room' }, { entity: 'TzBox' }];
const resolved = (c) => c.module ? c : { ...c, module: pickModule(c.entity).module };
const outName = (module, entity) => `gen_retarget_${entity.toLowerCase()}_from_${tagOf(module)}.dart`;
const PICKS = path.join(ROOT, 'machtzev/generator/retarget-picks.json');
if (isMain && process.argv.includes('--gate')) {
  const errs = [];
  // G5e: טבלת-הבחירה לכל ישויות-הדומיין ≡ טרייה (דטרמיניזם של הבורר)
  const fresh = JSON.stringify({ picks: picksTable() }, null, 1);
  if (process.argv.includes('--write')) fs.writeFileSync(PICKS, fresh); else if (!fs.existsSync(PICKS) || fs.readFileSync(PICKS, 'utf8') !== fresh) errs.push('retarget-picks.json ≠ בורר-טרי (הרץ --gate --write)');
  for (const c0 of COMMITTED) { const c = resolved(c0); const r = retarget(c); const f = path.join(DIR, outName(c.module, c.entity)); if (process.argv.includes('--write')) fs.writeFileSync(f, r.code); else if (!fs.existsSync(f) || fs.readFileSync(f, 'utf8') !== r.code) errs.push(`${path.basename(f)} ≠ retarget-טרי (הרץ --gate --write)`); }
  if (errs.length) { console.log('🔴 retarget: ' + errs.join(' · ')); process.exit(1); }
  const pt = picksTable(); const st = { strong: pt.filter((p) => p.strength === 'strong').length, medium: pt.filter((p) => p.strength === 'medium').length, weak: pt.filter((p) => p.strength === 'weak').length };
  console.log(`✓ retarget: ${COMMITTED.length} מודולים-לישות-אחרת (gen_retarget_*.dart) ≡ מחולל-דטרמיניסטי · בורר-מודול ${pt.length} ישויות (חזק ${st.strong} · בינוני ${st.medium} · חלש ${st.weak}) ≡ · הרנדר-בפועל בשער genverify`); process.exit(0);
}
if (isMain && arg('--entity') && !arg('--module')) {                // G5e: ישות בלבד ⇒ בחירת-מודול אוטומטית ⇒ retarget
  const p = pickModule(arg('--entity'));
  console.log(`🎯 בורר: ${p.entity} ⇒ ${p.module} (זרע ${p.seed} · שמות-זהים ${p.names}/${p.fields} · דמיון-צורה ${p.sim} · ${p.strength}) · חלופות: ${p.alternatives.map((a) => `${a.module}(${a.names}/${a.sim})`).join(' ')}`);
  const r = retarget({ module: p.module, entity: p.entity });
  const out = arg('--out') || path.join(DIR, outName(p.module, p.entity));
  fs.writeFileSync(out, r.code);
  console.log(`✓ ${p.entity} ⇒ ${path.basename(out)} · שם ${r.counts.name} · ערוץ ${r.counts.chan} · טיפוס-יחיד ${r.counts.unique} · מקום-שמור ${r.counts.reserved} · ${r.code.split('\n').length} שורות`);
}
if (isMain && arg('--module') && arg('--entity')) {
  const r = retarget({ module: arg('--module'), entity: arg('--entity') });
  const out = arg('--out') || path.join(DIR, outName(arg('--module'), arg('--entity')));
  fs.writeFileSync(out, r.code);
  console.log(`✓ ${arg('--module')} ⇒ ${arg('--entity')} ⇒ ${path.basename(out)} · זרע ${r.primary} · שם ${r.counts.name} · ערוץ ${r.counts.chan} · טיפוס-יחיד ${r.counts.unique} · מקום-שמור ${r.counts.reserved} · עמודות-מקום-שמור ${r.columnsAdded} · ${r.map.map((x) => `${x.src}⇒${x.dst || '∅'}`).join(' ')} · שדות-E בלי-מקור: ${r.unusedFields.join(',') || '—'} · ${r.code.split('\n').length} שורות`);
}

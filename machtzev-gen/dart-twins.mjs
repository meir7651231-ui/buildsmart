/** 🤝 רתמת-תאומי-Dart (מבצע-המאה, פאזה 1ב) — אטומים ילידי-buildsmart (מדף new/dart)
 *  שאין להם תאום-JS: הקציר קורא את קריאת-העבודה הראשונה מ-<base>_test.dart (ליטרלים
 *  בלבד — אמת-קרקע), ורושם fn ⇒ {file, tail}. ‏runDartBatch מריץ אצוות-הערכות בסקריפט-
 *  ‏Dart יחיד (import לכל הקבצים, הדפסת JSON-lines) — בר-הרצה באמת, לא הבטחה. */
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import * as R from '../root.mjs';
const ROOT = R.ROOT;
const DDIR = path.join(ROOT, 'new/dart');
// מדפי-הילידים הנקצרים + מדף-הדאטה התואם לכל אחד (מנוע-מפלצת: גם dart-maor, לא רק dart)
const SHELVES = new Set(['new/dart', 'new/dart-maor']);
const dataDirOf = (shelf) => shelf === 'new/dart-maor' ? 'new/dart-data-maor' : 'new/dart-data';
const DART = (() => {                                                // פתרון-Dart עמיד (L34): env → sdk-בית → flutter → PATH
  const cands = [process.env.DART_BIN, process.env.HOME && path.join(process.env.HOME, 'dart-sdk/bin/dart'),
    '/root/dart-sdk/bin/dart', '/home/user/flutter/bin/dart',
    '/tmp/claude-0/-home-user/2d086046-4b60-52a1-9aee-58e2962b1958/scratchpad/dart-sdk/bin/dart'].filter(Boolean);
  for (const c of cands) { try { if (fs.existsSync(c)) return c; } catch { } }
  return 'dart';                                                     // נפילה ל-PATH (execFileSync יפתור)
})();
const FEEDABLE0 = /^(String|dynamic|Object|num|int|double)\??$/;
// קבוצת-האימות-החי: שמות-פונקציות עם arg0-קבוע שהוכחו-רצים בהרצת-Dart מבודדת (proof-record,
// מחודש ע"י machtzev/verify-dart-arg0.mjs). חסר-קובץ ⇒ קבוצה-ריקה ⇒ arg0Fixed לא-נספר (שמרני, בלי חלול).
const ARG0_VERIFIED = (() => {
  try { return new Set(JSON.parse(fs.readFileSync(path.join(ROOT, 'machtzev/generator/knowledge/dart-arg0-verified.json'), 'utf8'))); }
  catch { return new Set(); }
})();

const balance = (s, start) => {
  let d = 1, q = null;
  for (let j = start; j < s.length; j++) {
    const ch = s[j];
    if (q) { if (ch === '\n') q = null; else if (ch === '\\') j++; else if (ch === q) q = null; continue; }
    if (ch === "'" || ch === '"') { q = ch; continue; }
    if (ch === '(') d++;
    else if (ch === ')') { d--; if (!d) return j; }
  }
  return -1;
};
const splitTop = (s) => {
  const out = []; let d = 0, q = null, cur = '';
  for (let j = 0; j < s.length; j++) {
    const ch = s[j];
    if (q) { cur += ch; if (ch === '\\') { cur += s[j + 1] ?? ''; j++; } else if (ch === q) q = null; continue; }
    if (ch === "'" || ch === '"') { q = ch; cur += ch; continue; }
    if ('([{<'.includes(ch)) d++;
    if (')]}>'.includes(ch)) d--;
    if (ch === ',' && d === 0) { out.push(cur.trim()); cur = ''; continue; }
    cur += ch;
  }
  if (cur.trim()) out.push(cur.trim());
  return out;
};
// ליטרל-Dart בלבד (מחרוזת/מספר/בוליאני/null/const-אוסף של אלה) — שום מזהה
const isLit = (a) => /^('(?:[^'\\]|\\.)*'|-?\d[\d._]*|true|false|null|const\s*[\[{].*[\]}]|[\[{].*[\]}])$/s.test(a.trim());
// מפת-ייבוא של קובץ-בדיקה: alias ⇒ נתיב-מוחלט (רק אטומי-דאטה = ../dart-data*/)
const importAliases = (tt, ddir) => {
  const map = new Map();
  for (const m of tt.matchAll(/import\s+'([^']+)'\s+as\s+(\w+)\s*;/g)) {
    if (!/dart-data/.test(m[1])) continue;
    map.set(m[2], path.resolve(ddir, m[1]));
  }
  return map;
};
// זנב בר-הזנה: ליטרל, או הפניה לאטום-דאטה מיובא (‏alias.name / name: alias.name).
// מחזיר {ok, deps:[{alias,abs}]} — deps נדרשים ל-import בסקריפט-האצווה.
const tailResolvable = (arg, aliases) => {
  const body = arg.replace(/^\s*\w+\s*:\s*/, '').trim();          // הסרת קידומת-שמית
  if (isLit(body)) return { ok: true, deps: [] };
  const deps = [];
  let ok = true;
  // מזהים-מקומיים מותרים: פרמטרי-closure (`(k)=>…` / `(a,b)=>…`) ומילות-מפתח
  const locals = new Set(['const', 'true', 'false', 'null', 'return']);
  for (const am of body.matchAll(/\(([\w,\s]*)\)\s*=>/g))
    for (const p of am[1].split(',')) { const n = p.trim(); if (n) locals.add(n); }
  // כל שרשרת-מזהה-מנוקדת חייבת להתחיל ב-alias-דאטה מוכר; מזהה-חופשי לא-מקומי ⇒ לא-פתיר
  for (const idm of body.matchAll(/(?<![\w.$])([A-Za-z_$][\w$]*)\b/g)) {
    const id = idm[1];
    if (locals.has(id)) continue;
    const after = body[idm.index + id.length];
    if (after === '.') { if (aliases.has(id)) deps.push({ alias: id, abs: aliases.get(id) }); else ok = false; }
    else if (body[idm.index - 1] !== '.') ok = false;             // מזהה-חופשי (לא חבר-שרשרת) ⇒ לא-פתיר
  }
  return { ok: ok && deps.length > 0, deps };
};

/** קציר: fn ⇒ {file, tail, params, imports} עבור מנועי-new/dart ברי-הזנה */
export function harvestDartTwins(functions, { allArg0 = false } = {}) {  // allArg0: עוקף שער-האימות (בוטסטרפ ל-verify)
  const out = new Map();
  for (const f of functions) {
    if (!SHELVES.has(f.shelf) || !f.params.length) continue;
    if (out.has(f.name)) continue;
    const feed0 = FEEDABLE0.test(f.params[0].type);
    const ddir = path.join(ROOT, f.shelf);                          // מדף-הילידים של-האטום (dart / dart-maor)
    const abs = path.join(ddir, path.basename(f.file));
    if (feed0 && f.params.length === 1) { out.set(f.name, { file: f.file, abs, tail: [], params: f.params, imports: [] }); continue; }
    // שקע-term יחיד: זנב דטרמיניסטי מאטום-הדאטה של-האטום (<base>-terms.dart · kTerms) —
    // גם כשהבדיקה לא קוראת לפונקציה-העוזרת ישירות (מנוע-ה-AST v3, טיהור-100%).
    const rest = f.params.slice(1);
    if (feed0 && rest.every(p => p.name === 'term' && /Function/.test(p.type))) {
      const base = path.basename(f.file).replace(/\.dart$/, '');
      const df = path.join(ROOT, dataDirOf(f.shelf), base + '-terms.dart');
      if (fs.existsSync(df)) {
        const alias = 'td_' + base.replace(/-/g, '_');
        out.set(f.name, { file: f.file, abs, tail: [`term: (k)=>${alias}.kTerms[k]!`], params: f.params, imports: [{ alias, abs: df }] });
        continue;
      }
    }
    const tp = path.join(ddir, path.basename(f.file).replace(/\.dart$/, '_test.dart'));
    if (!fs.existsSync(tp)) continue;
    const tt = fs.readFileSync(tp, 'utf8').replace(/\/\*[\s\S]*?\*\//g, '').replace(/(^|[^:])\/\/[^\n]*/g, '$1');
    const aliases = importAliases(tt, ddir);
    const re = new RegExp(`(?<![\\w.$])${f.name}\\(`, 'g');
    let m;
    while ((m = re.exec(tt))) {
      const close = balance(tt, m.index + m[0].length);
      if (close < 0) continue;
      const args = splitTop(tt.slice(m.index + m[0].length, close));
      if (args.length !== f.params.length) continue;
      const capture = feed0 ? args.slice(1) : args;
      const resolved = capture.map(a => tailResolvable(a, aliases));
      if (!resolved.every(r => r.ok)) continue;
      const imports = [...new Map(resolved.flatMap(r => r.deps).map(d => [d.alias, d])).values()];
      if (feed0) out.set(f.name, { file: f.file, abs, tail: args.slice(1), params: f.params, imports });
      else if (allArg0 || ARG0_VERIFIED.has(f.name)) out.set(f.name, { file: f.file, abs, arg0Fixed: args[0], tail: args.slice(1), params: f.params, imports });
      break;
    }
  }
  return out;
}

/** הרצת-אצווה: jobs=[{fn, input(String)}] ⇒ פלטים (String|null) — סקריפט-Dart יחיד */
export function runDartBatch(registry, jobs) {
  const esc = (s) => s.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\$/g, '\\$').replace(/\n/g, '\\n');
  const files = new Set();
  const dataImports = new Map();                                  // alias ⇒ absPath (אטומי-דאטה לשקעי-הזנב)
  const lines = [];
  jobs.forEach(({ fn, input }, i) => {
    const r = registry.get(fn);
    if (!r) { lines.push(`  print('${i}\\u0000!');`); return; }
    files.add(r.abs || path.join(ROOT, 'new/dart', path.basename(r.file)));
    for (const d of (r.imports || [])) dataImports.set(d.alias, d.abs);
    const t0 = r.params[0].type.replace(/\?$/, '');
    const arg0 = r.arg0Fixed !== undefined ? r.arg0Fixed
      : (t0 === 'num' || t0 === 'double') ? `(num.tryParse('${esc(input)}') ?? double.nan)`
      : t0 === 'int' ? `(int.tryParse('${esc(input)}') ?? 0)` : `'${esc(input)}'`;
    lines.push(`  try { print('${i}\\u0000' + ${fn}(${[arg0, ...r.tail].join(', ')}).toString()); } catch (_) { print('${i}\\u0000!'); }`);
  });
  const tmp = fs.mkdtempSync('/tmp/dtwin-');
  const imps = [
    ...[...files].map(f2 => `import '${path.relative(tmp, f2)}';`),
    ...[...dataImports].map(([alias, abs]) => `import '${path.relative(tmp, abs)}' as ${alias};`),
  ].join('\n');
  fs.writeFileSync(path.join(tmp, 'batch.dart'), `${imps}\nvoid main() {\n${lines.join('\n')}\n}\n`);
  let outs = new Array(jobs.length).fill(null);
  try {
    const res = execFileSync(DART, ['run', path.join(tmp, 'batch.dart')], { stdio: 'pipe', timeout: 120000 }).toString();
    for (const l of res.split('\n')) {
      const k = l.indexOf(' ');
      if (k > 0) { const i = +l.slice(0, k); const v = l.slice(k + 1); if (i >= 0 && i < outs.length) outs[i] = v === '!' ? null : v; }
    }
  } catch { }
  fs.rmSync(tmp, { recursive: true, force: true });
  return outs;
}

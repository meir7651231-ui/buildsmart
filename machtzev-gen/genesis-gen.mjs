#!/usr/bin/env node
/** 🧬 מחצב · המחולל (genesis-gen) — הכרעות 17+18: בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך עובד.
 *
 *  מנוע-טהור (חוק-1): אפס-דאטה בקובץ הזה. כל הידע בקבצים:
 *    knowledge/lexicon.json — מילת-צורה-בעברית ⇒ תפקיד
 *    knowledge/roles.json   — שם-מחלקה ⇒ תפקיד-צורני
 *    knowledge/tokens.json  — שם-prop-צבע ⇒ טוקן
 *    atlas.mjs              — כל האטומים: widgets + functions + data
 *
 *  ‏spec = machtzev/generator/specs/<slug>.txt — רב-שורתי:
 *    שורה 1: כותרת-המסך  ·  כל שורה אחריה: חלק אחד (מילת-צורה + תווית).
 *    תחבירים: 'בחירה X: א / ב / ג' (אופציות) · 'הירו X | תת-כותרת' · 'נתון ⚛️ 42 תווית' (ערך).
 *
 *  שימוש: node genesis-gen.mjs                  ⇒ מחולל את כל ה-specs
 *         node genesis-gen.mjs <slug> "<spec>"  ⇒ שומר spec ומחולל
 */
import fs from 'node:fs';
import path from 'node:path';
import { stripComments, snake } from '../assemble/lift-lib.mjs';
import { dartLit } from './twins.mjs';
import { buildAtlas, writeAtlas } from './atlas.mjs';
import { pickLook } from '../../new/atoms/pick-look.mjs';
import * as R from '../root.mjs';
const LOOKS = JSON.parse(fs.readFileSync((R.GEN_DIR + 'knowledge/looks.json'), 'utf8'));

const ROOT = R.ROOT;
const HERE = R.GEN_DIR;
const OUT = R.outDir();
const DATA = R.dataOutDir();
const SPECS = path.join(HERE, 'specs');

// ── הידע — נטען, לא-מוטמע ──
const LEX_RAW = JSON.parse(fs.readFileSync(path.join(HERE, 'knowledge/lexicon.json'), 'utf8'));
const LEXICON = new Map(Object.entries(LEX_RAW).filter(([k]) => !k.startsWith('_')));
const HERO_WORD = LEX_RAW._hero || '';
const NAV_WORD = LEX_RAW._nav || '';
const PIN_WORD = LEX_RAW._pin || '';
const pascalOf = (slug) => slug.replace(/(^|[_-])([a-z])/g, (_, __, c) => c.toUpperCase());
const ROLE_RULES = JSON.parse(fs.readFileSync(path.join(HERE, 'knowledge/roles.json'), 'utf8')).rules.map(r => ({ re: new RegExp(r.pattern), role: r.role }));
const TOKEN_RULES = JSON.parse(fs.readFileSync(path.join(HERE, 'knowledge/tokens.json'), 'utf8')).rules.map(r => ({ re: new RegExp(r.pattern, 'i'), token: r.token }));
const roleOf = (cls) => ROLE_RULES.find(r => r.re.test(cls))?.role || 'other';
const PURE = process.argv.includes('--pure'); // 🎨 מתג-Pure הפיך (חוק-7): מלביש את הרבנייה ב-BsPure במקום BsTokens
const TOK = PURE ? 'BsPure' : 'BsTokens';
const tokenFor = (n) => TOKEN_RULES.find(r => r.re.test(n)).token.replace('BsTokens', TOK);
const LOGIC_RULES = JSON.parse(fs.readFileSync(path.join(HERE, 'knowledge/logic-lexicon.json'), 'utf8')).rules;
let termKeyOf = new Map();
try {
  for (const t of JSON.parse(fs.readFileSync(path.join(ROOT, 'screens-seed/terms-catalog.json'), 'utf8')).terms || [])
    if (!termKeyOf.has(t.he)) termKeyOf.set(t.he, t.key);
} catch { }

const atlas = buildAtlas();
writeAtlas(atlas);
// ידע-זנבות-הקציר (נכתב ע"י רתמת-התאומים בריצת-הסינתזה; חסר ⇒ אין זנבות)
let TWIN_TAILS = {};
try { TWIN_TAILS = JSON.parse(fs.readFileSync(path.join(HERE, 'knowledge/twin-tails.json'), 'utf8')); } catch { }

// ── פירוק-בקשה: שורה ⇒ חלק {role,label,options,emoji,sub,hero,value} ──
function parsePart(txt) {
  let body = txt, options = null;
  const ci = txt.indexOf(':');
  if (ci > 0) { body = txt.slice(0, ci).trim(); options = txt.slice(ci + 1).split('/').map(s => s.trim()).filter(Boolean); }
  const em = body.match(/(\p{Extended_Pictographic}(?:️)?)/u);
  const emoji = em ? em[1] : null;
  if (emoji) body = body.replace(emoji, '').replace(/\s+/g, ' ').trim();
  let sub = null;
  const pi = body.indexOf('|');
  if (pi > 0) { sub = body.slice(pi + 1).trim(); body = body.slice(0, pi).trim(); }
  // חילוץ-ערך: רק אסימון-מספר עומד-לבדו (לא ספרה בתוך מילה — 'quest1'/'ברך 90°' נשארים שלמים),
  // ולא בשורות ניווט/אטום שבהן מספר הוא חלק מזהות (slug/שם-מחלקה)
  const firstWord = body.split(/\s+/)[0];
  // 🎨 תור-ערכים: כל האסימונים-המספריים העומדים-לבדם נאספים בסדרם — props מספריים נדרשים
  //   (done/total/pct/coins/flow) נמזגים מהם בזה-אחר-זה (עיצוב-חי, לא 0 קשיח). ניווט מוחרג (slug).
  const numRe = /(?<=^|\s)\d[\d,.]*[%+]?(?=\s|$)/g;
  const values = firstWord === NAV_WORD ? [] : [...body.matchAll(numRe)].map(mm => mm[0]);
  if (values.length) body = body.replace(numRe, ' ').replace(/\s+/g, ' ').trim();
  const value = values[0] ?? null;
  const words = body.split(/\s+/);
  // 📌 הצבעה-ישירה: 'אטום <ClassName> <תווית>' ⇒ האטום הזה בדיוק (מצב-האלתור מצביע כך)
  if (words[0] === PIN_WORD && /^[A-Z]\w+$/.test(words[1] || '')) {
    return { pin: words[1], role: roleOf(words[1]), label: words.slice(2).join(' ') || words[1], txt, options, emoji, sub, value, values };
  }
  // 📚 עיגון-דאטה: 'דאטה <ConstName> <תווית>' ⇒ chips חיים מתוכן אטום-דאטה מהמדף
  if (words[0] === 'דאטה' && /^[a-zA-Z_]\w*$/.test(words[1] || '')) {
    return { dataPin: words[1], role: 'chip', label: words.slice(2).join(' ') || words[1], txt, options, emoji, sub, value, values };
  }
  // 🔀 חיבור בין-מסכים: 'ניווט <slug> <תווית>' ⇒ כרטיס שפותח מסך-מחולל אחר
  if (words[0] === NAV_WORD && /^[a-z][a-z0-9_-]*$/.test(words[1] || '')) {
    return { role: 'card', hero: true, navSlug: words[1], label: words.slice(2).join(' ') || words[1], txt, options, emoji, sub, value, values };
  }
  return {
    role: LEXICON.get(words[0]) || 'row',
    hero: words[0] === HERO_WORD,
    label: (LEXICON.has(words[0]) ? words.slice(1) : words).join(' ') || body,
    txt, options, emoji, sub, value, values,
  };
}

// ── בחירה: האטום-הוויזואלי המנוקד-הכי-גבוה שכל ה-required שלו ניתנים-למילוי ──
const FILLABLE = /^(String|bool|int|double|Color|IconData|TextEditingController|VoidCallback|void Function\(\)|ValueChanged<(bool|int|String|TimeOfDay)>|void Function\((bool|int|String|TimeOfDay)( \w+)?\)|List<String>|EdgeInsets(Geometry)?|FontWeight|TimeOfDay|Key|Object|Future<void> Function\(\)|List<[A-Z]\w*>|List<\([^)]*\)>|\(\{[^}]*\}\))/;
const INTERACTIVE = new Set(['textfield', 'number', 'switch', 'radio', 'chip', 'button', 'slider']);
function pickAtom(part) {
  if (part.pin) return atlas.widgets.find(a => a.cls === part.pin) || null;
  let best = null, bestScore = -1;
  for (const a of atlas.widgets) {
    const role = roleOf(a.cls);
    let score = role === part.role ? 5 : role === 'row' ? 1 : 0;
    if (score === 0) continue;
    // תפקיד-אינטראקטיבי ⇒ האטום חייב יכולת-תגובה (on*) — תווית-דוממת לא משמשת שדה/מתג
    if (INTERACTIVE.has(part.role) && ![...a.types.keys()].some(n => /^on[A-Z]/.test(n))) continue;
    // עוגן-דאטה ⇒ חובה prop-אופציות List<String> (התוכן החי חייב משטח-הצגה)
    if (part.dataPin && ![...a.types.entries()].some(([n, t]) => /^(options|items)$/.test(n) && /^List<String>/.test(t.replace(/\?$/, '')))) continue;
    let fillable = true, widgetFills = 0;
    for (const rq of [...a.required, ...a.positional]) {
      const t = (a.types.get(rq) || '').replace(/\?$/, '');
      if (/^Widget\b/.test(t) || /^List<Widget>/.test(t)) { widgetFills++; continue; }
      if (/^List<\(/.test(t)) { if (!part.options?.length) { fillable = false; break; } continue; }
      if (!FILLABLE.test(t)) { fillable = false; break; }
    }
    if (!fillable) continue;
    if (part.options?.length && [...a.types.entries()].some(([n, t]) => /^(options|items)$/.test(n) && /^List</.test(t))) score += 2;
    if (part.hero && /Hero/.test(a.cls)) score += 4;
    if (part.sub && a.types.has('sub')) score += 2;
    if (a.dirty) score -= 3;                                          // חוב-טוהר ⇒ מעדיפים אטום נקי
    score -= widgetFills + 0.05 * (a.required.size + a.positional.length);
    if (score > bestScore) { bestScore = score; best = a; }
  }
  return best;
}

// ── חילול מסך אחד ──
function generate(slug, specText) {
  // שורה-מוזחת (שני-רווחים/טאב) = ענף של החלק שמעליה — חיבור אטום⇒אטום (הבורר מחליף ענפים)
  const rawLines = specText.split('\n').filter(l => l.trim());
  const lines = rawLines.map(s => s.trim().replace(/,$/, ''));
  // 🎨 שכבה E — בחירת-מראה מהמשפט (חסר=null ⇒ ברירת-מחדל ⇒ פלט ביט-זהה)
  const look = pickLook(specText, LOOKS);
  const first = lines[0];
  const oneLine = lines.length === 1;
  const rawTitle = (oneLine ? (first.includes(':') ? first.slice(0, first.indexOf(':')) : '') : first.replace(/:$/, '')).trim();
  // כותרת-AppBar נקייה: מסירים את מילת-ההירו ואת התת-כותרת (הכל אחרי '|') — משאירים
  // שם-מסך + אימוג'י בלבד ("🗂️ פרויקט"), לא את שורת-ההירו המלאה. עיצוב טהור.
  const title = (HERO_WORD ? rawTitle.replace(new RegExp('^' + HERO_WORD + '\\s*'), '') : rawTitle).replace(/\s*\|.*$/, '').trim() || rawTitle;
  const nodes = [];   // [{part, children:[part]}]
  if (oneLine) {
    for (const t of (first.includes(':') ? first.slice(first.indexOf(':') + 1) : first).split(',').map(s => s.trim()).filter(Boolean))
      nodes.push({ part: parsePart(t), children: [] });
  } else {
    for (let i = 1; i < rawLines.length; i++) {
      const indented = /^(\s{2,}|\t)/.test(rawLines[i]);
      const part = parsePart(lines[i]);
      if (indented && nodes.length) nodes.at(-1).children.push(part);
      else nodes.push({ part, children: [] });
    }
  }
  const parts = [...nodes.map(n => n.part), ...nodes.flatMap(n => n.children)];
  // 🌉 גשר-הלוגיקה: חלק-'חישוב' ⇒ קריאה חיה לאטום-לוגיקה מהמדף (מוצג כמדד).
  // סדר: כלל-מפורש מקובץ-הדעת ⇒ התאמה-אוטומטית לפי התיאור-העברי-העצמי של האטום +
  // כיול-ארגומנטים מהמשפט עצמו (מספרים · "מחרוזות" · תאריך-עכשיו). אין-התאמה ⇒ שורה כנה.
  const logicImports = new Set();
  const norm = (w) => w.replace(/^ה(?=..)/, '').replace(/[^֐-׿\w]/g, '');
  const RETS = new Set(['String', 'String?', 'int', 'double', 'num', 'bool']);
  const bindArgs = (fn, part, pendingHebArg, fieldFeed = false) => {
    const nums = [...part.txt.matchAll(/\d[\d.]*/g)].map(m => m[0]);
    const strs = [...part.txt.matchAll(/"([^"]*)"/g)].map(m => m[1]);
    // 🌾 זנב-הקציר: אמת-קרקע מבדיקת-האטום (twin-tails.json, נכתב ע"י רתמת-התאומים) —
    // פרמטרי-הזנב של מנוע רב-פרמטרי נפלטים כליטרלים ⇒ המסך שקול לתאום-ה-JS שהוכיח.
    const tailMeta = TWIN_TAILS[fn.name];
    // טוהר-המסך: מחרוזת-עברית בזנב יורדת לקובץ-התוכן (const) והליטרל מפנה אליה — אפס עברית בקוד
    const tl = (v) => {
      if (v === null) return 'null';
      if (typeof v === 'string') return /[֐-׿]/.test(v) ? pendingHebArg(v) : dartLit(v);
      if (typeof v === 'number' || typeof v === 'boolean') return dartLit(v);
      if (Array.isArray(v)) return 'const [' + v.map(tl).join(', ') + ']';
      return 'const {' + Object.entries(v).map(([k, x]) => `${tl(k)}: ${tl(x)}`).join(', ') + '}';
    };
    const tailLits = tailMeta && tailMeta.simple && tailMeta.tail.length === fn.params.length - 1 ? tailMeta.tail.map(tl) : null;
    const args = [];
    let pi = -1;
    for (const p of fn.params) {
      pi++;
      const t = p.type.replace(/\?$/, '');
      if (pi > 0 && tailLits) args.push(tailLits[pi - 1]);
      else if (t === 'DateTime') args.push('DateTime.now()');
      else if (t === 'String' && fieldFeed) args.push('__FIELD__');
      // 🔗 הזנת-שרשרת גם לפרמטר גמיש/מספרי (מנוע-הסינתזה מרכיב חוליות שקולטות מספר):
      // dynamic/Object בולעים String כמות-שהוא; num/int דרך tryParse — כשל-פרסור ⇒ NaN/0 ⇒
      // האטום עצמו מחזיר '' (כנות-תצוגה), בדיוק כמו תאום-ה-JS על קלט שבור.
      else if ((t === 'dynamic' || t === 'Object') && fieldFeed) args.push('__FIELD__');
      else if ((t === 'num' || t === 'double') && fieldFeed && !nums.length) args.push('(num.tryParse(__FIELD__) ?? double.nan)');
      else if (t === 'int' && fieldFeed && !nums.length) args.push('(int.tryParse(__FIELD__) ?? 0)');
      else if (t === 'String' && strs.length) { const s = strs.shift(); args.push(/[֐-׿]/.test(s) ? pendingHebArg(s) : `'${s.replace(/'/g, "\\'")}'`); }
      else if ((t === 'int') && nums.length) args.push(String(parseInt(nums.shift())));
      else if ((t === 'double' || t === 'num') && nums.length) args.push(nums.shift());
      else if (t === 'bool') args.push('false');
      else if (p.type.endsWith('?')) args.push('null');
      else return null;                                               // פרמטר-חובה בלי מקור ⇒ לא קוראים
    }
    return args;
  };
  // (לולאת-הגשר עצמה רצה אחרי הגדרת constFor — ראה resolveCalcParts להלן)

  const cls = 'Gen' + slug.replace(/(^|[_-])([a-z])/g, (_, __, c) => c.toUpperCase()) + 'Screen';
  const consts = [];
  const usedNames = new Set();
  const constFor = (v, purpose) => {
    let n = 'gen_' + slug + '_' + (purpose || 'text'), i = 2;
    while (usedNames.has(n)) n = 'gen_' + slug + '_' + (purpose || 'text') + i++;
    usedNames.add(n);
    consts.push([n, v]);
    return n;
  };
  const stateDecls = [];
  const imports = new Set(["import 'package:flutter/material.dart';", `import '../dart-ui-bs/auto/${PURE ? 'bs_pure_tokens' : 'bs_tokens'}.dart';`, `import '../dart-data-bs/auto/gen_${slug}_content.dart';`]);
  if (look === 'dark') imports.add("import '../dart-ui-bs/ds/ds_scale.dart';");  // 🎨 שכבה E — טוקן-כהה קיים (DsDark)
  let sIdx = 0;

  // מפת-הורים (לחיבור שדה⇒חישוב) + חיווט-ניווט בין-מסכים
  const parentOf = new Map();
  for (const n of nodes) for (const c of n.children) parentOf.set(c, n.part);
  for (const part of parts) {
    if (!part.navSlug) continue;
    imports.add(`import 'gen_${part.navSlug}.dart';`);
    part.navExpr = `() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Gen${pascalOf(part.navSlug)}Screen()))`;
  }

  // 🌉 פתרון חלקי-'חישוב' (רץ כאן — אחרי constFor, שמשרת ארגומנט-עברי דרך קובץ-התוכן)
  for (const part of parts) {
    if (part.role !== 'calc') continue;
    const pendingHebArg = (s) => constFor(s, 'calc_arg');
    const wrapCall = (f, args) => `${f.name}(${args.join(', ')})${f.ret === 'String' || f.ret === 'String?' ? '' : '.toString()'}${f.ret === 'String?' ? " ?? ''" : ''}`;
    let call = null, fnHit = null;
    // 📌 עיגון-מפורש '(fnName)' בסוף חלק-חישוב ⇒ האטום המדויק — לבקשות שהמכונה כותבת לעצמה
    const pinM = part.txt.match(/\(([a-z]\w*)\)\s*$/);
    if (pinM) {
      const pf = atlas.functions.find(f => f.name === pinM[1]);
      if (pf) {
        const args = bindArgs(pf, part, pendingHebArg, ['textfield', 'chip'].includes(parentOf.get(part)?.role));
        if (args) { fnHit = pf; call = wrapCall(pf, args); part.label = part.label.replace(/\s*\([a-z]\w*\)\s*$/, ''); }
      }
    }
    const rule = !fnHit && LOGIC_RULES.find(r => part.txt.includes(r.match));
    if (rule) { fnHit = atlas.functions.find(f => f.name === rule.fn); call = rule.call; }
    if (!fnHit) {
      // התאמה-אוטומטית: חפיפת-מילים בין הבקשה לתיאור-העצמי; רק פונקציות-ערך ניתנות-לכיול
      const words = new Set(part.label.split(/\s+/).map(norm).filter(w => w.length > 1));
      let best = null, bestScore = 1;                                 // סף: לפחות 2 מילים חופפות
      for (const f of atlas.functions) {
        if (!RETS.has(f.ret) || !f.he.length) continue;
        const overlap = f.he.filter(w => words.has(norm(w))).length;
        if (overlap > bestScore) { bestScore = overlap; best = f; }
      }
      if (best) {
        const args = bindArgs(best, part, pendingHebArg, ['textfield', 'chip'].includes(parentOf.get(part)?.role));
        if (args) { fnHit = best; call = wrapCall(best, args); }
      }
    }
    if (fnHit && call) {
      part.calcExpr = call;
      part.role = 'stat';
      imports.add(`import '../${fnHit.shelf.replace(/^new\//, '')}/${fnHit.file}';`);
    } else part.role = 'row';                                         // אין-גשר ⇒ שורה כנה, לא המצאה
  }

  // 🔗 שרשרת-חישובים: כמה ילדי-'חישוב' תחת קלט אחד ⇒ צינור אמיתי — פלט כל שלב מוזרם לבא.
  // שלב 1 ניזון מהקלט (__FIELD__); שלב N מקבל את ביטוי שלב N-1 (הביטוי תמיד String ⇒ תואם-טיפוס).
  for (const n of nodes) {
    if (!['textfield', 'chip'].includes(n.part.role)) continue;
    let prev = '__FIELD__';
    for (const c of n.children) {
      if (!c.calcExpr || !c.calcExpr.includes('__FIELD__')) continue;
      c.calcExpr = c.calcExpr.replace('__FIELD__', prev);
      prev = '(' + c.calcExpr + ')';
    }
  }

  // 🎨 תור-הערכים של החלק: כל בקשת-prop-מספרי מושכת את המספר-הבא בסדר-הכתיבה
  const nextNum = (part) => { part._vi = part._vi || 0; const v = (part.values || [])[part._vi]; if (v !== undefined) part._vi++; return v; };
  const fillProp = (a, name, part, shared) => {
    const t = (a.types.get(name) || 'String').replace(/\?$/, '');
    if (part.calcExpr && name === 'value' && t === 'String') return { expr: part.calcExpr };   // 🌉 ערך-חי ממנוע-לוגיקה
    if (name === 'value' && part.value != null && t === 'String') return { expr: constFor(nextNum(part) ?? part.value, part.role + '_value') };
    if (name === 'value' && part.value != null && t === 'int') return { expr: String(parseInt(String(nextNum(part) ?? part.value).replace(/[^0-9]/g, ''))) };
    if (part.dataPin && name === 'options' && t === 'List<String>') {
      const da = atlas.data.find(d => d.name === part.dataPin && d.type === 'List<String>');
      if (da) { imports.add(`import '../${da.shelf.replace(/^new\//, '')}/${da.file}';`); return { expr: da.name }; }
    }
    if (t === 'String' && /^(value|selected)$/.test(name)) { if (!shared.s) { shared.s = '_t' + (++sIdx); stateDecls.push(`String ${shared.s} = '';`); } return { expr: shared.s }; }
    if (t === 'String' && /^(glyph|emoji|icon)$/.test(name)) return { expr: constFor(part.emoji || '🔹', part.role + '_glyph') };
    if (t === 'String' && /^(sub|subtitle|caption|secondary)$/.test(name)) return { expr: constFor(part.sub || part.label, part.role + '_sub') };
    // 🎨 placeholder ריק — התווית כבר מוצגת מעל השדה; שכפול תווית-בתוך-שדה נראה רע (עיצוב טהור).
    if (t === 'String' && /^(hint|placeholder)$/.test(name)) return { expr: constFor('', part.role + '_hint') };
    if (t === 'String') {
      // 🎨 תור-טקסטים: prop-מחרוזת גנרי ראשון = התווית; הבאים נמזגים מה-options בסדרם
      // (רק כשהאטום עצמו אינו אטום-אופציות) ואז מה-sub — כך widget רב-כיתובים מקבל טקסט שונה לכל פינה.
      part._si = part._si || 0;
      const optWidget = [...a.types.entries()].some(([n2, t2]) => /^(options|items)$/.test(n2) && /^List</.test(t2.replace(/\?$/, '')));
      const texts = optWidget || !part.options ? [] : part.options;
      const pick = part._si === 0 ? part.label : (texts[part._si - 1] ?? part.sub ?? part.label);
      part._si++;
      return { expr: constFor(pick, part.role + '_' + snake(name)) };
    }
    if (t === 'bool' && name === 'value') { if (!shared.b) { shared.b = '_v' + (++sIdx); stateDecls.push(`bool ${shared.b} = false;`); } return { expr: shared.b }; }
    if (t === 'bool') return { expr: 'false' };
    if (t === 'int' && /^(value|selectedIndex|activeIndex|selected|currentIndex|currentTab|activeTab|tabIndex|pageIndex|current|qty|count)$/.test(name)) { if (!shared.i) { shared.i = '_n' + (++sIdx); stateDecls.push(`int ${shared.i} = 0;`); } return { expr: shared.i }; }
    if (t === 'int') { const nv = nextNum(part); return { expr: nv !== undefined ? String(parseInt(nv.replace(/[^0-9]/g, '')) || 0) : '0' }; }
    if (t === 'double') {
      if (/radius/i.test(name)) return { expr: '12' };
      const nv = nextNum(part);
      return { expr: nv !== undefined ? String(parseFloat(nv.replace(/[^0-9.]/g, '')) || 0) : '16' };
    }
    if (t === 'Color') return { expr: tokenFor(name) };
    if (t === 'IconData') return { expr: 'Icons.tune' };
    if (t === 'TextEditingController') { const c = '_c' + (++sIdx); stateDecls.push(`final TextEditingController ${c} = TextEditingController();`); return { expr: c }; }
    if (part.navExpr && (t === 'VoidCallback' || t === 'void Function()')) return { expr: part.navExpr };
    if (t === 'VoidCallback' || t === 'void Function()') return { expr: `() => _toast(${constFor(part.label, part.role + '_toast')})` };
    if (/^ValueChanged<bool>$|^void Function\(bool( \w+)?\)$/.test(t)) { if (!shared.b) { shared.b = '_v' + (++sIdx); stateDecls.push(`bool ${shared.b} = false;`); } return { expr: `(v) => setState(() => ${shared.b} = v)` }; }
    if (/^ValueChanged<int>$|^void Function\(int( \w+)?\)$/.test(t)) { if (!shared.i) { shared.i = '_n' + (++sIdx); stateDecls.push(`int ${shared.i} = 0;`); } return { expr: `(v) => setState(() => ${shared.i} = v)` }; }
    if (/^ValueChanged<String>$|^void Function\(String( \w+)?\)$/.test(t)) { if (!shared.s) { shared.s = '_t' + (++sIdx); stateDecls.push(`String ${shared.s} = '';`); } return { expr: `(v) => setState(() => ${shared.s} = v)` }; }
    if (/^List<String>/.test(t)) return { expr: part.options?.length ? `const <String>[${part.options.map(o => constFor(o, part.role + '_option')).join(', ')}]` : 'const <String>[]' };
    const rm2 = t.match(/^List<(\(\{[^}]*\}\))>$/);
    if (rm2 && part.options?.length) {
      const recT = rm2[1];
      const fields2 = [...recT.matchAll(/(String|bool|int)\s+(\w+)/g)];
      const items = part.options.map(o => '(' + fields2.map(([, ft, fn]) => `${fn}: ${ft === 'String' ? constFor(o, part.role + '_option') : ft === 'bool' ? 'true' : '0'}`).join(', ') + ')');
      return { expr: `const <${recT}>[${items.join(', ')}]` };
    }
    // 🧱 מתאמי-הלבנים (מבצע-המאה, פאזה 4): טיפוסי-עיצוב/מבנה שחסמו 25 לבנים
    if (t === 'EdgeInsetsGeometry' || t === 'EdgeInsets') return { expr: 'const EdgeInsets.all(12)' };
    if (t === 'FontWeight') return { expr: 'FontWeight.w600' };
    if (t === 'TimeOfDay') return { expr: 'const TimeOfDay(hour: 8, minute: 0)' };
    if (/^ValueChanged<TimeOfDay>$|^void Function\(TimeOfDay( \w+)?\)$/.test(t)) return { expr: '(v) {}' };
    if (t === 'Key') return { expr: `ValueKey(${constFor(part.label, part.role + '_key')})` };
    if (t === 'Object') return { expr: constFor(part.label, part.role + '_tag') };
    if (t === 'Future<void> Function()') return { expr: `() async => _toast(${constFor(part.label, part.role + '_toast')})` };
    const rmT = t.match(/^List<\(([^{}()]+)\)>$/);                  // רשומות-מיקומיות (String, String, bool)
    if (rmT && part.options?.length) {
      const fts = rmT[1].split(',').map(x => x.trim());
      const items = part.options.map(o => '(' + fts.map(ft => ft === 'String' ? constFor(o, part.role + '_cell') : ft === 'bool' ? 'true' : '0').join(', ') + ')');
      return { expr: `const <(${rmT[1]})>[${items.join(', ')}]` };
    }
    const rmR = t.match(/^\(\{([^}]*)\}\)$/);                       // רשומה-שמית יחידה ({String img, String why})
    if (rmR) {
      const fields3 = [...rmR[1].matchAll(/(String|bool|int)\s+(\w+)/g)];
      if (fields3.length) return { expr: '(' + fields3.map(([, ft, fn]) => `${fn}: ${ft === 'String' ? constFor(part.sub || part.label, part.role + '_' + snake(fn)) : ft === 'bool' ? 'false' : '0'}`).join(', ') + ')' };
    }
    if (/^List<[A-Z]\w*>$/.test(t)) return { expr: `const <${t.slice(5, -1)}>[]` };
    if (t === 'Widget') return { expr: 'const SizedBox(height: 4)' };
    if (/^List<Widget>/.test(t)) return { expr: 'const <Widget>[]' };
    return null;
  };

  const atomOf = new Map(parts.map(p => [p, pickAtom(p)]));
  const chosen = parts.map(part => ({ part, atom: atomOf.get(part) })).filter(c => c.atom);
  if (!chosen.length) { console.log(`🧬 ${slug}: אף אטום לא נבחר`); return null; }

  const buildCall = ({ part, atom }, shared = {}, overrides = {}) => {
    imports.add(`import '../dart-ui-bs/${atom.file}';`);
    const argsOut = [];
    for (const pn of atom.positional) { const r = fillProp(atom, pn, part, shared); argsOut.push(r ? r.expr : "''"); }
    for (const pn of atom.named) {
      if (overrides[pn]) { argsOut.push(`${pn}: ${overrides[pn]}`); continue; }
      const req = atom.required.has(pn);
      const t = (atom.types.get(pn) || '').replace(/\?$/, '');
      if (!req && !(t === 'String' && /^(label|title|text|hint)$/.test(pn)) && !/^ValueChanged|^void Function\(/.test(t) && pn !== 'value' && pn !== 'onTap' && pn !== 'onPressed') continue;
      const r = fillProp(atom, pn, part, shared);
      if (r) argsOut.push(`${pn}: ${r.expr}`);
      else if (req) argsOut.push(`${pn}: (null as dynamic) /* לא-ממולא */`);
    }
    return `${atom.cls}(${argsOut.join(', ')})`;
  };
  // הרכבה: אטומי-flex עוקבים ⇒ Row אחד · ענפים-מוזחים תחת בורר ⇒ IndexedStack מחווט
  // למצב-הבורר (חיבור אטום⇒אטום: הבחירה מחליפה את האטום המוצג) · אטום-מכיל ⇒ ילדים אמיתיים
  const calls = [];
  const flexBuf = [];
  const flushFlex = () => {
    if (!flexBuf.length) return;
    calls.push(`          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [${flexBuf.join(', ')}])),`);
    flexBuf.length = 0;
  };
  for (const node of nodes) {
    const atom = atomOf.get(node.part);
    if (!atom) continue;
    const kids = node.children.map(c => ({ part: c, atom: atomOf.get(c) })).filter(k => k.atom);
    if (!kids.length) {
      if (atom.flexRoot) { flexBuf.push(buildCall({ part: node.part, atom })); continue; }
      flushFlex();
      calls.push(`          ${buildCall({ part: node.part, atom })},`);
      continue;
    }
    flushFlex();
    const kidCalls = kids.map(k => k.atom.flexRoot ? `Row(children: [${buildCall(k)}])` : buildCall(k));
    if (node.part.role === 'radio' && node.part.options?.length) {
      const shared = {};
      const pickerCall = buildCall({ part: node.part, atom }, shared);
      calls.push(`          ${pickerCall},`);
      calls.push(`          IndexedStack(index: ${shared.i || '0'}, children: [${kidCalls.join(', ')}]),`);
    } else if (node.part.role === 'switch') {
      const shared = {};
      calls.push(`          ${buildCall({ part: node.part, atom }, shared)},`);
      for (const kc of kidCalls) calls.push(`          if (${shared.b || 'true'}) ${kc},`);
    } else if (node.part.role === 'textfield' || node.part.role === 'chip') {
      const shared = {};
      calls.push(`          ${buildCall({ part: node.part, atom }, shared)},`);
      for (const kc of kidCalls) calls.push(`          ${kc.replaceAll('__FIELD__', shared.s || "''")},`);
    } else if (/^List<Widget>/.test((atom.types.get('children') || ''))) {
      calls.push(`          ${buildCall({ part: node.part, atom }, {}, { children: `[${kidCalls.join(', ')}]` })},`);
    } else if ((atom.types.get('child') || '').replace(/\?$/, '') === 'Widget') {
      calls.push(`          ${buildCall({ part: node.part, atom }, {}, { child: `Column(children: [${kidCalls.join(', ')}])` })},`);
    } else {
      calls.push(`          ${buildCall({ part: node.part, atom })},`);
      for (const kc of kidCalls) calls.push(`          ${kc},`);
    }
  }
  flushFlex();

  const titleConst = constFor(title, 'app_bar_title');
  fs.writeFileSync(path.join(DATA, `gen_${slug}_content.dart`),
    '// 📦 דאטה · תוכן-המחולל (genesis-gen) — התוויות מן-הבקשה, verbatim. אל תערוך ידנית.\n' +
    consts.map(([n, v]) => `const String ${n} = '${v.replace(/\\/g, '\\\\').replace(/'/g, "\\'")}';${termKeyOf.has(v) ? ' // ' + termKeyOf.get(v) : ''}`).join('\n') + '\n');

  // 🧹 רק שדות-מצב שבאמת מופיעים בגוף (אחרת unused_field warning ⇒ שער-קומפילציה אדום)
  const body = calls.join('\n');
  const usedDecls = stateDecls.filter((d) => { const m = d.match(/(_[a-z]\d+)\b/); return !m || body.includes(m[1]); });

  const code = `// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: ${title}
// 🧬 בקשה: ${lines.join(' · ')}
// 🧬 אטומים שנבחרו: ${chosen.map(c => c.atom.cls).join(' · ')}
${look ? `// 🎨 מראה: ${look}\n` : ''}${[...imports].sort().join('\n')}

class ${cls} extends StatefulWidget {
  const ${cls}({super.key});

  @override
  State<${cls}> createState() => _${cls}State();
}

class _${cls}State extends State<${cls}> {
  ${usedDecls.join('\n  ')}

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ${look === 'dark' ? 'DsDark.bg' : TOK + '.bgLight'},
        appBar: AppBar(title: Text(${titleConst})),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
${calls.join('\n')}
          ],
        ),
      ),
    );
  }
}
`;
  // 🚨 שער-עצמי (הכרעה 16): קוד-המסך נקי — אפס-עברית ואפס-אימוג'י מחוץ להערות
  const codeOnly = stripComments(code);
  if (/[֐-׿]/.test(codeOnly) || /\p{Extended_Pictographic}/u.test(codeOnly)) {
    throw new Error(`🧬 ${slug}: עברית/אימוג'י דלפו לקוד-המסך — הפרת-טוהר`);
  }
  fs.mkdirSync(OUT, { recursive: true });
  fs.writeFileSync(path.join(OUT, `gen_${slug}.dart`), code);
  console.log(`🧬 ${slug} · "${title}" · ${chosen.length}/${parts.length} חלקים ⇒ ${chosen.map(c => c.atom.cls).join(', ')}`);
  return cls;
}

// ── 🪞 מסך-עצמי: המחולל כותב לעצמו את בקשת מסך-הכניסה מן הידע החי (אטלס · לקסיקון · דוח-לוחות).
// העובדות לא מוקלדות-ביד ולא מתיישנות: קידום-אטומים/צורה-חדשה ⇒ המסך מתעדכן בריצה הבאה.
// 🪞 דיוקן-עצמי: המחולל בוחר לבדו את הדגמותיו מהידע החי — הפונקציות בסריקת-האטלס,
// התוויות מהלקסיקון-של-עצמו בלבד, המסכים מרשימת-הבקשות. הניסוחים הקבועים = המודל-העצמי (דאטה).
// 🚫 ביקורת-בעלים ("איך יש לו את המושג ברך או פקק"): אפס-שאיבה מקטלוג-מונחי-האימפריה —
// הדיוקן משקף את המחולל, לא את הדומיין. תוויות = אוצר-המילים שלו (מילות-הצורה).
// 🏛️ מסך-הראווה: כרטיס-הביקור החי של המחולל — נמדד כולו מהאטלס ומהמדף ברגע-החילול
// (הכרעת-בעלים: "מסך חדש שישקף את היכולות, גם עיצוב וגרפיקה"). המנוע בוחר לבנים
// עשירות-ויזואלית מהמדף (גרדיאנט/מדדים/צינור/פסי-התקדמות) וממזג לתוכן מספרים חיים.
function writeShowcaseSpec() {
  const SM = JSON.parse(fs.readFileSync(path.join(HERE, 'knowledge/self-model.json'), 'utf8'));
  const W = SM.showcase;
  if (!W) return;
  const has = (cls) => atlas.widgets.some(a => a.cls === cls);
  const capSpecs = fs.readdirSync(SPECS).filter(f => /^cap.*\.txt$/.test(f));
  let orders = capSpecs.length;
  try { orders = fs.readdirSync(path.join(HERE, 'capabilities')).filter(f => f.endsWith('.txt')).length; } catch { }
  const proven = capSpecs.length;
  const pct = orders ? Math.round((proven / orders) * 100) : 0;
  let gates = 0;
  try { gates = fs.readFileSync(path.join(ROOT, 'machtzev/gates.tsv'), 'utf8').split('\n').filter(l => l && !l.startsWith('#')).length; } catch { }
  const navs = ['capmailphone', 'captimegematria', 'capclockcalendar', 'capautodream', 'improv', 'quest1']
    .filter(s => fs.existsSync(path.join(SPECS, s + '.txt')))
    .map(s => {
      const t = (fs.readFileSync(path.join(SPECS, s + '.txt'), 'utf8').split('\n')[0] || s).replace(/:$/, '').trim();
      return `ניווט ${s} ${t} | ${SM.phrases.navSub}`;
    });
  const lines = [
    `${W.name}:`,
    `הירו 🧬 ${SM.hero.title} | ${W.headerSub}`,
    `כותרת ${W.kpisTitle}`,
    ...(has('KpiBox') ? [
      `אטום KpiBox ${atlas.widgets.length} ${W.kpiWidgets}`,
      `אטום KpiBox ${atlas.functions.length} ${W.kpiFunctions}`,
      `אטום KpiBox ${atlas.data.length} ${W.kpiData}`,
    ] : []),
    `כותרת ${W.pipeTitle}`,
    ...(has('PipeLink') ? [`אטום PipeLink 0.9 ${W.pipeLabel} | ${W.pipeSub}`] : []),
    `כותרת ${W.synthTitle}`,
    ...(has('StatsCard') ? [`אטום StatsCard ${proven} 0 0 ${orders} ${W.synthLabel}: הוכחו / בבדיקה / נדחו`] : []),
    ...(has('ManagerDashboardCreditBar') ? [`אטום ManagerDashboardCreditBar ${pct} ${W.barLabel}`] : []),
    ...(() => {
      // 📈 צירי-מבצע-המאה: אחוזים חיים משער-הכיסוי (coverage-baseline.json — נמדד בכל משטרה)
      try {
        const c = JSON.parse(fs.readFileSync(path.join(ROOT, 'machtzev/coverage-baseline.json'), 'utf8'));
        const pc = (a2, b2) => b2 ? Math.round(a2 / b2 * 100) : 0;
        if (!has('ManagerDashboardCreditBar') || !W.axesTitle) return [];
        return [
          `כותרת ${W.axesTitle}`,
          `אטום ManagerDashboardCreditBar ${pc(c.widgetsFillable, c.widgetsTotal)} ${W.axisWidgets}`,
          `אטום ManagerDashboardCreditBar ${pc(c.enginesRunnable, c.enginesTotal)} ${W.axisEngines}`,
          `אטום ManagerDashboardCreditBar ${pc(c.essence, c.enginesTotal)} ${W.axisEssence}`,
          `אטום ManagerDashboardCreditBar ${pc(c.dataTwinned, c.dataTotal)} ${W.axisData}`,
        ];
      } catch { return []; }
    })(),
    `כותרת ${W.capsTitle}`,
    ...navs,
    `באנר ${gates} ${W.gatesBanner}`,
  ];
  fs.writeFileSync(path.join(SPECS, 'showcase.txt'), lines.join('\n') + '\n');
}

function writeSelfEntry() {
  const SM = JSON.parse(fs.readFileSync(path.join(HERE, 'knowledge/self-model.json'), 'utf8'));
  let boards = 0;
  try { boards = JSON.parse(fs.readFileSync(path.join(ROOT, 'screens-seed/board-gen-report.json'), 'utf8')).boards.length; } catch { }
  const RETS2 = new Set(['String', 'String?', 'int', 'double', 'num', 'bool']);
  const simple = (f, allow) => RETS2.has(f.ret) && f.he.length >= 2 && f.params.every(pp => allow.test(pp.type));
  // בחירת-הפונקציות — שלו: הראשונה שכל-פרמטריה DateTime (לגשר) · הראשונה עם String (להזנה-משדה)
  const bridgeFn = atlas.functions.find(f => simple(f, /^DateTime\??$/));
  const feedFn = atlas.functions.find(f => simple(f, /^(String|DateTime)\??$/) && f.params.some(pp => /^String/.test(pp.type)));
  // ענפי-ההחלפה — שלוש צורות אינטראקטיביות מהלקסיקון; התווית = שם-הצורה עצמה (טהור-עצמי)
  const roleWord = new Map();
  for (const [w, r] of LEXICON) if (!roleWord.has(r)) roleWord.set(r, w);
  const swapRoles = ['switch', 'textfield', 'stat'].filter(r => roleWord.has(r));
  const swapTerms = swapRoles.map(r => roleWord.get(r));
  const shapeWords = [...roleWord.values()];
  const siblingNavs = fs.readdirSync(SPECS).filter(f => f.endsWith('.txt') && f !== 'entry.txt').map(f => {
    const slug = f.replace('.txt', '');
    const t = (fs.readFileSync(path.join(SPECS, f), 'utf8').split('\n')[0] || slug).replace(/:$/, '').trim();
    return `ניווט ${slug} ${t} | ${SM.phrases.navSub}`;
  });
  const spec = [
    'המחולל:',
    `הירו ${SM.hero.emoji} ${SM.hero.title} | ${SM.hero.sub}`,
    `כותרת ${SM.titles.stats}`,
    `נתון ⚛️ ${atlas.widgets.length} ${SM.phrases.statWidgets}`,
    `נתון 🧠 ${atlas.functions.length} ${SM.phrases.statFunctions}`,
    `נתון 🖼️ ${boards} ${SM.phrases.statBoards}`,
    ...(bridgeFn ? [`כותרת ${SM.titles.bridge}`, `${SM.phrases.calcWord} ${bridgeFn.he.join(' ')}`] : []),
    ...(feedFn ? [`כותרת ${SM.titles.compose}`, `${SM.phrases.fieldPrompt} ${feedFn.he.join(' ')}`, `  ${SM.phrases.calcWord} ${feedFn.he.join(' ')}`] : []),
    `כותרת ${SM.titles.swap}`,
    `בחירה ${swapTerms.join(' או ')}: ${swapTerms.join(' / ')}`,
    ...swapRoles.map((r, i) => `  ${roleWord.get(r)} ${swapTerms[i] || roleWord.get(r)}`),
    `כותרת ${SM.titles.screens}`,
    ...siblingNavs,
    ...(() => {
      // אוצר-דאטה חי: אטום List<String> עשיר מהמדף — הוכחת "הדאטה חומר-בנייה" (הכרעה 19)
      const rich = atlas.data.filter(d => d.type === 'List<String>' && (d.items || []).length >= 4);
      if (!rich.length) return [];
      const pick2 = rich[Math.floor(rich.length / 2)];
      return [`כותרת ${SM.titles.dataTreasure || 'אוצר-דאטה חי מהמדף'}`, `דאטה ${pick2.name} ${pick2.name}`];
    })(),
    `תגיות ${SM.titles.shapes}: ${shapeWords.join(' / ')}`,
    SM.phrases.banner,
    SM.phrases.button,
  ].join('\n');
  fs.writeFileSync(path.join(SPECS, 'entry.txt'), spec + '\n');
}

// 🎲 מצב-אלתור: הוראה-חופשית מהבעלים ("תבחר N אטומים רנדומליים תחבר בין ותוציא יכולת חדשה").
// המנוע לבדו: מגריל N אטומים ברי-מילוי (זרע-יומי — יכולת חדשה כל יום), מסווג מפעילים/מציגים,
// ובוחר את החיבורים: שדה⇒חישוב-חי · מתג⇒שער-נראות · השאר מוזנים/מוצגים. הפלט = spec רגיל.
// 🎲 מצב-אלתור v3 — שרשרת-חמישה (ביקורת-בעלים: 'לא אטום-לוגיקה אחד — חמישה, מחוברים,
// יכולת חדשה'): המנוע מגריל 5 אטומי-לוגיקה שונים ומשרשר אותם לצינור אחד — פלט כל שלב
// מוזרם לשלב הבא וכל שלב מוצג חי. ההתחלה: אטום עם תחום-ערכים מוצהר ⇒ chips מהדאטה שלו.
async function writeImprovSpec() {
  const insPath = path.join(HERE, 'instructions/improv.txt');
  if (!fs.existsSync(insPath)) return;
  const ins = fs.readFileSync(insPath, 'utf8').trim();
  const SM = JSON.parse(fs.readFileSync(path.join(HERE, 'knowledge/self-model.json'), 'utf8'));
  let seed = parseInt(new Date().toISOString().slice(0, 10).replace(/-/g, '')) + ins.length;
  const rnd = () => { seed |= 0; seed = seed + 0x6D2B79F5 | 0; let t = Math.imul(seed ^ seed >>> 15, 1 | seed); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; };
  // חוליות-שרשרת: פונקציה בת פרמטר-String יחיד שמחזירה ערך — כל אחת יכולה לצרוך את פלט קודמתה
  // (הביטוי המשורשר תמיד String ⇒ כל צירוף של 5 תקין-טיפוסית). דדופ לפי-שם (התנגשות-import).
  const RETS3 = new Set(['String', 'String?', 'int', 'bool', 'double', 'num']);
  const byName = new Map();
  for (const f of atlas.functions) {
    if (!(RETS3.has(f.ret) && f.params.length === 1 && /^String\??$/.test(f.params[0].type.trim()) && f.he.length >= 1)) continue;
    if (!byName.has(f.name)) byName.set(f.name, f);
  }
  const pool = [...byName.values()];
  if (pool.length < 5) return;
  // התחלה מועדפת: חוליה עם תחום-ערכים מוצהר בגופה ⇒ ה-chips = הדאטה האמיתית של האטום
  const starts = [];
  for (const f of pool) {
    try {
      const dm = fs.readFileSync(path.join(ROOT, f.shelf, f.file), 'utf8').match(/const \w+ = \[([^\]]+)\]/);
      if (!dm) continue;
      const domain = [...dm[1].matchAll(/'([^']+)'/g)].map(m => m[1]);
      if (domain.length >= 2 && domain.length <= 6) starts.push({ fn: f, domain });
    } catch { }
  }
  // 🧪 בחינה-עצמית: לכל חוליה יש תאום-JS (new/atoms) — המנוע מריץ את המועמדים על הדאטה
  // האמיתית ובוחר שרשרת שבה כל שלב משנה את הערך באופן-נראה ("היכולת הכי טובה", לא עיוורת).
  const twins = new Map();
  for (const f of pool) {
    const base = path.basename(f.file).replace(/\.dart$/, '');
    const tp = path.join(ROOT, 'new/atoms', base + '.mjs');
    if (!fs.existsSync(tp)) continue;
    try {
      const m = await import('file://' + tp);
      if (typeof m[f.name] !== 'function') continue;
      // תאום-מטוהר: השקעים נקראים מהעטיפה שבבדיקת-האטום (אמת-הקרקע: סדר+ערכים מצולמים)
      let extra = [];
      if (m[f.name].length > 1) {
        try {
          const tt = fs.readFileSync(path.join(ROOT, 'new/atoms', base + '.test.mjs'), 'utf8');
          const wm = tt.match(new RegExp(`__pure_${f.name}\\(\\.\\.\\.a,\\s*\\.\\.\\.Array\\(Math\\.max\\([^)]*\\)\\)\\.fill\\(undefined\\),\\s*([^)]+)\\)`));
          if (wm) {
            for (const nm of wm[1].split(',').map(x => x.trim())) {
              const cm = tt.match(new RegExp(`const ${nm} = `));
              if (!cm) { extra = []; break; }
              const st2 = cm.index + cm[0].length;
              let d2 = 0, j2 = st2, q2 = null, started = false;
              for (; j2 < tt.length; j2++) {
                const ch = tt[j2];
                if (q2) { if (ch === '\\') j2++; else if (ch === q2) q2 = null; continue; }
                if (ch === "'" || ch === '"' || ch === '`') { q2 = ch; continue; }
                if ('([{'.includes(ch)) { d2++; started = true; }
                else if (')]}'.includes(ch)) d2--;
                else if (ch === ';' && d2 === 0) break;
              }
              extra.push(eval('(' + tt.slice(st2, j2) + ')'));
            }
          }
        } catch { extra = []; }
      }
      const fn0 = m[f.name];
      twins.set(f.name, extra.length ? (v) => fn0(v, ...extra) : fn0);
    } catch { }
  }
  const testable = starts.filter(s => twins.has(s.fn.name));
  // 🎲 v4 · ערבוב-שלושת-המדפים: החומר = אטום-דאטה אקראי (List<String> עשיר) מהמדף המטוהר;
  // אין-דאטה ⇒ נפילה-רכה לתחום-מוצהר-בפונקציה (v3). הצינור נבחן חי על ערכי-ההגרלה.
  const dataRich = atlas.data.filter(d => d.type === 'List<String>' && (d.items || []).filter(x => x && !/[<>{}$]/.test(x)).length >= 3);
  const dataPick = dataRich.length ? dataRich[Math.floor(rnd() * dataRich.length)] : null;
  // עוקבים אחרי וקטור-הערכים (ערך פר-בחירה): כל חוליה חייבת (1) לשנות-נראה, (2) להישאר
  // קריאה-לתצוגה, (3) לשמר הבחנה בין הבחירות — שהצינור יגיב לבחירת-המשתמש עד סופו.
  let start = null;
  let chain = [];
  let values = [];
  if (dataPick) {
    values = dataPick.items.filter(x => x && !/[<>{}$]/.test(x)).slice(0, 6);
  } else {
    start = testable.length ? testable[Math.floor(rnd() * testable.length)] : (starts.length ? starts[Math.floor(rnd() * starts.length)] : null);
    if (!start) return;
    chain = [start.fn];
    values = start.domain.slice(0, 6);
    try { values = values.map(v => String(twins.get(start.fn.name)?.(v) ?? v)); } catch { }
  }
  while (chain.length < 5) {
    const cands2 = pool.filter(f => twins.has(f.name) && !chain.includes(f));
    if (!cands2.length) break;
    // 🧭 חוש-המשמעות: קוהרנטיות-נושא — מנוע שחולק מילים עם תיאור-הדאטה קודם בתור
    const norm4 = (w) => w.replace(/^ה(?=..)/, '');
    const topic = new Set(((dataPick && dataPick.he) || (start && start.fn.he) || []).map(norm4));
    const cohere = (f) => f.he.reduce((n, w) => n + (topic.has(norm4(w)) ? 1 : 0), 0);
    const order = [...cands2].map(c => [c, cohere(c) + rnd() * 0.9]).sort((a, b) => b[1] - a[1]).map(x => x[0]);
    const evalC = (c) => {
      try {
        const outs = values.map(v => String(twins.get(c.name)(v)));
        if (outs.some(o => o.trim() === '' || o.length > 40)) return null;
        return { outs, changed: outs.some((o, i) => o !== values[i]), distinct: new Set(outs).size };
      } catch { return null; }
    };
    let hit = null;
    for (const c of order) { const e = evalC(c); if (e && e.changed && e.distinct >= 2) { hit = { c, e }; break; } }
    if (!hit) for (const c of order) { const e = evalC(c); if (e && e.changed) { hit = { c, e }; break; } }
    if (!hit) { const c = order[0]; hit = { c, e: evalC(c) || { outs: values } }; }
    chain.push(hit.c); values = hit.e.outs;
  }
  if (chain.length < 5) return;
  const inputLine = dataPick
    ? `דאטה ${dataPick.name} ${dataPick.name}`
    : start
      ? `אטום ChipWrap ${start.fn.he.join(' ')}: ${start.domain.join(' / ')}`
      : `שדה ${SM.phrases.improvType}`;
  const lines = [
    'יכולת מאולתרת - שרשרת חמישה:',
    `הירו 🎲 ${SM.phrases.improvHero} | ${ins}`,
    `כותרת ${SM.phrases.mixTitle || SM.phrases.chainTitle}`,
    inputLine,
    ...chain.map(f => `  חישוב ${f.he.join(' ')} (${f.name})`),
    `באנר ${SM.phrases.mixBanner || SM.phrases.chainBanner}`,
  ];
  fs.writeFileSync(path.join(SPECS, 'improv.txt'), lines.join('\n') + '\n');
}

// 🎯 שכבת-המטרה (ביקורת-בעלים: 'אתה רק מבקש ממנו מטרה - לא אומר מה לעשות'):
// הבעלים מניח משפט-מטרה בלבד ב-goals/<שם>.txt — אפס הוראות-הרכבה. המנוע לבדו:
// (1) מדרג את כל אטומי-הלוגיקה לפי קרבה-למטרה (חפיפת-מילים לתיאור-העצמי) + הגרלה זרועה-מהמטרה,
// (2) גוזר לכל אטום את צורת-החיבור מהחתימה שלו (תחום-מוצהר⇒בחירה-מזינה · String⇒שרשרת-משדה,
//     נבחנת על מילות-המטרה עצמן · DateTime⇒מנוע-חי, מוצב בבורר-החלפה או מאחורי מתג-שער),
// (3) מפצל את היחידות לחדרים ומחווט ניווט-מסע ביניהם (האחרון חוזר לראשון).
async function writeGoalSpecs() {
  const GOALS = path.join(HERE, 'goals');
  if (!fs.existsSync(GOALS)) return;
  const SM = JSON.parse(fs.readFileSync(path.join(HERE, 'knowledge/self-model.json'), 'utf8'));
  const P = SM.phrases;
  const norm2 = (w) => w.replace(/^ה(?=..)/, '');
  for (const gf of fs.readdirSync(GOALS).filter(f => /^[a-z][a-z0-9-]*\.txt$/.test(f))) {
    const goal = fs.readFileSync(path.join(GOALS, gf), 'utf8').trim();
    if (!goal) continue;
    const gname = gf.replace(/\.txt$/, '');
    let seed = 2166136261;
    for (const ch of goal) { seed ^= ch.codePointAt(0); seed = Math.imul(seed, 16777619); }
    const rnd = () => { seed |= 0; seed = seed + 0x6D2B79F5 | 0; let t = Math.imul(seed ^ seed >>> 15, 1 | seed); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; };
    const gwords = new Set((goal.match(/[֐-׿]+/g) || []).map(norm2));
    const score = (f) => f.he.reduce((s, w) => s + (gwords.has(norm2(w)) ? 1 : 0), 0);
    // בריכות לפי-חתימה — רק אטומים ברי-חיווט-עצמאי
    const RETS4 = new Set(['String', 'String?', 'int', 'bool', 'double', 'num']);
    const seen = new Set(); const strFns = []; const dateFns = []; const domFns = [];
    for (const f of atlas.functions) {
      if (!RETS4.has(f.ret) || !f.he.length || seen.has(f.name)) continue;
      if (f.params.length === 1 && /^String\??$/.test(f.params[0].type.trim())) {
        seen.add(f.name); strFns.push(f);
        try {
          const dm = fs.readFileSync(path.join(ROOT, f.shelf, f.file), 'utf8').match(/const \w+ = \[([^\]]+)\]/);
          const domain = dm ? [...dm[1].matchAll(/'([^']+)'/g)].map(m => m[1]) : [];
          if (domain.length >= 2 && domain.length <= 6) domFns.push({ fn: f, domain });
        } catch { }
      } else if (f.params.length >= 1 && f.params.every(pp => /^DateTime\??$/.test(pp.type.trim()))) {
        seen.add(f.name); dateFns.push(f);
      }
    }
    const pick = (arr, n, of = (x) => x) => [...arr].map(x => [x, score(of(x)) + rnd()]).sort((a, b) => b[1] - a[1]).slice(0, n).map(x => x[0]);
    // סל-היחידות שהמכונה מרכיבה לעצמה
    const units = [];
    for (const d of pick(domFns, 1, (x) => x.fn)) units.push({ kind: 'chips', d });
    // שרשרת-שדה: מועמדים מדורגים-למטרה, נבחנים על מילת-המטרה הראשונה (תאומי-JS)
    const sample = [...gwords][0] || gname;
    const twins = new Map();
    for (const f of strFns) {
      const tp = path.join(ROOT, 'new/atoms', path.basename(f.file).replace(/\.dart$/, '.mjs'));
      if (!fs.existsSync(tp)) continue;
      try { const m = await import('file://' + tp); if (typeof m[f.name] === 'function') twins.set(f.name, m[f.name]); } catch { }
    }
    const chain = [];
    let val = sample;
    for (const c of pick(strFns.filter(f => twins.has(f.name)), 12)) {
      if (chain.length >= 3) break;
      try {
        const o = String(twins.get(c.name)(val));
        if (o !== val && o.trim() !== '' && o.length <= 40) { chain.push(c); val = o; }
      } catch { }
    }
    if (chain.length) units.push({ kind: 'field', chain });
    const swaps = pick(dateFns, 3);
    const usedSwap = swaps.length >= 2;                          // בורר דורש 2+ מנועים
    if (usedSwap) units.push({ kind: 'swap', swaps });
    for (const g of pick(dateFns.filter(f => !usedSwap || !swaps.includes(f)), 2)) units.push({ kind: 'gate', g });
    if (!units.length) continue;
    // פיצול-חדרים: עד 2 יחידות לחדר, ניווט משורשר, האחרון סוגר מעגל
    const rooms = [];
    for (let i = 0; i < units.length; i += 2) rooms.push(units.slice(i, i + 2));
    const shortGoal = (goal.match(/[֐-׿]+/g) || []).slice(0, 3).join(' ');
    rooms.forEach((ru, i) => {
      const slug = `${gname}${i + 1}`;
      const lines = [`${shortGoal} - ${P.goalRoom} ${i + 1}:`, `הירו 🎯 ${goal} | ${P.goalHeroSub}`];
      for (const u of ru) {
        if (u.kind === 'chips') {
          lines.push(`כותרת ${P.goalUnitChips}`,
            `אטום ChipWrap ${u.d.fn.he.join(' ')}: ${u.d.domain.join(' / ')}`,
            `  חישוב ${u.d.fn.he.join(' ')} (${u.d.fn.name})`);
        } else if (u.kind === 'field') {
          lines.push(`כותרת ${P.goalUnitField}`, `${P.fieldPrompt} ${u.chain[0].he.join(' ')}`,
            ...u.chain.map(f => `  חישוב ${f.he.join(' ')} (${f.name})`));
        } else if (u.kind === 'swap') {
          const labels = u.swaps.map(f => f.he.slice(0, 2).join(' '));
          lines.push(`כותרת ${P.goalUnitSwap}`,
            `בחירה ${labels.join(' או ')}: ${labels.join(' / ')}`,
            ...u.swaps.map(f => `  חישוב ${f.he.join(' ')} (${f.name})`));
        } else if (u.kind === 'gate') {
          lines.push(`מתג 🔓 ${P.goalUnitGate}`, `  חישוב ${u.g.he.join(' ')} (${u.g.name})`);
        }
      }
      if (rooms.length > 1) {                                    // מסע = ניווט רק כשיש לאן
        const next = i < rooms.length - 1 ? `${gname}${i + 2}` : `${gname}1`;
        lines.push(`ניווט ${next} ${i < rooms.length - 1 ? P.goalNav : P.goalBack} | ${P.goalNavSub}`);
      }
      lines.push(`באנר ${P.goalBanner}`);
      fs.writeFileSync(path.join(SPECS, slug + '.txt'), lines.join('\n') + '\n');
    });
  }
}

// ── CLI ──
fs.mkdirSync(SPECS, { recursive: true });
await writeImprovSpec();
await writeGoalSpecs();
writeShowcaseSpec();
writeSelfEntry();
const [slugArg, specArg] = process.argv.slice(2);
if (slugArg && specArg) fs.writeFileSync(path.join(SPECS, slugArg + '.txt'), specArg + '\n');
fs.rmSync(OUT, { recursive: true, force: true });
for (const f of fs.readdirSync(DATA)) if (/^gen_.*_content\.dart$/.test(f)) fs.unlinkSync(path.join(DATA, f));
let n = 0;
for (const f of fs.readdirSync(SPECS).filter(f => f.endsWith('.txt')).sort()) {
  const spec = fs.readFileSync(path.join(SPECS, f), 'utf8').trim();
  if (spec && generate(f.replace('.txt', ''), spec)) n++;
}
console.log(`🧬 המחולל · ${n} מסכים · אטלס-מלא: ${atlas.widgets.length} widgets · ${atlas.functions.length} functions · ${atlas.data.length} data`);

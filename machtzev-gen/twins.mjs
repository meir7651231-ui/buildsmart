/** 🤝 רתמת-התאומים — הרצת אטומי-JS חיים (כולל מטוהרים: שקעי-הדאטה נקראים מהעטיפה
 *  המצולמת בבדיקת-האטום — אמת-קרקע של סדר+ערכים). משרתת את האלתור ואת מנוע-הסינתזה.
 *
 *  🌾 קוצר-הפיקסצ'רים (מבצע-המאה, פאזה 1): מנוע רב-פרמטרי שאין לו עטיפת-שקעים נקצר
 *  מקריאת-העבודה הראשונה בבדיקה שלו — זנב-הארגומנטים (אחרי הראשון) מוערך מתוך קבועי-הבדיקה
 *  ונרשם. זנב JSON-י פשוט (פרימיטיבים/רשימות) מסומן simple ⇒ המחולל והשער רשאים לפלוט
 *  אותו כליטרל-Dart במסך (שוויון JS⇄Dart נשמר); זנב מורכב משרת הרצת-JS בלבד. */
import fs from 'node:fs';
import path from 'node:path';
import * as R from '../root.mjs';
const ROOT = R.ROOT;

/** מטא-הזנבות של הקציר האחרון: fnName ⇒ { tail:any[], simple:boolean } */
export const twinMeta = new Map();

/** ערך-JS ⇒ ליטרל-Dart (רק לזנבות simple). top=true מוסיף const לאוספים. */
export const dartLit = (v, top = true) => {
  if (v === null) return 'null';
  if (typeof v === 'string') return "'" + v.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\$/g, '\\$').replace(/\n/g, '\\n').replace(/\r/g, '\\r') + "'";
  if (typeof v === 'number') return Number.isFinite(v) ? String(v) : 'double.nan';
  if (typeof v === 'boolean') return String(v);
  if (Array.isArray(v)) return (top ? 'const ' : '') + '[' + v.map(x => dartLit(x, false)).join(', ') + ']';
  return (top ? 'const ' : '') + '{' + Object.entries(v).map(([k, x]) => dartLit(k, false) + ': ' + dartLit(x, false)).join(', ') + '}';
};

const jsonable = (v) => {
  try { const s = JSON.stringify(v); return s !== undefined && s.length <= 2000 && JSON.stringify(JSON.parse(s)) === s; } catch { return false; }
};
const prim = (v) => v === null || ['string', 'number', 'boolean'].includes(typeof v);
const simpleVal = (v) => prim(v)
  || (Array.isArray(v) && v.length <= 60 && v.every(prim))
  || (v && typeof v === 'object' && !Array.isArray(v) && Object.keys(v).length <= 60 && Object.values(v).every(prim));

// חיתוך-מאוזן: מ-start עד סוגר-הסיום התואם (start מצביע אחרי הפותח)
const balanced = (s, start, open = '(', close = ')') => {
  let d = 1, q = null;
  for (let j = start; j < s.length; j++) {
    const ch = s[j];
    if (q) { if (ch === '\\') j++; else if (ch === q) q = null; continue; }
    if (ch === "'" || ch === '"' || ch === '`') { q = ch; continue; }
    if (ch === open || '([{'.includes(ch)) d++;
    else if (ch === close || ')]}'.includes(ch)) { d--; if (d === 0) return j; }
  }
  return -1;
};
const splitTop = (s) => {
  const out = []; let d = 0, q = null, cur = '';
  for (let j = 0; j < s.length; j++) {
    const ch = s[j];
    if (q) { cur += ch; if (ch === '\\') { cur += s[j + 1] ?? ''; j++; } else if (ch === q) q = null; continue; }
    if (ch === "'" || ch === '"' || ch === '`') { q = ch; cur += ch; continue; }
    if ('([{'.includes(ch)) d++;
    if (')]}'.includes(ch)) d--;
    if (ch === ',' && d === 0) { out.push(cur.trim()); cur = ''; continue; }
    cur += ch;
  }
  if (cur.trim()) out.push(cur.trim());
  return out;
};

// הקשר-הבדיקה: כל הצהרות-const ברמת-הקובץ מוערכות בסדרן (מה שנכשל — מדולג)
const buildCtx = (tt) => {
  const ctx = Object.create(null);
  const re = /(?:^|\n)\s*const\s+([A-Za-z_$][\w$]*)\s*=\s*/g;
  let m;
  while ((m = re.exec(tt))) {
    const st = m.index + m[0].length;
    let d = 0, j = st, q = null;
    for (; j < tt.length; j++) {
      const ch = tt[j];
      if (q) { if (ch === '\\') j++; else if (ch === q) q = null; continue; }
      if (ch === "'" || ch === '"' || ch === '`') { q = ch; continue; }
      if ('([{'.includes(ch)) d++;
      else if (')]}'.includes(ch)) d--;
      else if (ch === ';' && d === 0) break;
    }
    try { ctx[m[1]] = Function('ctx', 'with(ctx){ return (' + tt.slice(st, j) + '); }')(ctx); } catch { }
  }
  return ctx;
};
const evalIn = (expr, ctx) => Function('ctx', 'with(ctx){ return (' + expr + '); }')(ctx);

// 🎬 קציר-שידור-חוזר: מריץ את בדיקת-האטום עם עטיפת-הקלטה על fnName ומחזיר ארגומנטי-הקריאה-הראשונה
//    (חיים — כולל callbacks). מנטרל process.exit ובולע כשלי-אימות (הלכידה קורית לפני-אימות).
async function replayCapture(base, fnName, testSrc) {
  const atomsDir = path.join(ROOT, 'new/atoms');
  // גוף-הבדיקה בלי שורות-import; קריאות process.exit מנוטרלות; יבוא-ערך-זר (מלבד האטום) ⇒ פסילה
  const stray = [...testSrc.matchAll(/^import\s+(?!type)([^;]*?)from\s+['"]([^'"]+)['"]/gm)]
    .filter(m => m[2] !== `./${base}.mjs` && !/^node:/.test(m[2]));  // node: builtins בטוחים (assert וכו')
  if (stray.length) return null;                                    // תלוי-מדף-זר — לא-בטוח לשידור
  // שורות-import של node: נשמרות (assert דרוש לגוף); רק יבוא-האטום מוסר
  const keepNode = [...testSrc.matchAll(/^import\s+.*from\s+['"]node:[^'"]+['"];?$/gm)].map(m => m[0]);
  const body = testSrc.replace(/^import\s+.*$/gm, '').replace(/process\.exit\s*\([^)]*\)/g, 'void 0');
  const runner = path.join(atomsDir, `__twinreplay_${base}.mjs`);
  // שאר-יצואי-האטום מוזרקים כ-const — רק אלו שהבדיקה מזכירה ואינה מגדירה בעצמה (מניעת-התנגשות)
  const others = [];
  { const m = await import('file://' + path.join(atomsDir, base + '.mjs') + '?t=' + Date.now());
    for (const n of Object.keys(m)) if (n !== fnName
      && new RegExp('\\b' + n + '\\b').test(body)
      && !new RegExp('(?:const|let|var|function|class)\\s+' + n + '\\b').test(body)) others.push(n); }
  fs.writeFileSync(runner,
    keepNode.join('\n') + (keepNode.length ? '\n' : '') +
    `import * as __atom from './${base}.mjs';\n` +
    `const __rec = { args: null };\n` +
    `const ${fnName} = (...a) => { if (!__rec.args) __rec.args = a; return __atom.${fnName}(...a); };\n` +
    others.map(n => `const ${n} = __atom.${n};`).join('\n') + '\n' +
    `const describe = (n, fn) => { try { fn && fn(); } catch {} };\nconst it = describe, test = describe, beforeEach=()=>{}, afterEach=()=>{}, beforeAll=()=>{}, afterAll=()=>{};\n` +
    `try {\n${body}\n} catch {}\nexport const RECIPE = __rec;\n`);
  try {
    const rm = await import('file://' + runner + '?t=' + Date.now());
    return rm.RECIPE?.args || null;
  } finally { try { fs.unlinkSync(runner); } catch { } }
}

export async function buildTwinRegistry(fns) {
  const twins = new Map();
  twinMeta.clear();
  for (const f of fns) {
    const base = path.basename(f.file).replace(/\.dart$/, '');
    const tp = path.join(ROOT, 'new/atoms', base + '.mjs');
    if (!fs.existsSync(tp)) continue;
    try {
      const m = await import('file://' + tp);
      if (typeof m[f.name] !== 'function') continue;
      const fn0 = m[f.name];
      let tt = '';
      try { tt = fs.readFileSync(path.join(ROOT, 'new/atoms', base + '.test.mjs'), 'utf8'); } catch { }
      let extra = null;                                             // שקעי-עטיפה (מטוהרים) — קדימות ראשונה
      if (fn0.length > 1 && tt) {
        const wm = tt.match(new RegExp(`__pure_${f.name}\\(\\.\\.\\.a,\\s*\\.\\.\\.Array\\(Math\\.max\\([^)]*\\)\\)\\.fill\\(undefined\\),\\s*([^)]+)\\)`));
        if (wm) {
          const vals = [];
          let ok = true;
          for (const nm of wm[1].split(',').map(x => x.trim())) {
            const cm = tt.match(new RegExp(`const ${nm} = `));
            if (!cm) { ok = false; break; }
            const st2 = cm.index + cm[0].length;
            let d2 = 0, j2 = st2, q2 = null;
            for (; j2 < tt.length; j2++) {
              const ch = tt[j2];
              if (q2) { if (ch === '\\') j2++; else if (ch === q2) q2 = null; continue; }
              if (ch === "'" || ch === '"' || ch === '`') { q2 = ch; continue; }
              if ('([{'.includes(ch)) d2++;
              else if (')]}'.includes(ch)) d2--;
              else if (ch === ';' && d2 === 0) break;
            }
            try { vals.push(eval('(' + tt.slice(st2, j2) + ')')); } catch { ok = false; break; }
          }
          if (ok) extra = vals;
        }
      }
      // 🌾 קציר-פיקסצ'רים: אין עטיפה והמנוע רב-פרמטרי ⇒ קריאת-העבודה הראשונה בבדיקה
      if (extra === null && fn0.length > 1 && tt) {
        const clean = tt.replace(/\/\*[\s\S]*?\*\//g, '').replace(/(^|[^:])\/\/[^\n]*/g, '$1');
        const callRe = new RegExp(`(?<![\\w.$])${f.name}\\(`, 'g');
        let ctx = null, cm2;
        while ((cm2 = callRe.exec(clean))) {
          const end = balanced(clean, cm2.index + cm2[0].length);
          if (end < 0) continue;
          const args = splitTop(clean.slice(cm2.index + cm2[0].length, end));
          if (args.length !== fn0.length || args.some(a2 => a2.startsWith('...'))) continue;
          if (ctx === null) ctx = buildCtx(clean);
          const tail = [];
          let ok2 = true;
          for (const ax of args.slice(1)) {
            try { const v = evalIn(ax, ctx); if (!jsonable(v)) { ok2 = false; break; } tail.push(v); } catch { ok2 = false; break; }
          }
          if (!ok2) continue;
          extra = tail;
          twinMeta.set(f.name, { tail, simple: tail.every(simpleVal) });
          break;
        }
      } else if (extra !== null && extra.length && jsonable(extra)) {
        twinMeta.set(f.name, { tail: extra, simple: extra.every(simpleVal) });
      }
      // 🎬 קציר-שידור-חוזר: זנב לא-JSON-י (callbacks/DI) ⇒ מריצים את בדיקת-האטום עם עטיפת-הקלטה
      //    ולוכדים את הארגומנטים החיים (כולל פונקציות) — מנוע רהיץ אף שאינו-simple (לא-פליט-Dart).
      if (fn0.length > 1 && extra === null && tt) {
        try {
          const rec = await replayCapture(base, f.name, tt);
          if (rec && rec.length === fn0.length) { extra = rec.slice(1); twinMeta.set(f.name, { tail: [], simple: false, live: true }); }
        } catch { }
      }
      if (fn0.length > 1 && extra === null) continue;               // רב-פרמטרי שלא נקצר — לא נרשם (כנות)
      const tail = extra || [];
      twins.set(f.name, tail.length ? (v) => fn0(v, ...tail) : fn0);
    } catch { }
  }
  // ידע-הזנבות נשמר לקריאה סינכרונית (המחולל קורא בלי לייבא 1,100 מודולים)
  try {
    const out = {};
    for (const [n, meta] of twinMeta) out[n] = meta;
    fs.writeFileSync(path.join(ROOT, 'machtzev/generator/knowledge/twin-tails.json'), JSON.stringify(out, null, 1));
  } catch { }
  return twins;
}

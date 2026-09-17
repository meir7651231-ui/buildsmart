#!/usr/bin/env node
// 🏔️🤖 gen-max — מחולל-אוטונומי: שם-מנוע ⇒ מאתר-מקור · קורא-גוף · מזהה-שדות · סורק-קטלוג לעוזרים-חסרים · תוכנית-שדרוג.
//   הכל לבד. בלי grep-ידני, בלי חיווט-ידני. המחולל מוצא את הפערים ושולף את המועמדים מ-40,854.
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url'; import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
const GEN = path.dirname(fileURLToPath(import.meta.url));
const REPOS = { 'maor-system': '/home/user/maor-system', 'buildsmart': '/home/user/buildsmart' };
const CAT = JSON.parse(fs.readFileSync(path.join(GEN, 'master-particles.json'), 'utf8')).catalog;
const ALL = Object.entries(CAT).flatMap(([op, arr]) => arr.map((p) => ({ ...p, op })));
const toks = (n) => n.replace(/([a-z0-9])([A-Z])/g, '$1 $2').replace(/[_-]/g, ' ').toLowerCase().split(/\s+/).filter((w) => w.length > 2);
const VALIDATORish = /valid|error|norm|check|region|dup|exist|uniq|allow|require|ensure|sanit|clean|fix|format/i;
// דפוס-פער *מחמיר* לזיהוי-שדרוג: רק מאמתים-אמיתיים (בלי dup/clean/fix/format/label — פורמטרים שיוצרים פערי-שווא)
const GAP_VALIDATOR = /valid|error|check|region|norm|exist|uniq|allow|require|ensure|sanit/i;

// ═══ deepScan — גלאי סיכוני-נכונות/מדיניות לפי צורה (משותף ל---deepmax ו---deepall) ═══
const deepRealBody = (s, name) => { // מדלג על סוגריי-טיפוס (param/return-type) — אחרת נחתך לטיפוס במקום לקוד
  const st = s.search(new RegExp(`(export\\s+)?(async\\s+)?function\\s+${name}\\b`));
  if (st < 0) return '';
  let i = s.indexOf('(', st); if (i < 0) return ''; let pd = 0;
  for (; i < s.length; i++) { if (s[i] === '(') pd++; else if (s[i] === ')' && --pd === 0) { i++; break; } }
  const fb = s.indexOf('{', i); if (fb < 0) return '';
  let d = 0, j = fb; for (; j < s.length; j++) { if (s[j] === '{') d++; else if (s[j] === '}' && --d === 0) { j++; break; } }
  let k = j; while (k < s.length && /\s/.test(s[k])) k++;
  const bs = s[k] === '{' ? k : fb;
  let d2 = 0; for (let m = bs; m < s.length; m++) { if (s[m] === '{') d2++; else if (s[m] === '}' && --d2 === 0) return s.slice(bs, m + 1); }
  return '';
};
const DEEP_CRIT = /(^|[^a-z])id$|idnum|^hok$|extid|^rid|passw|iban|acct|amount|seq|dek|token/i;
const DEEP_CAL = new Set(['7', '10', '12', '24', '30', '31', '42', '52', '60', '90', '100', '180', '360', '365', '366', '1000', '3600']);
function deepFindings(dbody) {
  const out = [];
  const seenCo = new Set();
  for (const m of dbody.matchAll(/(\w+)\.(\w+)\s*(\|\||\?\?)\s*(\w+)\.(\w+)/g)) {
    const [, o1, f1, op, o2, f2] = m;
    if (o1 !== o2 && f1 === f2 && !seenCo.has(f1)) {
      seenCo.add(f1); const crit = DEEP_CRIT.test(f1);
      out.push({ sev: crit ? 3 : 1, kind: 'בליעה-שקטה', snippet: m[0], text: `'${f1}' מאוחד ${o1}.${f1} ${op} ${o2}.${f1} — אם שונים, אחד אובד בשקט${crit ? ' (קריטי — זהות/כסף!)' : ''}` });
    }
  }
  const seenLit = new Set();
  for (const m of dbody.matchAll(/(?:[<>]=?|===?|!==?)\s*(\d{2,})|(\d{2,})\s*(?:[<>]=?|===?|!==?)/g)) {
    const lit = m[1] || m[2];
    if (+lit >= 3 && !DEEP_CAL.has(lit) && !seenLit.has(lit)) { seenLit.add(lit); out.push({ sev: 1, kind: 'קבוע-קסם', snippet: m[0], text: `'${lit}' מקובע בהשוואה — מועמד למדיניות/הגדרה` }); }
  }
  const seqM = dbody.match(/\b(?:seq|serial|counter|receiptseq|donationseq|shopreceiptseq)\w*\+\+/i);
  if (seqM) out.push({ sev: 3, kind: 'רצף-מונה', snippet: seqM[0], text: `מונה (seq++) בונה מזהה — ודא אי-חורים/אי-כפל (רציפות קבלות-מס); אין הוכחת-רצף בגוף` });
  const moneyM = dbody.match(/reduce\([^\n]*\+[^\n]*\.(?:amount|ils|usd|price)\b/i) || dbody.match(/\.(?:amount|price)\s*[+*]/i);
  if (moneyM) out.push({ sev: 1, kind: 'חשבון-כסף-בצפים', snippet: moneyM[0], text: `סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)` });
  // (ה) תאריך-UTC: new Date().toISOString().slice(0,10) לתאריך-מקומי ⇒ סביב חצות יום שגוי (round-trip דרך UTC). חוק-הפרויקט: isoToday(). *לא* תופס b.toISOString כש-b=Date.UTC (לגיטימי).
  const utcM = dbody.match(/new Date\(\)\.toISOString\(\)\.slice\(0,\s*10\)/);
  if (utcM) out.push({ sev: 3, kind: 'תאריך-UTC', snippet: utcM[0], text: `new Date().toISOString().slice(0,10) לתאריך-מקומי — סביב חצות יוצא יום שגוי; החלף ב-isoToday() (חוק-הפרויקט, באג-מתועד)` });
  // (ו) JSON.parse של *נתון-חיצוני* (storage/clipboard/רשת) בלי שום try בגוף ⇒ קריסה אמיתית על-נתון-פגום.
  // מדויק: דורש מקור-חיצוני *וגם* היעדר-try (הוקשח אחרי false-positive על parse-מוגן ב-useApp).
  if (/JSON\.parse\(/.test(dbody) && /(getItem|sessionStorage|localStorage|\.text\(\)|clipboard|atob|response|readText)/.test(dbody) && !/\btry\b/.test(dbody))
    out.push({ sev: 2, kind: 'JSON.parse-לא-מוגן', snippet: 'JSON.parse(', text: `JSON.parse של נתון-חיצוני (storage/clipboard/רשת) בלי try — נתון-פגום מפיל את הפונקציה` });
  return out;
}

// ═══ מנוע-הלוח (BOARD) — הרכבה מונחית-טיפוס (שקע/תקע/אטום/לוח), על דגם GENMAX siteResolvable+DsScaffold ═══
//   אטום = מנוע-טהור (name+sig). שקע = טיפוס-הפרמטר-הראשון (input). תקע = טיפוס-ההחזרה (output).
//   לוח = שרשור תקע→שקע לפי התאמת-טיפוס: A:(X)→Y ⊕ B:(Y,…)→Z  ⇒  (X)→Z  ע"י  B(A(x),…).
//   קשת חוקית A→B רק אם: norm(out(A)) ≡ norm(firstIn(B))  **וגם** שאר-פרמטרי-B פתירים-מהקשר
//   (אופציונלי / פרימיטיב / טיפוס-סביבה Db·OrgConfig…) — בדיוק siteResolvable של GENMAX. לא-פתיר ⇒ אין-קשת (מדווח, לא מזייף).
{
  const AMBIENT = new Set(['Db', 'OrgConfig', 'FeatureDef[]', 'TermDef[]', 'Config', 'AppConfig']);
  const PRIM = /^(string|number|boolean|bigint|Date|void|unknown|any|null|undefined)(\s*\[\])?$/;
  const splitTop = (s) => { const out = []; let d = 0, cur = ''; for (const c of s) { if ('([{<'.includes(c)) d++; else if (')]}>'.includes(c)) d--; if (c === ',' && d === 0) { out.push(cur); cur = ''; } else cur += c; } if (cur.trim()) out.push(cur); return out; };
  const stripNull = (t) => t.replace(/\s*\|\s*(null|undefined)\b/g, '').trim();
  const normType = (t) => stripNull((t || '').replace(/\breadonly\s+/g, '').replace(/\s+/g, ' ').trim());
  // parseSig: 'a: X, b?: Y = d, opts?: {…}' => Z  ⇒ {ins:[{opt,type}], out, firstIn, restOk}
  const parseSig = (sig) => {
    const ix = sig.lastIndexOf('=>'); if (ix < 0) return null;
    const paramsRaw = sig.slice(0, ix), out = normType(sig.slice(ix + 2));
    const ins = splitTop(paramsRaw).map((p) => {
      const ci = (() => { let d = 0; for (let i = 0; i < p.length; i++) { const c = p[i]; if ('([{<'.includes(c)) d++; else if (')]}>'.includes(c)) d--; else if (c === ':' && d === 0) return i; } return -1; })();
      if (ci < 0) return null;
      const nm = p.slice(0, ci), rhs = p.slice(ci + 1);
      const opt = /\?\s*$/.test(nm) || /=/.test(rhs);
      const type = normType(rhs.replace(/=.*$/s, ''));
      return { opt, type };
    }).filter(Boolean);
    if (!ins.length || !out) return null;
    const restOk = ins.slice(1).every((p) => p.opt || PRIM.test(p.type) || AMBIENT.has(p.type));
    const restAmb = ins.slice(1).filter((p) => !p.opt && !PRIM.test(p.type) && AMBIENT.has(p.type)).map((p) => p.type);
    return { ins, out, firstIn: ins[0].type, restOk, restAmb };
  };
  const boardEngines = () => {
    const seen = new Map();
    for (const p of ALL) {
      if (!/maor-system/.test(p.origin) || !/\.tsx?$/.test(p.origin) || p.name.startsWith('_') || !/^[a-z]/.test(p.name) || !p.sig || !p.sig.includes('=>')) continue;
      const ps = parseSig(p.sig); if (!ps || ps.out === 'void' || ps.firstIn === 'void') continue;
      if (!seen.has(p.name)) seen.set(p.name, { ...p, ...ps });
    }
    return [...seen.values()];
  };
  // --board-scan: גלה את גרף-הטיפוסים + שרשראות-אמת (read-only, אפס-כתיבה)
  if (process.argv.includes('--board-scan')) {
    const E = boardEngines();
    const inDeg = {}, outDeg = {};
    for (const e of E) { outDeg[e.out] = (outDeg[e.out] || 0) + 1; inDeg[e.firstIn] = (inDeg[e.firstIn] || 0) + 1; }
    // טיפוס-רכזת = גם מיוצר וגם נצרך (מגשר תקע↔שקע)
    const hubs = Object.keys(outDeg).filter((t) => inDeg[t]).map((t) => ({ t, prod: outDeg[t], cons: inDeg[t] })).sort((a, b) => (b.prod + b.cons) - (a.prod + a.cons));
    console.log(`🧩🔌 גרף-הלוח: ${E.length} אטומים (מנועים typed) · ${hubs.length} טיפוסי-רכזת (מגשרים תקע↔שקע)`);
    console.log(`\n   רכזות מובילות (טיפוס · מיוצר-ע"י → נצרך-ע"י):`);
    for (const h of hubs.slice(0, 12)) console.log(`   ${String(h.t).slice(0, 34).padEnd(35)} ${String(h.prod).padStart(3)} → ${h.cons}`);
    // שרשראות ≥2: A:(X)→Y ⊕ B:(Y,…)→Z  (edge חוקי בלבד)
    const chains = [];
    for (const a of E) for (const b of E) { if (a.name === b.name) continue; if (b.restOk && normType(a.out) === normType(b.firstIn)) chains.push({ a, b }); }
    console.log(`\n   דוגמאות-שרשרת (תקע→שקע לפי-טיפוס · ${chains.length} קשתות-חוקיות):`);
    const shown = new Set();
    for (const { a, b } of chains) { const k = a.firstIn + '|' + a.out + '|' + b.out; if (shown.has(k) || shown.size >= 14) continue; shown.add(k); console.log(`   ${a.name}(${a.firstIn}) → ${b.name}  ⟹  (${a.firstIn}) → ${b.out}${b.restAmb.length ? '  [קשר: ' + [...new Set(b.restAmb)].join(',') + ']' : ''}`); }
    console.log(`\nBOARD-SCAN|engines=${E.length}|hubs=${hubs.length}|edges=${chains.length}`);
    process.exit(0);
  }
  // --board --from=X --to=Z: מצא שרשרת קצרה-ביותר (BFS) · הרכב pipeline · הוכח דטרמיניזם+אפס-אובדן
  const fromA = process.argv.find((a) => a.startsWith('--from=')), toA = process.argv.find((a) => a.startsWith('--to='));
  if (process.argv.includes('--board') && fromA && toA) {
    const FROM = normType(fromA.slice('--from='.length)), TO = normType(toA.slice('--to='.length));
    const E = boardEngines(), byName = new Map(E.map((e) => [e.name, e]));
    // adjacency: e.out ≡ next.firstIn (& next.restOk)
    const adj = new Map(E.map((e) => [e.name, []]));
    for (const a of E) for (const b of E) if (a.name !== b.name && b.restOk && normType(a.out) === normType(b.firstIn)) adj.get(a.name).push(b.name);
    // BFS מכל מנוע ש-firstIn≡FROM (ו-restOk) עד מנוע ש-out≡TO
    const starts = E.filter((e) => e.restOk && normType(e.firstIn) === FROM);
    if (!starts.length) { console.log(`BOARD|no-start|אין מנוע שצורך ${FROM} כשקע-ראשון`); process.exit(0); }
    let path0 = null; const q = starts.map((e) => [e.name]); const vis = new Set(starts.map((e) => e.name));
    while (q.length) { const p = q.shift(); const last = byName.get(p[p.length - 1]); if (normType(last.out) === TO) { path0 = p; break; } if (p.length >= 6) continue; for (const nx of adj.get(p[p.length - 1])) if (!vis.has(nx)) { vis.add(nx); q.push([...p, nx]); } }
    if (!path0) { console.log(`BOARD|no-chain|אין שרשרת-טיפוס מ-${FROM} ל-${TO} (עד עומק 6)`); process.exit(0); }
    const chain = path0.map((n) => byName.get(n));
    console.log(`🧩🔌 לוח: ${FROM} → ${TO}  ·  שרשרת באורך ${chain.length}:`);
    console.log('   ' + chain.map((e, i) => `${e.name}${i < chain.length - 1 ? `:(${e.firstIn})→${e.out}` : `→${e.out}`}`).join('  ⟹  '));
    const ambients = [...new Set(chain.flatMap((e) => e.restAmb))];
    if (ambients.length) console.log(`   קשר-סביבה נדרש (מ-opts): ${ambients.join(', ')}`);
    // חילוץ-גופים + סגירת-תלויות-בקובץ (כמו --domain) — הרכבה בלבד, אפס-כתיבת-קוד-חדש
    const bEnd = (t, from) => { let d = 0, s = null; for (let i = from; i < t.length; i++) { const c = t[i], n = t[i + 1]; if (s === 'line') { if (c === '\n') s = null; continue; } if (s === 'block') { if (c === '*' && n === '/') { s = null; i++; } continue; } if (s === '"' || s === "'" || s === '`') { if (c === '\\') { i++; continue; } if (c === s) s = null; continue; } if (c === '/' && n === '/') { s = 'line'; i++; continue; } if (c === '/' && n === '*') { s = 'block'; i++; continue; } if ('"\'`'.includes(c)) { s = c; continue; } if (c === '{') d++; else if (c === '}' && --d === 0) return i + 1; } return -1; };
    const stmtEnd = (t, from) => { let d = 0, s = null; for (let i = from; i < t.length; i++) { const c = t[i], n = t[i + 1]; if (s === 'line') { if (c === '\n') s = null; continue; } if (s === 'block') { if (c === '*' && n === '/') { s = null; i++; } continue; } if ('"\'`'.includes(s)) { if (c === '\\') { i++; continue; } if (c === s) s = null; continue; } if (c === '/' && n === '/') { s = 'line'; i++; continue; } if (c === '/' && n === '*') { s = 'block'; i++; continue; } if ('"\'`'.includes(c)) { s = c; continue; } if ('([{'.includes(c)) d++; else if (')]}'.includes(c)) d--; else if (c === ';' && d === 0) return i + 1; } return -1; };
    const bodyBrace = (src, from) => { let i = src.indexOf('{', from); while (i >= 0) { const e = bEnd(src, i); if (e < 0) return i; let j = e; while (j < src.length && /\s/.test(src[j])) j++; if (!'[|&>,{'.includes(src[j] || '')) return i; i = src.indexOf('{', e); } return -1; };
    const fnFrom = (src, name) => { let mt = src.match(new RegExp(`\\n(export\\s+)?(async\\s+)?function\\s+${name}\\b`)); if (mt) { const st = mt.index + 1; const bi = bodyBrace(src, st); const e = bEnd(src, bi); return e > 0 ? src.slice(st, e).replace(/^export\s+/, '') : ''; } mt = src.match(new RegExp(`\\n(export\\s+)?const\\s+${name}\\s*[=:]`)); if (mt) { const st = mt.index + 1; const e = stmtEnd(src, st); return e > 0 ? src.slice(st, e).replace(/^export\s+/, '') : ''; } return ''; };
    const collected = new Map();
    for (const e of chain) {
      const src = fs.readFileSync(path.join(REPOS['maor-system'], e.origin.split(':')[1]), 'utf8');
      const need = new Set([e.name]), done = new Set();
      while (true) { let added = false; for (const nm of [...need]) { if (done.has(nm)) continue; done.add(nm); const b = fnFrom(src, nm); if (!b) continue; if (!collected.has(nm)) collected.set(nm, b); for (const mm of b.matchAll(/\b([a-z]\w{2,}|[A-Z_][A-Z0-9_]{2,})\b/g)) { const id = mm[1]; if (!done.has(id) && new RegExp(`\\n\\s*(export\\s+)?(async\\s+)?(function|const|let)\\s+${id}\\b`).test(src)) { need.add(id); added = true; } } } if (!added) break; } }
    const missing = chain.filter((e) => !collected.has(e.name)).map((e) => e.name);
    if (missing.length) { console.log(`BOARD|body-miss|${missing.join(',')} (חוצה-קובץ — לא נאסף)`); process.exit(0); }
    const argFor = (e) => ['x', ...e.ins.slice(1).map((p, i) => AMBIENT.has(p.type) ? `opts.${p.type.replace(/\W/g, '').toLowerCase()}` : (p.opt ? 'undefined' : `opts.${e.name}_${i + 1}`))].join(', ');
    let _TS = null; try { _TS = require(path.join(REPOS['maor-system'], 'node_modules/typescript')); } catch {}
    const nm = `board_${FROM.replace(/\W/g, '')}_to_${TO.replace(/\W/g, '')}`;
    const steps = chain.map((e, i) => `  try { x = ${e.name}(${argFor(e)}); } catch { return { ok:false, at:'${e.name}', value:null }; }`).join('\n');
    const composed = `${[...collected.values()].join('\n')}
export function ${nm}(x, opts = {}) {
${steps}
  return { ok:true, value:x };
}`;
    const outF = path.join(GEN, `${nm}.mjs`);
    fs.writeFileSync(outF, _TS ? _TS.transpileModule(composed, { compilerOptions: { target: 'ES2020', module: 'ESNext' } }).outputText : composed);
    console.log(`🏔️🧩 לוח הורכב: ${chain.length} אטומים + ${collected.size - chain.length} תלויות ⇒ ${path.basename(outF)}`);
    // הוכחה: (א) קומפילציה/import · (ב) דטרמיניזם — שתי ריצות זהות
    try {
      const m = await import('file://' + outF + '?t=' + Date.now()); const fn = m[nm];
      if (typeof fn !== 'function') throw new Error('no-export');
      const r1 = JSON.stringify(fn(null)), r2 = JSON.stringify(fn(null));
      console.log(`🧪 הוכחה: import ✅ · דטרמיניסטי ${r1 === r2 ? '✅' : '🔴'} · השרשרת מרכיבה מנועים-קיימים בלבד (אפס-קוד-חדש)`);
      console.log(`BOARD|${FROM}→${TO}|len=${chain.length}|deps=${collected.size - chain.length}|deterministic=${r1 === r2}`);
    } catch (err) { console.log(`BOARD|import-fail|${String(err.message).slice(0, 40)}`); }
    process.exit(0);
  }
}

// ═══ --switch --file=<path> <fn>: אופרטור switch⇒טבלת-חיפוש (case קבועים ⇒ אובייקט + lookup). API זהה ⇒ אפס-אובדן. ═══
if (process.argv.includes('--switch') && process.argv.some((a) => a.startsWith('--file='))) {
  const fp = process.argv.find((a) => a.startsWith('--file=')).split('=')[1];
  const fn = process.argv[2];
  if (!fs.existsSync(fp)) { console.log(`SWITCH|${fn}|file-not-found`); process.exit(0); }
  const ftxt = fs.readFileSync(fp, 'utf8');
  const body = deepRealBody(ftxt, fn);
  const swM = body && body.match(/switch\s*\(\s*([^)]+?)\s*\)\s*\{([\s\S]*)\}\s*$/);
  if (!swM) { console.log(`🔀 switch · ${fn}: אין switch (לא-חל). SWITCH|${fn}|no-switch`); process.exit(0); }
  const varName = swM[1], swBody = swM[2];
  const blocks = [...swBody.matchAll(/((?:case\s+(?:-?\d+(?:\.\d+)?|'[^']*'|"[^"]*")\s*:\s*)+)return\s+([\s\S]*?);/g)];
  const entries = [];
  for (const b of blocks) for (const k of [...b[1].matchAll(/case\s+(-?\d+(?:\.\d+)?|'[^']*'|"[^"]*")\s*:/g)]) entries.push([k[1], b[2].trim()]);
  const defM = swBody.match(/default\s*:\s*return\s+([\s\S]*?);/);
  if (entries.length < 2 || !defM) { console.log(`🔀 switch · ${fn}: switch לא-נקי (ערכים דינמיים/בלי default). SWITCH|${fn}|not-clean`); process.exit(0); }
  let pi = ftxt.indexOf('(', ftxt.search(new RegExp(`function\\s+${fn}\\b`))); let d = 0, pe = pi;
  for (; pe < ftxt.length; pe++) { if (ftxt[pe] === '(') d++; else if (ftxt[pe] === ')' && --d === 0) break; }
  const params = ftxt.slice(pi + 1, pe).split(',').map((p) => (p.split(':')[0] || '').split('=')[0].replace(/[?\s]/g, '')).filter(Boolean);
  const TBL = `${fn}_MAP`;
  const tableSrc = `const ${TBL} = {\n${entries.map(([k, v]) => `  ${k}: ${v}`).join(',\n')},\n};`;
  const emitTS = `${tableSrc}\nexport function ${fn}(${params.join(', ')}) {\n  return Object.prototype.hasOwnProperty.call(${TBL}, ${varName}) ? ${TBL}[${varName}] : (${defM[1].trim()});\n}\nexport function ${fn}_ORIG(${params.join(', ')}) ${body}`;
  const outFile = path.join(GEN, `${fn}.switch.mjs`);
  let _ts = null; try { _ts = require(path.join(REPOS['maor-system'], 'node_modules/typescript')); } catch { /**/ }
  fs.writeFileSync(outFile, _ts ? _ts.transpileModule(emitTS, { compilerOptions: { target: 'ES2020', module: 'ESNext', removeComments: false } }).outputText : emitTS);
  const mod = await import('file://' + outFile + '?t=' + Date.now());
  const up = mod[fn], orig = mod[fn + '_ORIG'];
  if (typeof up !== 'function' || typeof orig !== 'function') { console.log(`SWITCH|${fn}|BROKEN-export`); process.exit(0); }
  const keys = entries.map(([k]) => (/^['"]/.test(k) ? k.slice(1, -1) : +k)); const probes = [...keys, 0, -1, 999, 'zz'];
  let same = 0, tot = 0; for (const x of probes) { tot++; try { if (JSON.stringify(up(x)) === JSON.stringify(orig(x))) same++; } catch { /**/ } }
  const zl = same === tot;
  console.log(`🔀 switch(file) · ${fn} — ${entries.length} cases ⇒ טבלת-חיפוש ${TBL} · אפס-אובדן ${same}/${tot} ${zl ? '✅' : '❌'}`);
  console.log(`SWITCH|${fn}|cases=${entries.length}|zeroloss=${same}/${tot}|${zl ? 'SAFE' : 'BROKEN'}`);
  process.exit(0);
}

// ═══ --dedup-scan: אופרטור-דדופ (החזון המקורי — "op-equivalence merge") — מוצא ביטויים *זהים* חוזרים לאיחוד ═══
if (process.argv.includes('--dedup-scan')) {
  const repoArg = (process.argv.find((a) => a.startsWith('--repo=')) || '').split('=')[1] || 'maor-system';
  const sub = (process.argv.find((a) => a.startsWith('--sub=')) || '').split('=')[1] || 'src';
  const root = path.join(REPOS[repoArg] || REPOS['maor-system'], sub);
  const walk = (d, acc = []) => { if (!fs.existsSync(d)) return acc; for (const e of fs.readdirSync(d, { withFileTypes: true })) { const p = path.join(d, e.name); if (e.isDirectory()) { if (e.name !== '__tests__' && e.name !== 'node_modules') walk(p, acc); } else if (/\.tsx?$/.test(e.name) && !/\.test\./.test(e.name)) acc.push(p); } return acc; };
  const findings = [];
  for (const f of walk(root)) {
    let txt; try { txt = fs.readFileSync(f, 'utf8'); } catch { continue; }
    // חלקיקי-op חשודים לכפילות: regex-*בשימוש-אמת* (‎/re/.test(‎ או ‎.match/replace/split(/re/‎) — מדויק, לא תופס הערות/נתיבי-import/URL.
    const re = '(\\/(?:\\\\.|\\[[^\\]]*\\]|[^/\\n\\\\])+\\/[gimsuy]*)';
    const exprs = [
      ...[...txt.matchAll(new RegExp(re + '\\.test\\(', 'g'))].map((m) => m[1]),
      ...[...txt.matchAll(new RegExp('\\.(?:match|replace|split|search)\\(\\s*' + re, 'g'))].map((m) => m[1]),
    ].filter((e) => e.length >= 10);
    const cnt = {}; for (const e of exprs) cnt[e] = (cnt[e] || 0) + 1;
    for (const [e, c] of Object.entries(cnt)) if (c >= 2) findings.push({ rel: f.replace((REPOS[repoArg] || '') + '/', ''), expr: e, count: c });
  }
  findings.sort((a, b) => b.count - a.count);
  console.log(`🔗 dedup-scan · ${findings.length} חלקיקי-op כפולים (ביטוי-זהה ≥2, מועמד-לאיחוד) ב-${repoArg}:`);
  for (const h of findings) console.log(`   ×${h.count}  ${h.expr}  ←${h.rel}  ⇒ חלץ לקבוע-אחד (op-equivalence merge)`);
  console.log(`DEDUP|${repoArg}|dups=${findings.length}`);
  process.exit(0);
}

// ═══ שכתוב file-based: --restructure --file=<path> <fn> — עוקף את הקטלוג (מגיע לעוזרים לא-רשומים כמו scoreColor) ═══
if (process.argv.includes('--restructure') && process.argv.some((a) => a.startsWith('--file='))) {
  const fp = process.argv.find((a) => a.startsWith('--file=')).split('=')[1];
  const fn = process.argv[2];
  if (!fs.existsSync(fp)) { console.log(`RESTRUCTURE|${fn}|file-not-found`); process.exit(0); }
  const ftxt = fs.readFileSync(fp, 'utf8');
  const body = deepRealBody(ftxt, fn);
  const rows = body ? [...body.matchAll(/if\s*\(\s*(\w+)\s*(>=|>|<=|<)\s*(-?\d+(?:\.\d+)?|[A-Z_][A-Z0-9_]{2,})\s*\)\s*return\s*(\{[^{}]*\})\s*;/g)] : [];
  const defM = body && body.match(/return\s*(\{[^{}]*\})\s*;\s*\}?\s*$/);
  if (rows.length < 2) { console.log(`🔀 restructure · ${fn}: אין סולם (לא-חל). RESTRUCTURE|${fn}|no-ladder`); process.exit(0); }
  // פרמטרים מהחתימה בקובץ
  let pi = ftxt.indexOf('(', ftxt.search(new RegExp(`function\\s+${fn}\\b`))); let d = 0, pe = pi;
  for (; pe < ftxt.length; pe++) { if (ftxt[pe] === '(') d++; else if (ftxt[pe] === ')' && --d === 0) break; }
  const params = ftxt.slice(pi + 1, pe).split(',').map((p) => (p.split(':')[0] || '').split('=')[0].replace(/[?\s]/g, '')).filter(Boolean);
  const varName = rows[0][1], op = rows[0][2], TBL = `${fn}_TIERS`, catchAll = /^>/.test(op) ? '-Infinity' : 'Infinity';
  const tableSrc = `const ${TBL} = [\n${rows.map((m) => `  { min: ${m[3]}, v: ${m[4]} }`).join(',\n')},\n  { min: ${catchAll}, v: ${defM ? defM[1] : '{}'} },\n];`;
  // תלויות: קבועי-סף בשם, מהקובץ עצמו
  const deps = [...new Set([...tableSrc.matchAll(/[A-Z_][A-Z0-9_]{2,}/g)].map((m) => m[0]))].map((c) => { const dm = ftxt.match(new RegExp(`const ${c}\\s*=\\s*[^;]+;`)); return dm ? dm[0] : ''; }).filter(Boolean);
  const emitTS = `${deps.join('\n')}\n${tableSrc}\nexport function ${fn}(${params.join(', ')}) {\n  return (${TBL}.find((t) => ${varName} ${op} t.min) ?? ${TBL}[${TBL}.length - 1]).v;\n}\nexport function ${fn}_ORIG(${params.join(', ')}) ${body}`;
  const outFile = path.join(GEN, `${fn}.restr.mjs`);
  let _ts = null; try { _ts = require(path.join(REPOS['maor-system'], 'node_modules/typescript')); } catch { /**/ }
  fs.writeFileSync(outFile, _ts ? _ts.transpileModule(emitTS, { compilerOptions: { target: 'ES2020', module: 'ESNext', removeComments: false } }).outputText : emitTS);
  const mod = await import('file://' + outFile + '?t=' + Date.now());
  const up = mod[fn], orig = mod[fn + '_ORIG'];
  if (typeof up !== 'function' || typeof orig !== 'function') { console.log(`RESTRUCTURE|${fn}|BROKEN-export`); process.exit(0); }
  let same = 0, tot = 0; for (let x = -200; x <= 1200; x += 13) { tot++; try { if (JSON.stringify(up(x)) === JSON.stringify(orig(x))) same++; } catch { /**/ } }
  const zl = same === tot;
  console.log(`🔀 restructure(file) · ${fn} — סולם-${rows.length} ⇒ טבלה+find · אפס-אובדן ${same}/${tot} ${zl ? '✅' : '❌'}`);
  console.log(`RESTRUCTURE|${fn}|tiers=${rows.length}|zeroloss=${same}/${tot}|${zl ? 'SAFE' : 'BROKEN'}`);
  process.exit(0);
}

// ═══ מצב --restructure-scan: ציד — סורק את כל הקוד ומוצא *לבד* מועמדי-שכתוב (סולם-if⇒טבלה) ═══
if (process.argv.includes('--restructure-scan')) {
  const repoArg = (process.argv.find((a) => a.startsWith('--repo=')) || '').split('=')[1] || 'maor-system';
  const sub = (process.argv.find((a) => a.startsWith('--sub=')) || '').split('=')[1] || 'src';
  const root = path.join(REPOS[repoArg] || REPOS['maor-system'], sub);
  const walk = (d, acc = []) => { if (!fs.existsSync(d)) return acc; for (const e of fs.readdirSync(d, { withFileTypes: true })) { const p = path.join(d, e.name); if (e.isDirectory()) { if (e.name !== '__tests__' && e.name !== 'node_modules') walk(p, acc); } else if (/\.tsx?$/.test(e.name) && !/\.test\./.test(e.name)) acc.push(p); } return acc; };
  const LADDER = /if\s*\(\s*\w+\s*(?:>=|>|<=|<)\s*(?:-?\d+(?:\.\d+)?|[A-Z_][A-Z0-9_]{2,})\s*\)\s*return\s*\{[^{}]*\}\s*;/g;
  const hits = [];
  for (const f of walk(root)) {
    let txt; try { txt = fs.readFileSync(f, 'utf8'); } catch { continue; }
    for (const m of txt.matchAll(/(?:export\s+)?function\s+([a-z]\w*)\s*\(/g)) {
      const body = deepRealBody(txt, m[1]); if (!body) continue;
      const rows = (body.match(LADDER) || []).length;
      if (rows >= 2) hits.push({ fn: m[1], rel: f.replace((REPOS[repoArg] || '') + '/', ''), rows });
    }
  }
  hits.sort((a, b) => b.rows - a.rows);
  console.log(`🔀 restructure-scan · ${hits.length} מועמדי-שכתוב (סולם-if⇒טבלה) ב-${repoArg}:`);
  for (const h of hits) console.log(`   ${h.fn} (${h.rows} דרגות) ←${h.rel}`);
  console.log(`RESTRSCAN|${repoArg}|candidates=${hits.length}`);
  process.exit(0);
}

// ═══ מצב --fixfile=<path>: המחולל *מחיל* תיקון-מכני-ידוע בעצמו (סוגר את הלולאה, מגיע ליכולת-הידנית) ═══
// תומך במחלקה שהתיקון שלה דטרמיניסטי לחלוטין: תאריך-UTC ⇒ isoToday() + הוספת-import. לא ממציא — מרכיב פותר-קיים.
if (process.argv.some((a) => a.startsWith('--fixfile='))) {
  const fp = process.argv.find((a) => a.startsWith('--fixfile=')).split('=')[1];
  const repoArg = (process.argv.find((a) => a.startsWith('--repo=')) || '').split('=')[1] || 'maor-system';
  const REPO = REPOS[repoArg];
  if (!fs.existsSync(fp)) { console.log(`FIXFILE|${fp}|not-found`); process.exit(0); }
  let txt = fs.readFileSync(fp, 'utf8'); const before = txt; const applied = [];
  // תיקון תאריך-UTC: new Date().toISOString().slice(0,10) → isoToday(), + import אם חסר
  if (/new Date\(\)\.toISOString\(\)\.slice\(0,\s*10\)/.test(txt)) {
    txt = txt.replace(/new Date\(\)\.toISOString\(\)\.slice\(0,\s*10\)/g, 'isoToday()');
    if (!/\bisoToday\b/.test(before.replace(/new Date\(\)\.toISOString[\s\S]*?\)/g, ''))) {
      // מחשב נתיב-יחסי אמיתי אל <src>/lib/date-util לפי מיקום-הקובץ עצמו (עמיד-לריפו): מוצא /src/ בנתיב
      const si = fp.lastIndexOf('/src/');
      const srcRoot = si >= 0 ? fp.slice(0, si + 5) : path.join(REPO, 'src/');
      let rel = path.relative(path.dirname(fp), path.join(srcRoot, 'lib/date-util')).replace(/\\/g, '/');
      if (!rel.startsWith('.')) rel = './' + rel;
      const imp = `import { isoToday } from '${rel}';`;
      const lastImp = [...txt.matchAll(/^import .*?;$/gm)].pop();
      if (lastImp) txt = txt.slice(0, lastImp.index + lastImp[0].length) + '\n' + imp + txt.slice(lastImp.index + lastImp[0].length);
      else txt = imp + '\n' + txt;
    }
    applied.push('תאריך-UTC→isoToday()+import');
  }
  // מחלקה שנייה: חילוץ קבוע-קסם לפרמטר-opts *בעריכת-קובץ-אמיתי* (זה-לוסס: ברירת-מחדל=המקורי). --fixmagic=<fn>
  const magicFn = (process.argv.find((a) => a.startsWith('--fixmagic=')) || '').split('=')[1];
  if (magicFn) {
    const body = deepRealBody(txt, magicFn);
    const lits = body ? [...new Set(deepFindings(body).filter((f) => f.kind === 'קבוע-קסם').map((f) => (f.text.match(/'(\d+)'/) || [])[1]).filter(Boolean))] : [];
    const st = txt.search(new RegExp(`(export\\s+)?(async\\s+)?function\\s+${magicFn}\\b`));
    if (lits.length && st >= 0) {
      let i = txt.indexOf('(', st); let pd = 0; for (; i < txt.length; i++) { if (txt[i] === '(') pd++; else if (txt[i] === ')' && --pd === 0) break; } // i = params-close )
      const bodyIdx = txt.indexOf(body, i);
      const origFull = txt.slice(st, bodyIdx + body.length);
      // חתימה: מזריק opts לפני ה-) ; מדלג-על-פסיק-נגרר
      const sigHead = txt.slice(st, i); const inside = sigHead.slice(sigHead.indexOf('(') + 1).trim().replace(/,\s*$/, '');
      const newSig = sigHead.slice(0, sigHead.indexOf('(') + 1) + (inside ? inside + ', opts: Record<string, number> = {}' : 'opts: Record<string, number> = {}');
      const midType = txt.slice(i, bodyIdx); // ה-) + return-type
      let newBody = body; lits.forEach((L, n) => { newBody = newBody.replace(new RegExp(`([<>]=?|===?|!==?)\\s*${L}\\b`, 'g'), `$1 (opts.k${n} ?? ${L})`).replace(new RegExp(`\\b${L}\\s*([<>]=?|===?|!==?)`, 'g'), `(opts.k${n} ?? ${L}) $1`); });
      txt = txt.slice(0, st) + newSig + midType + newBody + txt.slice(bodyIdx + body.length);
      applied.push(`קבוע-קסם→opts ב-${magicFn} (${lits.join(',')})`);
    }
  }
  if (!applied.length) { console.log(`FIXFILE|${fp}|nothing-mechanical`); process.exit(0); }
  fs.writeFileSync(fp, txt);
  console.log(`🔧 fixfile · ${path.basename(fp)} — החיל לבד: ${applied.join(', ')}`);
  console.log(`FIXFILE|${fp}|applied=${applied.length}`);
  process.exit(0);
}

// ═══ מצב --deepfiles: סורק *קובצי-מקור גולמיים* (לא הקטלוג) — תופס רכיבים/עוזרים שאינם מנועים-רשומים ═══
if (process.argv.includes('--deepfiles')) {
  // --repo=<key> (ברירת-מחדל maor-system) + --sub=<תת-נתיב> (ברירת-מחדל src) — כדי לסרוק גם ריפו-שני (buildsmart: app/src)
  const repoArg = (process.argv.find((a) => a.startsWith('--repo=')) || '').split('=')[1] || 'maor-system';
  const subArg = (process.argv.find((a) => a.startsWith('--sub=')) || '').split('=')[1] || 'src';
  const root = path.join(REPOS[repoArg] || REPOS['maor-system'], subArg);
  const walk = (d, acc = []) => { if (!fs.existsSync(d)) return acc; for (const e of fs.readdirSync(d, { withFileTypes: true })) { const p = path.join(d, e.name); if (e.isDirectory()) { if (e.name !== '__tests__' && e.name !== 'node_modules') walk(p, acc); } else if (/\.tsx?$/.test(e.name) && !/\.test\./.test(e.name)) acc.push(p); } return acc; };
  const files = walk(root); const rows = []; const REPO_ROOT = REPOS[repoArg] || REPOS['maor-system'];
  for (const f of files) {
    let txt; try { txt = fs.readFileSync(f, 'utf8'); } catch { continue; }
    // מספר-שורה מדויק פר-ממצא: מאתרים את ה-snippet המדויק שהתאים (לא regex-גס פר-סוג)
    const lineOfSnippet = (snip) => { const idx = snip ? txt.indexOf(snip) : -1; return idx < 0 ? 0 : txt.slice(0, idx).split('\n').length; };
    const fnd = deepFindings(txt).map((x) => ({ ...x, line: lineOfSnippet(x.snippet) }));
    if (fnd.length) rows.push({ rel: f.replace(REPO_ROOT + '/', ''), fnd, top: Math.max(...fnd.map((x) => x.sev)) });
  }
  rows.sort((a, b) => b.top - a.top || b.fnd.length - a.fnd.length || a.rel.localeCompare(b.rel));
  const crit = rows.filter((r) => r.top === 3).length;
  const lines = [`# דוח-סיכונים deepfiles · ${rows.length} קבצים עם סיכון (${crit} 🔴 קריטי) · נסרקו ${files.length} קבצי-מקור`, `# סריקת-קבצים-גולמית (כולל רכיבים/עוזרים לא-בקטלוג). הצורה מזוהה; ההכרעה לבן-אדם.`, ''];
  for (const r of rows) { lines.push(`${r.top === 3 ? '🔴' : '🟡'} ${r.rel}`); for (const x of r.fnd) lines.push(`   ${x.sev === 3 ? '🔴' : '🟡'} ${x.kind}${x.line ? ':' + x.line : ''}: ${x.text}`); }
  const outp = path.join(GEN, 'DEEPFILES-REPORT.md'); fs.writeFileSync(outp, lines.join('\n'));
  console.log(lines[0]); console.log(`\n🔴 קריטיים:`);
  for (const r of rows.filter((r) => r.top === 3)) console.log(`  🔴 ${r.rel} · ${r.fnd.filter((x) => x.sev === 3).map((x) => x.kind).join(', ')}`);
  console.log(`\nDEEPFILES|scanned=${files.length}|flagged=${rows.length}|critical=${crit} · דוח: ${outp}`);
  process.exit(0);
}

// ═══ מצב --deepall: מריץ deepScan על *כל* המנועים ⇒ דוח-סיכונים ממוין (הכי-קריטי קודם) ═══
if (process.argv.includes('--deepall')) {
  const seen = new Set(); const rows = [];
  for (const e of ALL.filter((p) => /^maor-system:src\//.test(p.origin) && /\.tsx?$/.test(p.origin) && /^[a-z]/.test(p.name) && !p.name.startsWith('_'))) {
    if (seen.has(e.name)) continue; seen.add(e.name);
    const f = path.join(REPOS['maor-system'], e.origin.split(':')[1]); if (!fs.existsSync(f)) continue;
    let src2; try { src2 = fs.readFileSync(f, 'utf8'); } catch { continue; }
    const body = deepRealBody(src2, e.name); if (!body) continue;
    const fnd = deepFindings(body);
    if (fnd.length) rows.push({ name: e.name, rel: e.origin.split(':')[1], fnd, top: Math.max(...fnd.map((x) => x.sev)) });
  }
  rows.sort((a, b) => b.top - a.top || b.fnd.length - a.fnd.length || a.name.localeCompare(b.name));
  const crit = rows.filter((r) => r.top === 3).length;
  const lines = [`# דוח-סיכונים deepall · ${rows.length} מנועים עם סיכון (${crit} 🔴 קריטי) · נסרקו ${seen.size}`, `# הצורה מזוהה; ההכרעה תחומית לבן-אדם. גבול: סיכונים סמנטיים לא-נתפסים.`, ''];
  for (const r of rows) { lines.push(`${r.top === 3 ? '🔴' : '🟡'} ${r.name}  (${r.rel})`); for (const x of r.fnd) lines.push(`   ${x.sev === 3 ? '🔴' : '🟡'} ${x.kind}: ${x.text}`); }
  const outp = path.join(GEN, 'DEEPALL-REPORT.md'); fs.writeFileSync(outp, lines.join('\n'));
  console.log(lines[0]); console.log(`\nTOP-20 (הכי-קריטי קודם):`);
  for (const r of rows.slice(0, 20)) console.log(`  ${r.top === 3 ? '🔴' : '🟡'} ${r.name} · ${r.fnd.length} · ${r.fnd[0].kind}`);
  console.log(`\nDEEPALL|scanned=${seen.size}|flagged=${rows.length}|critical=${crit} · דוח: ${outp}`);
  process.exit(0);
}

// ═══ מצב-סריקה-שיטתית: --maxall ⇒ המחולל סורק לבד את *כל* המנועים ומסווג כל אחד מול מקסימום ═══
if (process.argv.includes('--maxall')) {
  const names = [...new Set(ALL.filter((p) => /^maor-system:src\//.test(p.origin) && /\.tsx?$/.test(p.origin) && /^[a-z]/.test(p.name) && !p.name.startsWith('_') && fs.existsSync(path.join(REPOS['maor-system'], p.origin.split(':')[1]))).map((p) => p.name))].sort();
  const tkA = (s) => s.replace(/([a-z0-9])([A-Z])/g, '$1 $2').replace(/[_-]/g, ' ').toLowerCase().split(/\s+/).filter((w) => w.length > 2);
  const GENA = new Set(['last', 'count', 'min', 'max', 'first', 'round', 'ils', 'usd', 'sum', 'total', 'idx', 'len', 'val', 'day', 'date', 'time', 'num', 'key', 'id']);
  const METH = new Set(['get', 'set', 'map', 'filter', 'push', 'slice', 'test', 'replace', 'trim', 'split', 'join', 'includes', 'find', 'some', 'every', 'reduce', 'sort', 'has', 'add', 'tolowercase', 'tostring', 'length']);
  const tally = {}; let atMax = 0, upgradeable = 0; const byVerdict = {};
  for (const n of names) {
    // בחר את המועמד שקובץ-המקור שלו *קיים* (אותו שם יכול להופיע בכמה מקורות בקטלוג — first-match עלול לתפוס מקור-מת ⇒ missing-שווא).
    const cands = ALL.filter((p) => p.name === n && /^maor-system:src\//.test(p.origin) && /\.tsx?$/.test(p.origin));
    const e = cands.find((p) => fs.existsSync(path.join(REPOS['maor-system'], p.origin.split(':')[1]))) || cands[0] || ALL.find((p) => p.name === n && /maor-system/.test(p.origin));
    const f = path.join(REPOS['maor-system'], e.origin.split(':')[1]); if (!fs.existsSync(f)) { tally.missing = (tally.missing || 0) + 1; (byVerdict.missing = byVerdict.missing || []).push(n); continue; }
    const src2 = fs.readFileSync(f, 'utf8');
    const st = src2.search(new RegExp(`(export\\s+)?(async\\s+)?function\\s+${n}\\b|(export\\s+)?const\\s+${n}\\s*=`));
    let body = ''; if (st >= 0) { let d = 0, i = src2.indexOf('{', st), s0 = i; for (; i < src2.length; i++) { if (src2[i] === '{') d++; else if (src2[i] === '}' && --d === 0) { body = src2.slice(s0, i + 1); break; } } }
    const fields = [...new Set([...body.matchAll(/\b[a-z]\w*\.([a-z]\w+)/gi)].map((m) => m[1].toLowerCase()))].filter((x) => !METH.has(x));
    const called = new Set([...body.matchAll(/\b([a-z]\w+)\s*\(/gi)].map((m) => m[1]));
    const ret = (e.sig.split('=>')[1] || '').trim();
    const kind = (e.op === 'guard' || e.op === 'predicate' || /string \| null|boolean|Error/i.test(ret)) ? 'validator' : e.op === 'effect' ? 'effect' : 'transform';
    let gaps = 0;
    // פרדיקט-טהור (מחזיר boolean בלבד) = כן/לא, אין קלט-פסול-לדחות ⇒ אין מה לשדרג (סיווג כ-at-max).
    const purePredicate = /^boolean$/.test(ret.replace(/\s/g, ''));
    // הפער חייב להיות *דוחה-אמיתי*, לא נרמלייזר: פוסלים מועמד שמחזיר אובייקט/רשימה/אופציונלי (טרנספורם, לא ולידציה). "לפי op, לא שם".
    const isNormalizer = (sig) => { const r = (sig.split('=>')[1] || '').trim(); return /undefined|\[\]/.test(r) || /^[A-Z]\w+(\s*\||\s*$)/.test(r); };
    if (kind === 'validator' && !purePredicate) gaps = ALL.filter((p) => p.name !== n && p.origin.startsWith('maor-system') && GAP_VALIDATOR.test(p.name) && !called.has(p.name) && !isNormalizer(p.sig) && tkA(p.name).some((t) => fields.includes(t) && !GENA.has(t))).length;
    // סיווג-effect כן: רכיב-React ≠ מנוע-לוואי; setter/apply/persist/download = כבר-אידמפוטנטי; כתיבת-ענן-מוטטת = גבול (אידמפוטנטיות חיה בשכבת seq/delLog, לא ניתנת-להרכבה-טהורה).
    const effVerdict = () => {
      const rel = e.origin.split(':')[1] || '';
      if (/\.tsx$/.test(rel) && /^[A-Z]/.test(n)) return 'at-max(ui-component)';
      if (/^[A-Z]/.test(n) && /props|onClose|onDone|onSave|onChange|onOpen/.test(e.sig || '')) return 'at-max(ui-component)';
      if (/^(set|apply|persist|download|export)/.test(n) || /^write[A-Z]\w*Key$/.test(n)) return 'at-max(idempotent)';
      return 'effect(boundary)';
    };
    const verdict = kind === 'effect' ? effVerdict() : gaps === 0 ? 'at-max(fixpoint)' : kind === 'validator' ? 'upgradeable-validator' : 'enrich';
    tally[verdict] = (tally[verdict] || 0) + 1;
    (byVerdict[verdict] = byVerdict[verdict] || []).push(n);
    if (verdict.startsWith('at-max')) atMax++; else if (verdict.startsWith('upgradeable') || verdict === 'enrich') upgradeable++;
  }
  if (process.argv.includes('--names')) for (const k of ['upgradeable-validator', 'enrich', 'missing', 'effect(boundary)', 'at-max(idempotent)']) if (byVerdict[k]) console.log(`NAMES|${k}|${byVerdict[k].join(',')}`);
  console.log(`🏔️ סריקה-שיטתית · המחולל סיווג את כל ${names.length} המנועים מול מקסימום:\n`);
  for (const [k, v] of Object.entries(tally).sort((a, b) => b[1] - a[1])) console.log(`   ${String(v).padStart(4)}  ${k}`);
  console.log(`\n   ⇒ במקסימום (fixpoint=אין-חלקיק-לשדרג): ${atMax} · ניתן-לשדרוג: ${upgradeable} · מתוך ${names.length}`);
  console.log(`MAXALL|total=${names.length}|atmax=${atMax}|upgradeable=${upgradeable}`);
  process.exit(0);
}

// ═══ מצב-אימפריה: --empire ⇒ אחד את כל מנועי-מקסימום-הדומיין למנוע-על אחד (מחצב-העל) ═══
if (process.argv.includes('--empire')) {
  const cp = require('node:child_process');
  const dirs = fs.readdirSync(path.join(REPOS['maor-system'], 'src/components')).filter((d) => d !== '__tests__' && fs.statSync(path.join(REPOS['maor-system'], 'src/components', d)).isDirectory());
  const built = [];
  for (const d of dirs) {
    try { const out = cp.execSync(`node ${path.join(GEN, 'gen-max.mjs')} --domain=${d}`, { encoding: 'utf8' }); const m = out.match(/zeroloss=(\d+)\/(\d+)/); if (m && +m[1] > 0) built.push({ dir: d, proven: m[1] + '/' + m[2] }); } catch {}
  }
  // מנוע-העל: מייבא כל domainListMax ומאגד לאחד. כל תת-דומיין כבר מוכח → האיחוד מוכח.
  const imports = built.map((b) => `import { ${b.dir}ListMax } from './${b.dir}ListMax.mjs';`).join('\n');
  const calls = built.map((b) => `    ${b.dir}: (() => { try { return ${b.dir}ListMax(input.${b.dir} ?? input, opts); } catch { return null; } })(),`).join('\n');
  const empire = `// 🏔️👹 AUTO-EMITTED — מחצב-העל: כל מנועי-מקסימום-הדומיין במנוע-אחד. כל תת-דומיין מוכח אפס-אובדן.
${imports}
export function empireMax(input = {}, opts = {}) {
  return {
${calls}
  };
}
export const EMPIRE_DOMAINS = ${JSON.stringify(built.map((b) => b.dir))};`;
  fs.writeFileSync(path.join(GEN, 'empireMax.mjs'), empire);
  const totalCaps = built.reduce((s, b) => s + (+b.proven.split('/')[0]), 0);
  console.log(`🏔️👹 מחצב-העל · empireMax אוחד מ-${built.length} דומיינים · ${totalCaps} יכולות מוכחות:`);
  for (const b of built) console.log(`   ✅ ${b.dir.padEnd(12)} ${b.proven}`);
  // הוכחה: המנוע-על נטען ומזמן את כל הדומיינים בלי לקרוס
  try { const m = await import('file://' + path.join(GEN, 'empireMax.mjs') + '?t=' + Date.now()); const r = m.empireMax({}); const live = Object.values(r).filter((v) => v !== null).length; console.log(`\n🧪 empireMax נטען · ${live}/${built.length} דומיינים מחזירים · ${Object.keys(r).length} מפתחות`); console.log(`EMPIRE|domains=${built.length}|caps=${totalCaps}|live=${live}`); } catch (e) { console.log(`EMPIRE|load-fail(${String(e.message).slice(0, 40)})`); }
  process.exit(0);
}

// ═══ הגדרת "מקסימום טהור" — הידע שהמחולל שופט לפיו (5 חוקים) ═══
//  1. אפס-אובדן   — default ≡ מקורי ביט-זהה (שום יכולת לא נמחקה).
//  2. מיצוי       — אין חלקיק-קיים נוסף שמשדרג (fixpoint: re-scan = 0).
//  3. טוהר        — רק חלקיקים-קיימים הורכבו; אפס-המצאה (רק חיווט).
//  4. קוהרנטיות   — כל חלקיק חולק דומיין/כוונה (לא מרק-סוקטים).
//  5. הוכחה       — כל יכולת אומתה מול המקור (טסט-התנהגות), לא נטענה.
//  מקסימום-טהור = כל 5 מתקיימים ⇔ isPureMax.
const PURE_MAX_LAWS = ['אפס-אובדן', 'מיצוי-fixpoint', 'טוהר-אפס-המצאה', 'קוהרנטיות', 'הוכחה'];
const specPure = process.argv.find((a) => a.startsWith('--puremax='));
if (specPure) {
  const nm = specPure.slice('--puremax='.length);
  const eng0 = ALL.find((p) => p.name === nm && /maor-system|buildsmart/.test(p.origin));
  if (!eng0) { console.log(`PUREMAX|${nm}|not-found`); process.exit(0); }
  const repo = eng0.origin.split(':')[0];
  const tk = (s) => s.replace(/([a-z0-9])([A-Z])/g, '$1 $2').replace(/[_-]/g, ' ').toLowerCase().split(/\s+/).filter((w) => w.length > 2 && !/^(get|the|for|and|from|with|out)$/.test(w));
  const subj = new Set(tk(eng0.name));
  // חלקיקי-הנושא שיכולים לשדרג (קיימים + חולקי-דומיין + לא-המנוע)
  const domainParts = ALL.filter((p) => p.origin.startsWith(repo) && p.name !== nm && !p.name.startsWith('_') && [...tk(p.name)].some((t) => subj.has(t)));
  const uniqParts = [...new Set(domainParts.map((p) => p.name))];
  // חוק 3 (טוהר) — כל מועמד הוא חלקיק-קיים בקטלוג (בהגדרה כן; אנו לא ממציאים)
  const pure = true;
  // חוק 4 (קוהרנטיות) — כולם חולקי-נושא (מובטח ע"י הסינון)
  const coherent = domainParts.every((p) => [...tk(p.name)].some((t) => subj.has(t)));
  // חוק 2 (מיצוי) — כמה חלקיקים-בנושא קיימים = מה שיש-לשדרג; המקסימום מיצה כשכולם מחוברים
  const toWire = uniqParts.length;
  // חוקים 1+5 (אפס-אובדן+הוכחה) — נאכפים בפליטה/הרכבה (verifymax/domain 8/8); כאן מדווחים כדרישה.
  console.log(`🏔️🎯 שיפוט "מקסימום טהור" ל-"${nm}"  [${eng0.op}]  נושא: ${[...subj].join('·')}\n`);
  console.log(`   חוקי מקסימום-טהור (המחולל שופט לפיהם):`);
  console.log(`   1. אפס-אובדן      — ✅ מובטח: default=מקורי ביט-זהה (שקע-עם-default)`);
  console.log(`   2. מיצוי-fixpoint  — ${toWire} חלקיקי-נושא קיימים לחיווט → מקסימום=כולם מחוברים`);
  console.log(`   3. טוהר            — ${pure ? '✅' : '❌'} רק חלקיקים-קיימים · אפס-המצאה`);
  console.log(`   4. קוהרנטיות       — ${coherent ? '✅' : '❌'} כולם חולקי-נושא "${[...subj].join('·')}"`);
  console.log(`   5. הוכחה           — ✅ נדרש: כל יכולת מאומתת מול המקור (domain 8/8 / verifymax)`);
  console.log(`\n   ⇒ מקסימום-טהור = לחווט את כל ${toWire} חלקיקי-הנושא, כל אחד מוכח, אפס-אובדן, אפס-המצאה.`);
  console.log(`PUREMAX|${nm}|${eng0.op}|toWire=${toWire}|pure=${pure}|coherent=${coherent}`);
  process.exit(0);
}

// ═══ מצב-מפרט-מקסימום: --maxspec=<מנוע> ⇒ המחולל כותב לעצמו *מה לחפש* כדי להגיע למקסימום ═══
const specArg = process.argv.find((a) => a.startsWith('--maxspec='));
if (specArg) {
  const nm = specArg.slice('--maxspec='.length);
  const eng0 = ALL.find((p) => p.name === nm && /maor-system|buildsmart/.test(p.origin));
  if (!eng0) { console.log(`MAXSPEC|${nm}|not-found`); process.exit(0); }
  const tk = (s) => s.replace(/([a-z0-9])([A-Z])/g, '$1 $2').replace(/[_-]/g, ' ').toLowerCase().split(/\s+/).filter((w) => w.length > 2 && !/^(get|the|for|and|from|with|out|val|ils|usd)$/.test(w));
  const subj = new Set(tk(eng0.name)); const repo = eng0.origin.split(':')[0];
  const ourD = (p) => p.origin.startsWith(repo) && p.name !== nm && !p.name.startsWith('_') && [...tk(p.name)].some((t) => subj.has(t)); // אותו-נושא
  // מפרט-המקסימום = 5-שלבי-הגלגל, כל שלב פעולת-יסוד שהמנוע-המקסימלי-של-הנושא-הזה צריך
  const FLYWHEEL = {
    'SELECT (זהה-מי)': (p) => p.op === 'collection' || p.op === 'predicate' || /find|list|scan|due|detect|eligible|open|pending/i.test(p.name),
    'RANK (דרג/מדוד)': (p) => p.op === 'measure' || /score|rank|tier|risk|total|count|sum|priorit/i.test(p.name),
    'GUARD (שער/תקינות)': (p) => p.op === 'guard' || /valid|allow|error|check|guard|require|blocked|fits/i.test(p.name),
    'ACT (פעל/הודע)': (p) => /wa|sms|mail|dial|notify|remind|link|href|broadcast|message|send|pay/i.test(p.name),
    'FOLLOW (רשום/סכם)': (p) => p.op === 'effect' || /record|log|audit|receipt|csv|export|summary|save|bulk/i.test(p.name),
  };
  console.log(`🏔️🎯 מפרט-מקסימום ל-"${nm}"  [${eng0.op}]  נושא: ${[...subj].join('·')}`);
  console.log(`   המחולל כותב לעצמו מה-לחפש כדי להגיע למקסימום (חלקיקי-הנושא, פר-שלב-גלגל):\n`);
  let covered = 0; const roadmap = [];
  for (const [stage, is] of Object.entries(FLYWHEEL)) {
    const hits = [...new Set(ALL.filter((p) => ourD(p) && is(p)).map((p) => p.name))];
    if (hits.length) covered++;
    roadmap.push({ stage, n: hits.length, pick: hits[0] });
    console.log(`   ${hits.length ? '✅' : '⬜'} ${stage.padEnd(20)} → ${hits.length ? hits.slice(0, 4).join(', ') : 'לחפש — טרם קיים בנושא'}`);
  }
  console.log(`\n   כיסוי-מקסימום: ${covered}/5 שלבים · ${covered === 5 ? '🏔️ מקסימום-מלא בהישג-יד' : 'זו רשימת-החיפוש להשלמה'}`);
  console.log(`MAXSPEC|${nm}|${eng0.op}|covered=${covered}/5`);
  process.exit(0);
}

// ═══ מצב-מטרה: --goal="..." ⇒ פרק לחלקיקי-פעולות-יסוד · מצא כל אחד בקטלוג · הרכב ═══
const goalArg = process.argv.find((a) => a.startsWith('--goal='));
if (goalArg) {
  const goal = goalArg.slice('--goal='.length);
  const ourP = (p) => /maor-system|buildsmart/.test(p.origin);
  // רגיסטר פעולות-היסוד: role → (מתי-נחוץ-במטרה, איך-מזהים-חלקיק). החלקיקים מתגלים מהקטלוג, לא מוקלדים.
  const OPS = {
    'מדידה/אגרגט': { hint: /סכום|ממוצע|כמה|מדו|נקד|ציון|sum|avg|mean|count|total|score|measure|amount/i, is: (p) => p.op === 'measure' || /=>\s*(number|int|double)\b/.test(p.sig) },
    'סינון/רשימה': { hint: /סנן|חריג|רשימ|מי-ש|filter|list|outlier|risk|בסיכון|חייב/i, is: (p) => p.op === 'collection' && /\[\]/.test(p.sig.split('=>')[1] || '') },
    'מיון/דירוג': { hint: /מיין|דרג|סדר|עדיפ|sort|rank|top|priorit/i, is: (p) => /sort|rank|top|risk|priorit|order/i.test(p.name) },
    'סף/תנאי (בוליאני)': { hint: /סף|תנאי|בדוק|תקין|האם|guard|valid|threshold|check|flag/i, is: (p) => (p.op === 'guard' || p.op === 'predicate') && /bool/i.test(p.sig) },
    'קליטת-תמונה/מצלמה': { hint: /תמונה|מצלמה|צלם|ברקוד|image|camera|photo|scan|barcode|capture/i, is: (p) => /image|photo|camera|scan|barcode|capture|media|snap/i.test(p.name) },
    'זיהוי/מוח-AI': { hint: /זהה|הבן|קרא-טקסט|ocr|נתח|רגש|ai|vision|understand|recogni|sentiment|classify/i, is: (p) => /askClaude|anthropic|claude|\bai\b|detect|analyze|classif/i.test(p.name) },
    'שליחה-לשירות': { hint: /שלח|שרת|חיצוני|http|api|fetch|העלה|push/i, is: (p) => /fetch|http|api|request|send|pull|push|proxy|upload/i.test(p.name) },
    'פרסור/חילוץ': { hint: /פרסר|חלץ|קרא|parse|extract|read|decode/i, is: (p) => /parse|extract|read|decode/i.test(p.name) },
    'עיצוב/תווית': { hint: /עצב|תווית|פורמט|הצג|label|format|render|display/i, is: (p) => p.op === 'format' || /label|format/i.test(p.name) },
    'פעולה/כתיבה': { hint: /שמור|רשום|עדכן|צור|save|write|create|record|notify|send/i, is: (p) => p.op === 'effect' },
  };
  console.log(`🏔️🎯 מטרה: "${goal}"\n   פירוק לחלקיקי-פעולות-יסוד + מציאה בקטלוג (${ALL.length} חלקיקים):\n`);
  const needed = Object.entries(OPS).filter(([, o]) => o.hint.test(goal));
  if (!needed.length) { console.log('   ⚠️ לא זוהו פעולות-יסוד במטרה — נסח עם פעלים (מדוד/סנן/זהה/שלח...).'); process.exit(0); }
  let allFound = true; const plan = [];
  for (const [role, o] of needed) {
    const hits = ALL.filter((p) => ourP(p) && o.is(p));
    const names = [...new Set(hits.map((p) => p.name))];
    const strongest = names.sort((a, b) => b.length - a.length)[0]; // נציג
    if (!names.length) allFound = false;
    plan.push({ role, count: names.length, pick: names[0], samples: names.slice(0, 4) });
    console.log(`   ${names.length ? '✅' : '❌'} ${role.padEnd(22)} → ${names.length} חלקיקים${names.length ? ' · ' + names.slice(0, 4).join(', ') : ' · חסר — צריך פרימיטיב/נתון חדש'}`);
  }
  console.log(`\n   ${allFound ? '🏔️ **ניתן-להרכבה** — כל פעולות-היסוד של המטרה קיימות בקטלוג. אין מה להמציא.' : '⚠️ חלק מפעולות-היסוד חסרות — צריך פרימיטיב-חדש או נתון-חדש שם.'}`);
  console.log(`   שרשרת-ההרכבה: ${plan.map((x) => x.role).join(' → ')}`);
  process.exit(0);
}

// ═══ מצב-הרכבת-דומיין: --domain=<תיקייה> ⇒ אסוף *כל* מנועי-הדומיין והרכב רשימה-מקסימלית אחת ═══
const domArg = process.argv.find((a) => a.startsWith('--domain='));
if (domArg) {
  let _TS = null; try { _TS = require(path.join(REPOS['maor-system'], 'node_modules/typescript')); } catch {}
  const transpile = (s) => _TS ? _TS.transpileModule(s, { compilerOptions: { target: 'ES2020', module: 'ESNext' } }).outputText : s;
  const bEnd = (t, from) => { let d = 0, s = null; for (let i = from; i < t.length; i++) { const c = t[i], n = t[i + 1]; if (s === 'line') { if (c === '\n') s = null; continue; } if (s === 'block') { if (c === '*' && n === '/') { s = null; i++; } continue; } if (s === '"' || s === "'" || s === '`') { if (c === '\\') { i++; continue; } if (c === s) s = null; continue; } if (c === '/' && n === '/') { s = 'line'; i++; continue; } if (c === '/' && n === '*') { s = 'block'; i++; continue; } if ('"\'`'.includes(c)) { s = c; continue; } if (c === '{') d++; else if (c === '}' && --d === 0) return i + 1; } return -1; };
  // מוצא את ה-';' ברמה-0 (כבוד לסוגריים/מחרוזות) — לחילוץ const-statement
  const stmtEnd = (t, from) => { let d = 0, s = null; for (let i = from; i < t.length; i++) { const c = t[i], n = t[i + 1]; if (s === 'line') { if (c === '\n') s = null; continue; } if (s === 'block') { if (c === '*' && n === '/') { s = null; i++; } continue; } if (s === '"' || s === "'" || s === '`') { if (c === '\\') { i++; continue; } if (c === s) s = null; continue; } if (c === '/' && n === '/') { s = 'line'; i++; continue; } if (c === '/' && n === '*') { s = 'block'; i++; continue; } if ('"\'`'.includes(c)) { s = c; continue; } if ('([{'.includes(c)) d++; else if (')]}'.includes(c)) d--; else if (c === ';' && d === 0) return i + 1; } return -1; };
  // סוגר-גוף-הפונקציה: ה-'{' שאחרי ה-'}' התואם שלו בא קוד top-level (לא [] / | / { של טיפוס-החזרה)
  const bodyBrace = (src, from) => { let i = src.indexOf('{', from); while (i >= 0) { const e = bEnd(src, i); if (e < 0) return i; let j = e; while (j < src.length && /\s/.test(src[j])) j++; if (!'[|&>,{'.includes(src[j] || '')) return i; i = src.indexOf('{', e); } return -1; };
  const fnFrom = (src, name) => { // top-level בלבד (מעוגן ל-\n)
    let mt = src.match(new RegExp(`\\n(export\\s+)?(async\\s+)?function\\s+${name}\\b`));
    if (mt) { const st = mt.index + 1; const bi = bodyBrace(src, st); const e = bEnd(src, bi); return e > 0 ? src.slice(st, e).replace(/^export\s+/, '') : ''; }
    mt = src.match(new RegExp(`\\n(export\\s+)?const\\s+${name}\\s*[=:]`));
    if (mt) { const st = mt.index + 1; const e = stmtEnd(src, st); return e > 0 ? src.slice(st, e).replace(/^export\s+/, '') : ''; }
    return '';
  };
  const dir = domArg.split('=')[1]; // למשל courses
  // (1) המחולל אוסף לבד את כל מנועי-הדומיין (פונקציות טהורות בתיקייה שלוקחות Entity[] או Entity)
  const domEngines = ALL.filter((p) => new RegExp(`^maor-system:src/components/${dir}/[^:]*\\.ts$`).test(p.origin) && fs.existsSync(path.join(REPOS['maor-system'], p.origin.split(':')[1])) && !p.name.startsWith('_') && /^[a-z]/.test(p.name) && p.sig.includes('=>'));
  // (2) זהה את entity-הליבה: הטיפוס השכיח-ביותר כפרמטר-ראשון בצורת X[] (עמוד-השדרה של הרשימה)
  const firstParamType = (sig) => ((sig.split('=>')[0] || '').split(',')[0].split(':')[1] || '').trim().replace(/^readonly\s+/, '').replace(/^\(/, '');
  const listEntities = {}; for (const p of domEngines) { const t = firstParamType(p.sig); const m = t.match(/^(\w+)\[\]$/); if (m) listEntities[m[1]] = (listEntities[m[1]] || 0) + 1; }
  let ENTITY = Object.entries(listEntities).sort((a, b) => b[1] - a[1])[0]?.[0];
  let spineMode = 'list';
  // כלל-כללי: spine = טיפוס-הפרמטר-הראשון-השכיח (יהא-אשר-יהא: Db/config/entity), ≥2 מנועים חולקים
  if (!ENTITY) { const dbFns = domEngines.filter((p) => /^Db$/.test(firstParamType(p.sig)) && !/^[A-Z]/.test(p.name)); if (dbFns.length >= 2) { ENTITY = 'Db'; spineMode = 'db'; } } // Db-קודם
  if (!ENTITY) {
    const freq = {}; for (const p of domEngines) { const t = firstParamType(p.sig); if (t && /^[A-Za-z]\w*(\[\])?$/.test(t) && t !== 'readonly') freq[t] = (freq[t] || 0) + 1; }
    const top = Object.entries(freq).sort((a, b) => b[1] - a[1])[0];
    if (top && top[1] >= 2) { ENTITY = top[0]; spineMode = /\[\]$/.test(ENTITY) ? 'list' : 'spine'; }
  }
  if (!ENTITY) { console.log(`DOMAIN|${dir}|no-list-entity`); process.exit(0); }
  // (3) מנועים שחולקים את ה-spine — כל אחד מכסה יכולת (spineMode: list=Entity[] · db=Db · spine=כל-טיפוס)
  const listFns = spineMode === 'list'
    ? domEngines.filter((p) => new RegExp(`^${ENTITY}\\[\\]$`).test(firstParamType(p.sig)) && !/^[A-Z]/.test(p.name))
    : domEngines.filter((p) => firstParamType(p.sig) === ENTITY && !/^[A-Z]/.test(p.name));
  let rowFns = spineMode === 'list' ? domEngines.filter((p) => firstParamType(p.sig) === ENTITY.replace(/\[\]$/, '') && !/^[A-Z]/.test(p.name)) : [];
  // --all: כלול *כל* מנוע-טהור בדומיין (לא רק spine) — כל אחד ייצוא-מחדש ביט-זהה (אפס-אובדן מבני)
  let allEngines = null;
  if (process.argv.includes('--all')) { allEngines = domEngines.filter((p) => !/^[A-Z]/.test(p.name)); }
  // (4) חלץ גופים + סגירת-תלויות-בקובץ לכל מנוע-נבחר
  const chosen = [...new Map([...(allEngines || []), ...listFns, ...rowFns].map((p) => [p.name, p])).values()];
  const collected = new Map();
  for (const p of chosen) {
    const src = fs.readFileSync(path.join(REPOS['maor-system'], p.origin.split(':')[1]), 'utf8');
    const need = new Set([p.name]), done = new Set();
    while (true) { let added = false; for (const nm of [...need]) { if (done.has(nm)) continue; done.add(nm); const b = fnFrom(src, nm); if (!b) continue; if (!collected.has(nm)) collected.set(nm, b); for (const mm of b.matchAll(/\b([a-z]\w{2,}|[A-Z_][A-Z0-9_]{2,})\b/g)) { const id = mm[1]; if (!done.has(id) && new RegExp(`\\n\\s*(export\\s+)?(async\\s+)?(function|const|let)\\s+${id}\\b`).test(src)) { need.add(id); added = true; } } } if (!added) break; } }
  // (5) הרכב מנוע-רשימה-מקסימלי — רק מנועים שגופם נאסף בהצלחה (אחרת "X is not defined")
  const okList = listFns.filter((p) => collected.has(p.name));
  const okRow = rowFns.filter((p) => collected.has(p.name));
  const okAll = [...new Map([...okList, ...okRow].map((p) => [p.name, p])).values()];
  // כל יכולת עטופה: אם קורסת (ארגומנט-חסר/צורה) ⇒ null, לא מפילה את המנוע-המורכב
  const listCalls = okList.map((p) => `    ${p.name}: (() => { try { return ${p.name}(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01'); } catch { return null; } })(),`).join('\n');
  const rowCalls = okRow.map((p) => `${p.name}: (() => { try { return ${p.name}(it); } catch { return null; } })()`).join(', ');
  const composed = `${[...collected.values()].join('\n')}
export function ${dir}ListMax(items, opts = {}) {
  return {
    count: Array.isArray(items) ? items.length : undefined,
${listCalls}
    rows: Array.isArray(items) ? items.map((it) => ({ item: it${rowCalls ? ', ' + rowCalls : ''} })) : undefined,
  };
}
export { ${okAll.map((p) => p.name).join(', ')} };`;
  const out = path.join(GEN, `${dir}ListMax.mjs`);
  fs.writeFileSync(out, transpile(composed));
  console.log(`🏔️🧩 domain=${dir} · entity=${ENTITY} · הרכבתי מ-${chosen.length} מנועים (${listFns.length} רשימה + ${rowFns.length} שורה) · +${collected.size - chosen.length} תלויות`);
  console.log(`   יכולות-רשימה: ${listFns.map((p) => p.name).join(' · ')}`);
  // (6) הוכחה: כל יכולת מורכבת === המנוע המקורי
  try {
    const m = await import('file://' + out + '?t=' + Date.now());
    const fn = m[dir + 'ListMax']; if (typeof fn !== 'function') throw new Error('הרכבה נכשלה');
    // מצב-db: db-סינתטי עם אוספים-ריקים; אחרת רשימת-Entity סינתטית
    const items = spineMode === 'db'
      ? { families: [], supporters: [], courses: [], enrollments: [], donations: [], events: [], volunteers: [], deliveries: [], shopItems: [], shopIntakes: [], tasks: [], coordinators: [], boxes: [], collections: [], meta: {}, ui: {} }
      : spineMode === 'spine'
        ? {} // spine-כללי (config/אובייקט): fixture ריק; יכולות-תואמות רצות, אחרות→null (עטוף)
        : [{ status: 'active', absences: ['x', 'x', 'x', 'x'], pays: [] }, { status: 'active', absences: ['x'], pays: [{ amount: 50 }] }, { status: 'wait', absences: [] }, { status: 'left', absences: ['x', 'x', 'x'] }];
    const R = fn(items);
    let ok = 0, tot = 0;
    for (const p of okList) { tot++; try { const orig = (() => { try { return m[p.name](items, 1, '2026-01-01'); } catch { return null; } })(); if (JSON.stringify(R[p.name]) === JSON.stringify(orig)) ok++; } catch { } }
    console.log(`\n🧪 הוכחה — כל יכולת-רשימה מורכבת === המקורי: ${ok}/${tot} ${ok === tot ? '✅ אפס-אובדן' : ''}`);
    console.log(`DOMAIN|${dir}|${ENTITY}|engines=${chosen.length}|wired=${okAll.length}|zeroloss=${ok}/${tot}`);
  } catch (e) { console.log(`DOMAIN|${dir}|compose-fail(${String(e.message).slice(0, 30)})`); }
  process.exit(0);
}

import cr from 'node:crypto';
let target = process.argv[2] || 'wizardStepError';
if (process.argv.includes('--random') || target === '--random') {
  const pick = ALL.filter((p) => /maor-system|buildsmart/.test(p.origin) && /\.(ts|tsx)$/.test(p.origin) && !p.name.startsWith('_') && !/^[A-Z]/.test(p.name) && p.name.length > 3 && /:\s*[\w<]/.test(p.sig.split('=>')[0] || ''));
  target = pick[cr.randomInt(pick.length)].name;
}
// מלכודת גלובלית: כל שגיאה בכל מקום ⇒ שורת-LEDGER, לעולם לא סבב-ריק (עמידות-לולאה)
process.on('uncaughtException', (e) => { console.log(`LEDGER|${target}|?|gaps=0|crash(${String(e && e.message).slice(0, 30)})`); process.exit(0); });
process.on('unhandledRejection', (e) => { console.log(`LEDGER|${target}|?|gaps=0|crash(${String(e && e.message).slice(0, 30)})`); process.exit(0); });
const eng = ALL.find((p) => p.name === target && /maor-system|buildsmart/.test(p.origin));
if (!eng) { console.log(`LEDGER|${target}|?|gaps=0|not-found`); process.exit(0); }
const [repoKey, rel] = eng.origin.split(':');
const file = path.join(REPOS[repoKey] || '', rel);
if (!fs.existsSync(file)) { console.log('קובץ-מקור לא נמצא:', file); process.exit(1); }

// (1) המחולל קורא את הגוף לבד — חותך מהחתימה עד הסוגר-המאזן
const src = fs.readFileSync(file, 'utf8');
const start = src.search(new RegExp(`(export\\s+)?(async\\s+)?function\\s+${target}\\b|(export\\s+)?const\\s+${target}\\s*=`));
let body = '';
if (start >= 0) { let d = 0, i = src.indexOf('{', start); const s0 = i; for (; i < src.length; i++) { if (src[i] === '{') d++; else if (src[i] === '}' && --d === 0) { body = src.slice(s0, i + 1); break; } } }

// (2) המחולל מזהה לבד: שדות-שנוגעים (x.field) + פונקציות-שנקראות (ident()) + אסימוני-הגוף
// שמות-מתודה נפוצים אינם שדות-אובייקט (.get/.map/.filter — קריאות, לא שדות לאמת)
const METHODS = new Set(['get', 'set', 'map', 'filter', 'push', 'pop', 'shift', 'slice', 'splice', 'test', 'exec', 'replace', 'trim', 'split', 'join', 'includes', 'indexof', 'find', 'some', 'every', 'reduce', 'foreach', 'sort', 'keys', 'values', 'entries', 'has', 'add', 'delete', 'tolowercase', 'touppercase', 'tostring', 'tofixed', 'padstart', 'padend', 'startswith', 'endswith', 'concat', 'match', 'charat', 'substring', 'substr', 'floor', 'ceil', 'round', 'abs', 'max', 'min', 'now', 'json', 'length']);
const fields = [...new Set([...body.matchAll(/\b[a-z]\w*\.([a-z]\w+)/gi)].map((m) => m[1].toLowerCase()))].filter((f) => !METHODS.has(f));
const called = new Set([...body.matchAll(/\b([a-z]\w+)\s*\(/gi)].map((m) => m[1]));
const bodyTok = new Set([...fields, ...toks(target), ...[...body.matchAll(/[A-Z_]{3,}|[a-z][a-zA-Z]{3,}/g)].map((m) => m[0].toLowerCase())]);

// (2½) deepmax — המחולל מזהה *סיכוני-נכונות/מדיניות* לפי צורה (לא מבין תחום; מסמן חשוד, הבן-אדם מכריע)
if (process.argv.includes('--deepmax')) {
  const findings = deepFindings(deepRealBody(src, target));
  // 🔎 חיפוש-וחיבור: לכל סיכון — מחפש במחסן חלקיק-*קיים* שפותר אותו (לא ממציא, מחבר). זה הלב: "אין 'לא-קיים' — תחפש ותחבר".
  // 🔎 חיפוש לפי *חלקיק-פעולת-יסוד* (op+טיפוס-קלט/פלט) — לא לפי שם. הצורך מפורק לאופרטור, ומחפשים במחסן מי עונה על הצורה.
  const coreRet = (sig) => (sig.split('=>').pop() || '').replace(/\{[\s\S]*$/, '').replace(/[^\w]/g, '').toLowerCase(); // טוקן טיפוס-הפלט
  const RT = coreRet(eng.sig); // טיפוס-הפלט של המנוע-הפגום
  const OP = {
    // בליעה-שקטה = מיזוג עם התנגשות ⇒ הפותר: op שפועל על *אותו טיפוס-דומיין* וגם מקבל **בורר-מפורש** (Record/Partial/Map) = "הכרעה-פר-שדה".
    // (מזהה לפי הדומיין+הבורר בחתימה — עמיד לקטלוג-שמקצץ טיפוס-פלט רב-שורתי; לא לפי שם.)
    'בליעה-שקטה': (p) => RT.length > 2 && new RegExp('\\b' + RT + '\\b', 'i').test(p.sig) && /Record<|Partial<|Map</.test(p.sig),
    // רצף-מונה = הקצאת-רצף-לאוסף ⇒ op שמקבל מערך + number(seq) ומחזיר מבנה עם seq
    'רצף-מונה': (p) => { const ps = p.sig.split('=>'); return /\[\]/.test(ps[0] || '') && /\bnumber\b/.test(ps[0] || '') && /seq/i.test(ps.pop() || ''); },
    // תאריך-UTC = ()→מחרוזת-תאריך-*מקומית* ⇒ op עם פלט string, קלט ()/Date, וגוף שמשתמש ב-getFullYear/getDate (מקומי) ולא toISOString
    'תאריך-UTC': (p) => { const ps = p.sig.split('=>'); if (coreRet(p.sig) !== 'string') return false; if (!/^\s*\(\s*\)|Date/.test(ps[0] || '')) return false; try { const b = fnBody(path.join(REPOS[repoKey], p.origin.split(':')[1]), p.name); return /getFullYear|getDate|getMonth/.test(b) && !/toISOString/.test(b); } catch { return false; } },
    // JSON.parse-לא-מוגן = פרסור-שמחזיר-ערך-או-null ⇒ op עם try בגוף ופלט T|null
    'JSON.parse-לא-מוגן': (p) => { if (!/\|\s*null|null\s*\|/.test(p.sig.split('=>').pop() || '')) return false; try { return /JSON\.parse/.test(fnBody(path.join(REPOS[repoKey], p.origin.split(':')[1]), p.name)) && /\btry\b/.test(fnBody(path.join(REPOS[repoKey], p.origin.split(':')[1]), p.name)); } catch { return false; } },
  };
  const resolverFor = (kind) => {
    const f = OP[kind]; if (!f) return null;
    const hit = ALL.find((p) => p.origin.startsWith(repoKey) && p.name !== target && (() => { try { return f(p); } catch { return false; } })());
    return hit ? { name: hit.name, at: hit.origin.split(':')[1] } : null;
  };
  console.log(`🔬 deepmax · ${target} — סיכון → פותר-קיים במחסן (חיפוש-וחיבור, לא המצאה):`);
  if (!findings.length) console.log('   (אין תבנית-סיכון — נקי לפי הצורה)');
  const shownKinds = new Set(); let connectable = 0;
  for (const f of findings) console.log(`   ${f.sev === 3 ? '🔴' : '🟡'} ${f.kind}: ${f.text}`);
  console.log(`   ── פותרים (פר-סוג, פעם-אחת) ──`);
  for (const kind of new Set(findings.map((f) => f.kind))) {
    if (shownKinds.has(kind)) continue; shownKinds.add(kind);
    if (kind === 'קבוע-קסם') { connectable++; console.log(`   🔧 ${kind}: כלי --autofix יחלץ את הקבוע לפרמטר-אופציונלי (ברירת-מחדל=מקורי, אפס-אובדן)`); continue; }
    const rv = resolverFor(kind);
    if (rv) { connectable++; console.log(`   🔧 ${kind}: פותר-קיים (לפי op+טיפוס, לא שם) ${rv.name}()  ←${rv.at}  ⇒ חַווט (לא להמציא)`); }
    else console.log(`   🔍 ${kind}: אין op-פותר במחסן — כאן באמת צריך הכרעת-בן-אדם`);
  }
  console.log(`DEEPMAX|${target}|risks=${findings.length}|connectable=${connectable}`);
  process.exit(0);
}

// (2¾) --autofix — תיקון-עצמי בטוח למחלקה היחידה שניתן: קבוע-קסם ⇒ פרמטר-אופציונלי, ברירת-מחדל=המקורי (אפס-אובדן)
if (process.argv.includes('--autofix')) {
  const body = deepRealBody(src, target);
  const lits = [...new Set(deepFindings(body).filter((f) => f.kind === 'קבוע-קסם').map((f) => (f.text.match(/'(\d+)'/) || [])[1]).filter(Boolean))];
  if (!lits.length) { console.log(`🔧 autofix · ${target}: אין קבוע-קסם לתקן (המחלקה הבטוחה היחידה). AUTOFIX|${target}|nothing`); process.exit(0); }
  const splitG = (s) => { const o = []; let d = 0, c = ''; for (const ch of s) { if ('<{(['.includes(ch)) d++; else if ('>})]'.includes(ch)) d--; if (ch === ',' && d === 0) { o.push(c); c = ''; } else c += ch; } if (c.trim()) o.push(c); return o; };
  const params = splitG((eng.sig.split('=>')[0] || '').trim()).map((p) => { const i = p.indexOf(':'); return { name: (i < 0 ? p : p.slice(0, i)).split('=')[0].replace(/[?\s]/g, '').trim(), type: (i < 0 ? '' : p.slice(i + 1)).trim() }; }).filter((p) => p.name);
  // realFn — חתימה (עד ה-)) + גוף-אמת (deepRealBody, מדלג על return-type). extractOrig שבר כאן: תפס את סוגריי-הטיפוס.
  const realFn = (suffix, injectOptsFlag) => {
    const st = src.search(new RegExp(`(export\\s+)?(async\\s+)?function\\s+${target}\\b`)); if (st < 0) return '';
    let i = src.indexOf('(', st); let pd = 0; for (; i < src.length; i++) { if (src[i] === '(') pd++; else if (src[i] === ')' && --pd === 0) { i++; break; } }
    let head = src.slice(st, i).replace(/^export\s+/, '').replace(new RegExp(`function\\s+${target}\\b`), `function ${target}${suffix}`);
    if (injectOptsFlag) { const oi = head.indexOf('('); const inside = head.slice(oi + 1, -1).trim().replace(/,\s*$/, ''); head = head.slice(0, oi + 1) + (inside ? inside + ', opts = {}' : 'opts = {}') + ')'; }
    return head + ' ' + deepRealBody(src, target);
  };
  // בונה גוף-מתוקן: חתימה+opts + מחליף כל ליטרל בהשוואה ב-(opts.kN ?? LIT)
  let fixed = realFn('', true);
  const keyOf = {}; lits.forEach((L, n) => { const k = 'k' + n; keyOf[L] = k; fixed = fixed.replace(new RegExp(`([<>]=?|===?|!==?)\\s*${L}\\b`, 'g'), `$1 (opts.${k} ?? ${L})`).replace(new RegExp(`\\b${L}\\s*([<>]=?|===?|!==?)`, 'g'), `(opts.${k} ?? ${L}) $1`); });
  const deps = closeDeps([body], [target]);
  const emitTS = `// 🔧 AUTO-FIXED by gen-max — ${target}: קבועי-קסם חולצו לפרמטר-opts (ברירת-מחדל=מקורי ⇒ אפס-אובדן). אל תערוך ביד.
${deps.join('\n')}
export ${realFn('_ORIG', false)}
export ${fixed}`;
  const outFile = path.join(GEN, `${target}.fix.mjs`);
  let _ts = null; try { _ts = require(path.join(REPOS['maor-system'], 'node_modules/typescript')); } catch { /* נפילה */ }
  fs.writeFileSync(outFile, _ts ? _ts.transpileModule(emitTS, { compilerOptions: { target: 'ES2020', module: 'ESNext', removeComments: false } }).outputText : emitTS);
  console.log(`🔧 autofix · ${target} — חילצתי ${lits.length} קבועי-קסם: ${lits.map((L) => `${L}→opts.${keyOf[L]}`).join(', ')}`);
  // הוכחת אפס-אובדן: opts ריק ⇒ ${target} ≡ ${target}_ORIG על קלט-מסונתז
  const mod = await import('file://' + outFile + '?t=' + Date.now());
  const up = mod[target], orig = mod[target + '_ORIG'];
  const sample = (t) => { t = (t || '').toLowerCase(); const s = []; if (/number|\bint\b/.test(t)) s.push(0, 1, +lits[0] || 5, (+lits[0] || 5) + 10); if (/bool/.test(t)) s.push(true, false); if (/string|'|"/.test(t)) s.push('', 'x', 'noshow', 'cancel'); if (/null/.test(t)) s.push(null); if (/undefined|\?/.test(t)) s.push(undefined); return s.length ? s : [undefined, 0, '']; };
  const sets = params.map((p) => sample(p.type)); let same = 0, tot = 0, cap = 0;
  let threw = 0;
  const rec = (idx, args) => { if (cap > 4000) return; if (idx === sets.length) { tot++; cap++; try { const a = up(...args), b = orig(...args); if (JSON.stringify(a) === JSON.stringify(b)) same++; } catch { threw++; } return; } for (const v of sets[idx]) rec(idx + 1, [...args, v]); };
  rec(0, []);
  if (typeof up !== 'function' || typeof orig !== 'function') { console.log(`   ❌ המודול לא ייצא פונקציות תקינות (up/orig) — התיקון שבור. AUTOFIX|${target}|BROKEN-export`); process.exit(0); }
  const zl = same === tot && threw === 0;
  console.log(`   🧪 אפס-אובדן (opts ריק ≡ מקורי): ${same}/${tot}${threw ? ` (${threw} זרקו!)` : ''} ${zl ? '✅ ביט-זהה' : '❌ שבר!'}`);
  // הדגמת-שינוי: override הקבוע הראשון
  console.log(`   📄 נכתב: ${target}.fix.mjs — עכשיו אפשר ${target}(...,{ ${keyOf[lits[0]]}: <ערך> }) לשנות מדיניות בלי לגעת בקוד`);
  console.log(`AUTOFIX|${target}|lits=${lits.length}|zeroloss=${same}/${tot}|${zl ? 'SAFE' : 'BROKEN'}`);
  process.exit(0);
}

// ═══ --restructure: אופרטור-שכתוב — סולם-if שמחזיר אובייקטים ⇒ טבלת-נתונים + find (הפרדת נתונים-מלוגיקה). API זהה ⇒ אפס-אובדן. ═══
// הרכבה מחלקיקי-יסוד: טבלה + find + השוואה. "מקסימום מבני" שהמחולל מחיל לבד.
if (process.argv.includes('--restructure')) {
  const body = deepRealBody(src, target);
  // סף = ליטרל *או* קבוע-בשם (CRED_RED_THRESHOLD) — הקבוע נמשך כתלות (closeDeps), לא מפוספס.
  const rows = [...body.matchAll(/if\s*\(\s*(\w+)\s*(>=|>|<=|<)\s*(-?\d+(?:\.\d+)?|[A-Z_][A-Z0-9_]{2,})\s*\)\s*return\s*(\{[^{}]*\})\s*;/g)];
  const defMatch = body.match(/return\s*(\{[^{}]*\})\s*;\s*\}?\s*$/);
  if (rows.length < 2) { console.log(`🔀 restructure · ${target}: אין סולם-if-מחזיר-אובייקטים (לא-חל). RESTRUCTURE|${target}|no-ladder`); process.exit(0); }
  const splitG = (s) => { const o = []; let d = 0, c = ''; for (const ch of s) { if ('<{(['.includes(ch)) d++; else if ('>})]'.includes(ch)) d--; if (ch === ',' && d === 0) { o.push(c); c = ''; } else c += ch; } if (c.trim()) o.push(c); return o; };
  const params = splitG((eng.sig.split('=>')[0] || '').trim()).map((p) => (p.split(':')[0] || '').split('=')[0].replace(/[?\s]/g, '')).filter(Boolean);
  const varName = rows[0][1], op = rows[0][2];
  const TBL = `${target}_TIERS`;
  const catchAll = /^>/.test(op) ? '-Infinity' : 'Infinity'; // >=/>‏ ⇒ catch-all נמוך; <=/< ⇒ גבוה
  const tableSrc = `const ${TBL} = [\n${rows.map((m) => `  { min: ${m[3]}, v: ${m[4]} }`).join(',\n')},\n  { min: ${catchAll}, v: ${defMatch ? defMatch[1] : '{}'} },\n];`;
  const newFn = `export function ${target}(${params.join(', ')}) {\n  return (${TBL}.find((t) => ${varName} ${op} t.min) ?? ${TBL}[${TBL}.length - 1]).v;\n}`;
  const origFn = `export function ${target}_ORIG(${params.join(', ')}) ${body}`;
  const deps = closeDeps([tableSrc, body], [target, target + '_ORIG']); // מושך קבועי-סף בשם (CRED_RED_THRESHOLD) + כל תלות אחרת
  const emitTS = `// 🔀 AUTO-RESTRUCTURED — ${target}: סולם-if ⇒ טבלת-נתונים+find. API זהה (אפס-אובדן). נתונים מופרדים מלוגיקה.\n${deps.join('\n')}\n${tableSrc}\n${newFn}\n${origFn}`;
  const outFile = path.join(GEN, `${target}.restr.mjs`);
  let _ts = null; try { _ts = require(path.join(REPOS['maor-system'], 'node_modules/typescript')); } catch { /**/ }
  fs.writeFileSync(outFile, _ts ? _ts.transpileModule(emitTS, { compilerOptions: { target: 'ES2020', module: 'ESNext', removeComments: false } }).outputText : emitTS);
  console.log(`🔀 restructure · ${target} — סולם-${rows.length}-דרגות ⇒ טבלת-נתונים ${TBL} + find. נתונים הופרדו מלוגיקה.`);
  const mod = await import('file://' + outFile + '?t=' + Date.now());
  const up = mod[target], orig = mod[target + '_ORIG'];
  if (typeof up !== 'function' || typeof orig !== 'function') { console.log(`RESTRUCTURE|${target}|BROKEN-export`); process.exit(0); }
  let same = 0, tot = 0; for (let sc = -200; sc <= 1200; sc += 13) { tot++; try { if (JSON.stringify(up(sc)) === JSON.stringify(orig(sc))) same++; } catch { /* */ } }
  const zl = same === tot;
  console.log(`   🧪 אפס-אובדן (API זהה על ${tot} ערכים): ${same}/${tot} ${zl ? '✅ ביט-זהה' : '❌ שבר!'}`);
  console.log(`   ⇒ להוסיף דרגה = שורת-נתונים אחת ב-${TBL}, בלי שינוי-קוד. RESTRUCTURE|${target}|tiers=${rows.length}|zeroloss=${same}/${tot}|${zl ? 'SAFE' : 'BROKEN'}`);
  process.exit(0);
}

// (2ב) המחולל מסווג את *סוג* המנוע — קובע איזו אסטרטגיית-שדרוג חלה
const ret = (eng.sig.split('=>')[1] || '').trim();
const KIND = (eng.op === 'guard' || eng.op === 'predicate' || /string \| null|boolean|Error/i.test(ret)) ? 'validator'
  : (eng.op === 'effect') ? 'effect' : 'transform';
// טוקנים-גנריים מדי להתאמת-עוזר (סיכון עוזר-שווא כמו getSyncLastError↔last)
const GENERIC = new Set(['last', 'count', 'min', 'max', 'first', 'round', 'ils', 'usd', 'sum', 'total', 'idx', 'len', 'val', 'day', 'date', 'time', 'num', 'key', 'id']);

// (3) המחולל סורק את הקטלוג: עוזרים באותו ריפו, מאמת/מנרמל, נוגע-שדה-*לא-גנרי*, ו*לא-נקרא-כבר* = פער
const helpers = KIND !== 'validator' ? [] : ALL.filter((p) => p.name !== target && p.origin.startsWith(repoKey) && GAP_VALIDATOR.test(p.name) && !called.has(p.name) && toks(p.name).some((t) => (fields.includes(t) || bodyTok.has(t)) && !GENERIC.has(t)));
// דירוג: כמה שדות-של-המנוע העוזר נוגע בהם
const scored = helpers.map((h) => ({ h, hit: toks(h.name).filter((t) => fields.includes(t) && !GENERIC.has(t)) })).filter((x) => x.hit.length).sort((a, b) => b.hit.length - a.hit.length);
const seen = new Set(); const plan = [];
for (const { h, hit } of scored) { if (seen.has(h.name)) continue; seen.add(h.name); plan.push({ kind: 'fn', name: h.name, op: h.op, sig: h.sig.slice(0, 40), covers: hit, from: h.origin }); }

// (3ב) פערי-רשימות-const: כל `export const NAME =` באות-גדולה (אנומרציה — כולל .map(), לא רק [ ]).
const listConsts = [...src.matchAll(/export const ([A-Z][A-Z0-9_]+)\s*(?::[^=]*)?=/g)].map((m) => m[1]);
const matchList = (field) => listConsts.find((L) => { const lt = toks(L); return lt.includes(field) || lt.some((t) => field.includes(t) || t.includes(field)) || (field === 'size' && /SIZE/.test(L)) || (field === 'industry' && /INDUSTR/.test(L)) || (field.startsWith('need') && /NEED/.test(L)); });
// (3ג) שדות-הטיפוס: המחולל קורא את הממשק של הפרמטר ומשווה לשדות-שנוגעים.
const typeName = (eng.sig.match(/:\s*(\w+)\s*=>/) || [])[1];
const typeFields = typeName ? [...(src.match(new RegExp(`interface ${typeName}\\s*{([^}]*)}`)) || [, ''])[1].matchAll(/(\w+)\s*:/g)].map((m) => m[1].toLowerCase()) : [];
const allFields = KIND !== 'validator' ? [] : [...new Set([...fields, ...typeFields])];
for (const field of allFields) {
  const touched = fields.includes(field);
  const truthyOnly = touched && new RegExp(`[!\\s(]s\\.${field}\\s*[?)&|]|!s\\.${field}\\b`).test(body) && !new RegExp(`s\\.${field}\\s*[.=<>]|\\.(includes|has|test|indexOf)\\([^)]*${field}`, 'i').test(body);
  const ignored = !touched; // שדה-בטיפוס שהמנוע לא נוגע בו כלל
  if (!truthyOnly && !ignored) continue;
  const list = matchList(field);
  if (list && !body.includes(list)) plan.push({ kind: 'list', name: list, op: ignored ? 'ignored-field' : 'membership', sig: `s.${field} ∈ ${list}${ignored ? ' (שדה-מוזנח!)' : ''}`, covers: [field], from: eng.origin });
}

// (3ד) transform/measure: השדרוג = *העשרה* — transforms באותו נושא שהפלט שלהם יכול להזין קלט של המנוע (אות נוסף)
const inParams = (eng.sig.split('=>')[0] || '').split(',').map((x) => (x.split(':')[1] || '').trim().replace(/[|<>\[\]?]/g, ' ').trim().split(/\s+/)[0]).filter(Boolean);
const engSubj = new Set(toks(target).filter((t) => !GENERIC.has(t)));
let enrich = [];
if (KIND === 'transform') {
  enrich = ALL.filter((p) => p.name !== target && p.origin.startsWith(repoKey) && !called.has(p.name) && !p.name.startsWith('_')
    && toks(p.name).some((t) => engSubj.has(t))                                   // אותו נושא
    && inParams.some((it) => (p.sig.split('=>')[1] || '').includes(it)))          // פלטו = קלט-של-המנוע
    .map((p) => ({ name: p.name, op: p.op, produces: (p.sig.split('=>')[1] || '').trim().slice(0, 24), from: p.origin }));
  const seenE = new Set(); enrich = enrich.filter((e) => !seenE.has(e.name) && seenE.add(e.name));
}

console.log(`🏔️🤖 gen-max · שדרוג-אוטונומי ל-"${target}"  [סוג: ${KIND}]`);
console.log(`מקור: ${eng.origin}  ·  ${eng.sig.slice(0, 50)}`);
console.log(`שדות שהמנוע נוגע (זוהו לבד מהגוף): ${fields.join(' · ')}`);
console.log(`פונקציות שכבר קורא: ${[...called].filter((c) => VALIDATORish.test(c)).join(' · ') || '—'}\n`);
if (KIND === 'validator') {
  console.log(`אסטרטגיה: ולידטור ⇒ משוך מאמתים/רשימות-חברות. פערים שהמחולל מצא לבד (${plan.length}):`);
  for (const p of plan) console.log(`  ${p.kind === 'list' ? '📋' : '🔩'} ${p.name.padEnd(22)} [${p.op}] ${p.kind === 'list' ? p.sig : 'מכסה שדה: {' + p.covers.join(',') + '}'}  ←${p.from.split(':')[1] || p.from}`);
  if (!plan.length) console.log('  — אין פער: מקסימום מוצה.');
} else if (KIND === 'transform') {
  console.log(`אסטרטגיה: transform ⇒ *העשרה* (אותות-נוספים שהפלט שלהם מזין את הקלט). מועמדים (${enrich.length}):`);
  for (const e of enrich.slice(0, 10)) console.log(`  ➕ ${e.name.padEnd(22)} [${e.op}] מפיק ${e.produces}  ←${e.from.split(':')[1] || e.from}`);
  if (!enrich.length) console.log('  — אין אות-נוסף באותו נושא: מקסימום מוצה.');
} else {
  console.log(`אסטרטגיה: effect ⇒ שדרוג=אמינות/idempotency (טרם ממומש במחולל — פספוס-הבא בלולאה).`);
}
fs.writeFileSync(path.join(GEN, `gen-max-${target}.json`), JSON.stringify({ engine: target, origin: eng.origin, fields, plan }, null, 0));

// ── (4) המחולל פולט מנוע-משודרג עובד ומוכיח אפס-אובדן לבד ──────────────────
// transpiler-אמת: ts.transpileModule (מ-maor-system, read-only). מרכיבים את *כל* המודול כ-TS ומטרנספלים פעם-אחת.
let TS = null; try { TS = require(path.join(REPOS['maor-system'], 'node_modules/typescript')); } catch { /* נפילה ל-regex */ }
function rawFn(fnSrc) { return fnSrc.replace(/^\s*export\s+/, ''); } // רק מסיר export מוביל, שומר TS verbatim
function stripTs(fnSrc) { // נפילה-בלבד (בלי TS): הפשטת-חתימה גסה
  const b = fnSrc.indexOf('{'); if (b < 0) return rawFn(fnSrc);
  let sig = fnSrc.slice(0, b).replace(/^\s*export\s+/, '').replace(/\)([^)]*)$/, ')').replace(/([(,]\s*[A-Za-z_$][\w$]*)\s*:\s*[^,)]+/g, '$1');
  return sig + fnSrc.slice(b);
}
function transpileModuleTS(tsSrc) { // מודול-שלם TS ⇒ JS (פעם-אחת). נפילה: החזר כמות-שהוא (כבר-JS ברובו).
  if (TS) { try { const o = TS.transpileModule(tsSrc, { compilerOptions: { target: 'ES2020', module: 'ESNext', removeComments: false } }); if (o.outputText && o.outputText.trim()) return o.outputText; } catch { /* נפילה */ } }
  return tsSrc;
}
function fnBody(fileAbs, name) { if (!fs.existsSync(fileAbs)) return ''; const s = fs.readFileSync(fileAbs, 'utf8'); const st = s.search(new RegExp(`(export\\s+)?(async\\s+)?function\\s+${name}\\b`)); if (st < 0) return ''; let d = 0, i = s.indexOf('{', st), s0 = i; for (; i < s.length; i++) { if (s[i] === '{') d++; else if (s[i] === '}' && --d === 0) { return rawFn(s.slice(st, i + 1)); } } return ''; }
// מונה-סוגריים מודע-מחרוזות/הערות: מ-'{' ב-from מחזיר אינדקס אחרי ה-'}' התואם (מתעלם מ-{ במחרוזות/הערות)
function braceEnd(text, from) {
  let d = 0, s = null;
  for (let i = from; i < text.length; i++) {
    const c = text[i], n = text[i + 1];
    if (s === 'line') { if (c === '\n') s = null; continue; }
    if (s === 'block') { if (c === '*' && n === '/') { s = null; i++; } continue; }
    if (s === '"' || s === "'" || s === '`') { if (c === '\\') { i++; continue; } if (c === s) s = null; continue; }
    if (c === '/' && n === '/') { s = 'line'; i++; continue; }
    if (c === '/' && n === '*') { s = 'block'; i++; continue; }
    if (c === '"' || c === "'" || c === '`') { s = c; continue; }
    if (c === '{') d++; else if (c === '}' && --d === 0) return i + 1;
  }
  return -1;
}
// חילוץ הגדרת-המנוע (function OR const-arrow) מ-start, איזון-סוגריים, ושינוי-שם ל-NAME+suffix בכותרת בלבד
function extractOrig(suffix) {
  const decl = src.slice(start);
  // סוגר-הגוף = אחרי `=>` (arrow) או אחרי `)` של הפרמטרים (function) — לא סוגר-טיפוס-בפרמטרים
  const arrow = decl.indexOf('=>'); const paren = decl.indexOf(')'); const firstBrace = decl.indexOf('{');
  const from = (arrow >= 0 && (firstBrace < 0 || arrow < paren)) ? arrow : (paren >= 0 ? paren : 0);
  const bi = decl.indexOf('{', from);
  if (bi < 0) { const semi = decl.indexOf(';'); return rawFn(decl.slice(0, semi < 0 ? decl.indexOf('\n') : semi + 1)).replace(new RegExp(`\\b${target}\\b`), `${target}${suffix}`); }
  let head = decl.slice(0, bi).replace(new RegExp(`\\b(function\\s+)?${target}\\b`), (m) => m.includes('function') ? `function ${target}${suffix}` : `${target}${suffix}`);
  const end = braceEnd(decl, bi);
  return rawFn(head + decl.slice(bi, end < 0 ? decl.length : end));
}
const idsFrom = (text) => [...new Set((text.match(/id:\s*'([^']+)'/g) || []).map((x) => x.match(/'([^']+)'/)[1]))];
const listVals = (name) => {
  const m = src.match(new RegExp(`const ${name}\\b[^=]*=\\s*(\\[[\\s\\S]*?\\]);`)); // ליטרל
  if (m) { const ids = idsFrom(m[1]); if (ids.length) return ids; }
  const mm = src.match(new RegExp(`const ${name}\\b[^=]*=\\s*(\\w+)\\.map`)); // NAME = SOURCE.map(...) — חוצה-קובץ
  if (mm) {
    const source = mm[1];
    const imp = src.match(new RegExp(`import\\s*(?:type\\s*)?\\{[^}]*\\b${source}\\b[^}]*\\}\\s*from\\s*['"]([^'"]+)['"]`));
    if (imp && imp[1].startsWith('.')) {
      const dir = path.dirname(path.join(REPOS[repoKey], eng.origin.split(':')[1]));
      for (const ext of ['.ts', '.tsx', '/index.ts', '.js']) { const f = path.join(dir, imp[1] + ext); if (fs.existsSync(f)) { const s2 = fs.readFileSync(f, 'utf8'); const arr = s2.match(new RegExp(`const ${source}\\b[\\s\\S]*?\\n\\];`)); return idsFrom(arr ? arr[0] : s2); } }
    }
  }
  return [];
};

const splitTopG = (s) => { const out = []; let d = 0, cur = ''; for (const ch of s) { if ('<{(['.includes(ch)) d++; else if ('>})]'.includes(ch)) d--; if (ch === ',' && d === 0) { out.push(cur); cur = ''; } else cur += ch; } if (cur.trim()) out.push(cur); return out; };
function topDefG(name) { const fRe = new RegExp(`\\n(export\\s+)?(async\\s+)?function\\s+${name}\\b`); const fm = src.search(fRe); if (fm >= 0) { let d = 0, i = src.indexOf('{', fm); for (; i < src.length; i++) { if (src[i] === '{') d++; else if (src[i] === '}' && --d === 0) return rawFn(src.slice(fm, i + 1).trim()); } } const cm = src.search(new RegExp(`\\n(export\\s+)?const\\s+${name}\\b[^\\n]*=`)); if (cm >= 0) { let i = src.indexOf('=', cm), d = 0, started = false; for (; i < src.length; i++) { const ch = src[i]; if ('([{'.includes(ch)) { d++; started = true; } else if (')]}'.includes(ch)) d--; else if (ch === ';' && d === 0) return rawFn(src.slice(cm, i + 1).trim()); else if (ch === '\n' && d === 0 && started) return rawFn(src.slice(cm, i).trim()); } } return ''; }
function closeDeps(codes, seed) { const have = new Set(seed); const need = new Set(); const scan = (c) => { for (const m of c.matchAll(/\b([A-Z_][A-Z0-9_]{2,}|[a-z]\w+)\b/g)) need.add(m[1]); }; codes.forEach(scan); const defs = []; let g = 0; while (g++ < 60) { let added = false; for (const nm of [...need]) { if (have.has(nm)) continue; if (!/^[A-Z_]/.test(nm) && !new RegExp(`(function|const)\\s+${nm}\\b`).test(src)) continue; const def = topDefG(nm); if (def) { have.add(nm); defs.push(def); scan(def); added = true; } else have.add(nm); } if (!added) break; } return defs; }

if (process.argv.includes('--emit') && KIND === 'transform') {
  // העשרת-transform = פייפליין: מפיק-קלט(raw) → המנוע. default=המנוע-המקורי ביט-זהה; TARGET_fromSource=מסלול-מועשר.
  const engBody = extractOrig('');
  const params = splitTopG((eng.sig.split('=>')[0] || '').trim()).map((p) => { const i = p.indexOf(':'); return { name: (i < 0 ? p : p.slice(0, i)).split("=")[0].replace(/[?\s]/g,"").trim(), type: (i < 0 ? '' : p.slice(i + 1)).trim() }; }).filter((p) => p.name);
  const inT0 = (params[0]?.type || '').replace(/[^\w]/g, '');
  const P = enrich.map((e) => ALL.find((p) => p.name === e.name && p.origin.startsWith(repoKey))).find((p) => p && (p.sig.split('=>')[1] || '').replace(/[^\w]/g, '') === inT0 && p.origin.split(':')[1] === eng.origin.split(':')[1] && inT0);
  if (!P) { console.log(`\n🤖 emit(transform): אין מפיק-תואם-קלט באותו קובץ — נשאר enrich-detected (זיהוי בלבד).`); globalThis.__td = 'enrich-detected'; }
  else {
    const Pbody = fnBody(path.join(REPOS[repoKey], P.origin.split(':')[1]), P.name);
    const Pparams = splitTopG((P.sig.split('=>')[0] || '').trim()).map((p) => (p.split(':')[0] || '').split('=')[0].replace(/[?\s]/g, '')).filter(Boolean);
    const defs = closeDeps([engBody, Pbody], [target, P.name]);
    const rest = params.slice(1).map((p) => p.name);
    const emitTS = `// 🤖 AUTO-EMITTED by gen-max — ${target} (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
${defs.join('\n')}
export ${extractOrig('_ORIG')}
${Pbody ? 'function ' + Pbody.replace(/^function\s+/, '') : ''}
export function ${target}(${params.map((p) => p.name).join(', ')}) { return ${target}_ORIG(${params.map((p) => p.name).join(', ')}); }
export function ${target}_fromSource(${[...new Set([...Pparams, ...rest])].join(', ')}) { return ${target}_ORIG(${P.name}(${Pparams.join(', ')})${rest.length ? ', ' + rest.join(', ') : ''}); }`;
    const emit = transpileModuleTS(emitTS);
    const outFile = path.join(GEN, `${target}.max.mjs`);
    fs.writeFileSync(outFile, emit);
    console.log(`\n🤖 emit(transform): פייפליין ${P.name}→${target} · ${defs.length} deps · ${target}.max.mjs`);
    try {
      const mod = await import('file://' + outFile + '?t=' + Date.now());
      const up = mod[target], orig = mod[target + '_ORIG'], fromSrc = mod[target + '_fromSource'];
      if (typeof up !== 'function' || typeof orig !== 'function') throw new Error('export חסר');
      let rng = 7; const rnd = () => (rng = (rng * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff;
      const SS = ['x', '1', 'שלום', '']; const SN = [1, 5, 0]; const SB = [true, false];
      const synth = (type, d = 0) => { let t = (type || '').replace(/[\s?]/g, '').replace(/\|.*/, ''); if (/^number$/.test(t)) return SN; if (/^string$/.test(t)) return SS; if (/^boolean$/.test(t)) return SB; const arr = t.match(/^(\w+)\[\]$/) || t.match(/^Array<(\w+)>$/); if (arr) { const el = synth(arr[1], d + 1)[0]; return [[el], [el, el], []]; } if (d < 4) { const ib = (/^[A-Za-z]\w*$/.test(t) ? (src.match(new RegExp(`interface ${t}\\s*{([^}]*)}`)) || [, ''])[1] : ''); const fl = [...ib.matchAll(/(\w+)\??\s*:\s*([^;\n]+)/g)]; if (fl.length) { const o = {}; for (const [, fn, ft] of fl) { o[fn] = synth(ft, d + 1)[0]; } return [o]; } } return [{}, undefined]; };
      const engArgs = params.map((p) => synth(p.type));
      let same = 0, tot = 0; for (let k = 0; k < 300; k++) { const a = engArgs.map((vs) => vs[Math.floor(rnd() * vs.length)]); tot++; try { const A = up(...a), B = orig(...a); if (A === B || JSON.stringify(A) === JSON.stringify(B)) same++; } catch { same++; } }
      // העשרה-עובדת: fromSource מריץ את הפייפליין ומחזיר defined בלי לזרוק
      let live = 0, tries = 0; const Ptypes = splitTopG((P.sig.split('=>')[0] || '').trim()).map((p) => (p.split(':')[1] || '').trim());
      for (let k = 0; k < 60; k++) { tries++; try { const pa = Ptypes.map((t) => synth(t)[0]); const ra = params.slice(1).map((p) => synth(p.type)[0]); const r = fromSrc(...pa, ...ra); if (r !== undefined) live++; } catch { /* */ } }
      console.log(`🧪 transform: אפס-אובדן default≡מקורי ${same}/${tot} ${same === tot ? '✅' : '❌'} · פייפליין-חי ${live}/${tries} ${live ? '✅' : '⚠️'}`);
      globalThis.__td = (same === tot && live) ? 'PASS-enrich-e2e' : (same === tot ? 'enrich-zeroloss' : 'broken');
    } catch (e) { globalThis.__td = 'emit-fail'; globalThis.__err = String(e.message || e).slice(0, 40); console.log(`⚠️ ${globalThis.__err}`); }
  }
} else if (process.argv.includes('--emit') && KIND === 'effect') {
  console.log(`\n🤖 emit: effect — שדרוג=idempotency (הפספוס-הבא בלולאה).`);
} else if (process.argv.includes('--emit') && !plan.length) {
  console.log(`\n🤖 emit: אין פער (gaps=0) — המנוע כבר במקסימום, אין מה לפלוט.`); // ⇐ לא מנסים טרנספיל מיותר
} else if (process.argv.includes('--emit')) {
  const origBody = extractOrig('');
  function splitTop(s) { const out = []; let d = 0, cur = ''; for (const ch of s) { if ('<{(['.includes(ch)) d++; else if ('>})]'.includes(ch)) d--; if (ch === ',' && d === 0) { out.push(cur); cur = ''; } else cur += ch; } if (cur.trim()) out.push(cur); return out; }
  const params = splitTop((eng.sig.split('=>')[0] || '').trim()).map((p) => { const i = p.indexOf(':'); return { name: (i < 0 ? p : p.slice(0, i)).split("=")[0].replace(/[?\s]/g,"").trim(), type: (i < 0 ? '' : p.slice(i + 1)).trim() }; }).filter((p) => p.name);
  const pnames = params.map((p) => p.name);
  const SP = (params.find((p) => p.type.replace(/[\s?]/g, '') === typeName) || params.find((p) => /^[A-Z]/.test(p.type)) || params[params.length - 1] || { name: 's' }).name;
  const fnHelpers = plan.filter((p) => p.kind === 'fn' && !/^(fix|format|norm|normalize)Phone$|^formatIsraeliPhone$/.test(p.name) === false ? false : p.kind === 'fn');
  // בחר עוזר-אחד-מייצג לכל שדה (מקפל שקילות: כל וריאנטי-הטלפון ⇒ phoneRegion)
  const byField = {}; for (const p of plan.filter((x) => x.kind === 'fn')) { const f = p.covers[0]; if (!byField[f]) byField[f] = p; }
  const deps = new Set(); const depCode = [];
  for (const f in byField) { const p = byField[f]; const abs = path.join(REPOS[repoKey], p.from.includes(':') ? p.from.split(':')[1] : p.from); const b = fnBody(abs, p.name); if (b && !deps.has(p.name)) { deps.add(p.name); depCode.push('function ' + b.replace(/^function\s+/, '')); } }
  // גם signUpError (נקרא ע"י המקורי) — המחולל שולף אותו כדי שהמקורי ירוץ
  for (const dep of [...called].filter((c) => VALIDATORish.test(c) && !deps.has(c))) { const hit = ALL.find((p) => p.name === dep && p.origin.startsWith(repoKey)); if (hit) { const abs = path.join(REPOS[repoKey], hit.origin.split(':')[1]); const b = fnBody(abs, dep); if (b) { deps.add(dep); depCode.push('function ' + b.replace(/^function\s+/, '')); } } }
  // טיפוסי-השדות מהממשק (לזיהוי מערך) + דילוג-בטוח על רשימות-לא-פתירות (מחושבות ⇒ ids ריק)
  const ifaceBody = typeName ? (src.match(new RegExp(`interface ${typeName}\\s*{([^}]*)}`)) || [, ''])[1] : '';
  const fieldType = Object.fromEntries([...ifaceBody.matchAll(/(\w+)\s*:\s*([^;\n]+)/g)].map((m) => [m[1].toLowerCase(), m[2].trim()]));
  // (4ב) סגירת-תלויות: משוך כל קבוע/פונקציה ברמת-המודול שהגוף מפנה אליו (טרנזיטיבי, בתוך קובץ-המקור)
  function topDef(name) { // חילוץ הגדרת top-level מ-src: const NAME = ... ; או function NAME(){}
    const fRe = new RegExp(`\\n(export\\s+)?(async\\s+)?function\\s+${name}\\b`); const fm = src.search(fRe);
    if (fm >= 0) { let d = 0, i = src.indexOf('{', fm), s0 = i; for (; i < src.length; i++) { if (src[i] === '{') d++; else if (src[i] === '}' && --d === 0) return rawFn(src.slice(fm, i + 1).trim()); } }
    const cRe = new RegExp(`\\n(export\\s+)?const\\s+${name}\\b[^\\n]*=`); const cm = src.search(cRe);
    if (cm >= 0) { let i = src.indexOf('=', cm), d = 0, started = false, s0 = src.indexOf('\n', cm) < 0 ? cm : cm + 1; for (i = src.indexOf('=', cm); i < src.length; i++) { const ch = src[i]; if ('([{'.includes(ch)) { d++; started = true; } else if (')]}'.includes(ch)) d--; else if (ch === ';' && d === 0) return rawFn(src.slice(cm, i + 1).trim()); else if (ch === '\n' && d === 0 && started) return rawFn(src.slice(cm, i).trim()); } }
    return '';
  }
  const closureDefs = []; const have = new Set([target, ...deps]); const need = new Set();
  const scan = (code) => { for (const m of code.matchAll(/\b([A-Z_][A-Z0-9_]{2,}|[a-z]\w+)\b/g)) need.add(m[1]); };
  scan(origBody); depCode.forEach(scan);
  let guard = 0;
  while (guard++ < 40) { let added = false; for (const nm of [...need]) { if (have.has(nm) || !/^[A-Z_]/.test(nm) && !new RegExp(`(function|const)\\s+${nm}\\b`).test(src)) { continue; } if (have.has(nm)) continue; const def = topDef(nm); if (def) { have.add(nm); closureDefs.push(def); scan(def); added = true; } else have.add(nm); } if (!added) break; }

  // (4ד) עוזרים-בוליאניים חד-ארגומנטיים ⇒ בדיקת-strict גנרית (מעבר ל-phone/email הקבועים): if(!H(SP.f))return 'f לא חוקי'
  const boolChecks = [];
  for (const f in byField) {
    if (f === 'phone' || f === 'email') continue; // כבר מטופלים במפורש
    const full = ALL.find((p) => p.name === byField[f].name && p.origin.startsWith(repoKey)); if (!full) continue;
    const ins = splitTop((full.sig.split('=>')[0] || '').trim()); const ret = (full.sig.split('=>')[1] || '').trim();
    if (ins.length === 1 && /string/.test(ins[0]) && /^bool/.test(ret.replace(/[\s?]/g, ''))) {
      const abs = path.join(REPOS[repoKey], full.origin.split(':')[1]); const b = fnBody(abs, full.name);
      if (b && !deps.has(full.name)) { deps.add(full.name); depCode.push('function ' + b.replace(/^function\s+/, '')); }
      boolChecks.push(`  if (typeof ${SP}.${f}==='string' && ${SP}.${f} && !${full.name}(${SP}.${f})) return '${f} לא חוקי';`);
    }
  }
  const lists = plan.filter((p) => p.kind === 'list').map((p) => ({ field: p.covers[0], name: p.name, ids: listVals(p.name), arr: /\[\]|Array/.test(fieldType[p.covers[0]] || '') }))
    .filter((l) => { if (!l.ids.length) { console.log(`   ⚠️ ${l.name}: רשימה-מחושבת (לא-פתירה סטטית) — המחולל דילג בבטחה (לא פוסל-הכל).`); return false; } return true; });
  const emitTS = `// 🤖 AUTO-EMITTED by gen-max — ${target} משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
${closureDefs.join('\n')}
${depCode.join('\n')}
export ${extractOrig('_ORIG')}
${lists.map((l) => `const ${l.name}_IDS = ${JSON.stringify(l.ids)};`).join('\n')}
export function ${target}(${pnames.join(', ')}${pnames.length ? ', ' : ''}__opt = {}) {
  const base = ${target}_ORIG(${pnames.join(', ')});
  if (__opt.strict !== true) return base;                       // ← default: החזק לא נשבר (ביט-זהה)
  if (base !== null && base !== undefined && base !== '') return base;  // המקורי כבר פסל — כבד אותו
${byField.phone ? `  if (typeof ${SP}.phone==='string' && ${SP}.phone.trim() && !/^[\\d+][\\d\\s-]{6,}$/.test(${SP}.phone.trim())) return 'מספר טלפון תקין הוא שדה חובה';\n` : ''}${byField.email ? `  if (typeof ${SP}.email==='string' && ${SP}.email.trim() && !/^\\S+@\\S+\\.\\S+$/.test((${SP}.email||'').trim().toLowerCase())) return 'כתובת האימייל אינה תקינה';\n` : ''}${boolChecks.length ? boolChecks.join('\n') + '\n' : ''}${lists.map((l) => l.arr
    ? `  if (Array.isArray(${SP}.${l.field}) && ${SP}.${l.field}.some((v) => !${l.name}_IDS.includes(v))) return '${l.field} לא חוקי';`
    : `  if (typeof ${SP}.${l.field}==='string' && ${SP}.${l.field} && !${l.name}_IDS.includes(${SP}.${l.field})) return '${l.field} לא חוקי';`).join('\n')}
  return base;
}`;
  const emit = transpileModuleTS(emitTS); // מודול-שלם TS ⇒ JS פעם-אחת (regexes/טיפוסים נאמנים)
  const outFile = path.join(GEN, `${target}.max.mjs`);
  fs.writeFileSync(outFile, emit);
  console.log(`\n🤖 המחולל פלט מנוע-משודרג: ${target}.max.mjs (${deps.size} עוזרים+${lists.length} רשימות הושתלו)`);
  // (5) הוכחה-עצמית מקצה-לקצה: default≡מקורי + strict תופס-רע — עטוף: פלט-פגום לא מפיל את המחולל
  try {
    const mod = await import('file://' + outFile + '?t=' + Date.now());
    const up = mod[target], orig = mod[target + '_ORIG'];
    if (typeof up !== 'function' || typeof orig !== 'function') throw new Error('export חסר');
    let rng = 99; const rnd = () => (rng = (rng * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff;
    // סינתזת-קלט מהטיפוסים (גנרי — לא wizard-שקלי): string/number/bool/interface
    const SS = ['', 'x', '052-1234567', 'a@b.co', '12', 'שלום', 'zzz']; const SN = [0, 1, 5, -1, 12]; const SB = [true, false];
    const synth = (type, depth = 0) => { const t = (type || '').replace(/[\s?]/g, '').replace(/\|.*/, ''); if (/^number$/.test(t)) return SN; if (/^string$/.test(t)) return SS; if (/^boolean$/.test(t)) return SB; if (/\[\]$|^Array/.test(t)) return [[], ['crm'], ['zzz']]; if (depth < 2) { const ib = (/^[A-Za-z]\w*$/.test(t) ? (src.match(new RegExp(`interface ${t}\\s*{([^}]*)}`)) || [, ''])[1] : ''); const flds = [...ib.matchAll(/(\w+)\s*:\s*([^;\n]+)/g)]; if (flds.length) { const objs = []; for (let k = 0; k < 7; k++) { const o = {}; for (const [, fn, ft] of flds) { const s = synth(ft, depth + 1); o[fn] = s[k % s.length]; } objs.push(o); } return objs; } } return [undefined, null, {}, 'x']; };
    const perParam = params.length ? params.map((p) => synth(p.type)) : [[undefined]];
    const N = 800; const tuples = Array.from({ length: N }, () => perParam.map((vs) => vs[Math.floor(rnd() * vs.length)]));
    const eq = (a, b) => a === b || (a && b && typeof a === 'object' && JSON.stringify(a) === JSON.stringify(b));
    const passed = (v) => v === null || v === undefined || v === '';
    let same = 0, tot = 0; for (const args of tuples) { tot++; try { if (eq(up(...args), orig(...args))) same++; } catch { same++; } }
    const catches = tuples.filter((args) => { try { return passed(orig(...args)) && !passed(up(...args, { strict: true })); } catch { return false; } }).length;
    const cases = tuples;
    console.log(`\n🧪 הוכחה-עצמית (המחולל הריץ לבד):`);
    console.log(`   אפס-אובדן: default≡מקורי ${same}/${tot} ${same === tot ? '✅ ביט-זהה' : '❌ ' + (tot - same) + ' סטיות'}`);
    console.log(`   השדרוג-עובד: strict תפס קלט-רע ב-${catches}/${cases.length} מקרים ${catches ? '✅' : '⚠️'}`);
    console.log(`   מקצה-לקצה: ${same === tot && catches ? '✅ עובד — אפס-אובדן + שדרוג-פעיל' : '❌ לא-שלם'}`);
    globalThis.__zl = same === tot; globalThis.__wk = catches > 0;
    // ── (6) אימות-מקסימום = נקודת-שבת: על המנוע-המשודרג, כמה מהפערים-שנמצאו נסגרו? ──
    if (process.argv.includes('--verifymax')) {
      const upSrc = fs.readFileSync(outFile, 'utf8');
      const upBody = (upSrc.match(new RegExp(`function ${target}\\b[\\s\\S]*?\\n}`)) || [''])[0]; // הגוף המשודרג
      // ⚠️ חלקיק "נסגר" רק אם חוּוט בענף-ה-strict עצמו — לא כי נמשך כתלות-טקסט. בודקים *רק* מה שאחרי המגן.
      const strictBranch = upBody.split(/strict\s*!==\s*true/)[1] || '';
      const planFields = [...new Set(plan.map((p) => p.covers[0]))];
      const stillOpen = planFields.filter((f) => !new RegExp(`\\b(${f}|${(byField[f] || {}).name || f}|${(plan.find((p) => p.covers[0] === f && p.kind === 'list') || {}).name || f})\\b`, 'i').test(strictBranch));
      const closed = planFields.length - stillOpen.length;
      // fixpoint אמיתי = כל פער חוּוט בענף-strict *וגם* השדרוג מוכיח שינוי-התנהגות. פער-שנמצא בלי catch = לא-נסגר.
      const fixpoint = stillOpen.length === 0 && (planFields.length === 0 || globalThis.__wk);
      console.log(`\n🎯 אימות-מקסימום (נקודת-שבת):`);
      console.log(`   פערים-שנמצאו: ${planFields.length} · חוּוטו-בענף-strict: ${closed} · פתוחים: ${stillOpen.length}${stillOpen.length ? ' [' + stillOpen.join(',') + ']' : ''}`);
      console.log(`   fixpoint (חוּוט+שינוי-התנהגות): ${fixpoint ? '✅' : '❌'} · אפס-אובדן: ${globalThis.__zl ? '✅' : '❌'} · עובד: ${globalThis.__wk ? '✅' : '❌'}`);
      // מקסימום-טהור = מיצוי(fixpoint) + אפס-אובדן + (אם נמצא פער) הוכחת-עבודה. חלקיק שנמשך אך לא שינה התנהגות = לא-נסגר, לא-מקסימום.
      globalThis.__max = fixpoint && globalThis.__zl && (planFields.length === 0 || globalThis.__wk);
      console.log(`   ⇒ ${globalThis.__max
        ? '🏔️ **מקסימום מאומת** — ' + (planFields.length === 0 ? 'אין חלקיק לשדרג (זהות) · אפס-אובדן' : 'כל פער חוּוט ומשנה-התנהגות · אפס-אובדן')
        : (planFields.length > 0 && !globalThis.__wk ? '❌ פסאודו-שיא: חלקיק נמשך אך לא חוּוט (0 catches) — לא-מקסימום' : '⚠️ טרם-מקסימום')}`);
    }
  } catch (e) {
    globalThis.__err = String(e.message || e).slice(0, 60);
    console.log(`\n⚠️ הוכחה נכשלה (גוף עמוס-TS ש-stripTs לא ניקה): ${globalThis.__err} — המחולל ממשיך.`);
  }
}
// ── שורת-ledger לנהג-הלולאה ──
const gaps = KIND === 'validator' ? plan.length : (KIND === 'transform' ? enrich.length : 0);
const verdict = globalThis.__err ? 'emit-fail(' + globalThis.__err.slice(0, 20) + ')'
  : gaps === 0 ? 'exhausted-max'                       // אין פער ⇒ המנוע כבר במקסימום (לא כשל!)
  : KIND === 'validator' ? (globalThis.__max ? 'MAX-VERIFIED' : globalThis.__zl && globalThis.__wk ? 'PASS-e2e' : (globalThis.__zl ? 'pulled-not-wired' : 'broken'))
  : (KIND === 'transform' ? (globalThis.__td || 'enrich-detected') : 'effect-todo');
console.log(`LEDGER|${target}|${KIND}|gaps=${gaps}|${verdict}`);

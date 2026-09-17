#!/usr/bin/env node
// 🌍 empire-index — אינדקס-op מאוחד של כל האימפריה (קריאה-בלבד): maor-system + כל מנועי-machtzev.
//   לכל פונקציה/מנוע: {id, repo, file, op, sockets(טיפוסי-קלט), ret, dom(אסימוני-דומיין מהשם+כותרת)}.
//   dom = הבסיס למציאת-עוזרים סמנטית (בדיוק איך שהנחיל מצא: purity/data/hebrew...). מבודד: כותב ל-/tmp בלבד.
//
//   שדרוג up-buckets2 (סעיף 9 של UPGRADE-SPEC — "לכוון לכל ריפו, לא נתיב-קשוח"):
//     • --roots <name>=<path>,...   (או env EMPIRE_ROOTS באותו פורמט) — כל ריפו/שורש נסרק כ-repo נפרד.
//     • --out <path>                — יעד-הכתיבה (ברירת-מחדל: OUT הקשיח, כשקיים).
//     • --base <path>               — מיזוג אינדקס-בסיס קיים (maor/machtzev שכבר נחצבו) — מצורף *אחרי*
//                                     הרשומות-הטריות, כך שרשומת-ריפו-אמת מנצחת בהתאמת-קובץ (first-per-file).
//     שורשי --roots נסרקים בסט-סיומות מורחב (ts/tsx/js/mjs/cjs/dart/py/sh/bash/yml/yaml) וכוללים dot-dirs
//     (.claude/.githooks/.github — קבצים שקובץ-הזהב מסווג). ברירת-המחדל (maor/machtzev, --add) לא השתנתה.
import fs from 'node:fs'; import path from 'node:path';
const MAOR = '/home/user/maor-system';
const MACHTZEV = '/tmp/quarry-iso/machtzev';
const OUT = '/tmp/quarry-iso/machtzev/generator/empire-index.json';

// walk ברירת-מחדל: ts/mjs/js, מדלג dot-dirs — התנהגות מקורית, ללא-שינוי.
function walk(d, a = []) { if (!fs.existsSync(d)) return a; for (const e of fs.readdirSync(d, { withFileTypes: true })) { if (e.name === 'node_modules' || e.name.startsWith('.')) continue; const p = path.join(d, e.name); if (e.isDirectory()) walk(p, a); else if (/\.(ts|mjs|js)$/.test(e.name) && !/\.d\.ts$|\.test\.|\.spec\./.test(e.name)) a.push(p); } return a; }

// walk מורחב לשורשי --roots: סט-סיומות רחב + dot-dirs, מדלג ספריות-בנייה/תלויות (לא בזהב, מזהמות first-per-file).
const SKIP_DIR = new Set(['node_modules', '.git', '.dart_tool', 'build', 'dist', 'coverage', '.next', '.venv', '__pycache__', 'venv']);
const ROOT_EXT = /\.(ts|tsx|js|mjs|cjs|dart|py|sh|bash|yml|yaml)$/;
function walkAll(d, a = []) { if (!fs.existsSync(d)) return a; for (const e of fs.readdirSync(d, { withFileTypes: true })) { if (SKIP_DIR.has(e.name)) continue; const p = path.join(d, e.name); if (e.isDirectory()) walkAll(p, a); else if (ROOT_EXT.test(e.name) && !/\.d\.ts$|\.test\.|\.spec\./.test(e.name)) a.push(p); } return a; }

const opOfRet = (ret) => { const r = (ret || '').trim();
  if (/\|\s*null|\|\s*undefined/.test(r) && /string|number/i.test(r)) return 'guard';
  if (/\bboolean\b|\bbool\b/.test(r)) return 'predicate';
  if (/\[\]|Array|Map|Set|Record/.test(r)) return 'collection';
  if (/\bnumber\b/.test(r)) return 'measure';
  if (/\bstring\b/.test(r)) return 'format';
  if (/void|Promise<void>/.test(r)) return 'effect';
  return 'transform'; };

// op-מטיפוס-פייתון (חתימת def name(...)->ret) — מקביל ל-opOfRet אך לטיפוסי-פייתון (bool/int/str/list/None).
const opOfPyRet = (ret) => { const r = (ret || '').trim();
  if (/\|\s*None|Optional\[/.test(r)) return 'guard';
  if (/\bbool\b/.test(r)) return 'predicate';
  if (/\b(int|float|complex)\b/.test(r)) return 'measure';
  if (/\bstr\b/.test(r)) return 'format';
  if (/\b(list|dict|set|tuple|List|Dict|Set|Tuple|Iterable|Sequence|Iterator|Mapping)\b/.test(r)) return 'collection';
  if (/\bNone\b/.test(r)) return 'effect';
  return 'transform'; };

// אסימוני-דומיין: מילים באנגלית מפוצלות מ-camelCase של השם + מילים-לועזיות מהכותרת-העברית של הקובץ
const splitId = (id) => id.replace(/([a-z0-9])([A-Z])/g, '$1 $2').replace(/[_-]/g, ' ').toLowerCase().split(/\s+/).filter((w) => w.length > 2);
const STOP = new Set(['the','and','for','get','set','from','with','this','that','all','one','new','fun','out','val','str','num','has','are','not','var','let','const']);

function headTokens(src) {  // מילים מהכותרת (10 שורות ראשונות) — עברית ולועזית כאחד, לזיהוי-דומיין
  const head = src.split('\n').slice(0, 12).join(' ');
  const heb = [...head.matchAll(/[֐-׿]{2,}/g)].map((m) => m[0]);
  const eng = [...head.matchAll(/[a-zA-Z]{4,}/g)].map((m) => m[0].toLowerCase()).filter((w) => !STOP.has(w));
  return [...new Set([...heb, ...eng])];
}

// ── חתימות-מבנה ברמת-קובץ (ראיה מבנית לכללי-הסלים; סעיף 9 — נתיב/ייבוא/קריאה, לא מילים):
//   cli — קובץ-הרצה: shebang · process.argv · import.meta main · require.main. (⇒ מנוע-רץ, לא חלקיק K.)
//   srv — שרת/לולאה/hook: express/listen/createServer/onRequest · setInterval · addEventListener.
//   io  — קלט/פלט-קבצים: fs write/read · writeFileSync · readFileSync (⇒ effect/act בפועל).
const fileSig = (src) => ({
  cli: /^#!.*\b(node|bash|sh|python)/.test(src) || /process\.argv|import\.meta\.url\s*===|require\.main\s*===\s*module|import\.meta\.main/.test(src),
  srv: /\bexpress\(|createServer\(|\.listen\(|onRequest\b|setInterval\(|addEventListener\(|http\.Server|new WebSocket|app\.(get|post|use)\(/.test(src),
  io: /writeFileSync|readFileSync|fs\.write|fs\.read|createWriteStream|open\s*\(|\.to_csv|\.read_csv/.test(src),
});

const idx = [];
// scan(root, repo, roots, {ext}) — ext=true ⇒ walk מורחב (--roots) עם חילוץ py + רשומת-קובץ ל-sh/dart/yml.
const scan = (root, repo, roots, opts = {}) => {
  const walker = opts.ext ? walkAll : walk;
  for (const r of roots) for (const f of walker(path.join(root, r))) {
    let src; try { src = fs.readFileSync(f, 'utf8'); } catch { continue; }
    const rel = path.relative(root, f);
    const head = headTokens(src);
    const ext = path.extname(f);
    const sig = fileSig(src);
    // ── פייתון: חילוץ מינימלי של def name(params)->ret  (סעיף 9 — כשהמחלץ תומך רק ב-TS/JS/Dart)
    if (ext === '.py') {
      const defs = [...src.matchAll(/^\s*def\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(([^)]*)\)\s*(?:->\s*([^:]+))?:/gm)]
        .filter((m) => !m[1].startsWith('_')); // מדלג private/dunder (_x, __x)
      if (defs.length) {
        for (const m of defs) { const name = m[1]; const params = (m[2] || '').trim(); const ret = (m[3] || '').trim();
          const sockets = params ? params.split(',').map((s) => s.split(':').slice(1).join(':').trim() || s.split('=')[0].trim()).filter((s) => s && s !== 'self' && s !== 'cls') : [];
          idx.push({ id: name, repo, file: rel, op: opOfPyRet(ret), sockets, ret, kind: 'fn', ...sig, dom: [...new Set([...splitId(name), ...head])] }); }
      } else {
        const base = path.basename(f).replace(/\.py$/, '');
        idx.push({ id: base, repo, file: rel, op: 'engine', sockets: [], ret: '', kind: 'file', ...sig, dom: [...new Set([...splitId(base), ...head])] });
      }
      continue;
    }
    // ── sh/bash/yml/yaml/dart: רשומת-קובץ אחת (המנוע=הקובץ). op=engine, dom מהכותרת+השם.
    if (/\.(sh|bash|yml|yaml|dart)$/.test(ext)) {
      const base = path.basename(f).replace(/\.(sh|bash|yml|yaml|dart)$/, '');
      idx.push({ id: base, repo, file: rel, op: 'engine', sockets: [], ret: '', kind: 'file', ...sig, dom: [...new Set([...splitId(base), ...head])] });
      continue;
    }
    // ── TS/JS/MJS: אותו חילוץ-export מקורי.
    const exps = [...src.matchAll(/export\s+(?:async\s+)?function\s+([A-Za-z0-9_]+)\s*\(([^)]*)\)\s*:?\s*([^\{=]*)[\{=]|export\s+const\s+([A-Za-z0-9_]+)\s*=\s*(?:async\s*)?\(([^)]*)\)\s*:?\s*([^=]*)=>/g)];
    if (exps.length) {
      for (const m of exps) { const name = m[1] || m[4]; const params = (m[2] || m[5] || '').trim(); const ret = (m[3] || m[6] || '').trim();
        const sockets = params ? params.split(',').map((s) => s.split(':').slice(1).join(':').trim() || s.trim()).filter(Boolean) : [];
        idx.push({ id: name, repo, file: rel, op: opOfRet(ret), sockets, ret, kind: 'fn', ...sig, dom: [...new Set([...splitId(name), ...head])] }); }
    } else {
      // קובץ-מנוע ללא export (סקריפט CLI): id=שם-הקובץ, op מהכותרת (verb), dom מהכותרת
      const base = path.basename(f).replace(/\.(mjs|js|ts|tsx|cjs)$/, '');
      idx.push({ id: base, repo, file: rel, op: 'engine', sockets: [], ret: '', kind: 'file', ...sig, dom: [...new Set([...splitId(base), ...head])] });
    }
  }
};
scan(MAOR, 'maor', ['src/lib', 'telephony', 'src/components']);
scan(MACHTZEV, 'machtzev', ['.']);
// ריפואים-זרים דרך argv: --add <label>:<root>  (סורק כל תיקיית-קוד; כך "כל ריפו" — לא מקובע)
for (const a of process.argv.filter((x) => x.startsWith('--add='))) {
  const [label, root] = a.slice(6).split(':'); if (fs.existsSync(root)) scan(root, label, ['.']);
}
// ── --roots <name>=<path>,... (או env EMPIRE_ROOTS): כל שורש = repo נפרד, walk מורחב + חילוץ-py.
const rootsArg = process.argv.find((x) => x.startsWith('--roots='));
const rootsSpec = (rootsArg ? rootsArg.slice(8) : (process.env.EMPIRE_ROOTS || '')).trim();
const scannedRepos = [];
if (rootsSpec) {
  for (const pair of rootsSpec.split(',').map((s) => s.trim()).filter(Boolean)) {
    const eq = pair.indexOf('=');
    const name = eq >= 0 ? pair.slice(0, eq).trim() : path.basename(pair);
    const root = (eq >= 0 ? pair.slice(eq + 1) : pair).trim();
    if (!fs.existsSync(root)) { console.error(`⚠️ --roots: שורש לא קיים, מדלג: ${name}=${root}`); continue; }
    const before = idx.length;
    scan(root, name, ['.'], { ext: true });
    scannedRepos.push([name, idx.length - before]);
  }
}
// ── --base <path>: מיזוג אינדקס-בסיס (maor/machtzev שנחצבו קודם) — *אחרי* הטריות (first-per-file ⇒ אמת מנצחת).
const baseArg = process.argv.find((x) => x.startsWith('--base='));
let baseCount = 0;
if (baseArg) {
  const bp = baseArg.slice(7).trim();
  try { const base = JSON.parse(fs.readFileSync(bp, 'utf8')); if (Array.isArray(base)) { idx.push(...base); baseCount = base.length; } }
  catch (e) { console.error(`⚠️ --base: כשל בטעינת ${bp}: ${e.message}`); }
}
// ── --out <path>: יעד-כתיבה (ברירת-מחדל OUT הקשיח, כשספריתו קיימת).
const outArg = process.argv.find((x) => x.startsWith('--out='));
const outPath = outArg ? outArg.slice(6).trim() : OUT;
try { fs.mkdirSync(path.dirname(outPath), { recursive: true }); } catch { /* ok */ }
fs.writeFileSync(outPath, JSON.stringify(idx, null, 0));
const byRepo = {}; for (const x of idx) byRepo[x.repo] = (byRepo[x.repo] || 0) + 1;
console.log(`🌍 empire-index: ${idx.length} רשומות → ${outPath}`);
console.log(`   לפי-ריפו: ${Object.entries(byRepo).map(([r, c]) => r + ' ' + c).join(' · ')}`);
if (scannedRepos.length) console.log(`   --roots נסרקו: ${scannedRepos.map(([n, c]) => n + ' ' + c).join(' · ')}${baseCount ? ` · base +${baseCount}` : ''}`);
export const EMPIRE = idx;

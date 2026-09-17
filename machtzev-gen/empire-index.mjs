#!/usr/bin/env node
// 🌍 empire-index — אינדקס-op מאוחד של כל האימפריה (קריאה-בלבד): maor-system + כל מנועי-machtzev.
//   לכל פונקציה/מנוע: {id, repo, file, op, sockets(טיפוסי-קלט), ret, dom(אסימוני-דומיין מהשם+כותרת)}.
//   dom = הבסיס למציאת-עוזרים סמנטית (בדיוק איך שהנחיל מצא: purity/data/hebrew...). מבודד: כותב ל-/tmp בלבד.
import fs from 'node:fs'; import path from 'node:path';
const MAOR = '/home/user/maor-system';
const MACHTZEV = '/tmp/quarry-iso/machtzev';
const OUT = '/tmp/quarry-iso/machtzev/generator/empire-index.json';

function walk(d, a = []) { if (!fs.existsSync(d)) return a; for (const e of fs.readdirSync(d, { withFileTypes: true })) { if (e.name === 'node_modules' || e.name.startsWith('.')) continue; const p = path.join(d, e.name); if (e.isDirectory()) walk(p, a); else if (/\.(ts|mjs|js)$/.test(e.name) && !/\.d\.ts$|\.test\.|\.spec\./.test(e.name)) a.push(p); } return a; }

const opOfRet = (ret) => { const r = (ret || '').trim();
  if (/\|\s*null|\|\s*undefined/.test(r) && /string|number/i.test(r)) return 'guard';
  if (/\bboolean\b|\bbool\b/.test(r)) return 'predicate';
  if (/\[\]|Array|Map|Set|Record/.test(r)) return 'collection';
  if (/\bnumber\b/.test(r)) return 'measure';
  if (/\bstring\b/.test(r)) return 'format';
  if (/void|Promise<void>/.test(r)) return 'effect';
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

const idx = [];
const scan = (root, repo, roots) => {
  for (const r of roots) for (const f of walk(path.join(root, r))) {
    const src = fs.readFileSync(f, 'utf8'); const rel = path.relative(root, f);
    const head = headTokens(src);
    // מנוע-סקריפט (machtzev): לרוב אין export — המנוע = הקובץ. נרשום רשומת-קובץ אחת.
    const exps = [...src.matchAll(/export\s+(?:async\s+)?function\s+([A-Za-z0-9_]+)\s*\(([^)]*)\)\s*:?\s*([^\{=]*)[\{=]|export\s+const\s+([A-Za-z0-9_]+)\s*=\s*(?:async\s*)?\(([^)]*)\)\s*:?\s*([^=]*)=>/g)];
    if (exps.length) {
      for (const m of exps) { const name = m[1] || m[4]; const params = (m[2] || m[5] || '').trim(); const ret = (m[3] || m[6] || '').trim();
        const sockets = params ? params.split(',').map((s) => s.split(':').slice(1).join(':').trim() || s.trim()).filter(Boolean) : [];
        idx.push({ id: name, repo, file: rel, op: opOfRet(ret), sockets, ret, dom: [...new Set([...splitId(name), ...head])] }); }
    } else {
      // קובץ-מנוע ללא export (סקריפט CLI): id=שם-הקובץ, op מהכותרת (verb), dom מהכותרת
      const base = path.basename(f).replace(/\.(mjs|js|ts)$/, '');
      idx.push({ id: base, repo, file: rel, op: 'engine', sockets: [], ret: '', dom: [...new Set([...splitId(base), ...head])] });
    }
  }
};
scan(MAOR, 'maor', ['src/lib', 'telephony', 'src/components']);
scan(MACHTZEV, 'machtzev', ['.']);
// ריפואים-זרים דרך argv: --add <label>:<root>  (סורק כל תיקיית-קוד; כך "כל ריפו" — לא מקובע)
for (const a of process.argv.filter((x) => x.startsWith('--add='))) {
  const [label, root] = a.slice(6).split(':'); if (fs.existsSync(root)) scan(root, label, ['.']);
}
fs.writeFileSync(OUT, JSON.stringify(idx, null, 0));
console.log(`🌍 empire-index: ${idx.length} רשומות · maor ${idx.filter((x) => x.repo === 'maor').length} · machtzev ${idx.filter((x) => x.repo === 'machtzev').length}`);
export const EMPIRE = idx;

#!/usr/bin/env node
// ⬆️ upgrade-engine — מנוע-השדרוג האוניברסלי (עובד על כל מנוע · נגזרת-מאינדקס, לא תבנית).
//   קלט: id של מנוע כלשהו. פלט: קבוצת-העוזרים מכל האימפריה + תכנית-חיווט לשדרוג (זהה→מלא-פערים→אמת).
//   הכלל: מוצא שכני-דומיין (חופפי-אסימונים), מסווג לכל אחד תפקיד, ומחזיר את מי שממלא תפקיד שחסר למנוע.
//   מבודד: קורא empire-index.json בלבד, כותב ל-/tmp. זה מה שהנחיל עשה ידנית — כאן אוטומטי, לכל מנוע.
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
const GEN = path.dirname(fileURLToPath(import.meta.url));
const EMPIRE = JSON.parse(fs.readFileSync(path.join(GEN, 'empire-index.json'), 'utf8'));

// אסימונים-גנריים שאינם דומיין (רעש) — לא נספרים בחפיפה
const GENERIC = new Set(['node','import','path','root','mode','process','argv','dirs','atoms','dart','maor','const','function','export','return','string','number','boolean','void','file','files','אטום','אטומים','מחצב','קובץ','כל','מול','חדש','ללא','אפס','the','and','for']);
const domOf = (rec) => new Set((rec.dom || []).filter((t) => !GENERIC.has(t)));

// תפקיד-בשרשרת: פעולת-פועל בשם קודמת, אחר-כך כותרת. detect לפני fix (השם "purity" אינו "purify").
const ROLE = (rec) => {
  const id = rec.id.toLowerCase(), s = (rec.id + ' ' + (rec.dom || []).join(' ')).toLowerCase();
  if (/(^|[-_])(data|check|scan|audit|census|lint|report|classif|detect)([-_]|$)/.test(id) || /\b(סורק|מסווג|מדווח|census|ratchet|baseline)\b/.test(s)) return 'detect';
  if (/\b(purify|dehardcode|dehard|extract|lift|forge|reconvert|normalize|fixphone|clean\w*phone)\b/.test(id) || /\b(טיהור|מטהר|מחלץ|מרים|חשל|חילוץ)\b/.test(s)) return 'fix';
  if (/(verify|gate|golden|roundtrip|selftest|assert|police|proof)/.test(id) || /\b(מאמת|אימות|הוכחה|שער|round-trip)\b/.test(s)) return 'verify';
  if (/(guard|allow|can[A-Z]|permission|valid|block)/.test(rec.id) || /\b(הרשא|תקינות|חסימה|שוער)\b/.test(s)) return 'guard';
  if (/(socket|termof|cfgtext|fallback|externaliz)/.test(id) || /\bterm\b/.test(id)) return 'socket';
  if (rec.op === 'effect' || /(write|emit|send|render|append|record|apply|register)/.test(id)) return 'act';
  if (rec.op === 'collection' || rec.op === 'measure' || /(aggreg|total|sum|count|stats)/.test(id)) return 'aggregate';
  if (rec.op === 'predicate') return 'detect';
  return 'transform';
};
const CHAIN = ['guard', 'detect', 'fix', 'socket', 'verify', 'aggregate', 'act'];
const nondetHint = (rec) => /now|random|date|time/.test(rec.id.toLowerCase()) ? 1 : 0;

// ── משקל-IDF: אסימון-נדיר (purity/hok/tel) שווה הרבה; אסימון-שכיח (מודול/עזרי) ≈ 0.
const DF = new Map(); for (const r of EMPIRE) for (const t of domOf(r)) DF.set(t, (DF.get(t) || 0) + 1);
const N = EMPIRE.length;
const idf = (t) => Math.log((N + 1) / ((DF.get(t) || 0) + 1));

export function upgradeEngine(id) {
  const target = EMPIRE.find((x) => x.id === id) || EMPIRE.find((x) => x.id.toLowerCase() === id.toLowerCase());
  if (!target) return { id, error: 'לא נמצא באינדקס-האימפריה' };
  const splitId = (id) => id.replace(/([a-z0-9])([A-Z])/g, '$1 $2').replace(/[_-]/g, ' ').toLowerCase().split(/\s+/).filter((w) => w.length > 2 && !GENERIC.has(w));
  const tDom = domOf(target), tRole = ROLE(target);
  const tIdTok = new Set(splitId(target.id));           // אסימוני-השם = הזהות החזקה (מעל כותרת-פרוזה)
  const tKeys = [...tDom].filter((t) => idf(t) >= 3 || tIdTok.has(t));
  // ניקוד = סכום-IDF של המשותפים · אסימון-שם משותף שוקל פי-3 (הזהות, לא הפרוזה)
  const scored = EMPIRE.filter((r) => r.id !== target.id).map((r) => {
    const d = domOf(r), rIdTok = new Set(splitId(r.id)); let w = 0, shared = [];
    for (const t of tKeys) if (d.has(t)) { const bothId = tIdTok.has(t) && rIdTok.has(t); w += idf(t) * (bothId ? 3 : tIdTok.has(t) ? 1.5 : 1); if (bothId || idf(t) >= 4) shared.push(t); }
    return { rec: r, w: +w.toFixed(2), shared, role: ROLE(r) };
  }).filter((x) => x.shared.length >= 1 && x.w >= 5).sort((a, b) => b.w - a.w || nondetHint(a.rec) - nondetHint(b.rec) || a.rec.id.localeCompare(b.rec.id));
  const byRole = {}; for (const x of scored) (byRole[x.role] ||= []).push(x);
  const gap = CHAIN.filter((role) => role !== tRole && byRole[role]?.length);
  // חלופות פר-תפקיד: להעדיף קבצים שונים (לא 3 אחים מאותו קובץ)
  const pick3 = (arr) => { const seen = new Set(), out = []; for (const x of arr) { const k = x.rec.file; if (!seen.has(k) || out.length < 1) { out.push(x); seen.add(k); } if (out.length >= 3) break; } return out; };
  const plan = gap.map((role) => {
    const picks = pick3(byRole[role]).map((x) => `${x.rec.repo}:${x.rec.file}#${x.rec.id}[${x.shared.slice(0, 3).join('/')}]`);
    // מקסימום: כל העוזרים פר-תפקיד (variants-עם-default), לא top-1
    const all = byRole[role].map((x) => `${x.rec.repo}:${x.rec.file}#${x.rec.id}`);
    return { role, default: picks[0], top3: picks, count: all.length, all };
  });
  return { id: target.id, role: tRole, keys: tKeys.slice(0, 8), gap, helpersFound: scored.length, plan };
}

// ════════════════════════════════════════════════════════════════════════════
// bucketsOf — מיון-רשומה לסלים (A–Z). המיון שנעשה ידנית ע"י 6 סוכנים, כאן כמנוע.
// דטרמיניסטי · מבנה לפני מילים. סדר-הכללים (חרוט; ראה NOTES-up-buckets.md):
//   (1) K  — op לא-ריק ∈ {measure,predicate,collection,format,transform,guard,effect} ⇒ חלקיק-יסוד. (engine אינו חלקיק.)
//   (2) I  — קובץ ב-gates.tsv (עותק machtzev-gen/gates.tsv אם קיים) או שם ~ /-check|-gate|police|baseline|ratchet/.
//   (3) C/D/E/G/H/J — מיקום-בצנרת אם ידוע (STAGE), אחרת מ-ROLE():
//        detect⇒C+D · verify⇒E · fix⇒G · act⇒H+J · socket⇒L · aggregate⇒K. (guard/transform נשענים על K.)
//   (4) M/L/N/A/B — ds|looks|skin⇒M · *.data.json|terms|atlas⇒L · learn|curriculum⇒N · yeshiva|psak⇒A · particle|peruk|shape|decomp|partition⇒B.
//   (5) מילים מ-dom כשובר-שוויון — רק אם הסל עדיין ריק.
//   ואם עדיין ריק ⇒ Z. מנוע יכול לקבל כמה סלים; אף מנוע לא נשאר בלי סל.
const K_OPS = new Set(['measure', 'predicate', 'collection', 'format', 'transform', 'guard', 'effect']);
const ROLE_BUCKET = { detect: ['C', 'D'], verify: ['E'], fix: ['G'], act: ['H', 'J'], socket: ['L'], aggregate: ['K'] };
// מפת-שלבים לפי מיקום-בצנרת (מאצ'בב). איחוד: קובץ יכול לגעת בכמה שלבים (box-purify ⇒ H+G).
const STAGE = [
  [/(^|\/)(census|carve|chisel|quarry|extract)([-.\/]|$)/, 'C'],
  [/(^|\/)(index-check|empire-coverage|merge-regen|atom-count)/, 'C'],
  [/(^|\/)search/, 'D'],
  [/(^|\/)(selftest|verify|proof|golden|truth|mutation|contract-check|coverage-gate|no-fakers|cross-source|goal-proof)/, 'E'],
  [/(^|\/)(purity|pure|purify|repair|data-purity|deep-purity)/, 'G'],
  [/(^|\/)(box|emit|assemble|rethread|wiring)/, 'H'],
  [/(^|\/)(generator|compose-engine|run|root|tools|one|dart-bin|mahulal|lib-ts)([-.\/]|$)/, 'J'],
  [/(^|\/)dedup/, 'F'],
];
// נרמול-נתיב: הסרת קידומת-ריפו + ./ מובילים (להתאמה מול קובץ-הזהב).
export const normFile = (f) => String(f || '').replace(/^\.?\/+/, '').replace(/^(maor-system|maor|machtzev-gen|machtzev)\//, '');
// gates.tsv — אם המנהל הדביק עותק machtzev-gen/gates.tsv, טוענים את עמודת-הקובץ ל-I מדויק.
const GATES = (() => {
  const set = new Set();
  try {
    const raw = fs.readFileSync(path.join(GEN, 'gates.tsv'), 'utf8');
    for (const line of raw.split(/\r?\n/)) {
      const cells = line.split('\t');
      for (const c of cells) if (/\.(ts|tsx|js|mjs|dart)$/.test(c)) set.add(normFile(c.trim()));
    }
  } catch { /* אין עותק — נופלים לזיהוי-משם בלבד */ }
  return set;
})();

export function bucketsOf(rec) {
  const b = new Set();
  const file = String(rec.file || ''), id = String(rec.id || '');
  const hay = (file + ' ' + id).toLowerCase();
  const domStr = (rec.dom || []).join(' ').toLowerCase();
  // (1) K
  if (rec.op && K_OPS.has(rec.op)) b.add('K');
  // (2) I
  if (GATES.has(normFile(file)) || /(^|[-\/])(check|checks|gate|gates|police|baseline|ratchet)([-.\/]|$)/.test(hay)) b.add('I');
  // (3) C/D/E/G/H/J — מיקום אם ידוע, אחרת ROLE
  let located = false;
  for (const [re, bk] of STAGE) if (re.test(file)) { b.add(bk); located = true; }
  if (!located) for (const bk of (ROLE_BUCKET[ROLE(rec)] || [])) b.add(bk);
  // (4) M/L/N/A/B מבניים
  if (/(^|\/)(ds|looks|skin)([-\/]|$)/.test(hay)) b.add('M');
  if (/\.data\.json$|(^|\/)terms|atlas/.test(hay)) b.add('L');
  if (/(^|\/)(learn|curriculum)/.test(hay)) b.add('N');
  if (/(^|\/)(yeshiva|psak)|ישיב|פסק/.test(hay)) b.add('A');
  if (/particle|peruk|(^|\/)shape|decomp|partition|פירוק/.test(hay)) b.add('B');
  // (5) שובר-שוויון מ-dom — רק אם עדיין ריק
  if (b.size === 0) {
    if (/index|census|אינדקס|צנזוס|חציב/.test(domStr)) b.add('C');
    else if (/search|חיפוש|אחזור/.test(domStr)) b.add('D');
    else if (/proof|golden|test|הוכח|זהב|בדיק/.test(domStr)) b.add('E');
    else if (/purif|heal|טיהור|ריפוי|שדרוג/.test(domStr)) b.add('G');
    else if (/wire|assemble|box|חיווט|הרכב|קופס/.test(domStr)) b.add('H');
  }
  if (b.size === 0) b.add('Z');
  return [...b].sort();
}

// jaccard בין שתי קבוצות-סלים
const jaccard = (a, c) => {
  const A = new Set(a), C = new Set(c); if (!A.size && !C.size) return 1;
  let inter = 0; for (const x of A) if (C.has(x)) inter++;
  return inter / (A.size + C.size - inter);
};

// מדידה: מול sort-golden.json אם קיים, אחרת התפלגות מול empire-index בלבד.
function measureBuckets() {
  const rows = EMPIRE.map((r) => ({ id: r.id, repo: r.repo, file: r.file, buckets: bucketsOf(r) }));
  const dist = {}; let multi = 0, total = 0;
  const combo = {};
  for (const r of rows) {
    for (const bk of r.buckets) dist[bk] = (dist[bk] || 0) + 1;
    if (r.buckets.length > 1) multi++;
    total += r.buckets.length;
    const k = r.buckets.join('+'); combo[k] = (combo[k] || 0) + 1;
  }
  const out = { records: rows.length, buckets: rows, dist, avgPerRec: +(total / rows.length).toFixed(3), multiBucket: multi, topCombos: Object.entries(combo).sort((a, b) => b[1] - a[1]).slice(0, 15) };
  // זהב
  let golden = null;
  try { golden = JSON.parse(fs.readFileSync(path.join(GEN, 'sort-golden.json'), 'utf8')); } catch { /* אין */ }
  if (golden) {
    const gByFile = new Map();
    for (const g of golden) gByFile.set(normFile(g.file), Array.isArray(g.buckets) ? g.buckets : String(g.buckets || '').split(/[^A-Z]+/).filter(Boolean));
    const eByFile = new Map();
    for (const r of rows) if (!eByFile.has(normFile(r.file))) eByFile.set(normFile(r.file), r.buckets); // ראשון-לקובץ
    let shared = 0, sumJ = 0, ge05 = 0, zero = 0;
    const conf = {}; // conf[goldBucket][engineBucket] = count
    for (const [f, gb] of gByFile) {
      const eb = eByFile.get(f); if (!eb) continue;
      shared++; const j = jaccard(eb, gb); sumJ += j; if (j >= 0.5) ge05++; if (j === 0) zero++;
      for (const gx of gb) { conf[gx] = conf[gx] || {}; for (const ex of eb) conf[gx][ex] = (conf[gx][ex] || 0) + 1; }
    }
    out.golden = { goldRecords: golden.length, sharedFiles: shared, avgJaccard: shared ? +(sumJ / shared).toFixed(4) : 0, ge05, zero, confusion: conf };
  }
  return out;
}

const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  const args = process.argv.slice(2);
  const flags = args.filter((a) => a.startsWith('--'));
  const ids = args.filter((a) => !a.startsWith('--'));
  if (flags.includes('--buckets')) {
    const m = measureBuckets();
    if (flags.includes('--json')) { console.log(JSON.stringify(flags.includes('--full') ? m : { ...m, buckets: undefined }, null, flags.includes('--full') ? 0 : 1)); }
    else {
      console.log(`\n═══ מיון-לסלים · ${m.records} רשומות (empire-index) ═══`);
      console.log('התפלגות-סלים:'); for (const [bk, c] of Object.entries(m.dist).sort((a, b) => b[1] - a[1])) console.log(`  ${bk} : ${c}`);
      console.log(`ממוצע-סלים-לרשומה: ${m.avgPerRec} · רב-סליות: ${m.multiBucket} · Z(לא-ידוע): ${m.dist.Z || 0}`);
      console.log('שילובים-נפוצים:'); for (const [k, c] of m.topCombos) console.log(`  ${k.padEnd(10)} ${c}`);
      if (m.golden) {
        const g = m.golden;
        console.log(`\n── מול הזהב (sort-golden.json · ${g.goldRecords} רשומות) ──`);
        console.log(`קבצים-משותפים: ${g.sharedFiles} · Jaccard-ממוצע: ${g.avgJaccard} · ≥0.5: ${g.ge05} · =0: ${g.zero}`);
        console.log('מטריצת-בלבול (זהב→מנוע):'); for (const [gx, row] of Object.entries(g.confusion)) console.log(`  ${gx}: ${Object.entries(row).sort((a, b) => b[1] - a[1]).map(([e, c]) => e + ':' + c).join(' ')}`);
      } else {
        console.log('\n⚠️ אין sort-golden.json — מדידה מול empire-index בלבד. הדבק את SORT-ALL.json ל-machtzev-gen/sort-golden.json.');
      }
    }
  } else {
    for (const id of (ids.length ? ids : ['purity-data'])) {
      const u = upgradeEngine(id);
      console.log(`\n═══ שדרוג ${u.id}${u.error ? ' — ' + u.error : ''} ═══`);
      if (u.error) continue;
      console.log(`תפקיד-נוכחי: ${u.role} · אסימוני-זהות: ${u.keys.join(' ')} · עוזרים: ${u.helpersFound} · פער: [${u.gap.join(', ')}]`);
      for (const p of u.plan) console.log(` ${p.role.padEnd(9)} → ${p.default}${p.top3.length > 1 ? '   | חלופות: ' + p.top3.slice(1).join(' · ') : ''}`);
    }
  }
}

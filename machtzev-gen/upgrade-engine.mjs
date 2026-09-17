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

const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  const ids = process.argv.slice(2).filter((a) => !a.startsWith('--'));
  for (const id of (ids.length ? ids : ['purity-data'])) {
    const u = upgradeEngine(id);
    console.log(`\n═══ שדרוג ${u.id}${u.error ? ' — ' + u.error : ''} ═══`);
    if (u.error) continue;
    console.log(`תפקיד-נוכחי: ${u.role} · אסימוני-זהות: ${u.keys.join(' ')} · עוזרים: ${u.helpersFound} · פער: [${u.gap.join(', ')}]`);
    for (const p of u.plan) console.log(` ${p.role.padEnd(9)} → ${p.default}${p.variants.length > 1 ? '   | חלופות: ' + p.variants.slice(1).join(' · ') : ''}`);
  }
}

#!/usr/bin/env node
/** 🧪 מחצב · מנוע-הסינתזה (הכרעת-בעלים: "תביא יכולות שאין — והוא יהיה חייב לחבר
 *  כמה-וכמה אטומים כדי להגיע ליכולת"): הזמנת-יכולת = תיאור + דוגמאות קלט⇒פלט.
 *  המנוע מחפש לבדו הרכבה (שרשרת עד עומק-4) של אטומים חיים שמוכיחה את כל הדוגמאות —
 *  מונחה חוש-המשמעות (קוהרנטיות-תיאור) ואז רוחב. הצלחה ⇒ spec למחולל; כישלון ⇒ דוח כן.
 *  קבצים: machtzev/generator/capabilities/<שם>.txt — שורה 1 תיאור; אחריה 'קלט => פלט'.
 *  מצבים: (ברירת-מחדל) סינתזה לכל ההזמנות · --dream הזמנה-עצמית יומית לפני הסינתזה ·
 *  --gate שער-שימור: כל יכולת שהוכחה חייבת להישאר מוכחת על התאומים החיים (JS תמיד;
 *  ‏Dart כשיש dart ב-PATH/DART_BIN — משחזר את השחלת-המחרוזות של המסך המחולל). */
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync, execSync } from 'node:child_process';
import { buildAtlas } from './atlas.mjs';
import { buildTwinRegistry, twinMeta, dartLit } from './twins.mjs';
import { resolveDart, requireDart } from '../dart-bin.mjs';
import * as R from '../root.mjs';
const HERE = R.GEN_DIR;
const ROOT = R.ROOT;
const CAPS = path.join(HERE, 'capabilities');
const SPECS = path.join(HERE, 'specs');
const GATE = process.argv.includes('--gate');
const DREAM = process.argv.includes('--dream');
const P = JSON.parse(fs.readFileSync(path.join(HERE, 'knowledge/self-model.json'), 'utf8')).phrases;

const atlas = buildAtlas();
const norm = (w) => w.replace(/^ה(?=..)/, '');
// מילות-קישור תלושות בסוף מהות מחולצת ("מספר סידורי של") — נגזמות לתווית נקייה
const STOP_TAIL = new Set(['של', 'עם', 'או', 'אם', 'את', 'על', 'אל', 'מ', 'ל']);
const cleanHe = (ws) => { const a = [...ws]; while (a.length > 1 && STOP_TAIL.has(a[a.length - 1])) a.pop(); return a; };
const pool = [];
{
  const seen = new Set();
  for (const f of atlas.functions) {
    if (seen.has(f.name) || !f.he.length || !f.params.length) continue;
    seen.add(f.name); pool.push(f);
  }
}
const twins = await buildTwinRegistry(pool);
const fnsBy = new Map(pool.map(f => [f.name, f]));
// קבילות-למסך: המנוע רץ ב-JS, אבל spec חייב להיות ניתן-לחיווט Dart שקול —
// זנב אופציונלי (null) או זנב-קציר פשוט באורך-הפרמטרים (נפלט כליטרלים).
const FEEDABLE0 = /^(String|dynamic|Object|num|int|double)\??$/;
const wirable = (f) => {
  if (!twins.has(f.name)) return false;
  // חוליית-שרשרת ניזונה מ-String (השחלת-המסך) — פרמטר-ראשון מוקלד-מכולה (List/Map) אינו בר-הזנה ב-Dart
  if (!FEEDABLE0.test(f.params[0].type)) return false;
  // ‏Dart קובע את החיווט: תאום-Dart חד-פרמטרי / זנב-אופציונלי ⇒ תמיד ניתן (שקעי-JS הם
  // פרט-מימוש של הטיהור); אחרת נדרש זנב-קציר פשוט תואם-אורך שנפלט כליטרלים.
  if (f.params.length === 1 || f.params.slice(1).every(p => p.type.endsWith('?'))) return true;
  const meta = twinMeta.get(f.name);
  return !!(meta && meta.simple && meta.tail.length === f.params.length - 1);
};

// ── השחלת-מסך: בין חוליות עובר תמיד String (כמו ב-Dart המחולל: ‎.toString()‎ בין שלבים),
//    ופרמטר מספרי נפתח ב-tryParse. החיפוש רץ בדיוק בסמנטיקה שהמסך ירוץ — אפס פער JS⇄Dart.
const feed1 = (f, s) => {
  const t = f.params[0].type.replace(/\?$/, '');
  if (t === 'num' || t === 'double') { const n = s.trim() === '' ? NaN : Number(s); return Number.isNaN(n) ? NaN : n; } // num.tryParse ?? double.nan
  if (t === 'int') return /^[+-]?\d+$/.test(s.trim()) ? parseInt(s, 10) : 0;                                            // int.tryParse ?? 0
  return s;
};
const stepFn = (f, s) => {
  const out = twins.get(f.name)(feed1(f, s));
  return (out === undefined || out === null) ? null : String(out);
};
const runChain = (chain, input) => {
  let v = String(input);
  for (const c of chain) { try { v = stepFn(fnsBy.get(c), v); } catch { return null; } if (v === null) return null; }
  return v;
};

function synthesize(desc, examples) {
  const dwords = new Set((desc.match(/[֐-׿]+/g) || []).map(norm));
  const cohere = (f) => f.he.reduce((n, w) => n + (dwords.has(norm(w)) ? 1 : 0), 0);
  const fns = pool.filter(wirable).sort((a, b) => cohere(b) - cohere(a));
  const inputs = examples.map(e => String(e.in));
  const want = examples.map(e => e.out);
  const sig = (v) => JSON.stringify(v);
  const seenV = new Set([sig(inputs)]);
  let frontier = [{ vals: inputs, path: [] }];
  for (let depth = 1; depth <= 4; depth++) {
    const next = [];
    const wins = [];                                               // כל הפתרונות בעומק-הזכייה — לא רק הראשון
    for (const st of frontier) {
      for (const f of fns) {
        let outs;
        try { outs = st.vals.map(v => stepFn(f, v)); } catch { continue; }
        if (outs.some(o => o === null)) continue;
        if (outs.every((o, i) => o === want[i])) { wins.push([...st.path, f.name]); continue; }
        if (outs.some(o => o.length > 200 || o === '')) continue;
        const s2 = sig(outs);
        if (seenV.has(s2)) continue;
        seenV.add(s2);
        if (next.length < 4000) next.push({ vals: outs, path: [...st.path, f.name] });
      }
    }
    if (wins.length) {
      // בחירה: הפתרון הקוהרנטי-ביותר לתיאור; השאר מדווחים כחלופות (שקיפות-חיפוש)
      const score = (p) => p.reduce((n, x) => n + cohere(fnsBy.get(x)), 0);
      wins.sort((a, b) => score(b) - score(a));
      return { chain: wins[0], alts: wins.length - 1, shortcut: depth === 1 };
    }
    frontier = next;
    if (!frontier.length) break;
  }
  return null;
}

const parseCap = (cf) => {
  const lines = fs.readFileSync(path.join(CAPS, cf), 'utf8').split('\n').map(l => l.trim()).filter(Boolean);
  const examples = lines.slice(1).map(l => l.split(/=>|⇒/)).filter(p => p.length === 2).map(([a, b]) => ({ in: a.trim(), out: b.trim() }));
  return { desc: lines[0], examples };
};
const slugOf = (cf) => 'cap' + cf.replace(/\.txt$/, '').replace(/[^a-z0-9]/g, '');
const chainOfSpec = (specPath) => {                                // השרשרת = בלוק-החישובים הראשון (אחרי ה-chips)
  const ls = fs.readFileSync(specPath, 'utf8').split('\n');
  const chain = []; let collecting = false;
  for (const l of ls) {
    if (/^אטום ChipWrap /.test(l)) { collecting = true; continue; }
    if (collecting) {
      const m = l.match(/^\s+חישוב .*\(([a-zA-Z]\w*)\)\s*$/);
      if (m) chain.push(m[1]); else break;
    }
  }
  return chain;
};

// ── 🚪 שער-השימור (--gate): יכולת שהוכחה חייבת להישאר מוכחת ──
if (GATE) {
  let bad = 0, n = 0;
  const caps = fs.existsSync(CAPS) ? fs.readdirSync(CAPS).filter(x => x.endsWith('.txt')) : [];
  const dartJobs = [];
  for (const cf of caps) {
    const { desc, examples } = parseCap(cf);
    if (!examples.length) continue;
    n++;
    const specPath = path.join(SPECS, slugOf(cf) + '.txt');
    if (!fs.existsSync(specPath)) { console.error(`🚨 שער-הסינתזה: אין spec ל-${cf} — הרץ synth`); bad = 1; continue; }
    const chain = chainOfSpec(specPath);
    if (!chain.length || chain.some(c => !twins.has(c))) { console.error(`🚨 שער-הסינתזה: שרשרת חסרה/לא-ברת-הרצה ב-${cf}: ${chain.join('∘') || '—'}`); bad = 1; continue; }
    for (const ex of examples) {
      const v = runChain(chain, ex.in);
      if (v !== ex.out) { console.error(`🚨 שער-הסינתזה: ${cf} · ${ex.in} ⇒ ${JSON.stringify(v)} ≠ ${JSON.stringify(ex.out)} (${chain.join('∘')})`); bad = 1; }
    }
    dartJobs.push({ cf, chain, examples });
  }
  // בדיקת-שקילות-Dart: משחזרת את השחלת-המסך (String בין-חוליות, tryParse לפרמטר מספרי)
  let dartNote = '~ dart מדולג (אין בינארי)';
  const dartBin = (() => {
    // c2 · פותר-Dart משותף (dart-bin.mjs). L34: יש עבודות-Dart ואין בינארי ⇒ exit 2 (היה: דילוג-שקט ⇒ ירוק-כוזב).
    const d = resolveDart();
    if (!d && dartJobs.length) requireDart('synth · שקילות-Dart');
    return d;
  })();
  if (dartBin && dartJobs.length && !bad) {
    const esc = (s) => s.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\$/g, '\\$');
    const lines = [];
    const imported = new Set();
    for (const { chain } of dartJobs) for (const c of chain) {
      const f = fnsBy.get(c);
      const abs = path.join(ROOT, f.shelf.replace(/^new\//, 'new/'), f.file);
      if (!imported.has(abs)) { imported.add(abs); }
    }
    const tmpDir = fs.mkdtempSync('/tmp/synthgate-');
    const imps = [...imported].map(abs => `import '${path.relative(tmpDir, abs)}';`).join('\n');
    const body = [];
    for (const { cf, chain, examples } of dartJobs) for (const ex of examples) {
      let expr = `'${esc(ex.in)}'`;
      for (const c of chain) {
        const f = fnsBy.get(c);
        const t = f.params[0].type.replace(/\?$/, '');
        const meta = twinMeta.get(c);
        const tail = meta && meta.simple && meta.tail.length === f.params.length - 1 ? meta.tail.map(x => dartLit(x)) : f.params.slice(1).map(() => 'null');
        const arg = (t === 'num' || t === 'double') ? `(num.tryParse(${expr}) ?? double.nan)` : t === 'int' ? `(int.tryParse(${expr}) ?? 0)` : expr;
        // c2 · שקילות-מחרוזת JS↔Dart: JS String([a,b]) = 'a,b'; Dart List.toString() = '[a, b]' ⇒ ל-List משתמשים ב-join(',')
        // (באג-רתמה שהוסתר כי Dart מעולם לא רץ — התיקון במנוע, לא בפלט · L25).
        // כל ערך שאינו String עובר jsStr() — מחרוזת-בסגנון-JS (List ⇒ join(','), int בלי .0, null ⇒ 'null'),
        // גם ל-dynamic (sortSupportThreads('אחת') מחזיר List — Dart: '[א, ח, ת]', JS: 'א,ח,ת').
        const call = `${c}(${[arg, ...tail].join(', ')})`;
        expr = f.ret === 'String' ? call
             : f.ret === 'String?' ? `(${call} ?? '')`
             : `jsStr(${call})`;
      }
      body.push(`  check('${esc(cf)}', '${esc(ex.in)}', ${expr}, '${esc(ex.out)}');`);
    }
    const script = `${imps}\nString jsStr(dynamic v) => v == null ? 'null' : v is List ? v.map(jsStr).join(',') : v is double && v == v.truncateToDouble() && v.isFinite ? v.toInt().toString() : v.toString();\nint bad = 0;\nvoid check(String cf, String inp, String got, String want) {\n  if (got != want) { print('DARTFAIL \$cf \$inp => \$got != \$want'); bad = 1; }\n}\nvoid main() {\n${body.join('\n')}\n  print(bad == 1 ? 'DARTBAD' : 'DARTOK');\n}\n`;
    const tf = path.join(tmpDir, 'gate.dart');
    fs.writeFileSync(tf, script);
    try {
      const out = execFileSync(dartBin, ['run', tf], { timeout: 120000 }).toString();
      if (out.includes('DARTOK')) dartNote = '✓ שקילות-Dart אומתה (השחלת-המסך ביט-זהה לדוגמאות)';
      else { console.error('🚨 שער-הסינתזה: שקילות-Dart נשברה:\n' + out.trim()); bad = 1; dartNote = ''; }
    } catch (e) { console.error('🚨 שער-הסינתזה: הרצת-dart כשלה: ' + String(e.stderr || '') .slice(0, 500) + ' | ' + String(e.stdout || e.message).slice(0, 200)); bad = 1; dartNote = ''; }
    if (bad) console.error('   gate.dart נשמר לאבחון: ' + tf); else fs.rmSync(tmpDir, { recursive: true, force: true });
  }
  if (!bad) console.log(`✓ שער-הסינתזה: ${n} יכולות-מוזמנות מוכחות-חי · ${dartNote}`);
  process.exit(bad);
}

// ── 🌙 הזמנה-עצמית (--dream): המכונה חולמת יכולת, מחשבת דוגמאות, ואז מוכיחה כרגיל ──
if (DREAM) {
  const day = new Date().toISOString().slice(0, 10);
  let s = [...day].reduce((a, c) => (a * 31 + c.charCodeAt(0)) >>> 0, 7);
  const rnd = () => (s = (s * 1103515245 + 12345) >>> 0) / 2 ** 32;
  const bank = [];
  for (const d of atlas.data) if (d.type === 'List<String>' && Array.isArray(d.items))
    for (const it of d.items) if (typeof it === 'string' && it.length >= 2 && it.length <= 25) bank.push(it);
  const fns = pool.filter(wirable);
  let dreamed = null;
  for (let t = 0; t < 500 && !dreamed; t++) {
    const len = 2 + Math.floor(rnd() * 2);
    const chain = Array.from({ length: len }, () => fns[Math.floor(rnd() * fns.length)].name);
    const exs = [];
    for (let k = 0; k < 24 && exs.length < 2; k++) {
      const inp = bank[Math.floor(rnd() * bank.length)];
      const out = runChain(chain, inp);                            // אותה השחלת-מסך כמו בחיפוש ובשער
      if (out === null || !out || out.length > 40 || out === inp || exs.some(e => e.out === out || e.in === inp)) continue;
      exs.push({ in: inp, out });
    }
    if (exs.length !== 2) continue;
    // חלום מתקבל רק אם מנוע-הסינתזה עצמו מוכיח אותו בהרכבה אמיתית (לא אטום-יחיד,
    // לא מסלול שהחיפוש לא מסוגל לשחזר — למשל חוליית-ביניים ריקה שהגיזום פוסל)
    const ess = chain.map(c => cleanHe(fnsBy.get(c).he).slice(0, 3).join(' ')).join(' ואז ');
    const desc = `${P.capDream} - ${ess}`;
    const proof = synthesize(desc, exs);
    if (proof && !proof.shortcut) dreamed = { chain, exs, desc };
  }
  if (dreamed) {
    const txt = [dreamed.desc, ...dreamed.exs.map(e => `${e.in} => ${e.out}`)].join('\n') + '\n';
    fs.mkdirSync(CAPS, { recursive: true });
    fs.writeFileSync(path.join(CAPS, 'auto-dream.txt'), txt);
    console.log(`🌙 חלום-${day}: ${dreamed.chain.join(' ∘ ')} · ${dreamed.exs.map(e => `${e.in}⇒${e.out}`).join(' · ')}`);
  } else console.log('🌙 חלום: לא נמצאה שרשרת-חלום יציבה היום — מדולג בכנות');
}

// ── סינתזה רגילה: כל ההזמנות ⇒ specs ──
let made = 0;
if (fs.existsSync(CAPS)) for (const cf of fs.readdirSync(CAPS).filter(x => x.endsWith('.txt'))) {
  const { desc, examples } = parseCap(cf);
  if (!examples.length) continue;
  const found = synthesize(desc, examples);
  const slug = slugOf(cf);
  if (!found) {
    console.log(`🧪 ${cf}: לא נמצאה הרכבה (עומק≤4) — כישלון כן`);
    // ניקוי-כן: spec/מסך ישנים של יכולת שכבר לא מוכחת לא נשארים על המדף
    for (const stale of [path.join(SPECS, slug + '.txt'), path.join(R.outDir(), `gen_${slug}.dart`), path.join(ROOT, 'new/dart-data-bs/auto', `gen_${slug}_content.dart`)])
      if (fs.existsSync(stale)) { fs.rmSync(stale); console.log(`🧹 הוסר יתום: ${path.relative(ROOT, stale)}`); }
    continue;
  }
  const { chain, alts, shortcut } = found;
  if (shortcut) console.log(`⚠️ ${cf}: נפתר באטום-יחיד — הדוגמאות אינן כופות הרכבה (חזק אותן אם רצית שרשרת)`);
  if (alts) console.log(`🔎 ${cf}: נמצאו עוד ${alts} הרכבות שקולות באותו עומק — נבחרה הקוהרנטית-ביותר`);
  const calc = chain.map(n => `  חישוב ${cleanHe(fnsBy.get(n).he).join(' ')} (${n})`);
  const short = desc.split(/\s+/).slice(0, 3).join(' ');
  const spec = [
    `${desc}:`,
    `הירו 🧪 ${desc} | יכולת שהוזמנה ולא היתה קיימת - הרכבתי אותה לבד מ-${chain.length} אטומים והוכחתי על ${examples.length} דוגמאות`,
    `כותרת ${P.capProofTitle}`,
    `אטום ChipWrap ${desc}: ${examples.map(e => e.in).join(' / ')}`,
    ...calc,
    `כותרת ${P.capFreeTitle}`,
    `${P.fieldPrompt} ${short}`,
    ...calc,
    // בלי ':' — פרסר-הבקשות מפרש אותו כמפריד-אפשרויות והשמות היו נעלמים מהבאנר
    `באנר ההרכבה שמצאתי - ${chain.join(' ⟵ ')} - כל הדוגמאות עברו`,
  ].join('\n');
  fs.writeFileSync(path.join(SPECS, slug + '.txt'), spec + '\n');
  console.log(`🧪 ${cf}: ✅ הרכבה נמצאה — ${chain.join(' ∘ ')} ⇒ specs/${slug}.txt`);
  made++;
}
console.log(`🧪 סינתזה: ${made} יכולות-מוזמנות הורכבו (מאגר-חיווט: ${pool.filter(wirable).length} · ברי-הרצה: ${twins.size})`);

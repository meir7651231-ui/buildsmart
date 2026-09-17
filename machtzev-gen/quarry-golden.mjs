#!/usr/bin/env node
// ⛏️ quarry-golden — חציבה דטרמיניסטית של מודולי-הזהב לחלקיקי-הרכבה (GENMAX · G4a · הכרעה-24).
//   דוקטרינה: "הכל כבר חצוב — לא כותבים, חוצבים ומרכיבים." 9 מודולי-SchoolOS (ביד-בדרך) הם חומר-הגלם;
//   כאן הם נחתכים **מכנית** לשברים (fragments) לפי הסמנים שהבנאים השאירו בבייטים:
//     `// ═══ <מטרה> = Atom ⊕ Atom …`  (הצהרת-הרכבה)  ·  `// ─── …` (תת-בלוק)  ·  `Widget _x(` (בונה-תצוגה)  ·  `class X`.
//   לכל שבר: טווח-שורות · כותרת-מוצהרת · אטומים-מוצהרים (מה-⊕) · **אטומים-בשימוש (מהקוד, מול ops-map)** · ops · imports.
//   חוק-חציבה: השברים מכסים את הקובץ במלואו ⇒ הרכבה-חוזרת = הקובץ המקורי **ביט-לביט** (שער `quarry`).
//   פלט: golden-fragments.json (הקטלוג להרכבה) + golden-fragments-report.md.
import fs from 'node:fs';
import path from 'node:path';
import * as R from '../root.mjs';

const ROOT = R.ROOT;
const GEN = path.join(ROOT, 'machtzev/generator');
const DIR = path.join(ROOT, 'new/dart-gen-bs');
const MODULES = ['schoolos.dart', 'schoolos_students.dart', 'schoolos_attendance.dart', 'schoolos_courses.dart', 'schoolos_teachers.dart', 'schoolos_rooms.dart', 'schoolos_fees.dart', 'schoolos_parents.dart', 'schoolos_dashboard.dart'];
const MAP = JSON.parse(fs.readFileSync(path.join(GEN, 'ops-map.json'), 'utf8'));
const atomById = new Map(MAP.map((a) => [a.id.split('@')[0], a]));
const ATOM_IDS = new Set(atomById.keys());

const isHeader = (l) => /^\s*\/\/ ═══/.test(l);
const isSub = (l) => /^\s*\/\/ ───/.test(l);
const isClass = (l) => /^(abstract\s+)?class\s+\w+/.test(l);
const isBuilder = (l) => /^\s+Widget\s+_\w+\(/.test(l) || /^\s+@override\s*$/.test(l);
const isClose = (l) => /^}\s*$/.test(l);                     // סוגר-מחלקה בעמודה 0 = שבר עצמאי (כדי שהרכבת-משנה תשמור מבנה)
// הצהרת-חבר בהזחת-גוף-מחלקה (2 רווחים בדיוק): שדה/מתודה/getter — שבר משלה ⇒ סגירת-תלויות מדויקת (שדות-state לא נבלעים במתודה שלפניהם)
const isMember = (l) => /^ {2}(?! )(?!\/\/)(?!@)(?!\})(?!\])(?!\))(?:static\s+|final\s+|late\s+|const\s+|var\s+)?[A-Za-z_][\w<>?, \[\]]*?\s+(?:get\s+)?_?\w+\s*(?:\(|=|;|=>)/.test(l) && !/^ {2}(return|if|else|for|while|switch|case|await|throw|yield)\b/.test(l);
const isCut = (l) => isHeader(l) || isSub(l) || isClass(l) || isBuilder(l) || isClose(l) || isMember(l);

function importsOf(lines) {
  return lines.filter((l) => /^import '/.test(l)).map((l) => {
    const m = l.match(/^import '([^']+)'/); const p = m[1];
    const base = path.basename(p, '.dart');
    const sym = /dart-ui-bs/.test(p) ? base.replace(/(^|_)([a-z0-9])/g, (_, __, c) => c.toUpperCase()) : base.replace(/-([a-z0-9])/g, (_, c) => c.toUpperCase());
    return { line: l, path: p, sym };
  });
}

export function quarry(file) {
  const src = fs.readFileSync(path.join(DIR, file), 'utf8');
  const lines = src.split('\n');
  const imports = importsOf(lines);
  // חיתוך: כל שורת-סמן פותחת שבר חדש; השברים רציפים ומכסים את הקובץ כולו (⇒ round-trip ביט-לביט).
  const frags = [];
  let start = 0;
  // חוקי-דבק: (א) `@override` לבדו = אנוטציה של ההצהרה הבאה — לא נחתך ממנה · (ב) שבר של הערות/ריק בלבד (כותרת-⊕, תת-כותרת) נדבק להצהרה הבאה —
  //   הכותרת מתארת את הקוד שאחריה, ולכן declaredAtoms רוכבים על השבר שמממש אותם (לא שבר-הערה יתום שאף הרכבה לא בוחרת)
  const onlyComments = (a, b) => lines.slice(a, b).every((l) => /^\s*(\/\/.*)?$/.test(l));
  for (let i = 1; i < lines.length; i++) {
    if (!isCut(lines[i])) continue;
    if (/^\s*@override\s*$/.test(lines[i - 1])) continue;                 // (א)
    if (start > 0 && onlyComments(start, i)) continue;                       // (ב) — הפתיח (start=0) נשאר שבר משלו
    frags.push({ start, end: i }); start = i;
  }
  frags.push({ start, end: lines.length });
  // סיווג-שברים: כותרת, אטומים-מוצהרים, אטומים-בשימוש, ops, imports
  let curCls = '(preamble)';
  const out = frags.map((f, idx) => {
    const code = lines.slice(f.start, f.end);
    const first = code.find((l) => l.trim().length && !/^\s*\/\//.test(l) && !/^\s*@override\s*$/.test(l)) || code.find((l) => l.trim().length) || '';
    if (isClass(first)) curCls = first.match(/class\s+(\w+)/)[1];
    const fragCls = curCls;
    if (isClose(first)) curCls = '(top)';                        // אחרי סוגר-המחלקה: רמת-קובץ (זנב/פונקציות-חופשיות אינם של המחלקה)
    const hdrLine = code.find((l) => isHeader(l) || isSub(l));
    const header = hdrLine ? hdrLine.replace(/^\s*\/\/\s*[═─]+\s*/, '').replace(/\s*[═─]+\s*$/, '').trim() : (isBuilder(first) ? first.trim() : (isClass(first) ? first.trim() : ''));
    const declared = hdrLine && header.includes('=') ? [...header.split('=').pop().matchAll(/\b([A-Za-z_][A-Za-z0-9_]*)\b/g)].map((m) => m[1]).filter((s) => ATOM_IDS.has(s)) : [];
    const ids = new Set([...code.join('\n').matchAll(/\b([A-Za-z_][A-Za-z0-9_]*)\b/g)].map((m) => m[1]));
    const used = [...ids].filter((s) => ATOM_IDS.has(s) && !/^(String|List|Map|Set|Widget|Text|int|num|bool)$/.test(s));
    const ops = [...new Set(used.map((s) => atomById.get(s).op))];
    const need = imports.filter((im) => ids.has(im.sym)).map((im) => im.path);
    // הגדרות שהשבר תורם (לסגירת-תלויות בהרכבה): מתודות/שדות סטטיים · בוני-תצוגה · שדות-state · מחלקות
    const body = code.join('\n');
    const defs = new Set();
    const KW = /^(return|if|else|for|while|switch|case|await|throw|yield|import|export|part|class|enum|typedef|extends|with|implements|super|this|new|print|setState|assert|break|continue|do|try|catch|finally|in|is|as)$/;
    // הצהרות ברמת-קובץ (עמודה 0) וברמת-גוף-מחלקה (2 רווחים): שדה/מתודה/getter/setter/const/final/late/var/typedef/class — כולל שם-בודד ('d') ושם-ציבורי
    // טיפוס-רשומה `(A, B)` בטיפוס-ההחזרה (List<(String, num?)>) · getter עם גוף-בלוק (`get x {`) — שניהם הצהרות (לקח: weekIsos/avgGrades/_goalDefs לא נסגרו)
    for (const m of body.matchAll(/^(?: {2})?(?:static\s+)?(?:const\s+|final\s+|late\s+|var\s+)?(?:const\s+|final\s+)?(?:[A-Za-z_][\w<>?, \[\]]*?(?:\([^()]*\)[\w<>?, \[\]]*?)?\s+)?(?:(?:get|set)\s+)?([A-Za-z_]\w*)\s*(?:\(|=|;|=>|\{)/gm)) if (!KW.test(m[1])) defs.add(m[1]);
    for (const m of body.matchAll(/^(?:abstract\s+)?(?:class|enum|typedef|mixin|extension)\s+(\w+)/gm)) defs.add(m[1]);
    // 'build' = רק השבר שמכיל את Widget build( (לא כל @override — didUpdateWidget/initState הם חברים)
    const role = isClass(first) ? 'class-head' : isClose(first) ? 'class-close' : /\bWidget\s+build\s*\(/.test(body) ? 'build' : /^\s+Widget\s+_\w+\(/.test(first) ? 'builder' : idx === 0 ? 'preamble' : 'member';
    // G5a · שקעי-הבונים: ל-build מקורי — הפתיח (prelude = כל המשפטים לפני ה-return האחרון; הכנת-השקעים של הזהב: cls/visible/ranked…)
    //   ואתרי-הקריאה של כל בונה (`_x(args)` בארגומנטים כפי שהזהב קרא לו, כולל `for (final s in visible) _row(s)`) — הערכים = של הזהב, לא מומצאים (§20-ג)
    let prelude = null, callSites = null;
    const grabSites = (tail) => {
      const sites = {};
      const grab = (str, at) => { let d = 0; for (let i = at; i < str.length; i++) { if (str[i] === '(') d++; else if (str[i] === ')') { d--; if (d === 0) return str.slice(at, i + 1); } } return null; };
      for (const m of tail.matchAll(/(?<![\w.])(_\w+)\(/g)) {
        const args = grab(tail, m.index + m[1].length); if (args === null) continue;
        const before = tail.slice(Math.max(0, m.index - 80), m.index);
        const fm = before.match(/for \(final (\w+) in ([\w.]+)\)\s*$/);
        const site = fm ? `for (final ${fm[1]} in ${fm[2]}) ${m[1]}${args}` : `${m[1]}${args}`;
        (sites[m[1]] ??= []); if (!sites[m[1]].includes(site) && sites[m[1]].length < 4) sites[m[1]].push(site);
      }
      return sites;
    };
    if (role === 'builder') { const bi = code.findIndex((l) => /^\s+Widget\s+_\w+\(/.test(l)); callSites = grabSites(code.slice(bi + 1).join('\n')); if (!Object.keys(callSites).length) callSites = null; }
    if (role === 'build') {
      const bi = code.findIndex((l) => /^\s+Widget\s+build\s*\(/.test(l));
      let lastRet = -1; for (let i = bi + 1; i < code.length; i++) if (/^ {4}return\b/.test(code[i])) lastRet = i;
      if (bi >= 0 && lastRet > bi) {
        prelude = [f.start + bi + 1, f.start + lastRet];
        callSites = grabSites(code.slice(lastRet).join('\n'));
      }
    }
    return { id: `${file.replace(/\.dart$/, '')}#${idx}`, module: file, cls: fragCls, role, prelude, callSites, range: [f.start, f.end], header, declaredAtoms: declared, atomsUsed: used, ops, imports: need, defs: [...defs].filter((d) => !/^(build|initState|dispose|createState|Widget|State)$/.test(d)), lines: code };
  });
  const roundTrip = out.map((f) => f.lines.join('\n')).join('\n') === src;
  return { file, lines: lines.length, fragments: out, roundTrip };
}

const all = MODULES.map(quarry);
const frags = all.flatMap((q) => q.fragments);
const insight = frags.filter((f) => f.atomsUsed.length >= 2);
const declared = frags.filter((f) => f.declaredAtoms.length);
const bad = all.filter((q) => !q.roundTrip).map((q) => q.file);

let md = `# חציבת-הזהב (quarry-golden · G4a)\n\n**${all.length}** מודולים · **${frags.length}** שברים · **${insight.length}** שברי-תובנה (≥2 אטומים בשימוש) · **${declared.length}** עם הצהרת-⊕ · הרכבה-חוזרת ביט-לביט: **${bad.length ? '🔴 ' + bad.join(',') : '✓ 9/9'}**\n\n| מודול | שורות | שברים | תובנות | אטומים-בשימוש (ייחודיים) |\n|---|---|---|---|---|\n`;
for (const q of all) md += `| ${q.file} | ${q.lines} | ${q.fragments.length} | ${q.fragments.filter((f) => f.atomsUsed.length >= 2).length} | ${new Set(q.fragments.flatMap((f) => f.atomsUsed)).size} |\n`;
md += `\n## דוגמאות-הצהרה (כותרת ⇒ אטומים-מוצהרים ⇒ בשימוש)\n`;
for (const f of declared.slice(0, 20)) md += `- \`${f.id}\` ${f.header.slice(0, 70)} ⇒ [${f.declaredAtoms.join(' ⊕ ')}] · בשימוש: ${f.atomsUsed.join(', ')}\n`;

const OUT = path.join(GEN, 'golden-fragments.json'), REPORT = path.join(GEN, 'golden-fragments-report.md'), BASE = path.join(GEN, 'quarry-baseline.json');
if (process.argv.includes('--gate')) {
  const base = fs.existsSync(BASE) ? JSON.parse(fs.readFileSync(BASE, 'utf8')) : { fragments: 0, insight: 0 };
  const errs = [];
  if (bad.length) errs.push('round-trip נכשל: ' + bad.join(','));
  const fresh = JSON.stringify({ modules: all.map((q) => ({ file: q.file, lines: q.lines, roundTrip: q.roundTrip })), fragments: frags.map(({ lines, ...f }) => f) });
  if (!fs.existsSync(OUT) || fs.readFileSync(OUT, 'utf8') !== fresh) errs.push('golden-fragments.json ישן/שונה מחציבה-טרייה (הרץ quarry-golden.mjs בלי --gate)');
  if (frags.length < base.fragments) errs.push(`שברים ירדו ${base.fragments}⇒${frags.length}`);
  if (insight.length < base.insight) errs.push(`תובנות ירדו ${base.insight}⇒${insight.length}`);
  if (errs.length) { console.log('🔴 goldquarry: ' + errs.join(' · ')); process.exit(1); }
  console.log(`✓ goldquarry: ${all.length} מודולי-זהב ⇒ ${frags.length} שברים (${insight.length} תובנות) · round-trip ביט-לביט 9/9`); process.exit(0);
}
// הקטלוג = מטא-דאטה בלבד (טווחים, לא טקסט): הבייטים נקראים מהמקור לפי range בעת ההרכבה — המקור הוא ה-fixture, והקטלוג נשאר < 1MB (nobinary)
fs.writeFileSync(OUT, JSON.stringify({ modules: all.map((q) => ({ file: q.file, lines: q.lines, roundTrip: q.roundTrip })), fragments: frags.map(({ lines, ...f }) => f) }, null, 0));
fs.writeFileSync(REPORT, md);
if (process.argv.includes('--write-baseline') || !fs.existsSync(BASE)) fs.writeFileSync(BASE, JSON.stringify({ fragments: frags.length, insight: insight.length }));
process.stdout.write(md.split('\n').slice(0, 16).join('\n') + '\n');

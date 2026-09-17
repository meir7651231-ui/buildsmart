// combine-screens.mjs — הכיוון-ההפוך · §20-ב (הרכבה-עד-שמושג) על-פני מסכים-רשומים.
// המנוע-האחד פירק מסך-מלא ⇒ סקציות-אטומיות רשומות (screens-seed/manifests/*). כאן ההפך:
// צורך-מורכב ⇒ פיצול-מבני לפסוקיות ⇒ אחזור-מסך-לפי-מטרה לכל פסוקית (retrieveScreen) ⇒
// **מיזוג הסקציות של מסכים-שונים למניפסט-אחד** ⇒ gen-screen מרכיב Dart. התוצאה מכילה
// צירוף-סקציות שאף מסך-רשום-יחיד לא מכיל = יכולת-חדשה. אפס-מילון · המבנה נגזר מהאחזור.
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { retrieveScreen } from './retrieve-screen.mjs';

const ROOT = new URL('../../', import.meta.url).pathname;
const MAN = path.join(ROOT, 'screens-seed/manifests');
const definalize = (s) => String(s).replace(/ך/g, 'כ').replace(/ם/g, 'מ').replace(/ן/g, 'נ').replace(/ף/g, 'פ').replace(/ץ/g, 'צ');

// פיצול-מבני לפסוקיות — מחברים-סטרוקטורליים בלבד (ו/וגם/גם/;/פסיק), אפס-לקסיקון-דומייני.
function clauses(text) {
  return text.split(/\s+וגם\s+|\s+גם\s+|[;,\n]|\s+ו(?=[א-ת])/)
    .map((c) => c.trim()).filter((c) => c.length > 1);
}

// אחזור-מסך לכל פסוקית ⇒ שם-מסך-מנצח (score>0 בלבד — אחרת פער-כיסוי, לא נמציא).
function screenPerClause(text) {
  const seen = new Map(); // screenName ⇒ {clause, score}
  const misses = [];
  for (const cl of clauses(text)) {
    const [best] = retrieveScreen(cl, 1);
    if (!best || best.score <= 0) { misses.push(cl); continue; }
    const prev = seen.get(best.name);
    if (!prev || best.score > prev.score) seen.set(best.name, { clause: cl, score: best.score });
  }
  return { screens: [...seen.entries()].map(([name, v]) => ({ name, ...v })), misses };
}

function loadManifest(screen) {
  // screen שם-קצר (budget_screen) ⇒ מניפסט screens__<screen>.manifest.json
  const f = path.join(MAN, `screens__${screen}.manifest.json`);
  if (fs.existsSync(f)) return JSON.parse(fs.readFileSync(f, 'utf8'));
  // ייתכן שם-מלא (manager_dashboard_screen) בקובץ אחר — סרוק
  for (const g of fs.readdirSync(MAN)) {
    const m = JSON.parse(fs.readFileSync(path.join(MAN, g), 'utf8'));
    if (m.screen === screen) return m;
  }
  return null;
}

export function combine(text, outName = 'gen_combined') {
  const { screens, misses } = screenPerClause(text);
  if (screens.length === 0) return { ok: false, reason: 'אפס-כיסוי: אף פסוקית לא נמצאה בקורפוס', misses };

  // מיזוג: איחוד content · שרשור sections (ids ייחודיים כבר בין מסכים-שונים; ns ליתר-ביטחון).
  const contentSet = new Set();
  const sections = [];
  const sources = [];
  for (const s of screens) {
    const m = loadManifest(s.name);
    if (!m) { misses.push(`(מניפסט חסר: ${s.name})`); continue; }
    for (const c of m.content || []) contentSet.add(c);
    for (const sec of m.sections || []) {
      const id = sections.some((x) => x.id === sec.id) ? `${s.name}__${sec.id}` : sec.id;
      sections.push({ ...sec, id });
    }
    sources.push({ screen: s.name, clause: s.clause, score: s.score, sections: (m.sections || []).length });
  }
  if (sections.length === 0) return { ok: false, reason: 'אפס-סקציות אחרי מיזוג', misses };

  const merged = {
    generated: true,
    src: `combine:${text}`,
    screen: outName,
    content: [...contentSet],
    sections,
  };
  const outManifest = path.join(ROOT, 'screens-seed/manifests', `screens__${outName}.manifest.json`);
  fs.writeFileSync(outManifest, JSON.stringify(merged, null, 1));
  return { ok: true, outManifest, sources, misses, sectionCount: sections.length, screenCount: screens.length };
}

if (import.meta.url === 'file://' + process.argv[1]) {
  const text = process.argv.slice(2).join(' ');
  if (!text) { console.error('שימוש: node combine-screens.mjs "<צורך-מורכב>"'); process.exit(1); }
  const r = combine(definalize(text) === text ? text : text); // שמור-מקור
  if (!r.ok) { console.error('🔴 ' + r.reason + (r.misses?.length ? ' · פספוסים: ' + r.misses.join(' | ') : '')); process.exit(2); }
  console.log(`🧩 מיזוג ${r.screenCount} מסכים ⇒ ${r.sectionCount} סקציות:`);
  for (const s of r.sources) console.log(`   ← ${s.screen}  (פסוקית "${s.clause}" · ${s.score}) · ${s.sections} סקציות`);
  if (r.misses.length) console.log('   ⚠ פסוקיות-ללא-כיסוי (לא-הומצאו): ' + r.misses.join(' | '));
  console.log('   מניפסט: ' + path.relative(ROOT, r.outManifest));
  // הרכבה בפועל
  const out = execFileSync('node', [path.join(ROOT, 'machtzev/assemble/gen-screen.mjs'), r.outManifest], { encoding: 'utf8' });
  process.stdout.write(out);
}

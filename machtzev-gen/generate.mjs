#!/usr/bin/env node
// generate.mjs — הכניסה-האחת של המחולל (§22): משפט-עברי-חופשי ⇒ אפליקציית-Dart מתקמפלת.
// **בורר-מסלול מבני** (אפס-מילון-דומייני), לפי צורת-הכוונה שבמשפט:
//   1. יש סעיף-ניטור/התראה ("כש X חורג מ-Y")     ⇒ capability.emitApp  → אפליקציה-רצה (main() עצמאי).
//   2. אחרת, פסוקיות שמתאימות לקורפוס-המסכים      ⇒ combine-screens     → הרכבת-מסך (מאומת-מול-המדף).
//   3. אחרת (אין כיסוי)                            ⇒ דיווח-פער כן (§20-ג), לא מזייפים.
// כל מסלול נגזר מהמבנה+הקורפוס. אין LLM, אין מילון. הפלט מאומת ע"י שער-הקומפילציה (genesis-compile).
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { detectAllClauses, emitApp } from './capability.mjs';
import { combine } from './combine-screens.mjs';
import { retrieveScreen } from './retrieve-screen.mjs';
import * as R from '../root.mjs';

const ROOT = R.ROOT;
const GEN = path.join(ROOT, 'machtzev/assemble/gen-screen.mjs');

// פיצול-מבני לפסוקיות (מחברים בלבד) — לבדיקת-כיסוי-קורפוס.
const clauses = (t) => t.split(/\s+וגם\s+|\s+גם\s+|[;,\n]|\s+ו(?=[א-ת])/).map((c) => c.trim()).filter((c) => c.length > 1);
const anyCovered = (t) => clauses(t).some((c) => { const [b] = retrieveScreen(c, 1); return b && b.score > 0; });

export function generate(text, name = 'gen_out') {
  // מסלול-1: כוונת-ניטור/התראה מבנית ⇒ אפליקציה-רצה
  if (detectAllClauses(text).length) {
    const cls = name.replace(/(^|[_-])([a-z])/g, (_, __, c) => c.toUpperCase()) + 'Screen';
    const code = emitApp(text, cls);
    const file = path.join(R.outDir(), `${name}.dart`);
    fs.writeFileSync(file, code);
    return { ok: true, path: 'capability', runnable: true, file: path.relative(ROOT, file), units: detectAllClauses(text).length };
  }
  // מסלול-2: כיסוי-קורפוס ⇒ הרכבת-מסך מהכיוון-ההפוך
  if (anyCovered(text)) {
    const r = combine(text, name);
    if (r.ok) {
      const out = execFileSync('node', [GEN, r.outManifest], { encoding: 'utf8' });
      const gfile = out.match(/הורכב: (\S+)/)?.[1] || `new/dart-screens-bs/${name}.g.dart`;
      return { ok: true, path: 'combine', runnable: false, file: gfile, screens: r.sources, sections: r.sectionCount, misses: r.misses };
    }
    return { ok: false, path: 'combine', reason: r.reason, misses: r.misses };
  }
  // מסלול-3: אין כיסוי ⇒ דיווח-פער כן (לא מזייפים)
  return { ok: false, path: 'none', reason: 'אין כיסוי-קורפוס ואין כוונת-ניטור מבנית', misses: clauses(text) };
}

if (import.meta.url === 'file://' + process.argv[1]) {
  const args = process.argv.slice(2);
  const name = args[0] === '-n' ? args.splice(0, 2)[1] : 'gen_out';
  const text = args.join(' ');
  if (!text) { console.error('שימוש: node generate.mjs [-n <name>] "<משפט-עברי-חופשי>"'); process.exit(1); }
  const r = generate(text, name);
  if (!r.ok) { console.error(`🔴 [${r.path}] ${r.reason}` + (r.misses?.length ? ' · פסוקיות-ללא-כיסוי: ' + r.misses.join(' | ') : '')); process.exit(2); }
  console.log(`✅ מסלול=${r.path} · ${r.runnable ? 'אפליקציה-רצה (main)' : 'מסך-מורכב (Composed)'} · ${r.file}`);
  if (r.screens) for (const s of r.screens) console.log(`   ← ${s.screen} (פסוקית "${s.clause}" · ${s.score})`);
  if (r.misses?.length) console.log('   ⚠ פסוקיות-ללא-כיסוי (לא-הומצאו): ' + r.misses.join(' | '));
}

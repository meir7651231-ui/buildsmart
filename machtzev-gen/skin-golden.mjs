#!/usr/bin/env node
// 🎨 skin-golden — בית-הספר (SchoolOS, 9 מודולי-הזהב) בעור-forge (GENMAX·G12d): מרכיב כל מודול מהקטלוג (assemble compose+declared ≡ הזהב ביט-זהה, רתמת-G4),
//   מפנה ייבואי-אחים לעותקים-המעוררים, ומריץ skinPass (KpiTile·DsNavTile·StatHero·BareStat-ב-Wrap ⇒ אטומי-forge עם fields) ⇒ new/dart-gen-bs/gen_schoolos_<stem>_forge.dart.
//   הזהב עצמו לא נגע (חוק-7: טעינה-לצד, הפיך). העור מוצהר ב-skin-golden.json (הצבה של הבעלים) ומאומת מבנית ב-resolveSkin.
//   --gate [--write]: 9 הפלטים ≡ מחולל-טרי.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as R from '../root.mjs';
import { assemble, PARTICLE_IDS, TAG } from './render-module.mjs';
import { skinPass, MODULES } from './retarget.mjs';
import { resolveSkin } from './app-from-sentences.mjs';

const ROOT = R.ROOT, GEN = path.join(ROOT, 'machtzev/generator'), DIR = path.join(ROOT, 'new/dart-gen-bs');
const SPEC = path.join(GEN, 'skin-golden.json');
const outName = (m) => `gen_${m.replace(/\.dart$/, '')}_forge.dart`;   // schoolos.dart ⇒ gen_schoolos_forge.dart · schoolos_students.dart ⇒ gen_schoolos_students_forge.dart
export function skinGolden(spec) {
  const skins = resolveSkin(spec.skin);
  if (!skins) throw new Error('skin-golden: skin ריק');
  const outs = [];
  for (const module of MODULES) {
    const k = module.replace(/\.dart$/, ''), tag = TAG[k];
    const ids = PARTICLE_IDS.filter((id) => (tag && tag !== 'inv' ? id.startsWith(tag + '.') : !id.includes('.')));
    let code = assemble({ module, particles: ids, mode: 'compose', declared: true }).code;
    // ייבואי-אחים ⇒ העותקים-המעוררים (הרכזת מייבאת את 8 המודולים)
    for (const m of MODULES) if (m !== module) code = code.replace(new RegExp(`import '${m.replace('.', '\\.')}'`, 'g'), `import '${outName(m)}'`);
    const { code: skinned, stats } = skinPass(code, skins);
    const header = [`// 🎨 ${module} בעור-forge (GENMAX·G12d) — מחולל דטרמיניסטי: skin-golden.mjs · הזהב לא נגע (טעינה-לצד, חוק-7) · עור: ${Object.values(skins).map((x) => `${x.role}=${x.cls}`).join(' · ')}`,
      `//   החלפות: ${Object.entries(stats).map(([r, n]) => `${r}×${n}`).join(' · ') || '—'} · BareStat ב-Row נשאר DS (רצועת-4) · צבעי-מצב-DS לא מועברים · חיפוש/טבלאות/פילטרים = DS (אטומי-forge של קלט הם ציור, לא שדה)`];
    outs.push({ module, file: outName(module), code: header.join('\n') + '\n' + skinned, stats });
  }
  return { outs, skins };
}
const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  const spec = JSON.parse(fs.readFileSync(SPEC, 'utf8'));
  const { outs } = skinGolden(spec);
  const gate = process.argv.includes('--gate'), write = !gate || process.argv.includes('--write');
  const errs = [];
  for (const o of outs) { const f = path.join(DIR, o.file); if (write) fs.writeFileSync(f, o.code); else if (!fs.existsSync(f) || fs.readFileSync(f, 'utf8') !== o.code) errs.push(o.file); }
  if (gate) { if (errs.length) { console.log('🔴 skingolden: ≠ טרי: ' + errs.join(' · ')); process.exit(1); } console.log(`✓ skingolden: ${outs.length}/9 מודולי-SchoolOS בעור-forge ≡ מחולל-טרי`); process.exit(0); }
  console.log(`✓ skin-golden: ${outs.map((o) => `${o.file} (${Object.entries(o.stats).map(([r, n]) => `${r}×${n}`).join(' ')})`).join(' · ')}`);
}

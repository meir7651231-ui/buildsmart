#!/usr/bin/env node
// 🔢 enum-values — ערכי-הטיפוסים-המנויים כאטום-דאטה חצוב (GENMAX · G6a · §19-ד): `export type X = 'a' | 'b'` מ-maor-system/src/types/domain.ts
//   הסכמה (schema-fields) מצביעה על שמות (EnrollmentStatus…) — הערכים והסדר-המוצהר נחצבים מכאן; אין המצאת-מצבים (§20-ג).
//   פלט: enum-values.data.json · --gate: כשקיים maor-system — חציבה-טרייה ≡ הקובץ; אחרת מדולג.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as R from '../root.mjs';

const ROOT = R.ROOT, OUT = path.join(ROOT, 'machtzev/generator/enum-values.data.json');
const MAOR = process.env.MAOR_DOMAIN || path.resolve(ROOT, '../maor-system/src/types/domain.ts');
export function quarry() {
  const src = fs.readFileSync(MAOR, 'utf8');
  const enums = {};
  for (const m of src.matchAll(/^export type (\w+) =\s*\|?\s*((?:'[^']*'\s*\|?\s*)+);/gm)) { const vals = [...m[2].matchAll(/'([^']*)'/g)].map((x) => x[1]); if (vals.length >= 2) enums[m[1]] = vals; }
  return { source: 'maor-system/src/types/domain.ts (export type X = union of string literals)', enums };
}
const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  if (process.argv.includes('--gate')) {
    if (!fs.existsSync(MAOR)) { console.log(`⚪ enumvalues: אין maor-system (${MAOR}) — הקובץ המחויב הוא האמת`); process.exit(0); }
    const fresh = JSON.stringify(quarry(), null, 1);
    if (!fs.existsSync(OUT) || fs.readFileSync(OUT, 'utf8') !== fresh) { console.log('🔴 enumvalues: enum-values.data.json ≠ חציבה-טרייה מ-domain.ts (הרץ enum-values.mjs)'); process.exit(1); }
    console.log(`✓ enumvalues: ${Object.keys(JSON.parse(fresh).enums).length} טיפוסים-מנויים חצובים ≡ domain.ts`); process.exit(0);
  }
  const d = quarry(); fs.writeFileSync(OUT, JSON.stringify(d, null, 1));
  console.log(`✓ ${Object.keys(d.enums).length} טיפוסים-מנויים ⇒ enum-values.data.json · ${Object.entries(d.enums).map(([k, v]) => k + '(' + v.length + ')').join(' ')}`);
}

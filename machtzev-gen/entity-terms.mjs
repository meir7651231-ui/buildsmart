#!/usr/bin/env node
// 🔤 entity-terms — גשר-המונחים ישות⇔עברית כ**אטום-דאטה חצוב** (GENMAX · G5f · §19-ד: אוצר-מילים = דאטה, לא מילון-במנוע).
//   מקור-האמת: `maor-system/src/types/features.ts` TERM_DEFS (45 מונחי White-label · מפתחות `entity.*` עם fallback בעברית)
//   + מילים-נרדפות מחבילות-הורטיקל שכבר על המדף (`'entity.x': 'לקוח'` באטומי-דאטה ב-new/). כל שורה: key · entity (שם-סכמה אם קיים) · forms.
//   פלט: entity-terms.data.json (מחויב) · --gate: כשקיים maor-system — חציבה-טרייה ≡ הקובץ; אחרת מדולג (הקובץ המחויב הוא האמת).
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as R from '../root.mjs';
import { FIELDS } from '../../new/atoms/schema-fields.mjs';

const ROOT = R.ROOT, OUT = path.join(ROOT, 'machtzev/generator/entity-terms.data.json');
const MAOR = process.env.MAOR || path.resolve(ROOT, '../maor-system/src/types/features.ts');
const ENTITIES = new Set(FIELDS.map((f) => f.e));
const pascal = (s) => s.charAt(0).toUpperCase() + s.slice(1);
// מפתח ⇒ שם-סכמה: entity.shopItem⇒ShopItem · entity.volunteers⇒Volunteer (רבים) · familyOf⇒Family (סמיכות) · אין ⇒ null (מדווח, לא מומצא)
const resolveEntity = (suffix) => { const c = [pascal(suffix), pascal(suffix.replace(/s$/, '')), pascal(suffix.replace(/Of$/, ''))]; return c.find((x) => ENTITIES.has(x)) || null; };
export function quarry() {
  const src = fs.readFileSync(MAOR, 'utf8');
  const terms = [...src.matchAll(/\{\s*key:\s*'entity\.(\w+)',\s*label:\s*'([^']*)',\s*fallback:\s*'([^']*)'\s*\}/g)].map((m) => ({ key: 'entity.' + m[1], entity: resolveEntity(m[1]), forms: [m[3]], label: m[2] }));
  // נרדפות מהמדף (חבילות-ורטיקל): כל 'entity.x': 'עברית' באטומי-דאטה
  const syn = {};
  for (const d of ['new/dart-data-maor', 'new/dart-data', 'new/dart-data-bs', 'new/atoms']) { const dd = path.join(ROOT, d); if (!fs.existsSync(dd)) continue; for (const f of fs.readdirSync(dd)) { if (!/\.(dart|mjs)$/.test(f)) continue; for (const m of fs.readFileSync(path.join(dd, f), 'utf8').matchAll(/'entity\.(\w+)':\s*'([^']+)'/g)) { const v = m[2].trim(); if (v) (syn['entity.' + m[1]] ??= new Set()).add(v); } } }
  for (const t of terms) for (const v of syn[t.key] || []) if (!t.forms.includes(v)) t.forms.push(v);
  return { source: 'maor-system/src/types/features.ts TERM_DEFS (entity.*) + נרדפות-ורטיקל מהמדף', terms };
}
const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  if (process.argv.includes('--gate')) {
    if (!fs.existsSync(MAOR)) { console.log(`⚪ entityterms: אין maor-system (${MAOR}) — הקובץ המחויב הוא האמת`); process.exit(0); }
    const fresh = JSON.stringify(quarry(), null, 1);
    if (!fs.existsSync(OUT) || fs.readFileSync(OUT, 'utf8') !== fresh) { console.log('🔴 entityterms: entity-terms.data.json ≠ חציבה-טרייה מ-TERM_DEFS (הרץ entity-terms.mjs)'); process.exit(1); }
    const d = JSON.parse(fresh); console.log(`✓ entityterms: ${d.terms.length} מונחי-ישות חצובים (${d.terms.filter((t) => t.entity).length} פתורים לסכמה · ${d.terms.filter((t) => !t.entity).length} בלי ישות-סכמה) ≡ TERM_DEFS`); process.exit(0);
  }
  const d = quarry(); fs.writeFileSync(OUT, JSON.stringify(d, null, 1));
  console.log(`✓ ${d.terms.length} מונחי-ישות ⇒ entity-terms.data.json · פתורים: ${d.terms.filter((t) => t.entity).map((t) => `${t.key.replace('entity.', '')}⇒${t.entity}`).join(' ')} · בלי-ישות: ${d.terms.filter((t) => !t.entity).map((t) => t.key.replace('entity.', '')).join(' ')}`);
}

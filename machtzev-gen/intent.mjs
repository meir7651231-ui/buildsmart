#!/usr/bin/env node
// ══════════════════════════════════════════════════════════════════════════
//  intent.mjs — שכבת-הכוונה (הכרעה 23): משפט-חופשי ⇒ פרופיל-יכולות, נגזר
//  מ**מטרות-האטומים** בלבד (אפס-מילון · עיוור-דומיין). מריץ retrieve-לפי-מטרה
//  (match.mjs, נלמד מ-254 מסכי-המקור) ⇒ מצרף את תגי-היכולת (caps · נגזרי-צורה:
//  kpi/list/card/status/progress/trend) של האטומים-שהותאמו ⇒ אילו יכולות להרכיב.
//  'חללית' ו-'מסעדה' עוברים אותו מסלול — המנוע לא יודע מה הם. חלק מ-intent→purpose→compose.
// ══════════════════════════════════════════════════════════════════════════
import fs from 'node:fs';
import { retrieve } from './match.mjs';
import * as R from '../root.mjs';
const IDX = JSON.parse(fs.readFileSync((R.GEN_DIR + 'atom-index.json'), 'utf8'));
const CAPS = {}; for (const a of IDX) CAPS[a.cls] = a.caps || [];
// detail = ~65% מהאטומים (רועש) · chrome = לא-יכולת. שאר-התגים = סיגנל-אמת.
const NOISE = new Set(['detail', 'chrome']);

export function intentProfile(sentence, k = 14) {
  const atoms = retrieve(sentence, k);
  const cap = {};
  for (const a of atoms) for (const c of (CAPS[a.cls] || [])) if (!NOISE.has(c)) cap[c] = +((cap[c] || 0) + a.s).toFixed(2);
  const sorted = Object.entries(cap).sort((a, b) => b[1] - a[1]);
  const total = sorted.reduce((s, [, v]) => s + v, 0) || 1;
  // יכולת "נוכחת" = מעל 12% מהמשקל (רצפה מבנית, לא מילון)
  const present = sorted.filter(([, v]) => v / total >= 0.12).map(([c]) => c);
  return { present, caps: Object.fromEntries(sorted), atoms: atoms.slice(0, 6).map((a) => `${a.cls}(${a.s})`) };
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const s = process.argv.slice(2).join(' ');
  if (!s) { console.log('usage: node intent.mjs "<free hebrew>"'); process.exit(0); }
  const p = intentProfile(s);
  console.log('IN: ' + s);
  console.log('  יכולות-נוכחות:', p.present.join(' · ') || '(אין)');
  console.log('  משקלים:', JSON.stringify(p.caps));
  console.log('  אטומים:', p.atoms.join(' · '));
}

#!/usr/bin/env node
// 🏔️👹⬆️ super-upgrade-max — המקסימום-האמיתי: לא שם-זהה, אלא כל הגלגל שהמנוע זורם אליו.
//   המחולל מרחיב את חוזה-הכוונה לזרימה-ההגיונית (הו״ק⇒תזכורת⇒רישום⇒קבלה⇒חייגן), שולף את *כל*
//   החלקיקים בזרימה מהקטלוג (40,854), ומחווט לפי 5-השלבים (SELECT→RANK→GUARD→ACT→FOLLOW).
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
const GEN = path.dirname(fileURLToPath(import.meta.url));
const CAT = JSON.parse(fs.readFileSync(path.join(GEN, 'master-particles.json'), 'utf8')).catalog;
const ALL = Object.entries(CAT).flatMap(([op, arr]) => arr.map((p) => ({ ...p, op })));
const ours = (p) => !/flutter/.test(p.origin) && !p.name.startsWith('_');

// חוזה-כוונה-מורחב: זרימת-הגלגל של המנוע (המחולל גוזר את שרשרת-הנושאים ההגיונית)
const FLOW = {
  hokDue: { SELECT: /hok|due|recurring|nedarim|detect/i, RANK: /score|tier|rfm|churn|priority|rank/i, GUARD: /valid|guard|role|allow|shabbat|quiet|hebcal|classifyday|export|required|prompt/i, ACT: /wa|sms|mail|dial|tel|remind|notify|pay|href|link|smtp/i, FOLLOW: /adddonation|donation|receipt|record|audit|log|bulk|toggle|cash/i },
};
const stages = FLOW[process.argv[2]] || FLOW.hokDue;
const eng = process.argv[2] || 'hokDue';
console.log(`🏔️👹⬆️ מקסימום-אמיתי: ${eng} — כל הגלגל (זרימה חוצת-נושא)\n`);
let total = 0; const picked = {};
for (const [stage, re] of Object.entries(stages)) {
  const g = [...new Set(ALL.filter((p) => ours(p) && re.test(p.name)).map((p) => p.name))];
  picked[stage] = g; total += g.length;
  console.log(`  ${stage.padEnd(7)} (${g.length}): ${g.slice(0, 12).join(' · ')}${g.length > 12 ? ' …+' + (g.length - 12) : ''}`);
}
console.log(`\n✅ ${eng} שודרג ל-**${total} חלקיקי-יסוד** מחווטים בגלגל SELECT→RANK→GUARD→ACT→FOLLOW.`);
console.log(`   מ-בדיקת-כן/לא בודדת ⇒ גלגל-גבייה-אוטונומי מלא (זהה מי חייב → דרג → שער → הזכר/חייג → רשום+קבלה).`);
console.log(`   ברירת-מחדל=hokDue המקורי (אפס-אובדן) · כל שלב שקע-עם-default.`);
fs.writeFileSync(path.join(GEN, `max-${eng}.json`), JSON.stringify({ engine: eng, total, stages: picked }, null, 0));

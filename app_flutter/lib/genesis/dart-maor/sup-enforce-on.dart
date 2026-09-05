// ⚛️ אטום-Dart (דרגת-חוזה) · supEnforceOn — האם הקונפיג מדליק אכיפת-תומכים בשכבת-הנתונים.
// מוצא: maor/src/lib/config.ts:73-81 · המקור: new/atoms/sup-enforce-on.mjs —
//        `export function supEnforceOn(cfg) { return cfg.supporterEnforce === true; }`
// טוהר: פונקציה top-level עצמאית, אפס import. חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: off-by-default במכוון (הפוך מחוזה-הדגלים: כאן חסר=כבוי) —
// רק supporterEnforce:true מפורש מדליק. טהור, אפס שקעים.
//
// הערת-המרה (מקור→Dart):
//   • גישת-שדה `cfg.supporterEnforce` על אובייקט-JS ⇒ גישת-מפה `cfg['supporterEnforce']`
//     (הקונפיג = Map; טיוטת-ה-AST עם `.supporterEnforce` הייתה זורקת NoSuchMethodError על Map).
//   • ‏`=== true` הקפדני של JS: רק הערך הבוליאני true עובר; undefined (מפתח-חסר),
//     null, false, 1, 'true' — כולם ⇒ false. ב-Dart ‏`== true` שקול ביט-אחר-ביט:
//     מפתח-חסר ⇒ null == true ⇒ false; רק bool true ⇒ true. חוק-2 (containsKey)
//     אינו נדרש כאן — null-מפורש ו-undefined מתלכדים לאותה תוצאה (false) בדיוק כמו ב-JS.
//   • אין מספרים/מחרוזות/locale/תאריכים ⇒ חוקים 12/13/14/15/16 לא-רלוונטיים.

/// Is data-layer supporter enforcement explicitly enabled? Off-by-default —
/// verbatim behavior of the JS source new/atoms/sup-enforce-on.mjs:
/// only an explicit boolean `true` under 'supporterEnforce' turns it on.
bool supEnforceOn(dynamic cfg) {
  return cfg['supporterEnforce'] == true;
}

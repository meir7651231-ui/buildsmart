// ⚛️ אטום-Dart (דרגת-חוזה) · commercialOff — ערך-מערכת קבוע (צילום-ערך).
// מוצא: maor/src/lib/verticalPacks.ts:43-53 · המקור: new/atoms/commercial-off.mjs —
//        `export const COMMERCIAL_OFF = { 'core.taxreceipt': false, ... };`
// טוהר: ערך top-level עצמאי, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: קבוצת-דגלים שמכובה כשמעבירים ארגון לורטיקל מסחרי (כל הערכים false).
// קלט:  אין. פלט: מפה String→bool.
//
// הערת-המרה (מקור→Dart): ה-JS הוא אובייקט-קבוע; ב-Dart מפה-literal קבועה `const`
// שומרת על סדר-ההכנסה (כמו JS object) ⇒ ה-JSON המסודר זהה-ביט לצילום שבבדיקה.
// אין locale/פורמט/getMonth/truthiness/מוטביליות מעורבים — קבוע טהור, ללא שקעים.

/// Commercial-off system flags — every key false. Verbatim value of the JS source
/// new/atoms/commercial-off.mjs (`COMMERCIAL_OFF`). Insertion order preserved so the
/// serialised map is bit-identical to the JS snapshot.
const Map<String, bool> commercialOff = {
  'core.taxreceipt': false,
  'families.cred': false,
  'home.goldbook': false,
  'home.impactwall': false,
  'home.community': false,
  'home.credmetrics': false,
  'shell.privacy': false,
  'supporters.hist': false,
};

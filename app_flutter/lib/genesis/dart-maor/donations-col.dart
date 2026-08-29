// ⚛️ אטום-Dart (דרגת-חוזה) · donationsCol — ערך-מערכת קבוע (צילום-ערך).
// מוצא: maor/src/lib/cloud-diff.ts:64 (מסלול-B — אוסף-התרומות-הנפרד) · המקור:
//        new/atoms/donations-col.mjs — `export const DONATIONS_COL = 'donations';`
// טוהר: ערך top-level עצמאי, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: שם-האוסף הקבוע 'donations' (מקטע-נתיב יחיד ב-Firestore). קלט: אין. פלט: מחרוזת.
//
// הערת-המרה (מקור→Dart): האטום המיוצא-והנבדק הוא קבוע-מחרוזת בלבד. טיוטת-המנוע
// (dart-from-maor/donations-col.dart.draft) הפיקה `var DONATIONS_COL = 'donations';` —
// נכונה בערך אך `var` (מוטבילי, PascalCase). לפי כללי-הבית: `const String` שמו-camelCase.
// אין locale/פורמט/getMonth/truthiness/מוטביליות מעורבים (DART-PORTING-RULES 1-11 לא רלוונטיים) —
// קבוע-מחרוזת-לטיני טהור, ללא שקעים. התנהגות זהה-לחלוטין למקור.

/// Separate-donations-collection name constant. Verbatim value of the JS source
/// new/atoms/donations-col.mjs (`DONATIONS_COL`) — the 9-char string 'donations'.
const String donationsCol = 'donations';

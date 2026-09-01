// ⚛️ אטום-Dart (דרגת-חוזה) · defaultLockZones — ערך-מערכת קבוע (צילום-ערך).
// מוצא: maor/src/lib/lock.ts:22 · המקור: new/atoms/default-lock-zones.mjs —
//        `export const DEFAULT_LOCK_ZONES = ['wizard', 'settings'];`
// טוהר: ערך top-level עצמאי, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: ברירת-מחדל להגנת-המנהל — האזורים הנעולים: האשף וההגדרות.
// קלט:  אין. פלט: רשימת String בסדר-מקור.
//
// הערת-המרה (מקור→Dart): ה-JS הוא מערך-קבוע של שתי מחרוזות; ב-Dart רשימה-literal
// קבועה `const` שומרת על הסדר (כמו מערך-JS) ⇒ ביט-זהה לצילום שבבדיקה.
// אין locale/פורמט/getMonth/truthiness/מוטביליות מעורבים — קבוע טהור, ללא שקעים.

/// Manager-protection default lock zones — the wizard and settings. Verbatim value
/// of the JS source new/atoms/default-lock-zones.mjs (`DEFAULT_LOCK_ZONES`). Element
/// order preserved so the list is bit-identical to the JS snapshot.
const List<String> defaultLockZones = ['wizard', 'settings'];

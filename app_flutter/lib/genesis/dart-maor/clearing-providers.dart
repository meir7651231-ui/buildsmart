// ⚛️ אטום-Dart (דרגת-צילום-ערך) · CLEARING_PROVIDERS — ספקי-הסליקה של המערכת.
// מוצא: new/atoms/clearing-providers.mjs (export const CLEARING_PROVIDERS) ·
//        חוזה: new/atoms/clearing-providers.contract.md · מקור-על:
//        maor/src/lib/nedarimSync.ts:113-118. חוק-4 — ערך זהה-ביט למקור-ה-JS
//        (המקור קדוש). זהו אטום-קבוע (צילום-ערך), לא פונקציה.
//
// תפקיד: שני ספקי-הסליקה הקבועים, בסדר-המקור בדיוק: 'נדרים' ואז 'סולה'.
//        פלט: List<String> קפוא. (חסר-ספק בזרימות ⇒ ברירת-מחדל 'נדרים' — הכרעה
//        שחיה בקופסת-החיווט, לא באטום; האטום נושא ערך בלבד, חוק-5.)
//
// הערות-המרה (מקור→Dart):
//  • `export const CLEARING_PROVIDERS = ['נדרים', 'סולה']` →
//    `const List<String> clearingProviders = ['נדרים', 'סולה']`. שתי מחרוזות
//    עברית, בסדר-המקור בדיוק, ללא locale/פורמט/getMonth/truthiness/מוטביליות.
//  • הערת-הבאג שבזנב המקור היא הקשר-שימוש בלבד (חוק-5: אטום טהור-מהקשר) ⇒
//    לא מיוצאת ואינה בחוזה/בבדיקה, הושמטה מגוף-האטום.
//  • מוטביליות: `const` (בלתי-משתנה מוחלט).

/// The two fixed clearing providers, in source order (`'נדרים'`, `'סולה'`).
/// Value-snapshot port of new/atoms/clearing-providers.mjs
/// (`CLEARING_PROVIDERS`). Verbatim behaviour of the JS source.
const List<String> clearingProviders = [
  'נדרים',
  'סולה',
];

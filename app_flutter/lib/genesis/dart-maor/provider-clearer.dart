// ⚛️ אטום-Dart (דרגת-חוזה) · providerClearer — תווית-סליקה לפי ספק-העסקה.
// מוצא: maor/src/lib/nedarimSync.ts:119-121 · המקור: new/atoms/provider-clearer.mjs —
//        `return /sola/i.test(provider || '') ? 'סולה' : 'נדרים';`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: ספק שמכיל 'sola' (case-insensitive, כל מיקום) ⇒ 'סולה'; אחרת ⇒ 'נדרים'.
//        (באג-הסולה 23.8: הבחנת-ספק לפי תבנית ולא לפי שוויון-מדויק.)
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//   • truthiness (כלל 7): JS `provider || ''` מחליף כל ערך-שקרי (null/undefined/'')
//     ב-''. הערך-השקרי היחיד שרלוונטי כאן הוא null/undefined (''||'' עדיין '') ⇒
//     `provider ?? ''` מכסה זאת ביט-זהה: null⇒'', מחרוזת-ריקה⇒'' (אין match), כל
//     מחרוזת-אחרת נשמרת.
//   • `/sola/i.test(x)` = חיפוש-תת-מחרוזת case-insensitive ⇒
//     `RegExp('sola', caseSensitive: false).hasMatch(x)` (hasMatch = חיפוש כל-מיקום,
//     מקביל ל-.test של JS; אין anchor).
//   • אין locale/פורמט/getMonth/מודולו/substring/מיון — רק תבנית ובורר-שלישוני.

/// Returns the clearing-provider label for a transaction provider string.
/// A provider containing 'sola' (case-insensitive, anywhere) yields 'סולה';
/// everything else — including null and the empty string — yields 'נדרים'.
/// Verbatim behaviour of the JS source `providerClearer`.
String providerClearer(String? provider, {required String Function(String) term}) {
  return RegExp('sola', caseSensitive: false).hasMatch(provider ?? '')
      ? term('svlh')
      : term('ndrym');
}

// ⚛️ אטום-Dart (דרגת-חוזה) · monthHeOf — שם-Intl של חודש עברי ⇒ תווית עברית
// מוצא: maor/src/lib/hebdate.ts (monthHeOf; חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/month-he-of.mjs —
//        `MONTHS.find((m) => m[0] === en)?.[1] ?? ''`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: שם-Intl אנגלי של חודש עברי (לוח 'hebrew') ⇒ תווית עברית לתצוגה;
//        לא-מוכר ⇒ '' (מחרוזת ריקה). המראה של month-en-of (אותה טבלת 14 חודשים,
//        כיוון הפוך). אדר א׳/ב׳ בגרש ׳ (U+05F3).
// קלט:  en — שם-Intl (מחרוזת; ההתאמה מדויקת-תו ורגישת-רישיות — "av" ⇒ '').
// פלט:  תווית עברית, String; לא-מוכר ⇒ ''.
//
// הערת-המרה (מקור→Dart): ה-JS משתמש ב-`find(...)?.[1] ?? ''` — אי-מציאה ⇒ undefined
// ⇒ ''. ‏`firstWhere` של Dart **זורק** על אי-מציאה (זה הבאג בטיוטת-ה-AST!) —
// לכן לולאה מפורשת עם נפילה ל-''. ‏`===` על מחרוזות ⇒ `==` של Dart (השוואת-ערך,
// שקולה בדיוק; קלט לא-מחרוזתי לעולם לא ישווה ל-String ⇒ '' — כמו ב-JS).
// הטבלה הוטמעה-פנימה ביט-זהה (נתון של האטום, לא ייבוא — חוק-1).


/// Intl English Hebrew-month name ⇒ Hebrew display label; unknown ⇒ ''.
/// Exact, case-sensitive match. Verbatim behaviour of the JS source
/// new/atoms/month-he-of.mjs.
String monthHeOf(dynamic en, List<dynamic> MONTHS) {
  for (final m in MONTHS) {
    if (m[0] == en) return m[1];
  }
  return '';
}

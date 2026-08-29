// ⚛️ אטום-Dart (דרגת-חוזה) · monthEnOf — תווית-עברית של חודש עברי ⇒ שם-Intl
// מוצא: maor/src/lib/hebdate.ts (monthEnOf); המקור: new/atoms/month-en-of.mjs —
//        `MONTHS.find((m) => m[1] === he)?.[0] ?? null`
//        טבלת MONTHS הוטמעה-פנימה ביט-זהה (נתון של האטום, לא ייבוא — חוק-1).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: תווית עברית של חודש עברי (לוח 'hebrew', 14 חודשים כולל אדר א׳/ב׳
//        בגרש עברי ׳ U+05F3) ⇒ שם ה-Intl האנגלי; לא מוכר ⇒ null.
// קלט:  he — התווית העברית (ב-JS כל ערך; השוואה `===` מול String ⇒ dynamic כאן).
// פלט:  שם-Intl (String) או null.
//
// הערת-המרה (מקור→Dart): ה-JS משווה `m[1] === he` — זהות-מחרוזת מדויקת-תו
// ("אדר א'" בגרש-ASCII ⇒ null); ב-Dart `==` על String הוא השוואת-ערך ⇒ שקול.
// `find` של JS מחזיר undefined באין-התאמה ⇒ כאן לולאה עם null (לא firstWhere
// שזורק — סטיית-הטיוטה תוקנה). אין locale/לוח-חי/truthiness — טבלה סטטית בלבד.

/// Hebrew month label -> Intl English month name (calendar 'hebrew');
/// unknown label -> null. Exact-character match (Hebrew geresh U+05F3 only).
/// Verbatim behaviour of the JS source new/atoms/month-en-of.mjs.
String? monthEnOf(dynamic he, {required List<dynamic> months}) {
  for (final m in months) {
    if (m[1] == he) return m[0];
  }
  return null;
}

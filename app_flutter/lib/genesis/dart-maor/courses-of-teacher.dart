// ⚛️ אטום-Dart (דרגת-חוזה) · coursesOfTeacher — סינון חוגים לפי מזהה-מורה.
// מוצא: maor/src/components/courses/lib.ts:103-119 · המקור: new/atoms/courses-of-teacher.mjs —
//        `export function coursesOfTeacher(courses, teacherId) {
//           return teacherId ? courses.filter((c) => c.teacherId === teacherId) : courses; }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: מזהה-מורה "אמיתי" (truthy) ⇒ רק החוגים ש-teacherId שלהם שווה-ממש למזהה;
//        מזהה נעדר/ריק/0 (falsy) ⇒ כל החוגים כמו-שהם (אותה רפרנס). הבחירה מי-מורה =
//        עיוורת-לתוכן: משווה `===` בלבד.
// קלט:  courses (List של Map עם 'teacherId') · teacherId (מזהה, כל טיפוס). פלט: List
//        מסוננת בענף-ה-truthy, או courses המקורי (אותה רפרנס) בענף-ה-falsy.
//
// הערות-המרה (מקור→Dart — הנקודות שמנוע-ה-AST נוטה לפספס):
//  • truthiness: `teacherId ? ...` הוא בדיקת-אמת של JS — null/undefined/''/0/false/NaN
//    כולם falsy. מומש ב-`_truthy` שמחקה `!!` לתחום (null/bool/String/num). כך '' ו-0
//    (דוגמאות-הזהב) נופלים לענף-ה-else ומחזירים את courses כמו-שהוא, בדיוק כמו במקור.
//  • השוואת-חוג: `c.teacherId === teacherId` (strict) → `(c)['teacherId'] == teacherId`.
//    ל-num/String/bool ה-`==` של Dart מקביל ל-`===` של JS (אין coercion) — זהה-ביט.
//  • גישת-מאפיין `c.teacherId` (JS) → אינדוקס-מפה `c['teacherId']` (Dart) — למפה אין getter.
//  • בענף-ה-falsy מוחזר courses עצמו (אותה רפרנס, בלי העתקה) — נשמר. אין locale/פורמט/
//    getMonth/מוטביליות.

/// חיקוי `!!v` של JS לתחום-האטום: null/מחרוזת-ריקה/0/false/NaN ⇒ false, אחרת true.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  return true;
}

/// Courses filtered by teacher id. A truthy teacherId ⇒ only courses whose
/// teacherId strictly-equals it; a falsy id (null/''/0) ⇒ all courses, as-is
/// (same reference). Verbatim port of new/atoms/courses-of-teacher.mjs
/// (`coursesOfTeacher`).
dynamic coursesOfTeacher(dynamic courses, dynamic teacherId) {
  return _truthy(teacherId)
      ? (courses as List)
          .where((c) => (c as Map)['teacherId'] == teacherId)
          .toList()
      : courses;
}

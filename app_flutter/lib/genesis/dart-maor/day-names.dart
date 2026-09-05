// ⚛️ אטום-Dart (דרגת-חוזה) · day-names — שמות ימי-הפעילות (0=ראשון … 5=שישי, בלי שבת).
// מוצא: maor/src/components/courses/lib.ts:80 (DAY_NAMES) · המקור: new/atoms/day-names.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: טבלת-שמות = ערך בלבד (חוק-5): הרשימה לא יודעת מי מציג ימים או מתי;
//        התצוגה/החישוב = הקופסה. 6 שמות בסדר ראשון→שישי (בלי שבת).
// קלט: אין. פלט: List<String> — 6 מחרוזות עבריות, כלשונן מהמקור.
//
// הערת-המרה (מקור→Dart): המקור הוא literal-מערך טהור — אין locale/פורמט/
// getMonth/truthiness/מוטביליות. המרה ישירה של ה-literal ל-List<String>.

/// Returns the activity day-names (0=Sunday … 5=Friday, no Saturday).
/// Verbatim behaviour, no context knowledge (חוק-5).
List<String> dayNames() {
  return const ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי'];
}

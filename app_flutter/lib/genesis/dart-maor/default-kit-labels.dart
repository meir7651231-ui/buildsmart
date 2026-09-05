// ⚛️ אטום-Dart · defaultKitLabels — נורמל מ-const-דאטה לפונקציה (מנוע-טהור; העברית תחולץ למטרה).
// ignore_for_file: non_constant_identifier_names
// ⚛️ אטום-Dart (דרגת-חוזה) · DEFAULT_KIT_LABELS — תוויות-ברירת-מחדל לערכת-מסירה.
// מוצא: אטום-קבוע (צילום-ערך) · המקור: new/atoms/default-kit-labels.mjs.
// טוהר: קבוע top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). אין זהות/סוד (חוק-6).
//
// תפקיד: חמש תוויות-ברירת-המחדל של שלבי-מסירת התוצר ללקוח.
// קלט:  אין. פלט: List<String> קבוע בן 5 איברים, בסדר-המקור.
//
// הערות-המרה (מקור→Dart):
//  • `export const DEFAULT_KIT_LABELS = [...]` → `const List<String> defaultKitLabels = [...]`.
//    המנוע פלט `var` — קבוע-צילום הוא `const` (בלתי-שינוי, בזמן-קומפילציה) לא `var`.
//  • המחרוזות מועתקות ביט-אחר-ביט (עברית + '+' פנימי) — אין locale/פורמט/מוטביליות.
//  • אין getMonth/truthiness/מיון/מודולו — אטום-ערך טהור.

/// Default delivery-kit stage labels (five Hebrew strings, source order).
/// Verbatim port of new/atoms/default-kit-labels.mjs (`DEFAULT_KIT_LABELS`).
List<String> defaultKitLabels({required String Function(String) term}) => [
  term('htmat-htvtsr-bsbybthlkvch'),
  term('bdyktkblh-mvl-hlkvch'),
  term('msyrt-chvmryhdrkh'),
  term('gybvy-hrshavtgyshh'),
  term('chtymtmsyrh'),
];
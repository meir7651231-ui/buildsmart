// ⚛️ אטום-Dart (דרגת-חוזה) · a11yFabToggles — קבוע: מתגי-הנגישות של ה-FAB.
// מוצא: המקור new/atoms/a11y-fab-toggles.mjs (`A11Y_FAB_TOGGLES`, קודם אוטומטית — צילום-ערך).
// טוהר: ערך top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). אין שכן, אין locale/פורמט/getMonth/truthiness.
//
// תפקיד: רשימת מתגי-הנגישות המוצגים ב-FAB — כל איבר [מפתח, תווית-עברית].
// קלט:  אין (קבוע). פלט: List של [String key, String label] — 4 מתגים, בסדר-המקור.
//
// הערות-המרה (מקור→Dart):
//  • `export const A11Y_FAB_TOGGLES = [[...],...]` → `const List<List<String>>` top-level.
//    הצילום ב-JS הוא JSON.stringify של המערך; ‏Dart-const שומר אותם ערכים ואותו סדר ⇒
//    רתמת-הזהב מוכיחה זהות-ביט מול אותו snapshot.
//  • המחרוזות-העבריות ראשוניות (codepoints U+05D0..) — מועתקות verbatim, אפס-שינוי.
//  • מוטביליות: `const` (immutable מוחלט) — אין var מוקצה-מחדש.

/// Accessibility FAB toggles — constant list of `[key, hebrewLabel]` pairs, in
/// source order. Verbatim port of new/atoms/a11y-fab-toggles.mjs (`A11Y_FAB_TOGGLES`).
const List<List<String>> a11yFabToggles = [
  ['contrast', 'ניגודיות גבוהה'],
  ['links', 'הדגשת כפתורים וקישורים'],
  ['noanim', 'עצירת אנימציות ותנועה'],
  ['spacing', 'ריווח טקסט מוגדל'],
];

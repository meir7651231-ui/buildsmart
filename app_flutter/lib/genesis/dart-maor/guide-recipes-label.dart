// ⚛️ אטום-Dart (דרגת-חוזה) · GUIDE_RECIPES_LABEL — כותרת מקטע-המתכונים במדריך.
// מוצא: אטום-קבוע (צילום-ערך) · המקור: new/atoms/guide-recipes-label.mjs
//        (חולץ כלשונו מ-maor/src/lib/guide.ts:79, legacy:2909).
// טוהר: קבוע top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). אין זהות/סוד (חוק-6).
//
// תפקיד: נוסח-הלגאסי מילה-במילה לכותרת "המתכונים המהירים:".
// קלט:  אין. פלט: String קבוע.
//
// הערות-המרה (מקור→Dart):
//  • `export const GUIDE_RECIPES_LABEL = '...'` → `const String guideRecipesLabel = '...'`.
//    המנוע פלט `var` — קבוע-צילום הוא `const` (בלתי-שינוי, בזמן-קומפילציה) לא `var`.
//  • המחרוזת מועתקת ביט-אחר-ביט (עברית + נקודתיים) — אין locale/פורמט/מוטביליות.
//  • אורך: JS `.length` = יחידות-UTF-16; Dart `String.length` = יחידות-UTF-16 — זהה (17).
//  • אין getMonth/truthiness/מיון/מודולו — אטום-ערך טהור.

/// Guide quick-recipes section heading (verbatim legacy wording).
/// Verbatim port of new/atoms/guide-recipes-label.mjs (`GUIDE_RECIPES_LABEL`).
const String guideRecipesLabel = 'המתכונים המהירים:';

// ⚛️ אטום-Dart (דרגת-חוזה) · subsidyTotal — הסבסוד הכולל: שווי-שנמסר פחות מה-ששולם.
// מוצא: maor/src/components/shop/lib.ts:447-451 · המקור: new/atoms/subsidy-total.mjs —
//        `export function subsidyTotal(assignments, givenValue, collectedPaid) {
//           return givenValue(assignments) - collectedPaid(assignments);
//         }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: חישוב-הפרש טהור — השווי שנמסר בפועל פחות התשלום הסמלי. שני האגרגטים
//        עצמם מוזרקים (מימושים מבוטלים מוחרגים אצלם, לא כאן); האטום לא מגן מפני
//        תוצאה שלילית (שולם מעל השווי) — בדיוק כמו המקור.
// שקעים (חוק-1 — קריאה-לשכן הוזרקה כפרמטר):
//   givenValue(assignments)⇒number    — Σ שווי המימושים החיים (שכן באותו קובץ במקור).
//   collectedPaid(assignments)⇒number — Σ התשלום הסמלי במימושים החיים (שכן).
// קלט: assignments — מועבר לשני השקעים **כמו-שהוא** (אותה רפרנס, בלי סינון/העתקה).
// פלט: מספר (עשוי להיות 0 ואף שלילי). אין עיגול.
//
// הערת-המרה (מקור→Dart): החיסור של JS על שני numbers ≡ חיסור num ב-Dart לערכים
// המוחזרים מהשקעים (החוזה מבטיח number). סדר-הקריאות נשמר: givenValue קודם,
// collectedPaid אחריו — כמו סדר-האיוולואציה של אופרנד-שמאל-קודם ב-JS.
// אין locale/תאריך/מיון/coercion-אינדקס/toLowerCase/trim — חוקים 12–16 לא נדרשים כאן.

/// Total subsidy of shop assignments: delivered value minus symbolic payment.
/// Pure difference; both aggregates are injected sinks. `assignments` is passed
/// through to both sinks as-is (same reference). May return 0 or negative —
/// verbatim behaviour of the JS source `subsidyTotal`.
dynamic subsidyTotal(dynamic assignments, dynamic givenValue, dynamic collectedPaid) {
  return givenValue(assignments) - collectedPaid(assignments);
}

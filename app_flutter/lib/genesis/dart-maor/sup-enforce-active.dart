// ⚛️ אטום-Dart (דרגת-חוזה) · supEnforceActive — שאילתת מצב אכיפת-התומכים (פאזה-2, dormant).
// מוצא: maor/src/lib/cloud.ts:126-129 · המקור: new/atoms/sup-enforce-active.mjs —
//        `export function supEnforceActive(supEnforceOn) { return supEnforceOn; }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: הצד-הדוחף/המושך שואל "האם אכיפת-התומכים פעילה?" לפני הזרקת/סינון skey.
//        במקור נקרא משתנה-המודול supEnforceOn (ברירת-מחדל דורמנטית false) — תא-המצב
//        הוא חיווט-קופסה (חוק-1/חוק-5, אותה דוקטרינה כמו set-sup-enforce): האטום רק
//        מחזיר את הערך הנוכחי שהוזרק לו, כמו-שהוא, בלי העתקה ובלי שינוי.
// שקע (חוק-1): supEnforceOn — ערך תא-המצב הנוכחי (הקופסה מחזיקה ומזינה).
// קלט: השקע supEnforceOn. פלט: אותו ערך בדיוק (=== ⇒ identical ב-Dart).
//
// הערת-המרה (מקור→Dart): ה-JS עיוור-לתוכן (מחזיר גם ערך-זקיף 7 או אובייקט). כדי
// לשמר זהות-רפרנס לכל טיפוס (bool, int, Map), החתימה `Object? → Object?` והזהות
// נבדקת ב-identical (מקביל ל-=== של JS). אין locale/תאריך/truthiness/מוטביליות.

/// Returns the current supporter-enforcement state (phase-2, dormant by default).
/// The push/pull side asks "is enforcement active?" before injecting/filtering skey.
/// Verbatim behaviour of the JS source `supEnforceActive` (identity function) —
/// the state cell itself is box wiring; the value is injected as a socket.
Object? supEnforceActive(Object? supEnforceOn) {
  return supEnforceOn;
}

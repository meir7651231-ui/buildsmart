// ⚛️ אטום-Dart (דרגת-חוזה) · pushNav — דחיפת מיקום קודם למחסנית "↩ חזרה", תקרה 20.
// מוצא: maor/src/lib/navhist.ts:28-33 (תורגם TS→JS) · המקור: new/atoms/push-nav.mjs —
//        `export function pushNav(hist, prev) { ... }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: המיקום הקודם נדחף לסוף המחסנית; אם עברה תקרת NAV_HIST_MAX=20 —
//        הישן-ביותר נזרק (נשמרים ה-20 האחרונים). טהור — מחזיר רשימה חדשה (המקור לא משתנה).
// NAV_HIST_MAX=20 (navhist.ts:19, לגאסי:166) הוטמע כערך מתועד — כמו במקור-ה-JS.
// קלט: hist (List<String>) · prev (String). פלט: List<String> (רשימה חדשה).
//
// הערת-המרה (מקור→Dart):
//   * אין locale/פורמט/getMonth/truthiness/מודולו מעורבים — המרה טהורה של list-slice.
//   * `[...hist, prev]` בונה רשימה חדשה ⇒ אימוטביליות המקור נשמרת אוטומטית (h הוא final).
//   * `h.slice(h.length - NAV_HIST_MAX)` ⇒ `h.sublist(h.length - navHistMax)`
//     (התנאי h.length > navHistMax מבטיח אינדקס-התחלה חיובי ⇒ אין substring-שלילי, כלל-המרה 5).

const int navHistMax = 20;

/// Pushes [prev] onto the back-navigation stack [hist], keeping at most
/// [navHistMax] (20) entries — the oldest is dropped once over the ceiling.
/// Verbatim behaviour of the JS source new/atoms/push-nav.mjs (`pushNav`).
/// Pure: returns a new list, [hist] is left unchanged.
List<String> pushNav(List<String> hist, String prev) {
  final List<String> h = [...hist, prev];
  return h.length > navHistMax ? h.sublist(h.length - navHistMax) : h;
}

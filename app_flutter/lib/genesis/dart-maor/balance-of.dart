// ⚛️ אטום-Dart (דרגת-חוזה) · balanceOf — יתרת-חוב של שיבוץ (לעולם לא שלילית).
// מוצא: maor/src/components/reports/lib.ts:54-56 · המקור: new/atoms/balance-of.mjs
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק dart:math). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: max(0, (e.totalDue || 0) − paidOf(e)) — סה"כ העסקה פחות מה ששולם, נקטם ל-0.
// שקע (חוק-1 — קריאה-לשכן הוזרקה כפרמטר): paidOf(e) → num (סכום e.payments; שכן במקור).
//        האטום קורא לו פעם-אחת על אותו e.
// קלט: e — שיבוץ (Map, שדה totalDue?) · השקע paidOf. פלט: num ≥ 0.
//
// הערות-המרה (מקור→Dart — מה שמנוע-ה-AST פספס):
//  · אובייקט-JS e ⇒ Map<String, Object?>; גישת-שדה e.totalDue ⇒ e['totalDue'].
//  · **truthiness** של המקור `e.totalDue || 0`: falsy (null/חסר/0/NaN) ⇒ 0. הטיוטה
//    השתמשה ב-`?? 0` (null-coalescing) שאינו זהה ל-`||` (0/NaN היו דולפים) — תוקן
//    לבדיקת-truthy מפורשת (num חוקי ולא-אפס ולא-NaN, אחרת 0).
//  · Math.max ⇒ dart:math max (הטיוטה קראה ל-max בלי import — תוקן).

import 'dart:math';

/// Outstanding balance of an assignment. Verbatim behaviour of the JS source
/// `balanceOf`. `paidOf` is an injected socket returning the total already paid.
num balanceOf(Map<String, Object?> e, num Function(Map<String, Object?>) paidOf) {
  final t = e['totalDue'];
  // מקבילה נאמנה ל-JS `e.totalDue || 0`: רק num-חוקי-ולא-אפס עובר, השאר ⇒ 0.
  final num due = (t is num && !t.isNaN && t != 0) ? t : 0;
  return max(0, due - paidOf(e));
}

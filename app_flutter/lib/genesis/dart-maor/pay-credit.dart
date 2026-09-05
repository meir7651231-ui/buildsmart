// ⚛️ אטום-Dart (דרגת-חוזה) · payCredit — יתרת-זכות של שיבוץ.
// מוצא: maor/src/components/courses/lib.ts:319-321 · המקור: new/atoms/pay-credit.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). השכן paidOf הוזרק כשקע (חוק-1/חוק-3).
//
// תפקיד: יתרת-זכות = max(0, ששולם − סה"כ-עסקה − חוב-מועבר). היפוך של יתרת-החוב.
//        carryBalance שלילי = זכות-מועברת (מגדילה); חיובי = חוב-מועבר (מקטין); חסר ⇒ 0.
// קלט:  e (שיבוץ: totalDue? · carryBalance?) · השקע paidOf(e) ⇒ num (סכום e.payments[].amount).
//        פלט: num ≥ 0.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • `(e.totalDue || 0)` ו-`(e.carryBalance || 0)` הם `||` של JS: מחזיר את הערך אם truthy,
//    אחרת 0. לנתון-מספרי: 0/NaN/null/חסר ⇒ 0; מספר-אחר (כולל שלילי) נשמר. מומש ב-`_orZero`
//    שמחקה `v || 0` בדיוק — כך carry שלילי (זכות-מועברת) נשמר ולא נבלע.
//  • `Math.max(0, v)` → `v < 0 ? 0 : v` (אין תלות ב-dart:math; שקיפות-ביט).
//  • מוטביליות: כל המקומיים final. אין locale/פורמט/getMonth. השקע paidOf נושא את סכום-התשלומים.

/// חיקוי `v || 0` של JS לתחום-מספרי: num-truthy ⇒ הערך, אחרת 0 (0/NaN/null/חסר).
num _orZero(dynamic v) => (v is num && v != 0 && !(v is double && v.isNaN)) ? v : 0;

/// A placement's credit balance = max(0, paid − totalDue − carryBalance). The inverse of the
/// debt balance. Verbatim port of new/atoms/pay-credit.mjs (`payCredit`); the neighbour call
/// paidOf (amount paid) is injected as a socket (Law 1/3).
num payCredit(Map<String, dynamic> e, num Function(Map<String, dynamic>) paidOf) {
  final v = paidOf(e) - _orZero(e['totalDue']) - _orZero(e['carryBalance']);
  return v < 0 ? 0 : v;
}

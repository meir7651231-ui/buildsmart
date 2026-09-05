// ⚛️ אטום-Dart (דרגת-חוזה) · collectedPaid — Σ מה ששולם בפועל (מימושים חיים בלבד).
// מוצא: maor/src/components/shop/lib.ts:440-446 · המקור: new/atoms/collected-paid.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). השכן liveRedemptions הוזרק כשקע (חוק-1/חוק-3 —
//        אטום לא מייבא אטום, קריאת-שכן = פרמטר-פונקציה).
//
// תפקיד: סכימת paid על המימושים החיים בלבד של כל השיוכים (מבוטלים מוחרגים דרך השקע);
//        paid לא-מספרי נספר כ-0.
// קלט:  assignments (מערך שיוכים) · השקע liveRedemptions(a)⇒מימושים חיים. פלט: מספר (Σ paid).
//
// הערות-המרה (מקור→Dart):
//  • `Number.isFinite(r.paid)` → `paid is num && paid.isFinite`: ב-JS undefined/null/NaN
//    מחזירים false ⇒ בדארט null.is-num=false, double.nan.isFinite=false — זהה סמנטית.
//  • truthiness/טרנרי `? r.paid : 0` נשמר כלשונו — לא-מספרי מוסיף 0.
//  • מוטביליות: `sum` הוא var מוקצה-מחדש (`let sum` במקור) ⇒ num sum; ה-loop-vars final.
//  • אין locale/פורמט/getMonth — liveRedemptions הוא שקע, האטום עיוור להחרגת-המבוטלים (חוק-5).

/// Sum of what was actually paid (live redemptions only) across all assignments;
/// non-numeric `paid` counts as 0. Verbatim port of new/atoms/collected-paid.mjs.
/// Neighbour liveRedemptions is injected as a socket (Law 1/3).
num collectedPaid<A>(
  List<A> assignments,
  List<Map<String, dynamic>> Function(A) liveRedemptions,
) {
  num sum = 0;
  for (final a in assignments) {
    for (final r in liveRedemptions(a)) {
      final paid = r['paid'];
      sum += (paid is num && paid.isFinite) ? paid : 0;
    }
  }
  return sum;
}

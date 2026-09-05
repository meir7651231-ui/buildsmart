// ⚛️ אטום-Dart (דרגת-חוזה) · matchAll — שיוך-מרובה של תשלומים-נכנסים לחיובים-מתוכננים.
// מוצא: maor/src/lib/plannedMatch.ts:130-144 (matchAll) · המקור: new/atoms/match-all.mjs
// חוזה: new/atoms/match-all.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מריץ שיוך-יחיד (השקע) על כל תשלום-נכנס לפי-סדר, ומחזיר רק את ההתאמות.
//        אנטי-כפילות: פלן שכבר-שויך בסבב-הזה (used על plan.id) מוצא מהמאגר
//        לתשלום-הבא — אחרת אותו פלן היה נתפס פעמיים בבאלק. משמר סדר-הקלט.
// שקע (חוק-1 — קריאה-לשכן הוזרקה כפרמטר):
//   matchIncomingToPlanned(inc, stillOpen) ⇒ התאמה {plan:{id},…} או null (שיוך-יחיד).
// קלט: incomings [{id,amount}] · allOpen [{plan:{id,amount},…}] · השקע.
// פלט: רשימת-התאמות (תת-קבוצה של תוצאות-השקע), בסדר-הקלט.
//
// הערת-המרה (מקור→Dart):
//  · JS `if (m)` (truthiness על אובייקט/null) ⇒ Dart `m != null` מפורש — ההתאמה
//    היא Map או null; אין ערכי-falsy אחרים בזרם.
//  · JS `used.has(x)` / `used.add(x)` ⇒ Dart `used.contains(x)` / `used.add(x)`.
//  · JS `pool.filter(...)` (מחזיר רשימה-חדשה, לא-מוטבילי) ⇒ `pool.where(...).toList()`.
//  · גישת-שכן r.plan.id / m.plan.id ⇒ r['plan']['id'] (המבנה הוא Map מקונן).
//  · plan.id הוא Object? (מזהה כלשהו) — ה-Set ומפתחות הזהות עיוורים-לטיפוס.
//  אין locale/פורמט/getMonth/תאריך-מגלגל/substring/מודולו/num.parse בזרם-הזה.

/// Multi-match: runs the single-match socket on every incoming payment in order,
/// returning only the matches. Anti-double-capture: a plan already matched this
/// round (tracked by plan.id in `used`) is removed from the pool for the next
/// payment. Verbatim behaviour of the JS source `matchAll`.
List<Map<String, dynamic>> matchAll(
  List<Map<String, dynamic>> incomings,
  List<Map<String, dynamic>> allOpen,
  Map<String, dynamic>? Function(
    Map<String, dynamic> inc,
    List<Map<String, dynamic>> stillOpen,
  ) matchIncomingToPlanned,
) {
  final out = <Map<String, dynamic>>[];
  final used = <Object?>{}; // planId שכבר-שויך בסבב-הזה
  final pool = [...allOpen];
  for (final inc in incomings) {
    final stillOpen = pool
        .where((r) => !used.contains((r['plan'] as Map)['id']))
        .toList();
    final m = matchIncomingToPlanned(inc, stillOpen);
    if (m != null) {
      out.add(m);
      used.add((m['plan'] as Map)['id']);
    }
  }
  return out;
}

// ⚛️ אטום-Dart (דרגת-חוזה) · cockpitCollectedThisMonth — סכום שנגבה החודש (ש״ח-שקול).
// מוצא: maor/src/components/supporters/cockpit.ts:199 · המקור-הקדוש: new/atoms/cockpit-collected-this-month.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). חוק-4 — זהה-ביט למקור-JS.
//
// תפקיד: קבלות (donations) + hist בחודש-הנוכחי (todayIso[0..7]); $ ⇒ *rate; מעוגל.
// קלט:  supporters (List<Map>) · todayIso (String) · rate (num, ברירת-מחדל 3.7). פלט: int.
//
// הערות-המרה (JS→Dart — הנקודות העדינות):
//  • `todayIso.slice(0,7)` ⇒ substring(0,7). `date.startsWith(month)` זהה.
//  • `(d.cur || '₪') === '$'` — cur ריק/חסר ⇒ '₪' (truthiness). כאן: null/'' ⇒ '₪'.
//  • JS `Math.round(sum)` = `floor(sum + 0.5)` (חצי כלפי +∞). מיושם ככה בדיוק ((sum+0.5).floor())
//    ⇒ זהה-ל-JS גם על חצי (הסכומים כאן שלמים; מגן על עתיד). מחזיר int.
//  • הכל float64 בביניים (rate*amount) — sum כ-double.

/// Sum collected this (calendar) month in ILS-equivalent (donations + hist), USD*rate.
/// Verbatim port of new/atoms/cockpit-collected-this-month.mjs.
int cockpitCollectedThisMonth(List supporters, String todayIso, [num rate = 3.7]) {
  final month = todayIso.substring(0, 7);
  double sum = 0;
  for (final s in supporters) {
    final sp = s as Map;
    for (final dd in (sp['donations'] as List)) {
      final d = dd as Map;
      if (!(d['date'] as String).startsWith(month)) continue;
      final cur = d['cur'];
      final c = (cur == null || cur == '') ? '₪' : cur;
      sum += c == '\$' ? (d['amount'] as num) * rate : (d['amount'] as num);
    }
    for (final hh in ((sp['hist'] ?? const []) as List)) {
      final h = hh as Map;
      final hd = h['d'];
      if (!((hd == null ? '' : hd) as String).startsWith(month)) continue;
      final cc = h['c'];
      final c = (cc == null || cc == '') ? '₪' : cc;
      sum += c == '\$' ? (h['a'] as num) * rate : (h['a'] as num);
    }
  }
  return (sum + 0.5).floor();
}

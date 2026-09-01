// ⚛️ אטום-Dart (דרגת-חוזה) · activeByMonth — מונה-פעילים פר-חודש (נתנו באותו חודש).
// מוצא: maor-system/src/components/supporters/portfolio.ts:139 · המקור: new/atoms/portfolio-active-by-month.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import-אטום (dart:core בלבד). חוק-4 — זהה-ביט למקור-JS.
//        שקע יחיד הוזרק כפרמטר: donorScan (אח-intel).
//
// הערות-המרה (JS→Dart):
//  • `new Array(months).fill(0)` ⇒ `List<int>.filled(months, 0)` (ניתן-מוטציה בכל אינדקס).
//  • `scan.monthly[i] > 0` ⇒ `(monthly[i] as num) > 0` · `out[i]++` ⇒ `out[i]++`.

/// Active-donor count per month (gave that month). Verbatim port of
/// new/atoms/portfolio-active-by-month.mjs (`activeByMonth`).
List<int> activeByMonth(
  List supporters,
  String todayIso, {
  int months = 12,
  num rate = 3.7,
  required Map Function(dynamic, String, num, int) donorScan,
}) {
  final out = List<int>.filled(months, 0);
  for (final sp in supporters) {
    final scan = donorScan(sp, todayIso, rate, months);
    final monthly = scan['monthly'] as List;
    for (int i = 0; i < months; i++) {
      if ((monthly[i] as num) > 0) out[i]++;
    }
  }
  return out;
}

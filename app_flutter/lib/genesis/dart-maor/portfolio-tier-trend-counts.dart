// ⚛️ אטום-Dart (דרגת-חוזה) · tierTrendCounts — פרוקסי-מגמה פר-דרגה (rising/falling/stable).
// מוצא: maor-system/src/components/supporters/portfolio.ts:116 · המקור: new/atoms/portfolio-tier-trend-counts.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import-אטום (dart:core בלבד). חוק-4 — זהה-ביט למקור-JS.
//        שקעים הוזרקו כפרמטרים: donorScan/rfmFromScan/trendFromScan (אחי-intel) · supTier (Genesis).
//
// הערות-המרה (JS→Dart):
//  • `new Map(order.map(...))` ⇒ Map בסדר-הכנסה; `map.get(tier)` ⇒ `map[tier]` (null אם אין דרגה).
//  • השורות מוטבלות (row.total++) ⇒ Map<String,dynamic> ממוטבל בתוך ה-map; `order.map(t=>map.get(t))`
//    מחזיר את אותן שורות (הפניה) בסדר order — סדר-מפתחות של כל שורה: tier,total,rising,falling,stable.
//  • `trendFromScan(scan).dir` ⇒ `['dir']`; `supTier(...).label` ⇒ `['label']`.

/// Trend proxy per tier. Verbatim port of new/atoms/portfolio-tier-trend-counts.mjs
/// (`tierTrendCounts`).
List<Map<String, dynamic>> tierTrendCounts(
  List supporters,
  String todayIso, {required String Function(String) term, 
  num rate = 3.7,
  required Map Function(dynamic, String, num, int) donorScan,
  required Map Function(Map, String) rfmFromScan,
  required Map Function(Map) trendFromScan,
  required Map Function(num) supTier,
}) {
  final order = [term('zhb'), term('ksf'), term('ard'), term('rdvmh')];
  final map = <String, Map<String, dynamic>>{};
  for (final t in order) {
    map[t] = {'tier': t, 'total': 0, 'rising': 0, 'falling': 0, 'stable': 0};
  }
  for (final sp in supporters) {
    final scan = donorScan(sp, todayIso, rate, 12);
    if ((scan['count'] as num) == 0) continue;
    final tier = supTier(rfmFromScan(scan, todayIso)['score'] as num)['label'] as String;
    final row = map[tier];
    if (row == null) continue;
    row['total'] = (row['total'] as int) + 1;
    final d = trendFromScan(scan)['dir'] as String;
    if (d == 'up') {
      row['rising'] = (row['rising'] as int) + 1;
    } else if (d == 'down') {
      row['falling'] = (row['falling'] as int) + 1;
    } else {
      row['stable'] = (row['stable'] as int) + 1;
    }
  }
  return order.map((t) => map[t]!).toList();
}

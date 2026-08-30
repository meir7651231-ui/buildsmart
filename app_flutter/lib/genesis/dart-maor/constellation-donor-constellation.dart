// ⚛️ אטום-Dart (דרגת-חוזה) · donorConstellation — פריסת-גלקסיה של תורמים.
// מוצא: maor-system/src/components/supporters/constellation.ts:54 · המקור: new/atoms/constellation-donor-constellation.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import-אטום (dart:core + dart:math ל-log/ln10). חוק-4 — זהה-ביט למקור-JS.
//        עוזרים/דאטה-פרטיים (TIER_KEY · hash01 · radiusFor) מוטבעים inline; שקעים הוזרקו כפרמטרים:
//        donorScan/dayDiff/rfmFromScan/churnFromScan (אחי-intel) · supTier (Genesis).
//
// ⚠️ נקודות עדינות (JS→Dart):
//  • hash01 = FNV-1a **uint32**. ‏JS `Math.imul(h,16777619)` ו-`h>>>0` פועלים ב-32-סיביות;
//    ‏Dart int הוא 64-סיביות ⇒ **חובה למדל uint32**: `h = (h ^ c) & 0xFFFFFFFF` ואז
//    `h = (h * 16777619) & 0xFFFFFFFF` בכל צעד (הכפל 0xFFFFFFFF×16777619≈7.2e16 < 2^63 ⇒ מדויק ב-64bit,
//    ואז מסכת-32-הסיביות התחתונות ≡ תוצאת Math.imul). לבסוף `h / 4294967296.0` (double, ≡ (h>>>0)/…).
//  • `Math.log10(x)` ⇒ `log(x)/ln10` — אומת זהה-ביט מול Node (double). `Math.round` ⇒ `(x+0.5).floor()`.
//  • `Math.max(a, Math.min(b, x))` ⇒ טרנרי ידני (min ואז max), משמר סמנטיקת-קצה.
//  • `opts.rate ?? 3.7` (‏?? על null/undefined בלבד) ⇒ `opts['rate'] ?? 3.7` (Dart ?? על null בלבד — זהה).
//  • `s.charCodeAt(i)` (UTF-16) ⇒ `s.codeUnitAt(i)`. המזהים ASCII/BMP.

import 'dart:math' show log, ln10;

int _round(num x) => (x + 0.5).floor();

/// Galaxy layout: angle=hash01(id) · radius=recency · size=log(ltv) · tier · atRisk.
/// Verbatim port of new/atoms/constellation-donor-constellation.mjs (`donorConstellation`).
List<Map<String, dynamic>> donorConstellation(
  List supporters,
  String todayIso, {
  Map opts = const {},
  required Map Function(dynamic, String, num, int) donorScan,
  required num Function(dynamic, String) dayDiff,
  required Map Function(Map, String) rfmFromScan,
  required num Function(Map, String) churnFromScan,
  required Map Function(num) supTier,
}) {
  const tierKey = {'זהב': 'gold', 'כסף': 'silver', 'ארד': 'bronze', 'רדומה': 'dormant'};
  double hash01(String s) {
    int h = 2166136261;
    for (int i = 0; i < s.length; i++) {
      h = (h ^ s.codeUnitAt(i)) & 0xFFFFFFFF;
      h = (h * 16777619) & 0xFFFFFFFF;
    }
    return h / 4294967296.0;
  }

  double radiusFor(num daysSince, double jitter) {
    final double base = daysSince <= 30
        ? 0.30
        : daysSince <= 90
            ? 0.45
            : daysSince <= 180
                ? 0.60
                : daysSince <= 365
                    ? 0.75
                    : 0.9;
    final double v = base + (jitter - 0.5) * 0.1;
    final double m = v < 0.98 ? v : 0.98; // Math.min(0.98, v)
    return m > 0.18 ? m : 0.18; // Math.max(0.18, …)
  }

  final num rate = ((opts['rate'] ?? 3.7) as num);
  final num riskT = ((opts['riskThreshold'] ?? 60) as num);
  final raw = <Map<String, dynamic>>[];
  double maxLog = 0;
  for (final sp in supporters) {
    final scan = donorScan(sp, todayIso, rate, 12);
    if ((scan['count'] as num) == 0) continue;
    final days = dayDiff(scan['last'], todayIso);
    final tier = tierKey[supTier(rfmFromScan(scan, todayIso)['score'] as num)['label']] ?? 'dormant';
    final churn = churnFromScan(scan, todayIso);
    final double lg = log((scan['ils'] as num) + 1) / ln10;
    if (lg > maxLog) maxLog = lg;
    raw.add({'sp': sp, 'ils': scan['ils'], 'days': days, 'tier': tier, 'churn': churn});
  }
  return raw.map((r) {
    final sp = r['sp'];
    final num ils = r['ils'] as num;
    double size;
    if (maxLog > 0) {
      final double x = (log(ils + 1) / ln10) / maxLog;
      final double m = x < 1 ? x : 1; // Math.min(1, …)
      size = m > 0.15 ? m : 0.15; // Math.max(0.15, …)
    } else {
      size = 0.15;
    }
    return <String, dynamic>{
      'id': sp['id'],
      'name': sp['name'],
      'angle': hash01(sp['id'] as String),
      'radius': radiusFor(r['days'] as num, hash01('${sp['id']}#r')),
      'size': size,
      'tier': r['tier'],
      'atRisk': (r['churn'] as num) >= riskT,
      'val': _round(ils),
      'churn': r['churn'],
    };
  }).toList();
}

// ⚛️ אטום-Dart (דרגת-חוזה) · portfolioIntel — מודיעין-תיק במעבר-יחיד.
// מוצא: maor-system/src/components/supporters/portfolio.ts:44 · המקור: new/atoms/portfolio-portfolio-intel.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import-אטום (dart:core בלבד). חוק-4 — זהה-ביט למקור-JS.
//        עוזרים/דאטה-פרטיים (_shiftIso · RISK=60) מוטבעים inline; שקעים הוזרקו כפרמטרים (חוק-1/3):
//        donorScan/dayDiff/rfmFromScan/churnFromScan/forecastFromScan (אחי-intel) · supTier (Genesis).
//
// הערות-המרה (JS→Dart):
//  • `_shiftIso(iso,days) = new Date(Date.parse(iso.slice(0,10)+'T12:00:00') + days*86400000).toISOString().slice(0,10)`
//    ⇒ בניית DateTime-מקומי בצהריים, הוספת days*86400000ms על ה-epoch, `.toUtc().toIso8601String()` (⇒ UTC כמו-Date),
//    substring(0,10). (הקונטיינר UTC ⇒ מקומי≡UTC; הפורט נכון גם באזור-זמן אחר.)
//  • `Math.round(x)` (חצי-כלפי-+∞) ⇒ `(x + 0.5).floor()` (לא `num.round`, שמעגל-הרחק-מאפס).
//  • `Math.min(9, Math.floor(score/100))` ⇒ `.floor()` + min ידני. `Math.min(topN, ltvs.length)` דומה.
//  • `tierCounts[tier] = (tierCounts[tier]||0)+1` — Map בסדר-הכנסה (LinkedHashMap) ⇒ סדר-מפתחות זהה-JS.
//  • `ltvs.sort((a,b)=>b-a)` — יורד; רק הסכום `top` נצרך ⇒ יציבות אדישה; משתמשים ב-compareTo יורד.
//  • `if(fc){...}` — forecast null ⇒ מדולג; השוואות-dueIso הן השוואות-מחרוזת (‏<=).

int _round(num x) => (x + 0.5).floor();

String _shiftIso(String iso, int days) {
  final base = DateTime.parse('${iso.substring(0, 10)}T12:00:00');
  final ms = base.millisecondsSinceEpoch + days * 86400000;
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  return d.toUtc().toIso8601String().substring(0, 10);
}

/// Single-pass portfolio intelligence: ltv/retention/concentration/forecast/bins/tiers.
/// Verbatim port of new/atoms/portfolio-portfolio-intel.mjs (`portfolioIntel`).
Map<String, dynamic> portfolioIntel(
  List supporters,
  String todayIso, {
  num rate = 3.7,
  int topN = 10,
  required Map Function(dynamic, String, num, int) donorScan,
  required num Function(dynamic, String) dayDiff,
  required Map Function(Map, String) rfmFromScan,
  required num Function(Map, String) churnFromScan,
  required Map? Function(Map, String) forecastFromScan,
  required Map Function(num) supTier,
}) {
  const risk = 60;
  final scoreBins = List<int>.filled(10, 0);
  final tierCounts = <String, int>{};
  final ltvs = <num>[];
  int giftCount = 0, gaveEver = 0, retained = 0, atRiskCount = 0;
  num ltv = 0, atRiskMoney = 0, forecast30 = 0, forecast90 = 0;
  final in30 = _shiftIso(todayIso, 30), in90 = _shiftIso(todayIso, 90);
  for (final sp in supporters) {
    final scan = donorScan(sp, todayIso, rate, 12);
    if ((scan['count'] as num) == 0) continue;
    gaveEver++;
    giftCount += scan['count'] as int;
    ltv += scan['ils'] as num;
    ltvs.add(scan['ils'] as num);
    if (dayDiff(scan['last'], todayIso) <= 365) retained++;
    final rfm = rfmFromScan(scan, todayIso);
    final bin = (rfm['score'] as num) / 100;
    final int bi = bin.floor() < 9 ? bin.floor() : 9;
    scoreBins[bi]++;
    final tier = supTier(rfm['score'] as num)['label'] as String;
    tierCounts[tier] = (tierCounts[tier] ?? 0) + 1;
    final churn = churnFromScan(scan, todayIso);
    if (churn >= risk) {
      atRiskCount++;
      atRiskMoney += scan['ils'] as num;
    }
    final fc = forecastFromScan(scan, todayIso);
    if (fc != null) {
      if ((fc['dueIso'] as String).compareTo(in30) <= 0) {
        forecast30 += fc['amount'] as num;
      }
      if ((fc['dueIso'] as String).compareTo(in90) <= 0) {
        forecast90 += fc['amount'] as num;
      }
    }
  }
  ltvs.sort((a, b) => b.compareTo(a));
  num top = 0;
  final lim = topN < ltvs.length ? topN : ltvs.length;
  for (int i = 0; i < lim; i++) {
    top += ltvs[i];
  }
  return {
    'count': supporters.length,
    'giftCount': giftCount,
    'ltv': _round(ltv),
    'avgGift': giftCount != 0 ? _round(ltv / giftCount) : 0,
    'retention12m': gaveEver != 0 ? _round((retained / gaveEver) * 100) : 0,
    'atRiskCount': atRiskCount,
    'atRiskMoney': _round(atRiskMoney),
    'concentrationTopN': ltv > 0 ? _round((top / ltv) * 100) : 0,
    'topN': topN,
    'forecast30': _round(forecast30),
    'forecast90': _round(forecast90),
    'scoreBins': scoreBins,
    'tierCounts': tierCounts,
  };
}

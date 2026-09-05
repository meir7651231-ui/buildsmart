// ⚛️ אטום-Dart (דרגת-חוזה) · donorIntel — כל-המודיעין במעבר-יחיד + נגזרות.
// מוצא: maor-system/src/components/supporters/intel.ts:179 (donorIntel) · המקור: new/atoms/intel-donor-intel.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import-אטום (dart:core בלבד). חוק-4 — זהה-ביט למקור-JS.
//        חמשת-השכנים (donorScan/rfmFromScan/churnFromScan/forecastFromScan/trendFromScan)
//        הוזרקו כשקעים-פרמטרים (חוק-1/חוק-3) — המקור מזריקם כבר-"קשורים" (dayDiff בתוכם).
//
// הערות-המרה (JS→Dart):
//  • rate/months (ברירות 3.7/12) ⇒ פרמטרים-נקובים; השקעים ⇒ פרמטרים-נקובים-חובה (Dart אוסר
//    ערבוב אופציונלי-מיקומי עם נקוב). המקור מעביר rate/months ל-donorScan במיקום — נשמר.
//  • `Math.round(scan.ils)` / `Math.round(scan.ils/scan.count)` ⇒ _jsRound (floor(x+0.5)).
//  • `scan.count ? … : 0` (truthy) ⇒ count != 0.
//  • הפלט Map בסדר: scan → rfm → churn → forecast → trend → ltv → avgGift.
int _jsRound(num x) => (x + 0.5).floor();

/// Full donor intel {scan, rfm, churn, forecast, trend, ltv, avgGift}.
/// Verbatim port of intel-donor-intel.mjs (`donorIntel`); five neighbours injected as sockets.
Map<String, dynamic> donorIntel(
  Map<String, dynamic> sp,
  String todayIso, {
  num rate = 3.7,
  int months = 12,
  required Map<String, dynamic> Function(Map<String, dynamic>, String, num, int) donorScan,
  required Map<String, dynamic> Function(Map<String, dynamic>, String) rfmFromScan,
  required num Function(Map<String, dynamic>, String) churnFromScan,
  required Map<String, dynamic>? Function(Map<String, dynamic>, String) forecastFromScan,
  required Map<String, dynamic> Function(Map<String, dynamic>) trendFromScan,
}) {
  final scan = donorScan(sp, todayIso, rate, months);
  final num ils = scan['ils'] as num;
  final int count = scan['count'] as int;
  return {
    'scan': scan,
    'rfm': rfmFromScan(scan, todayIso),
    'churn': churnFromScan(scan, todayIso),
    'forecast': forecastFromScan(scan, todayIso),
    'trend': trendFromScan(scan),
    'ltv': _jsRound(ils),
    'avgGift': count != 0 ? _jsRound(ils / count) : 0,
  };
}

// ⚛️ אטום-Dart (דרגת-חוזה) · rfmFromScan — ציון RFM (recency/frequency/monetary) מסריקה.
// מוצא: maor-system/src/components/supporters/intel.ts:95 (rfmFromScan)+rScore/fScore/mScore:73-81 · המקור: new/atoms/intel-rfm-from-scan.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import-אטום (dart:core בלבד). חוק-4 — זהה-ביט למקור-JS.
//        השכן dayDiff הוזרק כשקע-פרמטר (חוק-1/חוק-3); rScore/fScore/mScore inline (חוק-2).
//
// הערות-המרה (JS→Dart):
//  • `scan.last` (truthy) ⇒ scan['last'] לא-null ולא-''; אחרת days=99999.
//  • ספי-הציון = int-literals; days יכול להיות double.infinity (dayDiff) ⇒ כל התנאים כוזבים ⇒ 40.
//  • `Math.round((r/350)*100)` — r/f/m חיוביים ⇒ המנה חיובית; בכל-זאת משתמשים ב-_jsRound
//    (floor(x+0.5)) = הפורט הנאמן של Math.round (‏Dart.round שונה בקצה-.5 של שליליים).
//  • הפלט Map בסדר: r → f → m → score → rPct → fPct → mPct.

int _jsRound(num x) => (x + 0.5).floor(); // Math.round של JS = floor(x+0.5), נאמן בשני-הסימנים.

/// RFM score from a donorScan. Verbatim port of intel-rfm-from-scan.mjs (`rfmFromScan`).
/// `dayDiff` injected as a socket (Law 1/3).
Map<String, dynamic> rfmFromScan(
    Map<String, dynamic> scan, String todayIso, num Function(String, String) dayDiff) {
  int rScore(num days) => days <= 30
      ? 350
      : days <= 90
          ? 280
          : days <= 180
              ? 200
              : days <= 365
                  ? 120
                  : 40;
  int fScore(num cnt) => cnt >= 10
      ? 300
      : cnt >= 5
          ? 230
          : cnt >= 3
              ? 160
              : cnt >= 2
                  ? 100
                  : 50;
  int mScore(num tot) => tot >= 5000
      ? 350
      : tot >= 2000
          ? 280
          : tot >= 1000
              ? 210
              : tot >= 500
                  ? 140
                  : tot >= 100
                      ? 80
                      : 40;
  final last = scan['last'];
  final num days =
      (last != null && last != '') ? dayDiff(last as String, todayIso) : 99999;
  final r = rScore(days), f = fScore(scan['count'] as num), m = mScore(scan['ils'] as num);
  return {
    'r': r,
    'f': f,
    'm': m,
    'score': r + f + m,
    'rPct': _jsRound((r / 350) * 100),
    'fPct': _jsRound((f / 300) * 100),
    'mPct': _jsRound((m / 350) * 100),
  };
}

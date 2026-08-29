// ⚛️ אטום-Dart (דרגת-חוזה) · churnFromScan — סיכון-נטישה 0–100 מול קצב-הנתינה האישי.
// מוצא: maor-system/src/components/supporters/intel.ts:111 (churnFromScan) · המקור: new/atoms/intel-churn-from-scan.mjs.
// טוהר: פונקציית top-level עצמאית, import שפה-בלבד (dart:math למ-max/min). חוק-4 — זהה-ביט למקור-JS.
//        השכן dayDiff הוזרק כשקע-פרמטר (חוק-1/חוק-3).
//
// הערות-המרה (JS→Dart):
//  • `scan.count === 0 || !scan.last` ⇒ count==0 || last==null || last=='' ⇒ מחזיר 0.
//  • `scan.first && scan.first !== scan.last` ⇒ first לא-ריק וגם ≠ last.
//  • `span / (scan.count-1)` — חלוקת-JS = double תמיד (Dart `/`).
//  • `Math.max(30, cadence*1.5)` ⇒ math.max(30.0, …) (double; 30.0==30 בערך).
//  • `Math.round(ratio*50)` ⇒ _jsRound (floor(x+0.5)); ratio-שלילי-חצי אפשרי אך נבלע ב-max(0,…);
//    בכל-זאת _jsRound = הפורט הנאמן. last מובטח-תקין (או ריק⇒יצא) ⇒ ratio סופי (ללא throw על round).
import 'dart:math' as math;

int _jsRound(num x) => (x + 0.5).floor();

/// Churn-risk 0–100 vs. personal cadence. Verbatim port of intel-churn-from-scan.mjs.
/// `dayDiff` injected as a socket (Law 1/3).
num churnFromScan(
    Map<String, dynamic> scan, String todayIso, num Function(String, String) dayDiff) {
  final last = scan['last'];
  if (scan['count'] == 0 || last == null || last == '') return 0;
  final num daysSince = dayDiff(last as String, todayIso);
  final first = scan['first'];
  final num span = (first != null && first != '' && first != last)
      ? dayDiff(first as String, last)
      : 0;
  final int count = scan['count'] as int;
  final num cadence = (count >= 2 && span > 0) ? span / (count - 1) : 365;
  final num expected = math.max(30.0, cadence * 1.5);
  final num ratio = daysSince / expected;
  return math.max(0, math.min(100, _jsRound(ratio * 50)));
}

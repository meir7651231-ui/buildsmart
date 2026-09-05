// ⚛️ אטום-Dart (דרגת-חוזה) · trendFromScan — מגמה: מחצית-חדשה מול ישנה בסדרה-החודשית.
// מוצא: maor-system/src/components/supporters/intel.ts:154 (trendFromScan) · המקור: new/atoms/intel-trend-from-scan.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import-אטום (dart:core בלבד). חוק-4 — זהה-ביט למקור-JS.
//
// הערות-המרה (JS→Dart):
//  • `scan.monthly` = List (מספרים int/double מעורבים); סכימה ל-num.
//  • `Math.floor(n/2)` ⇒ n ~/ 2 (חיתוך זהה ל-n חיובי).
//  • `older === 0 && newer === 0` ⇒ older==0 && newer==0 (0.0==0 נכון).
//  • `Math.round(((newer-older)/older)*100)` ⇒ _jsRound (floor(x+0.5)); **pct-שלילי אפשרי**
//    (מגמת-ירידה) ולא-נבלע — לכן _jsRound חובה (Dart.round שונה בקצה-.5 של שליליים).
//  • הפלט Map בסדר: dir → pct.
int _jsRound(num x) => (x + 0.5).floor();

/// Trend {dir, pct} — newer half vs. older half. Verbatim port of intel-trend-from-scan.mjs.
Map<String, dynamic> trendFromScan(Map<String, dynamic> scan) {
  final mo = scan['monthly'] as List;
  final n = mo.length;
  final h = n ~/ 2;
  num older = 0, newer = 0;
  for (var i = 0; i < h; i++) older += mo[i] as num;
  for (var i = n - h; i < n; i++) newer += mo[i] as num;
  if (older == 0 && newer == 0) return {'dir': 'flat', 'pct': 0};
  final int pct = older == 0 ? 100 : _jsRound(((newer - older) / older) * 100);
  final String dir = pct > 8
      ? 'up'
      : pct < -8
          ? 'down'
          : 'flat';
  return {'dir': dir, 'pct': pct};
}

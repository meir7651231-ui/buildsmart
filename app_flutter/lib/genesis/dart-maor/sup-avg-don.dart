// ⚛️ אטום-Dart (דרגת-חוזה) · supAvgDon — ממוצע-לתרומה על-פני רשימת-תורמים.
// מוצא: maor/src/components/supporters/lib.ts:191-197 · המקור: new/atoms/sup-avg-don.mjs —
//   export function supAvgDon(supporters, rate = 3.7, supTotalIls, supCount) {
//     const totIls = supporters.reduce((a, x) => a + supTotalIls(x, rate), 0);
//     const totCnt = supporters.reduce((a, x) => a + supCount(x), 0);
//     return totCnt ? Math.round(totIls / totCnt) : null;
//   }
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט.
//
// תפקיד: ‏Σ שווי-בש"ח (דרך השקע supTotalIls, דולר לפי rate) ÷ ‏Σ מספר-תרומות
//        (דרך השקע supCount), מעוגל Math.round; אין אף תרומה (המונה falsy) ⇒ null.
// שקעים (חוק-1 — קריאה-לשכן הוזרקה כפרמטר, אפס-import של אטום אחר):
//   • supTotalIls(sp, rate) ⇒ number — שווי-תורם כולל בש"ח.
//   • supCount(sp) ⇒ number — מספר-תרומות של תורם.
//
// הערות-המרה (מקור→Dart):
//   • ברירת-מחדל rate=3.7 — פרמטר-אופציונלי; העברת undefined ב-JS ⇒ אי-העברה בדארט.
//   • החשבון כולו ב-double (מספרי-JS הם double) — הצטברות, חילוק ועיגול זהי-ביט.
//   • Math.round של JS = חצי-כלפי-מעלה (לכיוון ‎+∞‎: ‏round(-2.5)=-2), שונה מ-
//     ‏num.round() של Dart (חצי-הרחק-מאפס: ‎-3‎) ⇒ עוזר מקומי _jsMathRound נאמן-ספק.
//   • 🔧 תיקון-הסגר (FIXES.md): ‏Math.round(-0.4) ⇒ ‏−0 ב-JS (שימור-סימן). הענף
//     ‏f+1 עם f=−1.0 נותן ‏+0.0 ב-IEEE ⇒ אובדן-סימן. גידור מפורש לטווח ‏[-0.5,0) ⇒ ‏-0.0.
//   • truthiness (חוק-7): ‏totCnt ⇒ falsy כש-0/-0/NaN — תנאי מפורש _numFalsy.

/// JS-faithful Math.round: nearest integer, halves toward +Infinity,
/// preserving the negative-zero result for x in [-0.5, 0).
/// (Dart's num.round() rounds halves away from zero and never yields -0.)
double _jsMathRound(num x) {
  final v = x.toDouble();
  if (v.isNaN || v.isInfinite || v == 0) return v; // NaN/±Inf/±0 עוברים כמו-שהם
  // 🔧 טווח שבו JS מחזיר ‎-0‎: כל ‏x ב-[-0.5,0) מתעגל ל-‏-0 (שימור-סימן).
  if (v < 0 && v >= -0.5) return -0.0;
  final f = v.floorToDouble();
  final frac = v - f;
  return frac < 0.5 ? f : f + 1; // בדיוק 0.5 ⇒ מעלה (לכיוון +∞), כמו-JS
}

/// JS falsiness for a numeric total: 0, -0 or NaN are falsy.
bool _numFalsy(double v) => v == 0 || v.isNaN;

/// ממוצע-לתרומה: ‏Σ‏supTotalIls ÷ ‏Σ‏supCount, מעוגל; המונה falsy ⇒ null.
/// Verbatim behaviour of the JS source `supAvgDon`.
dynamic supAvgDon(dynamic supporters, dynamic supTotalIls, dynamic supCount,
    [dynamic rate = 3.7]) {
  var totIls = 0.0;
  for (final x in (supporters as Iterable)) {
    totIls += (supTotalIls(x, rate) as num).toDouble();
  }
  var totCnt = 0.0;
  for (final x in supporters) {
    totCnt += (supCount(x) as num).toDouble();
  }
  return _numFalsy(totCnt) ? null : _jsMathRound(totIls / totCnt);
}

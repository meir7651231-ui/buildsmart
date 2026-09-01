// ⚛️ אטום-Dart (דרגת-חוזה) · round2 — עיגול כסף לשתי ספרות.
// מוצא: maor/src/components/reports/lib.ts (round2; חוק-4 — התנהגות זהה למקור-ה-JS).
//        המקור: new/atoms/round2.mjs —
//        `export const round2 = (x) => Math.round(x * 100) / 100;`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט), אפס שקעים.
//
// תפקיד: עיגול לשתי ספרות אחרי הנקודה — סכומי כסף מצטברים כ-float וזולגים
//        (0.1+0.2). כולל התנהגות-הקצה הצפה של המימוש: 2.675⇒2.68
//        (כי ‎2.675*100 == 267.50000000000003 ב-IEEE-754, זהה ב-JS וב-Dart).
//
// הערות-המרה (מקור→Dart):
//  • `Math.round` של JS מעגל חצי כלפי +∞ (‏Math.round(-2.5) == -2); ‏`.round()`
//    של Dart מעגל חצי הרחק-מאפס (‏(-2.5).round() == -3) ⇒ אסור. משוקף ידנית
//    ב-`_jsMathRound` דרך floor+שארית — כולל קצה-הספק: ‏Math.round(0.49999999999999994)
//    הוא 0 לפי הספק (לא floor(x+0.5) שהיה מחזיר 1 בגלל אובדן-דיוק בחיבור).
//  • NaN⇒NaN, ‏±∞ נשמרים (Dart ‏.round() עליהם זורק — עוד סיבה לשיקוף הידני).
//  • ‏JS מחזיר ‎-0 לקלט שלילי-זעיר (‏Math.round(-0.3) === -0); משוקף (‎-0.0).
//  • קלט int של Dart מקודם ל-double לפני הכפל — ב-JS כל מספר הוא double ממילא;
//    הכפל, ה-floor והחילוק ב-100 הם IEEE-754 זהי-ביט בשתי השפות.

/// Money rounding to two decimals — verbatim behaviour of the JS source
/// new/atoms/round2.mjs: `Math.round(x * 100) / 100`, including the floating
/// edge (2.675 ⇒ 2.68) and JS half-toward-+∞ rounding.
dynamic round2(dynamic x) => _jsMathRound((x as num).toDouble() * 100) / 100;

/// שיקוף מדויק של ‏ECMAScript `Math.round`: חצי כלפי +∞; ‏NaN/±∞ עוברים
/// כמו-שהם; ‏שארית<0.5 ⇒ floor (גם 0.49999999999999994⇒0); תוצאה 0 מקלט
/// שלילי ⇒ ‎-0.0 (כמו JS).
double _jsMathRound(double v) {
  if (v.isNaN || v.isInfinite) return v;
  final f = v.floorToDouble();
  // ‎v-f מדויק ב-IEEE-754: קלט לא-שלם ⇒ |v| < 2^52 ⇒ אין אובדן-דיוק.
  final r = (v - f) >= 0.5 ? f + 1 : f;
  return (r == 0 && v < 0) ? -0.0 : r;
}

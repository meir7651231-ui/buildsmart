// ⚛️ אטום-Dart (דרגת-חוזה) · stepScale — צעד-זום אחד למעלה/למטה, עיגול-לעשירית
// מוצא: maor/src/lib/a11y.ts:44-48 (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/step-scale.mjs —
//        `return clampScale(Math.round((clampScale(v) + dir * step) * 10) / 10);`
// טוהר: פונקציית top-level עצמאית, אפס-import של אטום אחר (חוק-1) — השכן clampScale
//        והקבוע SCALE_STEP=0.1 הם שקעי-פרמטר, כמו במקור.
//
// תפקיד: צעד-זום בסולם-הגופן של ה-FAB ♿ — הצמדה-כפולה (קלט מוצמד לפני הצעד,
//        תוצאה מוצמדת אחריו) + עיגול לעשירית כמו בלגאסי נגד שאריות float
//        (1.1+0.1=1.2000000000000002 ⇒ 1.2 בדיוק).
// שקעים (חוק-1): clampScale(v) ⇒ מספר (נקרא פעמיים) · step — גודל-הצעד (ברירת-מחדל 0.1).
// קלט:  v — הזום הנוכחי · dir — ‏1 למעלה / ‏-1 למטה · השקע clampScale · step.
// פלט:  מספר — הזום החדש, מוצמד ומעוגל לעשירית.
//
// הערות-המרה (מקור→Dart):
//   • Math.round של JS ≠ ‏.round() של Dart (חצי-לכיוון-+∞ מול חצי-מהאפס-והלאה:
//     ‏JS round(-1.5)=-1, ‏Dart (-1.5).round()=-2) ⇒ עוזר _jsRound נאמן-ספק:
//     floor + השוואת-שארית (לא floor(x+0.5) — נכשל על 0.49999999999999994!),
//     ‏NaN/±∞/שלם ⇒ כמות-שהם, תוצאת-0 מקלט-שלילי ⇒ ‎-0.0 (‏Math.round(-0.3) === -0).
//   • חוק-15 (קוארציית-ארגומנט): ‏dir/step עוברים ToNumber-שקול (_toNum) —
//     ‏null-שהועבר-מפורשות ⇒ 0 (ב-JS ברירת-המחדל נדלקת רק על undefined; null*0.1=0),
//     מחרוזת ⇒ ‏StringNumericLiteral (ריק/רווחים ⇒ 0, hex/oct/bin, Infinity), בוליאני ⇒ 0/1.
//   • חוק-16: ה-trim בתוך _toNum הוא קבוצת-הרווחים של ECMAScript (בלי U+0085/U+180E).
//   • תוצאת-השקע clampScale מוזנת לאריתמטיקה כמות-שהיא (החוזה מתחייב שהשקע מחזיר מספר;
//     דוגמאות-החוזה כולן בתוך ההתחייבות הזו).
//   • כל האריתמטיקה (+ · * · /) על double = ‏IEEE-754 זהה ל-JS — אין סטייה.

/// One zoom step up/down with the legacy round-to-tenth. Verbatim behaviour of
/// the JS source new/atoms/step-scale.mjs (double-clamp + Math.round(x*10)/10).
dynamic stepScale(dynamic v, dynamic dir, dynamic clampScale,
    [dynamic step = 0.1]) {
  final double d = _toNum(dir);
  final double s = _toNum(step);
  return clampScale(_jsRound((clampScale(v) + d * s) * 10) / 10);
}

// — עוזרים מקומיים (קידומת _, חוק-1: בלי import של אטום אחר) —

/// Math.round של JS: הקרוב-ביותר, תיקו ⇒ לכיוון ‎+∞; ‏NaN/±∞/שלם ⇒ כמות-שהם.
double _jsRound(num x) {
  final double d = x.toDouble();
  if (d.isNaN || d.isInfinite || d == d.floorToDouble()) return d;
  final double f = d.floorToDouble();
  // ‏d-f מדויק ב-IEEE (שני הערכים ייצוגיים והשארית ייצוגית) — אין floor(x+0.5)!
  final double r = (d - f >= 0.5) ? f + 1 : f;
  // ‏JS: תוצאת-אפס מקלט-שלילי היא ‎-0 (Math.round(-0.3) === -0).
  if (r == 0 && d < 0) return -0.0;
  return r;
}

/// ToNumber-שקול של JS לארגומנטים (חוק-15): null⇒0, בוליאני⇒0/1, מחרוזת⇒פרסור-ES.
double _toNum(dynamic x) {
  if (x == null) return 0.0;
  if (x is num) return x.toDouble();
  if (x is bool) return x ? 1.0 : 0.0;
  if (x is String) {
    final s = _jsTrim(x);
    if (s.isEmpty) return 0.0;
    if (s.length > 2 && s[0] == '0') {
      final c = s[1];
      if (c == 'x' || c == 'X') {
        return int.tryParse(s.substring(2), radix: 16)?.toDouble() ??
            double.nan;
      }
      if (c == 'o' || c == 'O') {
        return int.tryParse(s.substring(2), radix: 8)?.toDouble() ?? double.nan;
      }
      if (c == 'b' || c == 'B') {
        return int.tryParse(s.substring(2), radix: 2)?.toDouble() ?? double.nan;
      }
    }
    if (s == 'Infinity' || s == '+Infinity') return double.infinity;
    if (s == '-Infinity') return double.negativeInfinity;
    return double.tryParse(s) ?? double.nan;
  }
  return double.nan; // אובייקט/פונקציה ⇒ NaN (בלי valueOf — אין כזה ב-Dart)
}

/// קבוצת-הרווחים של ECMAScript (חוק-16) — TAB/LF/VT/FF/CR/SP/NBSP/Zs/LS/PS/BOM,
/// בלי U+0085 (NEL) ו-U+180E שה-trim של Dart גוזם.
const String _esWs = '\u0009\u000A\u000B\u000C\u000D\u0020\u00A0\u1680'
    '\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A'
    '\u2028\u2029\u202F\u205F\u3000\uFEFF';

String _jsTrim(String s) {
  var start = 0;
  var end = s.length;
  while (start < end && _esWs.contains(s[start])) {
    start++;
  }
  while (end > start && _esWs.contains(s[end - 1])) {
    end--;
  }
  return s.substring(start, end);
}

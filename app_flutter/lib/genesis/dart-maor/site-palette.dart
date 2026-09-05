// ⚛️ אטום-Dart (דרגת-חוזה) · sitePalette — גוזר משפחת-פלטה מלאה לאתר-הציבורי
//    מצבע-הדגשה (accent): הגוון נשמר; רוויה+בהירות מכווננות לבהיר/בינוני/עמוק
//    + מילת-הדגשה + דיו + קרקעות בהירות-גוון. אין accent/לא-תקין ⇒ פלטת-הנפילה
//    המוזרקת (ביט-זהה — אותה הפניה).
// מוצא: maor/src/lib/publicSite.ts:121-152 · המקור: new/atoms/site-palette.mjs.
//        חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
// טוהר: פונקציה top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core).
//        העזרים הפרטיים של קובץ-המקור (hexToRgb/rgbToHsl/hslToRgb/toHex/rgbStr —
//        לא-מיוצאים במקור) הוטמעו כעוזרים מקומיים בקידומת _ (לא שקעים, לפי החוזה).
// שקעים: fallbackPalette — פלטת-הנפילה (במקור: CORAL_PALETTE, האטום השכן
//        coral-palette) הוזרקה כפרמטר-נתונים (חוק-1 — אפס import פנימי).
//
// הערות-המרה (מקור→Dart):
//  • truthiness (כלל-7): JS `accent && accent.trim()` — accent ריק/undefined או
//    trim ריק ⇒ falsy. ב-Dart: תנאי-מפורש null/isEmpty. מחרוזת ריקה נופלת באותו
//    ענף בשתי השפות (trim('') ריק).
//  • Math.round של JS = חצי-כלפי-+∞ (Math.round(-0.5)=-0, Math.round(2.5)=3),
//    ושומר את קצה-הספק 0.49999999999999994⇒0 (floor(x+0.5) היה נותן 1!).
//    ‏Dart .round() = חצי-הרחק-מאפס ⇒ עוזר _jsRound נאמן-ספק (floor + השוואת-שארית).
//  • ‏% על doubles חיוביים: JS remainder ≡ Dart % ≡ fmod — זהה-ביט בטווחי h∈[0,360)
//    ו-(h/60)%2 (כלל-9 רלוונטי רק לשלילי; h כאן לעולם אי-שלילי לפני הנרמול,
//    והנרמול ((h%360)+360)%360 ממילא נותן אותו ערך בשתי השפות לכל h סופי).
//  • ‏toString(16) של JS = אותיות-קטנות ≡ toRadixString(16) של Dart; ‏padStart ≡ padLeft.
//  • ‏parseInt(h,16) על 6 ספרות-hex שעברו regex ⇒ int.parse(radix:16) — אין מסלול-NaN.
//  • סדר-מפתחות המפה = סדר-הליטרל של המקור (Dart map literal = insertion-order) —
//    קריטי לסריאליזציה תלוית-סדר (JSON.stringify) — כלל-14.
//  • אריתמטיקת-double: IEEE754 זהה בשתי השפות; אותן פעולות באותו סדר ⇒ אותם ביטים.

num _minN(num a, num b) => a < b ? a : b;
num _maxN(num a, num b) => a > b ? a : b;

/// Math.round של JS: הקרוב-ביותר, ספק ⇒ כלפי +אינסוף.
/// (‏0.49999999999999994⇒0 — לא floor(x+0.5); ‏-0.5⇒-0≡0.)
int _jsRound(num x) {
  final f = x.floorToDouble();
  final diff = x - f;
  if (diff < 0.5) return f.toInt();
  return f.toInt() + 1; // diff ≥ 0.5 — כולל ספק — כלפי מעלה (+∞)
}

/// hexToRgb של המקור: '#rgb'/'#rrggbb' (עם/בלי #, לא-רגיש-לרישיות, trim) ⇒
/// [r,g,b] או null על אי-התאמה.
List<int>? _hexToRgb(String hex) {
  final m = RegExp(r'^#?([0-9a-f]{3}|[0-9a-f]{6})$', caseSensitive: false)
      .firstMatch(hex.trim());
  if (m == null) return null;
  var h = m.group(1)!;
  if (h.length == 3) h = h[0] + h[0] + h[1] + h[1] + h[2] + h[2];
  final n = int.parse(h, radix: 16);
  return [(n >> 16) & 255, (n >> 8) & 255, n & 255];
}

/// rgbToHsl של המקור: [h∈[0,360), s∈[0,1], l∈[0,1]].
List<num> _rgbToHsl(num r, num g, num b) {
  r /= 255;
  g /= 255;
  b /= 255;
  final max = _maxN(_maxN(r, g), b), min = _minN(_minN(r, g), b), d = max - min;
  final l = (max + min) / 2;
  num h = 0, s = 0;
  if (d != 0) {
    // JS: if (d) — ‏d≥0 תמיד; falsy רק על 0
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    if (max == r) {
      h = ((g - b) / d + (g < b ? 6 : 0));
    } else if (max == g) {
      h = (b - r) / d + 2;
    } else {
      h = (r - g) / d + 4;
    }
    h *= 60;
  }
  return [h, s, l];
}

/// hslToRgb של המקור — כולל עיגול-JS על כל ערוץ.
List<int> _hslToRgb(num h, num s, num l) {
  h = ((h % 360) + 360) % 360;
  final c = (1 - (2 * l - 1).abs()) * s;
  final x = c * (1 - ((h / 60) % 2 - 1).abs());
  final m = l - c / 2;
  num r = 0, g = 0, b = 0;
  if (h < 60) {
    r = c;
    g = x;
    b = 0;
  } else if (h < 120) {
    r = x;
    g = c;
    b = 0;
  } else if (h < 180) {
    r = 0;
    g = c;
    b = x;
  } else if (h < 240) {
    r = 0;
    g = x;
    b = c;
  } else if (h < 300) {
    r = x;
    g = 0;
    b = c;
  } else {
    r = c;
    g = 0;
    b = x;
  }
  return [
    _jsRound((r + m) * 255),
    _jsRound((g + m) * 255),
    _jsRound((b + m) * 255),
  ];
}

/// toHex של המקור: '#'+שלושה זוגות hex קטנים, כל ערוץ נכלא ל-0..255.
String _toHex(List<int> rgb) {
  return '#' +
      rgb
          .map((v) =>
              _maxN(0, _minN(255, v)).toInt().toRadixString(16).padLeft(2, '0'))
          .join('');
}

/// rgbStr של המקור: "r,g,b".
String _rgbStr(List<int> rgb) => '${rgb[0]},${rgb[1]},${rgb[2]}';

/// גוזר משפחת-פלטה מלאה (12 שדות) מצבע-הדגשה; אין accent / ריק-רווחים /
/// hex לא-תקין ⇒ fallbackPalette כמות-שהוא (אותה הפניה — ביט-זהה).
/// פורט-verbatim של sitePalette מ-new/atoms/site-palette.mjs.
dynamic sitePalette(dynamic accent, dynamic fallbackPalette) {
  // JS: accent && accent.trim() ? hexToRgb(accent) : null (כלל-7 — truthiness)
  final base = (accent != null && (accent as String).trim().isNotEmpty)
      ? _hexToRgb(accent)
      : null;
  if (base == null) return fallbackPalette;
  final hsl = _rgbToHsl(base[0], base[1], base[2]);
  final num h = hsl[0], s0 = hsl[1];
  final s = _maxN(0.42, _minN(0.86, s0));
  List<int> mk(num sat, num l) => _hslToRgb(h, sat, l);
  final c1 = mk(_minN(0.8, s * 0.92), 0.75);
  final c2 = mk(s, 0.62);
  final c3 = mk(_minN(0.9, s * 1.04), 0.47);
  final word = mk(s, 0.67);
  final ink = mk(0.18, 0.16);
  return {
    'c1': _toHex(c1),
    'c2': _toHex(c2),
    'c3': _toHex(c3),
    'word': _toHex(word),
    'ink': _toHex(ink),
    'paper': _toHex(mk(0.4, 0.986)),
    'cream': _toHex(mk(0.46, 0.955)),
    'blush': _toHex(mk(0.62, 0.965)),
    'marquee': _toHex(mk(0.5, 0.9)),
    'rgb1': _rgbStr(c1),
    'rgb2': _rgbStr(c2),
    'inkRgb': _rgbStr(ink),
  };
}

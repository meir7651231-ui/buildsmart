// ⚛️ אטום-Dart (דרגת-חוזה) · spotlightBox — חלון-ה-spotlight של הסיור סביב מלבן-אלמנט.
// מוצא: maor/src/lib/tour.ts:98-108 (מנוע הסיור/מדריך — CONNECT).
//        המקור: new/atoms/spotlight-box.mjs · חוזה: new/atoms/spotlight-box.contract.md
// טוהר: גאומטריה טהורה — אפס שקעים, אפס DOM (המלבן מוזרק כנתון, חוק-1);
//        פונקציות top-level עצמאיות, אפס import (עוזרים מקומיים בקידומת _).
//
// תפקיד: חישוב מלבן-ה"חור" של סיור-ההדרכה סביב אלמנט: ריפוד קבוע (ברירת-מחדל 10px)
//        סביב המלבן, left/top נצמדים ל-0, width/height נחתכים לגבול ה-viewport.
//        מלבן חסר (falsy) או במידות ≤0 ⇒ null (אין חור).
// קלט:  rect ({left,top,width,height} או null) · vw,vh (מידות viewport) · pad (רשות, 10).
// פלט:  Map {'left','top','width','height'} (בסדר-מפתחות זה) או null.
//
// הערות-המרה (חוק-4 — התנהגות זהה-ביט ל-JS):
// • `!rect` = בדיקת-falsy של JS (null/false/0/-0/NaN/'') — עוזר _falsy (חוק-7);
//   הגנה לפני כל גישת-שדה (short-circuit כמו במקור: rect=null לא נוגע ב-.width).
// • מפתח-חסר ≠ null (חוק-2): גישת-שדה דרך _prop עם containsKey — מפתח-חסר ⇒ undefined
//   (זקיף _Undef) ⇒ NaN באריתמטיקה; null-מפורש ⇒ ToNumber(null)=0. גישת-שדה על
//   לא-אובייקט truthy (מספר/מחרוזת) ⇒ undefined, לא זריקה (דוק-טייפינג, חוק-15).
// • `rect.width + pad*2` = אופרטור `+` של JS: אגף-מחרוזת ⇒ שרשור (_jsAdd + _jsStr
//   לפי חוק-12); `-`/`*` תמיד מספריים דרך _toNum (ToNumber: null⇒0, undefined⇒NaN,
//   bool⇒0/1, מחרוזת ⇒ trim-ECMAScript לפי חוק-16 + פרסור; ''⇒0; כישלון ⇒ NaN).
// • Math.max/Math.min של JS: NaN באחד-האגפים ⇒ NaN; ‏+0 גובר ב-max, ‏-0 גובר ב-min —
//   עוזרים _jsMax/_jsMin (לא math.max/min של Dart).

/// undefined-של-JS: זקיף למפתח-חסר (חוק-2 — מובחן מ-null-מפורש).
class _Undef {
  const _Undef();
}

const _undef = _Undef();

/// בדיקת-falsy של JS (חוק-7): null/undefined/false/0/-0/NaN/'' ⇒ true.
bool _falsy(dynamic v) {
  if (v == null || v is _Undef) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false; // אובייקטים (Map/List/...) תמיד truthy ב-JS.
}

/// גישת-שדה נאמנת-JS (חוק-2/15): Map עם המפתח ⇒ הערך (גם null-מפורש);
/// מפתח-חסר או מקבל שאינו Map ⇒ undefined (לא זריקה).
dynamic _prop(dynamic obj, String key) {
  if (obj is Map) return obj.containsKey(key) ? obj[key] : _undef;
  return _undef;
}

/// קבוצת-הרווחים של ECMAScript (חוק-16): TAB/LF/VT/FF/CR/SP/NBSP/BOM/Zs/LS/PS —
/// בלי U+0085 (NEL) ו-U+180E שאותם Dart trim כן גוזם.
const _esWs = '\t\n\x0B\f\r \u00A0\uFEFF\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000\u2028\u2029';

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

/// ToNumber של JS (חוק-10/15/16): num ⇒ עצמו · null ⇒ 0 · undefined ⇒ NaN ·
/// bool ⇒ 1/0 · מחרוזת ⇒ trim-ES ואז פרסור ('' ⇒ 0, Infinity, hex; כישלון ⇒ NaN,
/// לעולם לא זריקה) · אחר ⇒ NaN.
num _toNum(dynamic v) {
  if (v is num) return v;
  if (v == null) return 0;
  if (v is _Undef) return double.nan;
  if (v is bool) return v ? 1 : 0;
  if (v is String) {
    final t = _jsTrim(v);
    if (t.isEmpty) return 0;
    if (t == 'Infinity' || t == '+Infinity') return double.infinity;
    if (t == '-Infinity') return double.negativeInfinity;
    final hex = RegExp(r'^0[xX][0-9a-fA-F]+$');
    if (hex.hasMatch(t)) return int.parse(t.substring(2), radix: 16);
    return num.tryParse(t) ?? double.nan;
  }
  return double.nan;
}

/// המרת-מספר-למחרוזת של JS (חוק-12 — shortest-round-trip):
/// שלם-בטוח (|v|<2^53) ⇒ עשרוני בלי ".0"; ‏2^53–1e21 ⇒ פריסת המדעי-של-Dart
/// לעשרוני מרופד-אפסים; ‏≥1e21 ⇒ הכתיב-המעריכי של Dart (זהה ל-JS).
String _jsNumStr(num v) {
  if (v is int) return v.toString();
  final d = v as double;
  if (d.isNaN) return 'NaN';
  if (d.isInfinite) return d > 0 ? 'Infinity' : '-Infinity';
  const maxSafe = 9007199254740992.0; // 2^53
  if (d == d.truncateToDouble() && d.abs() < maxSafe) {
    return d.truncate().toString(); // גם -0.0 ⇒ "0" כמו JS.
  }
  final s = d.toString();
  final e = s.indexOf('e');
  if (e < 0 || d.abs() >= 1e21) return s; // עשרוני-רגיל, או מעריכי כמו-JS.
  // 2^53 ≤ |v| < 1e21 שנדפס מדעית ⇒ פריסה מרופדת-אפסים.
  final neg = s.startsWith('-');
  final mant = s.substring(neg ? 1 : 0, e);
  final exp = int.parse(s.substring(e + 1));
  final dot = mant.indexOf('.');
  final digits = dot < 0 ? mant : mant.replaceFirst('.', '');
  final intLen = (dot < 0 ? mant.length : dot) + exp;
  final padded = digits.padRight(intLen, '0');
  return (neg ? '-' : '') + padded;
}

/// ToString של JS לצורך שרשור-`+` (חוק-12).
String _jsStr(dynamic v) {
  if (v is String) return v;
  if (v is num) return _jsNumStr(v);
  if (v == null) return 'null';
  if (v is _Undef) return 'undefined';
  if (v is bool) return v ? 'true' : 'false';
  return v.toString();
}

/// אופרטור `+` של JS: אגף-מחרוזת ⇒ שרשור; אחרת חיבור-מספרי (ToNumber).
dynamic _jsAdd(dynamic a, dynamic b) {
  if (a is String || b is String) return _jsStr(a) + _jsStr(b);
  return _toNum(a) + _toNum(b);
}

/// Math.max של JS: NaN באחד ⇒ NaN; ‏+0 גובר על ‎-0.
num _jsMax(num a, num b) {
  if (a.isNaN || b.isNaN) return double.nan;
  if (a == 0 && b == 0) {
    final aNegZero = a is double && a.isNegative;
    return aNegZero ? b : a;
  }
  return a > b ? a : b;
}

/// Math.min של JS: NaN באחד ⇒ NaN; ‏-0 גובר על ‎+0.
num _jsMin(num a, num b) {
  if (a.isNaN || b.isNaN) return double.nan;
  if (a == 0 && b == 0) {
    final aNegZero = a is double && a.isNegative;
    return aNegZero ? a : b;
  }
  return a < b ? a : b;
}

/// חלון-ה-spotlight של הסיור סביב מלבן-אלמנט — התנהגות verbatim של
/// new/atoms/spotlight-box.mjs (חוק-4). מלבן falsy או במידות ≤0 ⇒ null;
/// אחרת ריפוד pad סביב, הצמדת left/top ל-0 וחיתוך width/height ל-viewport.
dynamic spotlightBox(dynamic rect, dynamic vw, dynamic vh, [dynamic pad = 10]) {
  // if (!rect || rect.width <= 0 || rect.height <= 0) return null;
  // short-circuit כמו-JS: rect falsy ⇒ אין גישת-שדה כלל.
  if (_falsy(rect)) return null;
  final w = _toNum(_prop(rect, 'width'));
  final h = _toNum(_prop(rect, 'height'));
  // השוואת `<= 0` של JS: ‏NaN ⇒ false (מפתח-חסר לא מפיל ל-null — ממשיך ל-NaN בגוף).
  if ((!w.isNaN && w <= 0) || (!h.isNaN && h <= 0)) return null;

  final padN = _toNum(pad);
  final left = _jsMax(0, _toNum(_prop(rect, 'left')) - padN); // Math.max(0, rect.left - pad)
  final top = _jsMax(0, _toNum(_prop(rect, 'top')) - padN); // Math.max(0, rect.top - pad)
  return {
    'left': left,
    'top': top,
    // Math.min(vw - left, rect.width + pad * 2) — ‏`+` בסמנטיקת-JS (שרשור על מחרוזת),
    // ‏Math.min מקרץ את אגפיו ב-ToNumber.
    'width': _jsMin(_toNum(vw) - left, _toNum(_jsAdd(_prop(rect, 'width'), padN * 2))),
    'height': _jsMin(_toNum(vh) - top, _toNum(_jsAdd(_prop(rect, 'height'), padN * 2))),
  };
}

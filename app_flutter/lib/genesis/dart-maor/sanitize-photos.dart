// ⚛️ אטום-Dart (דרגת-חוזה) · sanitizePhotos — שער-חיטוי לגלריית-תמונות.
// מוצא: maor/src/lib/photoGallery.ts:38-41 · המקור: new/atoms/sanitize-photos.mjs.
// טוהר: פונקציה top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core).
// חוק-1: אטום לא-מייבא — עוזרי js-compat הוזרקו INLINE עם קידומת _.
// חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: סינון מערך מתקבל-מבחוץ לתמונות-data תקינות מתחת לתקרת-משקל,
//         עד תקרת-כמות. לא-מערך ⇒ []. הסדר נשמר; מוחזר מערך חדש (לא-משנה-מקור).
// שקעים: isDataImage (חובה) · photoMaxLen (460000) · photoMax (5).
//
// ⚠️ תיקון-הסגר (כלל-15 · קוארציית-ארגומנטים של slice/השוואה, FIXES.md:87):
//  • photoMax="3": JS ToIntegerOrInfinity("3")=3 ⇒ חיתוך-ל-3; הפורט-השבור
//    מיפה לא-num ל-0 ⇒ []. התיקון: _jsNum (ToNumber) על ארגומנט-ה-slice.
//  • photoMaxLen="6": השוואת-JS `len <= "6"` מקוארצת ל-6; הפורט-השבור
//    `photoMaxLen is num ? … : false` ⇒ false. התיקון: _jsNum על שני האגפים.
//  • {length:5}: JS קורא x.length=5 על אובייקט; הפורט-השבור החזיר null ⇒ false.
//    התיקון: _lenOf דוק-טייפינג — Map בעל מפתח 'length' מחזיר את ערכו.
//  • raw=[null] כש-isDataImage אמת: JS זורק (null.length); הפורט-השבור שקט.
//    התיקון: _lenOf זורק על null — זריקה-נאמנה.

/// חוק-7 · truthiness של JS: ''/0/-0/NaN/null/false כוזבים; השאר אמת.
bool _jsTruthy(dynamic v) {
  if (v == null || v == false) return false;
  if (v == true) return true;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// חוק-16 · קבוצת-הרווחים של ECMAScript (trim).
const Set<int> _esWs = {
  0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x20, 0xA0, 0x1680,
  0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007,
  0x2008, 0x2009, 0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000, 0xFEFF,
};

/// חוק-16 · trim נאמן-ES (String.prototype.trim). גוזם רק את _esWs.
String _jsTrim(String s) {
  var start = 0, end = s.length;
  while (start < end && _esWs.contains(s.codeUnitAt(start))) start++;
  while (end > start && _esWs.contains(s.codeUnitAt(end - 1))) end--;
  return s.substring(start, end);
}

double _fromRadix(String digits, int radix) {
  try {
    return BigInt.parse(digits, radix: radix).toDouble();
  } catch (_) {
    return double.nan;
  }
}

/// חוקים 10+18 · ToNumber של JS על מחרוזת (דקדוק-ES קפדני לפני פרסינג).
double _jsStrToNum(String raw) {
  final s = _jsTrim(raw);
  if (s.isEmpty) return 0.0; // Number('') === 0
  if (s == 'Infinity' || s == '+Infinity') return double.infinity;
  if (s == '-Infinity') return double.negativeInfinity;
  if (RegExp(r'^0[xX][0-9a-fA-F]+$').hasMatch(s)) return _fromRadix(s.substring(2), 16);
  if (RegExp(r'^0[oO][0-7]+$').hasMatch(s)) return _fromRadix(s.substring(2), 8);
  if (RegExp(r'^0[bB][01]+$').hasMatch(s)) return _fromRadix(s.substring(2), 2);
  if (!RegExp(r'^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$').hasMatch(s)) return double.nan;
  return double.tryParse(s) ?? double.nan;
}

/// חוק-10/17 · ToNumber כללי (כל טיפוס), במרחב-double של JS.
double _jsNum(dynamic v) {
  if (v == null) return double.nan; // null≡undefined בהקשר-מספר (Number(undefined)=NaN)
  if (v is bool) return v ? 1.0 : 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return _jsStrToNum(v);
  return double.nan;
}

/// סמן ל-`undefined` של JS — נקרא כשלערך אין מאפיין length (מספר/בוליאני/וכו').
final Object _undef = Object();

/// עוזר: קריאת `.length` בסגנון-JS. String/List ⇒ אורך; Map בעל 'length' ⇒
/// ערכו (JS קורא את המאפיין); null ⇒ זריקה נאמנה (JS: Cannot read of null);
/// כל השאר ⇒ _undef (JS: undefined ⇒ בהשוואה מקוארץ ל-NaN ⇒ false).
dynamic _lenOf(dynamic x) {
  if (x == null) {
    throw StateError("TypeError: Cannot read properties of null (reading 'length')");
  }
  if (x is String) return x.length;
  if (x is List) return x.length;
  if (x is Map && x.containsKey('length')) return x['length'];
  return _undef;
}

/// עוזר: Array.prototype.slice(0, end) של JS על רשימה — סלחן לגבולות.
/// end עובר ToIntegerOrInfinity: ToNumber ⇒ NaN⇒0, ±∞⇒קצה, שבר⇒חיתוך-לאפס.
List<dynamic> _jsSlice0(List<dynamic> list, dynamic end) {
  final len = list.length;
  final e = _jsNum(end);
  int ei;
  if (e.isNaN) {
    ei = 0;
  } else if (e == double.infinity) {
    ei = len;
  } else if (e == double.negativeInfinity) {
    ei = 0;
  } else {
    ei = e.truncate();
  }
  if (ei < 0) {
    ei = len + ei;
    if (ei < 0) ei = 0;
  }
  if (ei > len) ei = len;
  return list.sublist(0, ei);
}

/// Verbatim port of new/atoms/sanitize-photos.mjs (`sanitizePhotos`).
/// שער-חיטוי: רק פריטים שעוברים את שקע-האימות וגם length <= photoMaxLen,
/// חתוך ל-photoMax הראשונים. לא-מערך ⇒ [].
List<dynamic> sanitizePhotos(dynamic raw, dynamic isDataImage,
    [dynamic photoMaxLen = 460000, dynamic photoMax = 5]) {
  if (raw is! List) return [];
  final kept = raw.where((x) {
    if (!_jsTruthy(isDataImage(x))) return false; // && קצר-חשמלי כמו במקור
    final lv = _lenOf(x); // זורק על null; _undef לחסרי-length
    if (identical(lv, _undef)) return false; // JS: undefined <= n ⇒ false
    final ln = _jsNum(lv);
    final mx = _jsNum(photoMaxLen);
    if (ln.isNaN || mx.isNaN) return false; // JS: השוואה עם NaN ⇒ false
    return ln <= mx;
  }).toList();
  return _jsSlice0(kept, photoMax);
}

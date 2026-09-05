/// חוט · wa-app-link — קישור-אפליקציה whatsapp://send (הכרעת-בעלים 24.8 "שהקישור
/// יתבצע אצלי, לא דרך wa.me"): קריאה ישירה לאפליקציה דרך מערכת-ההפעלה, בלי דומיין
/// wa.me — עוקף חסימת-דומיין של סינון-כשר. בלי מספר תקין ⇒ null.
/// חוזה: wa-app-link.contract.md · שקעים: waDigits
/// מוצא: maor/src/lib/wa.ts · waAppLink (main 24-25.8; חוק-4 verbatim).
/// המרת-Dart מ-new/atoms/wa-app-link.mjs — התנהגות זהת-ביט ל-JS:
///  • ברירת-המחדל של JS ‏(text = '') היא פרמטר-אמצעי — ב-Dart אין ברירת-מחדל
///    אמצעית-פוזיציונלית; קורא שמשמיט מעביר '' (זהה-סמנטית: undefined⇒'').
///  • ‏`!digits` של JS ⇒ ‏_jsFalsy (חוק-7: null/'' כוזבים).
///  • ‏`text.trim()` ⇒ ‏_jsTrim (חוק-16: קבוצת-הרווחים של ES, בלי U+0085/U+180E).
///  • ‏`encodeURIComponent` ⇒ ‏Uri.encodeComponent (dart:core) — אותה קבוצת-תווים
///    בדיוק (ECMA-262: אלפאנומרי + ‎-_.!~*'()‎ לא-מקודדים, hex-רבתי, UTF-8).
/// אפס-import (dart:core בלבד).
String? waAppLink(dynamic phone, dynamic text, dynamic Function(dynamic) waDigits) {
  final digits = waDigits(phone);
  if (_jsFalsy(digits)) return null;
  final t = _jsTrim(text as String);
  return 'whatsapp://send?phone=' +
      (digits as String) +
      (_jsTruthy(t) ? '&text=' + Uri.encodeComponent(t) : '');
}

/// חוק-7 · truthiness של JS: ''/0/-0/NaN/null/false כוזבים; השאר אמת.
/// ‏(inline מ-machtzev/emit/js-compat-reference.dart — אטום לא מייבא, חוק-1.)
bool _jsTruthy(dynamic v) {
  if (v == null || v == false) return false;
  if (v == true) return true;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true; // אובייקט/מערך — תמיד אמת
}

bool _jsFalsy(dynamic v) => !_jsTruthy(v);

/// חוק-16 · קבוצת-הרווחים של ECMAScript (trim). **בלי** U+0085/U+180E
/// (ש-Dart.trim גוזם אך JS לא). כולל WhiteSpace + LineTerminator של ES.
const Set<int> _esWs = {
  0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x20, 0xA0, 0x1680,
  0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007,
  0x2008, 0x2009, 0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000, 0xFEFF,
};

/// חוק-16 · trim נאמן-ES (String.prototype.trim). גוזם רק את _esWs.
String _jsTrim(String s) {
  var start = 0, end = s.length;
  while (start < end && _esWs.contains(s.codeUnitAt(start))) {
    start++;
  }
  while (end > start && _esWs.contains(s.codeUnitAt(end - 1))) {
    end--;
  }
  return s.substring(start, end);
}

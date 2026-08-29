/// חוט · time-to-min — "HH:MM" לדקות-מחצות. חוזה: new/atoms/time-to-min.contract.md
/// הומר מ-new/atoms/time-to-min.mjs (חוק-4: זהה-ביט). טהור, אפס-import של אטום אחר.

/// ‏truthiness של JS (חוק 7): '' / 0 / -0 / NaN / null / false כוזבים.
bool _falsy(dynamic v) =>
    v == null || v == false || v == '' || (v is num && (v == 0 || v.isNaN));

/// ‏String(v) של JS — מספיק לקלטי האטום (מחרוזת/null/בוליאני/מספר).
String _jsString(dynamic v) {
  if (v is String) return v;
  if (v == null) return 'null';
  if (v is bool) return v ? 'true' : 'false';
  return v.toString();
}

/// קבוצת-הרווחים של ES ל-trim (חוק 16), כקודי-תווים:
/// TAB LF VT FF CR SP NBSP OGHAM 2000–200A LS PS NNBSP MMSP IDEO BOM.
/// ‏U+0085/U+180E אינם נגזמים (בניגוד ל-String.trim של Dart).
const Set<int> _esWsCodes = {
  0x0009, 0x000A, 0x000B, 0x000C, 0x000D, 0x0020, 0x00A0, 0x1680,
  0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007,
  0x2008, 0x2009, 0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000,
  0xFEFF,
};

String _jsTrim(String s) {
  var start = 0;
  var end = s.length;
  while (start < end && _esWsCodes.contains(s.codeUnitAt(start))) {
    start++;
  }
  while (end > start && _esWsCodes.contains(s.codeUnitAt(end - 1))) {
    end--;
  }
  return s.substring(start, end);
}

/// ‏"HH:MM" ⇒ דקות מחצות; כל סטייה מהתבנית ⇒ NaN.
/// ‏JS: ‏`String(t || '')` — קלט כוזב ⇒ '' (וממילא לא-מתאים לתבנית ⇒ NaN).
dynamic timeToMin(dynamic t) {
  final s = _jsTrim(_jsString(_falsy(t) ? '' : t));
  final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(s);
  if (m == null) return double.nan;
  // ‏`+m[1]` על ספרות-בלבד (הרגקס מבטיח) ⇒ פירוק-שלם מדויק, בטווח 0–1439.
  return int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);
}

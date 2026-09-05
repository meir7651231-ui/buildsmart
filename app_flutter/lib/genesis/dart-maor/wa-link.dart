/// חוט · wa-link — קישור wa.me לפתיחת-שיחה. חוזה: wa-link.contract.md · שקע: waDigits
/// הומר מ-new/atoms/wa-link.mjs (מקור: maor/src/lib/wa.ts:32-37).
/// חוק-1: אפס import של אטום אחר — waDigits מוזרק כפרמטר.
/// חוק-7 (תקציר): truthiness של JS ⇒ _falsy מפורש.
/// חוק-16 (תקציר): trim של JS = קבוצת-ES בלבד ⇒ _jsTrim (לא String.trim של Dart).
/// encodeURIComponent ⇒ Uri.encodeComponent (מוגדר ב-SDK כזהה ל-ECMA-262).

/// truthiness של JS: null / false / 0 / -0 / NaN / '' כוזבים; כל השאר אמת.
bool _falsy(dynamic v) {
  if (v == null || v == false) return true;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false;
}

/// קבוצת-הרווחים של ES (TrimString): WhiteSpace + LineTerminator.
/// כולל FEFF; לא כולל U+0085/U+180E (בניגוד ל-String.trim של Dart).
bool _esWhite(int c) {
  switch (c) {
    case 0x09:
    case 0x0A:
    case 0x0B:
    case 0x0C:
    case 0x0D:
    case 0x20:
    case 0xA0:
    case 0x1680:
    case 0x2028:
    case 0x2029:
    case 0x202F:
    case 0x205F:
    case 0x3000:
    case 0xFEFF:
      return true;
  }
  return c >= 0x2000 && c <= 0x200A;
}

/// trim נאמן-ל-JS על יחידות UTF-16.
String _jsTrim(String s) {
  var start = 0;
  var end = s.length;
  while (start < end && _esWhite(s.codeUnitAt(start))) start++;
  while (end > start && _esWhite(s.codeUnitAt(end - 1))) end--;
  return s.substring(start, end);
}

/// קישור wa.me: waDigits(phone) ⇒ ספרות-בינלאומי או null; null/ריק ⇒ null.
/// הטקסט נגזם (ES-trim); ריק ⇒ בלי ?text=, אחרת ?text= + קידוד-רכיב.
/// ‏text חובה בקריאה (ברירת-המחדל '' של JS = העברת '' מפורשת — אין
/// optional-אמצעי ב-Dart לפני פרמטר-השקע).
dynamic waLink(dynamic phone, dynamic text, dynamic waDigits) {
  final digits = waDigits(phone);
  if (_falsy(digits)) return null;
  final t = _jsTrim(((text) as String));
  return 'https://wa.me/' +
      ((digits) as String) +
      (_falsy(t) ? '' : '?text=' + Uri.encodeComponent(t));
}

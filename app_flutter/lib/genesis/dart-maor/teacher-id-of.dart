// חוט · teacher-id-of — מייל-מורה ⇒ teacherId ממפת roles.teachers (סלחני-רישיות), אחרת null.
// חוזה: new/atoms/teacher-id-of.contract.md · מקור-JS: new/atoms/teacher-id-of.mjs (חוק-4: זהה-ביט).
// מוצא: maor/src/lib/config.ts:660-666 (courses.teacherapp). אפס-import (dart-core בלבד).
// תיקון-הסגר (חוק-16 + חוק-13): ‏Dart .trim() גוזם U+0085/U+180E ש-JS לא, ו-.toLowerCase()
//   הפשוט מחמיץ İ/ς-סופית/צ'רוקי. הזרקנו INLINE את _jsTrim + _jsLower (העתק-מהספרייה,
//   קידומת _), כדי שנרמול-המיילים יהיה זהה-ביט ל-(email||'').trim().toLowerCase() של JS.
dynamic teacherIdOf(dynamic config, dynamic email) {
  final e = _jsLower(_jsTrim((email ?? '') as String));
  final roles = (config is Map) ? config['roles'] : null;
  final teachers = (roles is Map) ? roles['teachers'] : null;
  if (e.isEmpty || teachers == null) return null;
  for (final entry in (teachers as Map).entries) {
    if (_jsLower(_jsTrim(entry.key as String)) == e) return entry.value;
  }
  return null;
}

// ── עוזרים מוזרקים (INLINE, חוק-1: אטום לא-מייבא) ─────────────────────────────

/// חוק-16 · קבוצת-הרווחים של ECMAScript (trim). בלי U+0085/U+180E.
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

/// חוק-13 · toLowerCase נאמן-JS (מיפוי-מלא): İ⇒i+U+0307 · צ'רוקי-רבתי⇒קטנות · Σ-סופית⇒ς.
String _jsLower(String s) {
  final out = StringBuffer();
  final runes = s.runes.toList();
  for (var i = 0; i < runes.length; i++) {
    final c = runes[i];
    if (c == 0x0130) {
      out.writeCharCode(0x69); // i
      out.writeCharCode(0x0307); // combining dot above
    } else if (c >= 0x13A0 && c <= 0x13EF) {
      out.writeCharCode(c + 0x97D0); // Cherokee upper ⇒ lower
    } else if (c == 0x03A3) {
      final prevWord = i > 0 && _isCased(runes[i - 1]);
      final nextWord = i + 1 < runes.length && _isCased(runes[i + 1]);
      out.write(prevWord && !nextWord ? 'ς' : 'σ');
    } else {
      out.write(String.fromCharCode(c).toLowerCase());
    }
  }
  return out.toString();
}

/// עזר ל-Final_Sigma: האם התו "אות" (Cased) לצורך גבול-מילה.
bool _isCased(int c) {
  final s = String.fromCharCode(c);
  return s.toLowerCase() != s.toUpperCase();
}

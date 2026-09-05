/// 🔌 חוט · term-of — מונח-מותאם מהמילון: ‏cfg['terms'][key] אחרי trim אם אינו-ריק, אחרת fallback.
/// דריסה ריקה/רווחים-בלבד = "אין דריסה". הלב של ה-White-label (45 מונחים).
/// מוצא: new/atoms/term-of.mjs (זהה-ביט; חוק-16: trim בקבוצת-ES בלבד — לא Dart.trim).

/// חוק-16: קבוצת-הרווחים של ES (WhiteSpace + LineTerminator) — ‏U+0085/U+180E לא נגזמים.
bool _esTrimmable(int c) {
  switch (c) {
    case 0x09: // TAB
    case 0x0A: // LF
    case 0x0B: // VT
    case 0x0C: // FF
    case 0x0D: // CR
    case 0x20: // SPACE
    case 0xA0: // NBSP
    case 0x1680: // OGHAM SPACE MARK (Zs)
    case 0x2000:
    case 0x2001:
    case 0x2002:
    case 0x2003:
    case 0x2004:
    case 0x2005:
    case 0x2006:
    case 0x2007:
    case 0x2008:
    case 0x2009:
    case 0x200A: // Zs טווח
    case 0x2028: // LS
    case 0x2029: // PS
    case 0x202F: // NARROW NBSP (Zs)
    case 0x205F: // MEDIUM MATH SPACE (Zs)
    case 0x3000: // IDEOGRAPHIC SPACE (Zs)
    case 0xFEFF: // ZWNBSP/BOM
      return true;
  }
  return false;
}

String _esTrim(String s) {
  var start = 0;
  var end = s.length;
  while (start < end && _esTrimmable(s.codeUnitAt(start))) {
    start++;
  }
  while (end > start && _esTrimmable(s.codeUnitAt(end - 1))) {
    end--;
  }
  return s.substring(start, end);
}

dynamic termOf(dynamic cfg, dynamic key, dynamic fallback) {
  // ‏cfg.terms?.[key] — ‏terms חסר/לא-מפה ⇒ אין דריסה (אפס-זריקות, ערבות 3).
  final terms = (cfg is Map) ? cfg['terms'] : null;
  final v = (terms is Map) ? terms[key] : null;
  if (v is String) {
    final t = _esTrim(v);
    if (t.isNotEmpty) return t; // truthiness של מחרוזת ב-JS = לא-ריקה (חוק-7)
  }
  return fallback;
}

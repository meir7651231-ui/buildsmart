// ⚛️ אטום-Dart (דרגת-חוזה) · sortTeamMsgs — מיון הודעות-צוות לפי `at` עולה.
// מוצא: maor/src/lib/supportChat.ts:99-103 · המקור: new/atoms/sort-team-msgs.mjs —
//   `return [...msgs].sort((a, b) => (a.at < b.at ? -1 : a.at > b.at ? 1 : 0));`
// טוהר: פונקציות top-level עצמאיות, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט ל-JS.
//
// הערות-המרה (הנאמנות נקנתה בדם — ראה machtzev/emit/DART-PORTING-RULES.md):
// • חוק-1 (מיון-יציב): List.sort של Dart אינו יציב ⇒ decorate-sort-undecorate עם
//   אינדקס-מקורי כשובר-שוויון. חוזה-ה-Golden כולו תלוי ביציבות (ראו להלן).
// • ‏[...msgs] של JS: מחרוזת ⇒ פריסה ל-code points (זוג-פונדקאי נשאר תו אחד);
//   מערך ⇒ עותק-רדוד (אותן רפרנסים). אובייקט-רגיל אינו iterable ⇒ TypeError ⇒ StateError.
// • מפתח-המיון `a.at`: על אובייקט-הודעה = המאפיין at; מפתח-חסר = undefined (חוק-2:
//   containsKey, לא ==null — null-מפורש הוא ערך!). על מחרוזת/מערך = המתודה המובנית
//   ‎.at — וב-`<`/`>` פונקציה עוברת ToPrimitive⇒toString⇒"function at() { [native code] }"
//   (אומת מול V8) — לכן המפתח מיוצג כמחרוזת הזו בדיוק: כל התווים שווים זה-לזה
//   (⇒ יציבות ⇒ סדר-מקור, זה כל סוד ה-Golden), והשוואה מול מחרוזת-ערך נשמרת ביט.
// • השוואה רלציונית של JS: שתי מחרוזות ⇒ לקסיקוגרפי לפי יחידות-UTF-16 (compareTo של
//   Dart זהה); אחרת ToNumber על שני הצדדים; NaN בכל צד ⇒ שתי ההשוואות false ⇒ 0.
// • ‏ToNumber("…"): ‏trim בקבוצת-ES המדויקת (חוק-16 — בלי U+0085/U+180E), ""⇒0,
//   הקס/בינארי/אוקטלי, Infinity; num.parse לעולם לא ישירות (חוק-10 — tryParse⇒NaN).
// • ‏undefined (מפתח-חסר / .at על מספר/בוליאני) ⇒ NaN בהשוואה ⇒ תמיד 0 ⇒ נשאר במקום.
// • ‏a.at על null/undefined היה זורק TypeError ב-JS ⇒ StateError מקביל.

/// זקיף ל-undefined של JS (חוק-2: מובחן מ-null-מפורש שנשמר במפה).
const Object _undef = Object();

/// ‏String.prototype.at / Array.prototype.at תחת ToPrimitive של `<`/`>` ב-V8 —
/// זו המחרוזת המדויקת שהושוותה (אומת: node ⇒ "function at() { [native code] }").
const String _nativeAtFnStr = 'function at() { [native code] }';

/// קבוצת-הרווחים של ECMAScript ל-trim (חוק-16): TAB/LF/VT/FF/CR/SP/NBSP/BOM + Zs + LS/PS,
/// **בלי** U+0085 (NEL) ו-U+180E שאותם Dart גוזם ו-JS לא.
bool _isEsWhitespace(int c) {
  switch (c) {
    case 0x09: // TAB
    case 0x0A: // LF
    case 0x0B: // VT
    case 0x0C: // FF
    case 0x0D: // CR
    case 0x20: // SP
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
    case 0x200A: // Zs range
    case 0x2028: // LS
    case 0x2029: // PS
    case 0x202F: // NARROW NBSP (Zs)
    case 0x205F: // MEDIUM MATH SPACE (Zs)
    case 0x3000: // IDEOGRAPHIC SPACE (Zs)
    case 0xFEFF: // BOM
      return true;
  }
  return false;
}

/// ‏trim נאמן-ES (חוק-16).
String _jsTrim(String s) {
  var start = 0;
  var end = s.length;
  while (start < end && _isEsWhitespace(s.codeUnitAt(start))) {
    start++;
  }
  while (end > start && _isEsWhitespace(s.codeUnitAt(end - 1))) {
    end--;
  }
  return s.substring(start, end);
}

/// ‏ToNumber של JS על מחרוזת (חוק-10: tryParse, כשל ⇒ NaN; לעולם לא parse-זורק).
double _jsStringToNumber(String s) {
  final t = _jsTrim(s);
  if (t.isEmpty) return 0.0;
  if (t == 'Infinity' || t == '+Infinity') return double.infinity;
  if (t == '-Infinity') return double.negativeInfinity;
  if (t.length > 2 && t.codeUnitAt(0) == 0x30 /* '0' */) {
    final p = t.codeUnitAt(1);
    final digits = t.substring(2);
    if (p == 0x78 || p == 0x58) {
      final v = int.tryParse(digits, radix: 16); // 0x/0X
      return v == null ? double.nan : v.toDouble();
    }
    if (p == 0x6F || p == 0x4F) {
      final v = int.tryParse(digits, radix: 8); // 0o/0O
      return v == null ? double.nan : v.toDouble();
    }
    if (p == 0x62 || p == 0x42) {
      final v = int.tryParse(digits, radix: 2); // 0b/0B
      return v == null ? double.nan : v.toDouble();
    }
  }
  return double.tryParse(t) ?? double.nan;
}

/// ‏ToNumber של JS על מפתח-מיון פרימיטיבי.
double _jsToNumber(Object? v) {
  if (identical(v, _undef)) return double.nan; // undefined ⇒ NaN
  if (v == null) return 0.0; // null ⇒ +0
  if (v is bool) return v ? 1.0 : 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return _jsStringToNumber(v);
  return double.nan;
}

/// `a < b` הרלציוני של JS (על פרימיטיבים): מחרוזת-מול-מחרוזת ⇒ יחידות-UTF-16;
/// אחרת ToNumber; NaN ⇒ false.
bool _jsLt(Object? a, Object? b) {
  if (a is String && b is String) return a.compareTo(b) < 0;
  final x = _jsToNumber(a);
  final y = _jsToNumber(b);
  if (x.isNaN || y.isNaN) return false;
  return x < y;
}

/// `a > b` הרלציוני של JS (על פרימיטיבים).
bool _jsGt(Object? a, Object? b) {
  if (a is String && b is String) return a.compareTo(b) > 0;
  final x = _jsToNumber(a);
  final y = _jsToNumber(b);
  if (x.isNaN || y.isNaN) return false;
  return x > y;
}

/// גישת-JS ל-`x.at` על איבר-הרשימה.
Object? _atOf(Object? x) {
  if (x == null) {
    // ‏JS: TypeError — Cannot read properties of null/undefined (reading 'at').
    throw StateError("TypeError: Cannot read properties of null (reading 'at')");
  }
  if (x is Map) {
    // חוק-2: מפתח-חסר = undefined; null-מפורש = ערך (ToNumber⇒0).
    return x.containsKey('at') ? x['at'] : _undef;
  }
  if (x is String || x is List) {
    // המתודה המובנית ‎.at — תחת `<`/`>` היא toString-הפונקציה (אומת מול V8).
    return _nativeAtFnStr;
  }
  return _undef; // num/bool וכו' — אין מאפיין at ⇒ undefined
}

/// פריסת `[...msgs]` של JS: מחרוזת ⇒ code points; רשימה ⇒ עותק-רדוד; אחרת TypeError.
List<dynamic> _jsSpread(dynamic msgs) {
  if (msgs is String) {
    return [for (final r in msgs.runes) String.fromCharCode(r)];
  }
  if (msgs is List) {
    return List<dynamic>.of(msgs);
  }
  throw StateError('TypeError: msgs is not iterable');
}

/// מיון הודעות-צוות לפי `at` עולה — עותק חדש, המקור לא משתנה, מיון **יציב**
/// (חוק-1: decorate-sort-undecorate). התנהגות זהה-ביט ל-JS:
/// שוויון/undefined/מפתח-חסר ⇒ 0 ⇒ סדר-המקור נשמר; מחרוזת-קלט ⇒ פירוק לתווים
/// בסדר-המקור (מפתח-המיון לכל תו הוא אותה מתודת-at ⇒ הכול שווה ⇒ יציבות).
List<dynamic> sortTeamMsgs(dynamic msgs) {
  final copy = _jsSpread(msgs);
  final decorated = [
    for (var i = 0; i < copy.length; i++) [i, copy[i]],
  ];
  decorated.sort((pa, pb) {
    final ka = _atOf(pa[1]);
    final kb = _atOf(pb[1]);
    final c = _jsLt(ka, kb) ? -1 : (_jsGt(ka, kb) ? 1 : 0);
    if (c != 0) return c;
    return (pa[0] as int) - (pb[0] as int); // חוק-1: אינדקס-מקורי = יציבות
  });
  return [for (final p in decorated) p[1]];
}

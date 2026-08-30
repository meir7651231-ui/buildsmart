// ⚛️ אטום-Dart (דרגת-Golden) · supTier — תווית-דרגת-תומך לפי ציון.
// מוצא: maor/src/components/supporters/lib.ts:172-178 · המקור: new/atoms/sup-tier.mjs
// חוזה: new/atoms/sup-tier.contract.md — 12 הקלטות-Golden, זהה-ביט.
// טוהר: פונקציית top-level עצמאית, אפס import של אטום אחר; עוזרים מקומיים בקידומת _.
//
// הערות-המרה (חוק-4 — התנהגות זהת-ביט ל-JS):
// • כלל-15 (קוארציה בהשוואה) ⚠️ מרכזי כאן: ההקלטות מזינות מחרוזות! ‏JS `sc >= 800`
//   מקרץ דרך ToNumber — ‏"0501234567" ⇒ 501234567 ⇒ זהב; ‏"אבג" ⇒ NaN ⇒ כל
//   ההשוואות שקר ⇒ רדומה; ‏"" ⇒ 0 ⇒ רדומה. ‏Dart `>=` על dynamic היה זורק —
//   לכן ‏_jsGte עם ‏_jsToNum שקול-ToNumber ו-NaN⇒false.
// • כלל-16 (trim-ECMAScript): פרסור-מחרוזת גוזם רק את קבוצת-הרווחים של ES
//   ‏(בלי U+0085/U+180E) — ‏_jsTrim, לא ‏String.trim של Dart.
// • כלל-10 (פירוק-מספר): כשל-פרסור ⇒ NaN לוגי, לעולם לא זריקה. הפרסור מגודר-regex
//   בדקדוק StrNumericLiteral של ES (עשרוני/hex/binary/octal/Infinity; סימן אסור
//   על כתיבים לא-עשרוניים; ‏"1."/".5" תקינים כמו ב-JS) — לא סומכים על גחמות
//   ‏num.tryParse של Dart.
// • כלל-2 (null מול undefined): ל-null-של-Dart ניתן label יחיד — ב-JS ‏null⇒0
//   ו-undefined⇒NaN, אבל שניהם < 400 ⇒ אותה תוצאה ('רדומה') בכל הספים.
//   אין הבחנה נצפית ⇒ אין סטייה.
// • כלל-12 (String(num)): נדרש רק בקוארציית-מערך (join של ToPrimitive) — עוזר
//   ‏_jsNumStr מינימלי לשלמים-בטוחים; מעבר לכך = מחוץ לטווח-שימוש האטום.

/// קבוצת-הרווחים המדויקת של ECMAScript (כלל-16): TAB/LF/VT/FF/CR/SP/NBSP/
/// OGHAM/EN-QUAD…HAIR-SP/LS/PS/NNBSP/MMSP/IDEOGRAPHIC-SP/BOM — בלי U+0085/U+180E.
const String _esWs = '\u0009\u000A\u000B\u000C\u000D\u0020\u00A0\u1680'
    '\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A'
    '\u2028\u2029\u202F\u205F\u3000\uFEFF';

/// trim נאמן-ES (כלל-16) — כל תווי-הרווח הם BMP ⇒ בטוח על יחידות-UTF-16.
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

/// ‏String(num) מינימלי (כלל-12): NaN/±Infinity · שלם-בטוח ⇒ עשרוני בלי ‎.0 ·
/// אחרת ‏toString של Dart (shortest-round-trip — זהה ל-JS בטווח הרגיל).
String _jsNumStr(num v) {
  if (v is double) {
    if (v.isNaN) return 'NaN';
    if (v == double.infinity) return 'Infinity';
    if (v == double.negativeInfinity) return '-Infinity';
    if (v == v.truncateToDouble() && v.abs() < 9007199254740992.0) {
      return v.truncate().toString();
    }
  }
  return v.toString();
}

/// ‏Array.prototype.toString של JS = join(','): ‏null/undefined ⇒ '' ·
/// מקונן ⇒ רקורסיה · אובייקט ⇒ "[object Object]".
String _listToStr(List v) => v.map((e) {
      if (e == null) return '';
      if (e is String) return e;
      if (e is num) return _jsNumStr(e);
      if (e is bool) return e ? 'true' : 'false';
      if (e is List) return _listToStr(e);
      return '[object Object]';
    }).join(',');

/// פרסור-מחרוזת לפי StrNumericLiteral של ES (כללים 10/15/16):
/// ריק-אחרי-trim ⇒ 0 · hex/binary/octal בלי-סימן · Infinity · עשרוני
/// ("1."/".5"/"1e3" תקינים) · כל השאר ⇒ NaN. מגודר-regex — לא num.tryParse.
num _strToNum(String raw) {
  final s = _jsTrim(raw);
  if (s.isEmpty) return 0;
  // כתיבים לא-עשרוניים — סימן אסור ב-JS ("-0x1" ⇒ NaN).
  final hex = RegExp(r'^0[xX][0-9A-Fa-f]+$');
  final bin = RegExp(r'^0[bB][01]+$');
  final oct = RegExp(r'^0[oO][0-7]+$');
  if (hex.hasMatch(s)) return _radix(s.substring(2), 16);
  if (bin.hasMatch(s)) return _radix(s.substring(2), 2);
  if (oct.hasMatch(s)) return _radix(s.substring(2), 8);
  var body = s;
  var neg = false;
  if (body.startsWith('+') || body.startsWith('-')) {
    neg = body[0] == '-';
    body = body.substring(1);
  }
  if (body == 'Infinity') {
    return neg ? double.negativeInfinity : double.infinity;
  }
  if (!RegExp(r'^(\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?$').hasMatch(body)) {
    return double.nan;
  }
  // נירמול לדקדוק-Dart: ".5"⇒"0.5" · "1."⇒"1" · "1.e3"⇒"1e3".
  var t = body;
  if (t.startsWith('.')) t = '0$t';
  t = t.replaceFirst(RegExp(r'\.(?=[eE]|$)'), '');
  final d = double.parse(t);
  return neg ? -d : d;
}

/// פרסור בבסיס נתון — ספרות שכבר אומתו ב-regex; גלישת-int64 ⇒ BigInt⇒double
/// (ב-JS הכול double ממילא).
num _radix(String digits, int radix) =>
    int.tryParse(digits, radix: radix)?.toDouble() ??
    BigInt.parse(digits, radix: radix).toDouble();

/// ToNumber שקול-JS (כללים 10/15): num⇒עצמו · bool⇒1/0 · null⇒0 (ראה הערת
/// כלל-2 בכותרת) · מחרוזת⇒_strToNum · מערך⇒ToPrimitive-join ואז פרסור ·
/// אובייקט⇒NaN ("[object Object]").
num _jsToNum(dynamic v) {
  if (v is num) return v;
  if (v is bool) return v ? 1 : 0;
  if (v == null) return 0;
  if (v is String) return _strToNum(v);
  if (v is List) return _strToNum(_listToStr(v));
  return double.nan;
}

/// ‏`sc >= rhs` של JS: קוארציה מספרית (ה-rhs תמיד ליטרל-מספר במקור) —
/// NaN באחד הצדדים ⇒ false.
bool _jsGte(dynamic v, num rhs) {
  final n = _jsToNum(v);
  if (n.isNaN) return false;
  return n >= rhs;
}

/// חוט · sup-tier — התנהגות זהת-ביט ל-new/atoms/sup-tier.mjs.
Map<String, String> supTier(dynamic sc, Map<String, dynamic> T) {
  if (_jsGte(sc, 800)) {
    return {'label': T['k1']!, 'bg': '#fdf3dd', 'c': '#9a6414', 'dot': '#f3c76b'};
  }
  if (_jsGte(sc, 600)) {
    return {'label': T['k3']!, 'bg': '#eef1f5', 'c': '#44546a', 'dot': '#94a3b8'};
  }
  if (_jsGte(sc, 400)) {
    return {'label': T['k5']!, 'bg': '#f6ead1', 'c': '#9a6414', 'dot': '#d97706'};
  }
  return {'label': T['k7']!, 'bg': '#eceae2', 'c': '#8b8474', 'dot': '#a8a29e'};
}

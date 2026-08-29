// ⚛️ אטום-Dart (דרגת-חוזה) · supLastInPeriod — האם התרומה-האחרונה נפלה בשנה/חודש.
// מוצא: maor/src/components/supporters/lib.ts:133-142 · המקור: new/atoms/sup-last-in-period.mjs —
//        `export function supLastInPeriod(sp, year, month, supLast) { ... }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: ‏null=כל (שניהם null ⇒ true תמיד, גם לתורם בלי תרומות); תורם בלי אף
//        תרומה (השקע מחזיר '') ⇒ false כשיש סינון. שנה = ‏+iso.slice(0,4),
//        חודש = ‏+iso.slice(5,7) — השוואה קפדנית (!==) מול הפרמטר.
// שקע (חוק-1): supLast(sp)⇒string — ה-ISO של התרומה האחרונה, '' כשאין
//        (קיים גם כחוט sup-last; כאן פרמטר-שקע — אטום לא מייבא אטום).
//
// הערות-המרה (מקור→Dart, לפי DART-PORTING-RULES):
//   • ‏`year == null` הרופף של JS תופס null/undefined; ב-Dart אין undefined ⇒ ‏`== null` שקול.
//   • ‏`!iso` (truthiness) ⇒ שקע ‏_falsy מפורש (כלל-7): ‏''/null/false/0/NaN/-0/0n = כבוי.
//   • ‏`iso.slice(0,4)` הסלחן של JS (קוצץ-לטווח, לא זורק על מחרוזת קצרה) ⇒ ‏_jsSlice
//     עם ‏clamp (כלל-5) — ‏substring של Dart היה זורק על iso קצר מ-7.
//   • ‏`+str` (ToNumber) ⇒ ‏_jsToNum (כלל-10 — אפס-זריקה): ‏ES-trim (כלל-16 — בלי
//     ‏U+0085/U+180E!), ריק⇒0, ‏0x/0o/0b, ‏±Infinity, אחרת ‏NaN; שער-regex לפני
//     ‏parse של Dart כדי לא לרשת את סלחנות-הרווחים/הדקדוק השונה שלו.
//   • ‏`!==` קפדני: מספר-מול-לא-מספר ⇒ שונים; ב-Dart ‏`!=` על num↔non-num מחזיר true —
//     זהה. ‏NaN !== year ⇒ true (נפסל) — גם ב-Dart ‏NaN != x תמיד true. ‏-0!==0 שקר בשניהם.
//   • ‏iso truthy שאינו מחרוזת ⇒ ‏JS זורק TypeError על ‏.slice; ב-Dart ה-cast ל-String זורק — שקול.

/// Whether the supporter's LAST donation falls in the given year/month
/// (null = any; no donation at all ⇒ false unless both filters are null).
/// Verbatim behaviour of the JS source new/atoms/sup-last-in-period.mjs.
/// [supLast] is an injected socket (חוק-1): sp ⇒ ISO string of the last
/// donation, '' when none.
bool supLastInPeriod(dynamic sp, dynamic year, dynamic month, dynamic supLast) {
  if (year == null && month == null) return true;
  final dynamic iso = supLast(sp);
  if (_falsy(iso)) return false;
  final String s = iso as String; // JS: non-string truthy ⇒ TypeError on .slice
  if (year != null && _jsToNum(_jsSlice(s, 0, 4)) != year) return false;
  if (month != null && _jsToNum(_jsSlice(s, 5, 7)) != month) return false;
  return true;
}

// --- עוזרים מקומיים (קידומת _; אפס-import של אטום אחר) ---

/// JS truthiness: `!v` — false for null/false/''/0/-0/NaN/0n (כלל-7).
bool _falsy(dynamic v) {
  if (v == null) return true; // null/undefined ⇒ falsy
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  if (v is BigInt) return v == BigInt.zero;
  return false; // כל אובייקט אחר truthy ב-JS
}

/// JS String.prototype.slice with non-negative literal bounds — clamps, never
/// throws (כלל-5). Negative handling included for fidelity.
String _jsSlice(String s, int start, int end) {
  final int len = s.length;
  int a = start < 0 ? (len + start) : start;
  int b = end < 0 ? (len + end) : end;
  if (a < 0) a = 0;
  if (a > len) a = len;
  if (b < 0) b = 0;
  if (b > len) b = len;
  if (a >= b) return '';
  return s.substring(a, b);
}

/// ECMAScript WhiteSpace∪LineTerminator trim — WITHOUT U+0085/U+180E (כלל-16).
const String _esWs = '\u0009\u000A\u000B\u000C\u000D\u0020\u00A0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u2028\u2029\u202F\u205F\u3000\uFEFF';

String _jsTrim(String s) {
  int i = 0, j = s.length;
  while (i < j && _esWs.contains(s[i])) i++;
  while (j > i && _esWs.contains(s[j - 1])) j--;
  return s.substring(i, j);
}

/// JS ToNumber(string): ES-trim, ''⇒0, ±Infinity, 0x/0o/0b (ללא-סימן),
/// ‏StringNumericLiteral עשרוני; אחרת NaN. לעולם לא זורק (כלל-10).
num _jsToNum(String s) {
  final String t = _jsTrim(s);
  if (t.isEmpty) return 0;
  if (RegExp(r'^[+-]?Infinity$').hasMatch(t)) {
    return t.startsWith('-') ? double.negativeInfinity : double.infinity;
  }
  final Match? hex = RegExp(r'^0[xX]([0-9a-fA-F]+)$').firstMatch(t);
  if (hex != null) return int.parse(hex.group(1)!, radix: 16);
  final Match? oct = RegExp(r'^0[oO]([0-7]+)$').firstMatch(t);
  if (oct != null) return int.parse(oct.group(1)!, radix: 8);
  final Match? bin = RegExp(r'^0[bB]([01]+)$').firstMatch(t);
  if (bin != null) return int.parse(bin.group(1)!, radix: 2);
  if (!RegExp(r'^[+-]?(\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?$').hasMatch(t)) {
    return double.nan;
  }
  // '5.' חוקי ב-JS אך לא בדקדוק-double.parse של Dart ⇒ השמטת הנקודה התלויה.
  final String core = t.replaceFirst(RegExp(r'\.(?=[eE]|$)'), '');
  return num.tryParse(core) ?? double.parse(core);
}

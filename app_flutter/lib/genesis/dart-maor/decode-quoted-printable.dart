// ⚛️ אטום-Dart (דרגת-חוזה) · decodeQuotedPrintable — פענוח Quoted-Printable → מחרוזת.
// מוצא: maor/src/lib/vcardImport.ts · המקור: new/atoms/decode-quoted-printable.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core).
// חוק-4 — התנהגות זהה למקור-ה-JS (המקור קדוש).
//
// תפקיד: אוסף בייטים — `=XX` (הקס) ⇒ הבית; תו-אחר ⇒ code-unit אם ≤0xFF, אחרת '?'
//        (0x3F) — ואז מפענח את מערך-הבייטים כ-UTF-8 למחרוזת.
// קלט:  מחרוזת QP. פלט: מחרוזת מפוענחת.
//
// הערות-המרה (מקור→Dart) — מה שמנוע-ה-AST פספס:
//  • `HEX2` — הקבוע שהמקור השמיט (מוגדר בקופסה: vcardImport.ts:33
//    `const HEX2 = /^[0-9A-Fa-f]{2}$/`). כאן הוא נשתל מקומית, כפי שהמקור התכוון.
//  • `s[i]` / `s.charCodeAt(i)` → `s.codeUnitAt(i)` (השוואת '=' = 0x3D). אורך-JS
//    (`s.length`) = יחידות-UTF-16 = אורך-Dart, לכן האינדוקס זהה.
//  • `s.slice(i+1,i+3)` → `s.substring(i+1,i+3)`.
//  • `parseInt(x, 16)` → `int.parse(x, radix: 16)` (המנוע כתב tryParse בלי בסיס — שגוי).
//  • `new TextDecoder('utf-8').decode(new Uint8Array(bytes))` — אין ב-Dart בלי
//    dart:convert (אסור); ממומש ידנית ב-`_utf8Decode` (non-fatal: רצף-פגום ⇒ U+FFFD,
//    כמו TextDecoder ברירת-מחדל). ה-try/catch נשמר verbatim (נופל למקור s).
//  • מוטביליות: `const bytes`/`const ch` → `final`; מונה-הלולאה `var i`.
//  אין locale/פורמט/getMonth/truthiness מעורבים.

/// Verbatim port of the JS source new/atoms/decode-quoted-printable.mjs
/// (`decodeQuotedPrintable`): decodes Quoted-Printable `=XX` escapes to bytes,
/// keeps other chars as single bytes (≤0xFF, else '?'), then UTF-8 decodes.
String decodeQuotedPrintable(String s) {
  final hex2 = RegExp(r'^[0-9A-Fa-f]{2}$'); // ⇐ vcardImport.ts:33 (השמטת-המקור)
  final bytes = <int>[];
  for (var i = 0; i < s.length; i++) {
    final ch = s.codeUnitAt(i);
    if (ch == 0x3D /* '=' */ &&
        i + 2 < s.length &&
        hex2.hasMatch(s.substring(i + 1, i + 3))) {
      bytes.add(int.parse(s.substring(i + 1, i + 3), radix: 16));
      i += 2;
    } else {
      // תו ASCII רגיל — code-point בטווח בית בודד; מעל 0xFF נשמר כ-'?' (נדיר).
      final cp = s.codeUnitAt(i);
      bytes.add(cp <= 0xff ? cp : 0x3f /* '?' */);
    }
  }
  try {
    return _utf8Decode(bytes);
  } catch (_) {
    return s;
  }
}

/// UTF-8 decode של מערך-בייטים למחרוזת — תחליף ל-TextDecoder('utf-8') הלא-קטלני:
/// רצף-פגום/קטוע ⇒ U+FFFD (תו-החלפה), בלי לזרוק (כמו ברירת-המחדל של TextDecoder).
String _utf8Decode(List<int> bytes) {
  final sb = StringBuffer();
  final n = bytes.length;
  var i = 0;
  while (i < n) {
    final b0 = bytes[i] & 0xff;
    if (b0 < 0x80) {
      sb.writeCharCode(b0);
      i += 1;
    } else if (b0 >= 0xc2 && b0 <= 0xdf) {
      if (i + 1 < n && (bytes[i + 1] & 0xc0) == 0x80) {
        sb.writeCharCode(((b0 & 0x1f) << 6) | (bytes[i + 1] & 0x3f));
        i += 2;
      } else {
        sb.writeCharCode(0xfffd);
        i += 1;
      }
    } else if (b0 >= 0xe0 && b0 <= 0xef) {
      final lo = b0 == 0xe0 ? 0xa0 : 0x80;
      final hi = b0 == 0xed ? 0x9f : 0xbf;
      if (i + 2 < n &&
          (bytes[i + 1] & 0xff) >= lo &&
          (bytes[i + 1] & 0xff) <= hi &&
          (bytes[i + 2] & 0xc0) == 0x80) {
        sb.writeCharCode(((b0 & 0x0f) << 12) |
            ((bytes[i + 1] & 0x3f) << 6) |
            (bytes[i + 2] & 0x3f));
        i += 3;
      } else {
        sb.writeCharCode(0xfffd);
        i += 1;
      }
    } else if (b0 >= 0xf0 && b0 <= 0xf4) {
      final lo = b0 == 0xf0 ? 0x90 : 0x80;
      final hi = b0 == 0xf4 ? 0x8f : 0xbf;
      if (i + 3 < n &&
          (bytes[i + 1] & 0xff) >= lo &&
          (bytes[i + 1] & 0xff) <= hi &&
          (bytes[i + 2] & 0xc0) == 0x80 &&
          (bytes[i + 3] & 0xc0) == 0x80) {
        sb.writeCharCode(((b0 & 0x07) << 18) |
            ((bytes[i + 1] & 0x3f) << 12) |
            ((bytes[i + 2] & 0x3f) << 6) |
            (bytes[i + 3] & 0x3f));
        i += 4;
      } else {
        sb.writeCharCode(0xfffd);
        i += 1;
      }
    } else {
      sb.writeCharCode(0xfffd);
      i += 1;
    }
  }
  return sb.toString();
}

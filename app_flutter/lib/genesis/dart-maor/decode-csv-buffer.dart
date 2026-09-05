// ⚛️ אטום-Dart (דרגת-חוזה) · decodeCsvBuffer — זיהוי-קידוד ופענוח בייטי-CSV לטקסט.
// מוצא: maor/src/lib/csvx.ts:43-63 · המקור: new/atoms/decode-csv-buffer.mjs.
// חוזה: new/atoms/decode-csv-buffer.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core + dart:math).
// חוק-4 — התנהגות זהה למקור-ה-JS (המקור קדוש).
//
// תפקיד: קסקדת-זיהוי-קידוד לפענוח בייטי-קובץ-ייבוא:
//  1. BOM UTF-16 (FF FE / FE FF) ⇒ utf-16le / utf-16be.
//  2. בלי BOM אך גדוש-NUL (400 בייטים ראשונים: אורך>8 וגם nuls>אורך/5) ⇒ utf-16le.
//  3. אחרת utf-8; מכיל תו-החלפה (U+FFFD �) ⇒ ניסיון-שני windows-1255; אחרת utf-8 כמו-שהוא.
//
// קלט:  buf — מערך-בייטים גולמי (במקור ArrayBuffer→Uint8Array). כאן List<int> (0..255).
// פלט:  מחרוזת-טקסט מפוענחת, String.
//
// הערות-המרה (מקור→Dart) — מה שמנוע-ה-AST פספס/לא-יכול (Uint8Array/TextDecoder אין ב-Dart
// בלי dart:typed_data/dart:convert — אסורים):
//  • `new Uint8Array(buf)` → הקלט כבר-מערך-בייטים; משתמשים בו ישירות.
//  • `bytes.subarray(0,400)` → `bytes.sublist(0, min(400, length))` (כמו subarray — קיטום-בטוח).
//  • `nuls > probe.length / 5` — ב-JS זו חלוקה-צפה; ב-Dart `/` מחזיר double, לכן זהה (int>double).
//  • `new TextDecoder('utf-16le'/'utf-16be')` → `_utf16Decode` ידני: זוגות-בייטים ל-code-units,
//    little/big-endian, פילת-BOM מובילה (U+FEFF) כמו TextDecoder עם ignoreBOM=false (ברירת-מחדל),
//    ובית-בודד-נותר ⇒ U+FFFD (כמו המפענח הלא-קטלני).
//  • `new TextDecoder('utf-8')` → `_utf8Decode` ידני לא-קטלני (רצף-פגום/קטוע ⇒ U+FFFD).
//  • `utf8.includes('�')` → `utf8.contains('�')` (U+FFFD = תו-ההחלפה �).
//  • `new TextDecoder('windows-1255')` → `_win1255Decode` ידני מטבלת-WHATWG (undefined ⇒ U+FFFD);
//    המפענח אינו זורק לעולם, לכן ה-try/catch-של-המקור נשמר verbatim אך אינו נדרך (dead-safe).
//  • מוטביליות: `const bytes`/`let nuls` → `final`/`var`. אין locale/getMonth/truthiness מעורבים.

import 'dart:math' as math;

/// Verbatim port of the JS source new/atoms/decode-csv-buffer.mjs
/// (`decodeCsvBuffer`): detects the byte encoding of an import buffer and
/// decodes it to text — UTF-16 (BOM or NUL-heavy) → UTF-8 → windows-1255.
/// `buf` is the raw byte list (0..255), matching `new Uint8Array(buf)`.
String decodeCsvBuffer(List<int> buf) {
  final bytes = buf;
  if (bytes.length >= 2 && bytes[0] == 0xff && bytes[1] == 0xfe) {
    return _utf16Decode(bytes, littleEndian: true);
  }
  if (bytes.length >= 2 && bytes[0] == 0xfe && bytes[1] == 0xff) {
    return _utf16Decode(bytes, littleEndian: false);
  }
  final probe = bytes.sublist(0, math.min(400, bytes.length));
  var nuls = 0;
  for (final b in probe) {
    if (b == 0) nuls++;
  }
  if (probe.length > 8 && nuls > probe.length / 5) {
    return _utf16Decode(bytes, littleEndian: true);
  }
  final utf8 = _utf8Decode(bytes);
  if (!utf8.contains('�')) return utf8;
  try {
    return _win1255Decode(bytes);
  } catch (_) {
    return utf8;
  }
}

/// UTF-16 decode (little/big-endian) — תחליף ל-TextDecoder('utf-16le'/'utf-16be').
/// זוגות-בייטים ל-code-units; פילת-BOM מובילה (U+FEFF, ברירת-מחדל ignoreBOM=false);
/// בית-בודד-נותר ⇒ U+FFFD (מפענח לא-קטלני).
String _utf16Decode(List<int> bytes, {required bool littleEndian}) {
  final units = <int>[];
  var i = 0;
  while (i + 1 < bytes.length) {
    final b0 = bytes[i] & 0xff;
    final b1 = bytes[i + 1] & 0xff;
    units.add(littleEndian ? (b0 | (b1 << 8)) : ((b0 << 8) | b1));
    i += 2;
  }
  if (i < bytes.length) units.add(0xfffd); // בית-בודד-נותר (אורך-אי-זוגי)
  if (units.isNotEmpty && units[0] == 0xfeff) units.removeAt(0); // פילת-BOM
  return String.fromCharCodes(units);
}

/// UTF-8 decode לא-קטלני — תחליף ל-TextDecoder('utf-8') (רצף-פגום/קטוע ⇒ U+FFFD, בלי לזרוק).
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

/// windows-1255 decode — תחליף ל-TextDecoder('windows-1255') (single-byte עברי).
/// 0x00..0x7F ⇒ ASCII; 0x80..0xFF ⇒ טבלת-WHATWG; מצביע-undefined ⇒ U+FFFD (לא-קטלני, לא-זורק).
String _win1255Decode(List<int> bytes) {
  final units = <int>[];
  for (final raw in bytes) {
    final b = raw & 0xff;
    units.add(b < 0x80 ? b : _win1255[b - 0x80]);
  }
  return String.fromCharCodes(units);
}

/// טבלת windows-1255 לבייטים 0x80..0xFF (אינדקס = byte-0x80). undefined ⇒ 0xFFFD.
/// מקור: WHATWG index-windows-1255.
const List<int> _win1255 = [
  0x20ac, 0xfffd, 0x201a, 0x0192, 0x201e, 0x2026, 0x2020, 0x2021, // 80-87
  0x02c6, 0x2030, 0xfffd, 0x2039, 0xfffd, 0xfffd, 0xfffd, 0xfffd, // 88-8F
  0xfffd, 0x2018, 0x2019, 0x201c, 0x201d, 0x2022, 0x2013, 0x2014, // 90-97
  0x02dc, 0x2122, 0xfffd, 0x203a, 0xfffd, 0xfffd, 0xfffd, 0xfffd, // 98-9F
  0x00a0, 0x00a1, 0x00a2, 0x00a3, 0x20aa, 0x00a5, 0x00a6, 0x00a7, // A0-A7
  0x00a8, 0x00a9, 0x00d7, 0x00ab, 0x00ac, 0x00ad, 0x00ae, 0x00af, // A8-AF
  0x00b0, 0x00b1, 0x00b2, 0x00b3, 0x00b4, 0x00b5, 0x00b6, 0x00b7, // B0-B7
  0x00b8, 0x00b9, 0x00f7, 0x00bb, 0x00bc, 0x00bd, 0x00be, 0x00bf, // B8-BF
  0x05b0, 0x05b1, 0x05b2, 0x05b3, 0x05b4, 0x05b5, 0x05b6, 0x05b7, // C0-C7
  0x05b8, 0x05b9, 0x05ba, 0x05bb, 0x05bc, 0x05bd, 0x05be, 0x05bf, // C8-CF
  0x05c0, 0x05c1, 0x05c2, 0x05c3, 0x05f0, 0x05f1, 0x05f2, 0x05f3, // D0-D7
  0x05f4, 0xfffd, 0xfffd, 0xfffd, 0xfffd, 0xfffd, 0xfffd, 0xfffd, // D8-DF
  0x05d0, 0x05d1, 0x05d2, 0x05d3, 0x05d4, 0x05d5, 0x05d6, 0x05d7, // E0-E7
  0x05d8, 0x05d9, 0x05da, 0x05db, 0x05dc, 0x05dd, 0x05de, 0x05df, // E8-EF
  0x05e0, 0x05e1, 0x05e2, 0x05e3, 0x05e4, 0x05e5, 0x05e6, 0x05e7, // F0-F7
  0x05e8, 0x05e9, 0x05ea, 0xfffd, 0xfffd, 0x200e, 0x200f, 0xfffd, // F8-FF
];

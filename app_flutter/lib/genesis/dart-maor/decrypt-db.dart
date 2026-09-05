// ⚛️ אטום-Dart (דרגת-חוזה) · decryptDb — פענוח נתוני-מעטפת עם DEK חלוץ.
// מוצא: maor/src/lib/crypto.ts:123-127 → new/atoms/decrypt-db.mjs.
// חוזה: new/atoms/decrypt-db.contract.md.
// טוהר: פונקציית top-level אסינכרונית, אפס import (רק שפה/סטנדרט: dart:core).
// חוק-4 — התנהגות זהה למקור-ה-JS (המקור קדוש); חוק-1 — השכן aesDec הוזרק כשקע.
//
// המקור:  return new TextDecoder().decode(await aesDec(dek, env.data));
// תפקיד: מעביר את env.data למפענח-ה-AES (השקע), ומקודד את הבייטים שחזרו
//        ל-טקסט UTF-8. השקע זורק ⇒ ההבטחה נדחית (האטום מעביר, לא בולע).
//
// קלט:  env — מעטפת בעלת שדה `data` · dek — מפתח-פענוח · aesDec — שקע (dek,data)⇒בייטים.
// פלט:  Future<String> — ה-JSON הגלוי.
//
// הערות-המרה (מקור→Dart) — מה שמנוע-ה-AST פספס (הטיוטה עצרה על AwaitExpression):
//  • `new TextDecoder()` (ברירת-מחדל = UTF-8 לא-קטלני) אין ב-Dart בלי dart:convert
//    (אסור). ⇒ `_utf8Decode` ידני לא-קטלני: רצף-פגום/קטוע ⇒ U+FFFD, בלי לזרוק —
//    בדיוק כסמנטיקת TextDecoder('utf-8') ברירת-המחדל (fatal:false).
//  • `await aesDec(...)` → `await` על Future<List<int>> של השקע.
//  • `env.data` — env הוא dynamic (מעטפת שרירותית); הגישה דרך `(env as dynamic).data`
//    (מקבילה לגישת-property של JS; שקע-הבדיקה נושא שדה `data`).
//  • הבייטים: `Uint8Array` של JS → `List<int>` (0..255) בדארט; `& 0xff` בכל קריאה.

typedef AesDec = Future<List<int>> Function(dynamic key, dynamic blob);

/// Verbatim port of the JS source new/atoms/decrypt-db.mjs (`decryptDb`):
/// hands `env.data` to the AES socket, then UTF-8-decodes the returned bytes
/// to the plaintext JSON. A throwing socket rejects the future (not swallowed).
Future<String> decryptDb(dynamic env, dynamic dek, AesDec aesDec) async {
  return _utf8Decode(await aesDec(dek, (env as dynamic).data));
}

/// UTF-8 decode לא-קטלני — תחליף ל-TextDecoder('utf-8') ברירת-המחדל
/// (רצף-פגום/קטוע ⇒ U+FFFD, בלי לזרוק).
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

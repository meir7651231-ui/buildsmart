// ⚛️ אטום-Dart (דרגת-חוזה) · reencryptDb — הצפנת JSON חדש עם DEK קיים.
// מוצא: maor/src/lib/crypto.ts:128-131 → new/atoms/reencrypt-db.mjs.
// חוזה: new/atoms/reencrypt-db.contract.md.
// טוהר: פונקציית top-level אסינכרונית, אפס import (רק שפה/סטנדרט: dart:core).
// חוק-4 — התנהגות זהה למקור-ה-JS (המקור קדוש); חוק-1 — השכן aesEnc הוזרק כשקע.
//
// המקור:  const enc = new TextEncoder();
//         return { ...env, data: await aesEnc(dek, enc.encode(json)) };
// תפקיד: שומר את מעטפת-הקלט כמות-שהיא ומחליף **רק** את שדה `data` בתוצאת-הצפנת
//        ה-JSON (מקודד UTF-8). האטום לא מציץ בתוצאה — מניח אותה כמות-שהיא. אין
//        מוטציה של הקלט (עותק-spread).
//
// קלט:  env — מעטפת (Map) · dek — מפתח-הנתונים (מועבר כמות-שהוא) · json — מחרוזת ·
//        aesEnc — שקע (dek, bytes)⇒Future<מוצפן>.
// פלט:  Future<Map<String,dynamic>> — מעטפת חדשה עם `data` מוצפן.
//
// הערות-המרה (מקור→Dart) — מה שמנוע-ה-AST פספס (הטיוטה נעצרה כליל: engine-failed):
//  • `{...env}` (spread) → Map<String,dynamic>.from(env): עותק חדש (out !== env),
//    סדר-הכנסה נשמר (LinkedHashMap) בדיוק כמו object-spread של JS; המפתח `data`
//    כבר קיים ⇒ הצבה מחדש שומרת על מיקומו (זהה לסמנטיקת-spread-ואז-override של JS).
//  • `new TextEncoder().encode(json)` (UTF-8) אין ב-Dart בלי dart:convert (אסור,
//    חוק-1). ⇒ `_utf8Encode` ידני המשקף TextEncoder: זוגות-סרוגייט מקודדים כ-4
//    בייטים; סרוגייט-יתום ⇒ U+FFFD (EF BF BD) — בדיוק כסמנטיקת TextEncoder.
//  • הבייטים: `Uint8Array` של JS → `List<int>` (0..255) בדארט (השקע מקבל List<int>).
//  • `await aesEnc(...)` → await על Future של השקע; שקע-זורק ⇒ ההבטחה נדחית
//    (האטום מעביר, לא בולע) — כמו במקור.

typedef AesEnc = dynamic Function(dynamic dek, List<int> bytes);

/// Verbatim port of the JS source new/atoms/reencrypt-db.mjs (`reencryptDb`):
/// keeps the input envelope as-is and replaces only `data` with the AES socket's
/// encryption of the UTF-8-encoded JSON. Spread copy — no input mutation.
Future<Map<String, dynamic>> reencryptDb(
  dynamic env,
  dynamic dek,
  String json,
  AesEnc aesEnc,
) async {
  final out = Map<String, dynamic>.from(env as Map);
  out['data'] = await aesEnc(dek, _utf8Encode(json));
  return out;
}

/// UTF-8 encode — תחליף ל-TextEncoder().encode() (UTF-8, החלפת-סרוגייט-יתום
/// ב-U+FFFD). מייצר List<int> של בייטים 0..255.
List<int> _utf8Encode(String s) {
  final out = <int>[];
  final units = s.codeUnits;
  final n = units.length;
  var i = 0;
  while (i < n) {
    var cp = units[i];
    if (cp >= 0xd800 && cp <= 0xdbff) {
      // high surrogate — צריך low-surrogate צמוד להרכבת נקודת-קוד תקינה.
      if (i + 1 < n && units[i + 1] >= 0xdc00 && units[i + 1] <= 0xdfff) {
        cp = 0x10000 + ((cp - 0xd800) << 10) + (units[i + 1] - 0xdc00);
        i += 2;
      } else {
        cp = 0xfffd; // high-surrogate יתום
        i += 1;
      }
    } else if (cp >= 0xdc00 && cp <= 0xdfff) {
      cp = 0xfffd; // low-surrogate יתום
      i += 1;
    } else {
      i += 1;
    }
    if (cp < 0x80) {
      out.add(cp);
    } else if (cp < 0x800) {
      out.add(0xc0 | (cp >> 6));
      out.add(0x80 | (cp & 0x3f));
    } else if (cp < 0x10000) {
      out.add(0xe0 | (cp >> 12));
      out.add(0x80 | ((cp >> 6) & 0x3f));
      out.add(0x80 | (cp & 0x3f));
    } else {
      out.add(0xf0 | (cp >> 18));
      out.add(0x80 | ((cp >> 12) & 0x3f));
      out.add(0x80 | ((cp >> 6) & 0x3f));
      out.add(0x80 | (cp & 0x3f));
    }
  }
  return out;
}

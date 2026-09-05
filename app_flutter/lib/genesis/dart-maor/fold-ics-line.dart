// ⚛️ אטום-Dart (דרגת-חוזה) · foldIcsLine — קיפול-שורת-ICS ל-≤75 אוקטטים (RFC 5545).
// מוצא: maor/src/lib/ics.ts:40-58 · המקור: new/atoms/fold-ics-line.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: מקפל שורה כך שכל שורת-פלט ≤75 בייטים של UTF-8; שורת-המשך נפתחת ברווח
//        (אוקטט אחד משלה) ולכן נושאת עד 74 בייט תוכן. לעולם לא חוצים תו באמצע.
// קלט:  String line (בלי CRLF). פלט: List<String> — לפחות איבר אחד ([''] לריק).
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס, לפי DART-PORTING-RULES):
//  • ‏TextEncoder חסר עם dart:core בלבד ⇒ אורך-הבייטים של תו נגזר ישירות מקוד-התו
//    (‏_utf8Len): ‏<=0x7F→1 · <=0x7FF→2 (עברית!) · <=0xFFFF→3 · אחרת→4. זהה
//    ל-`enc.encode(ch).length` של המקור (עברי='א' U+05D0 <=0x7FF ⇒ 2 בייט).
//  • `for (const ch of line)` של JS מפרק לפי code-points (Unicode), לא UTF-16 units ⇒
//    `line.runes`; בניית התו-בחזרה דרך `String.fromCharCode(cp)` (תומך גם באסטרלי).
//  • truthiness: `if (cur)` על מחרוזת = לא-ריקה ⇒ `cur.isNotEmpty`.
//  • `out.length ? out : ['']` ⇒ `out.isNotEmpty ? out : ['']` (ריק ⇒ [''] נשמר).
//  • `limit` נשמר verbatim (תמיד 75 — המקור קדוש; ההמשך מוגבל ל-74 בפועל דרך
//    curBytes שנפתח ב-1 עבור הרווח-המוביל).
//  • מוטביליות: `out` final (מוטבל דרך add); `cur/curBytes/limit` משתני-var כמו המקור.

/// אורך UTF-8 בבייטים של code-point יחיד — מקבילה ל-`new TextEncoder().encode(ch).length`.
int _utf8Len(int cp) {
  if (cp <= 0x7F) return 1;
  if (cp <= 0x7FF) return 2;
  if (cp <= 0xFFFF) return 3;
  return 4;
}

/// Folds a single ICS line to ≤75 UTF-8 octets per RFC 5545 — continuation lines
/// open with a leading space (its own octet, so they carry up to 74 content octets);
/// a character is never split. Verbatim port of new/atoms/fold-ics-line.mjs (`foldIcsLine`).
List<String> foldIcsLine(String line) {
  final out = <String>[];
  var cur = '';
  var curBytes = 0;
  var limit = 75; // השורה הראשונה; שורות-המשך: 74 + רווח מוביל
  for (final cp in line.runes) {
    final b = _utf8Len(cp);
    final ch = String.fromCharCode(cp);
    if (curBytes + b > limit) {
      out.add(cur);
      cur = ' ' + ch;
      curBytes = 1 + b;
      limit = 75;
    } else {
      cur += ch;
      curBytes += b;
    }
  }
  if (cur.isNotEmpty) out.add(cur);
  return out.isNotEmpty ? out : [''];
}

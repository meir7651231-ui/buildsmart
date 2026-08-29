// ⚛️ אטום-Dart (דרגת-חוזה) · supKeyOf — מפתח-הפירוק (skey) של תומך.
// מוצא: maor/src/lib/supporterPartition.ts:26-34 · המקור: new/atoms/sup-key-of.mjs —
//        `const f = (sp.forWho ?? '').trim(); return f || sharedSupKey;`
// טוהר: פונקציות top-level עצמאיות, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט ל-JS.
//
// תפקיד: הייעוד-פר-תורם (forWho) המחוטא (trim); ריק/רווחים-בלבד/חסר/null ⇒ המפתח-המשותף.
// שקע (חוק-1): sharedSupKey — הקבוע-השכן SHARED_SUP_KEY הוזרק כפרמטר (בחיווט-maor: '_shared_').
//
// הערות-המרה (מקור→Dart):
//  • `sp.forWho` — ‏sp מיוצג כ-Map; ‏sp['forWho'] מחזיר null גם על מפתח-חסר וגם על null-מפורש.
//    חוק-2: כאן אין הבחנה לשמר — `?? ''` של JS בולע undefined ו-null לאותו ענף ('') בדיוק
//    כמו `?? ''` של Dart על null-יחיד. (containsKey לא נדרש — שני המקרים מתלכדים בכוונה.)
//  • `.trim()` → ‏`_jsTrim` (חוק-16): ‏String.trim של Dart גוזם גם U+0085 (NEL) ו-U+180E —
//    ‏JS לא. העוזר גוזם בדיוק את קבוצת-ECMAScript: TAB/LF/VT/FF/CR/SP/NBSP/OGHAM/Zs/LS/PS/BOM.
//  • `f || sharedSupKey` — truthiness-מחרוזת של JS: רק '' falsy (חוק-7) ⇒ תנאי-מפורש isEmpty.
//  • ‏forWho שאינו-מחרוזת (מחוץ-לחוזה): ‏JS זורק TypeError על ‎.trim()‎; ‏Dart זורק על ההצבה
//    ל-String — שניהם זורקים, אין ענף-פלט שקט חדש. אין המרת-מספר-למחרוזת ⇒ חוק-12 לא נדרש.

/// קבוצת-הרווחים של ECMAScript (TrimString: WhiteSpace ∪ LineTerminator):
/// TAB LF VT FF CR SP NBSP OGHAM(U+1680) Zs(U+2000–U+200A, U+202F, U+205F, U+3000)
/// LS(U+2028) PS(U+2029) BOM(U+FEFF).
/// במכוון בלי U+0085 (NEL) ובלי U+180E — Dart גוזם אותם, JS לא (חוק-16).
final String _esWhitespace = String.fromCharCodes(const [
  0x0009, 0x000A, 0x000B, 0x000C, 0x000D, 0x0020, 0x00A0, 0x1680,
  0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007,
  0x2008, 0x2009, 0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000,
  0xFEFF,
]);

/// ‏trim נאמן-JS: גוזם משני הקצוות אך ורק תווים מקבוצת-ES (חוק-16).
/// כל תווי-הקבוצה ב-BMP ומחוץ לטווח-הפונדקאים ⇒ גישת s[i] (יחידות-UTF-16) בטוחה.
String _jsTrim(String s) {
  var start = 0;
  var end = s.length;
  while (start < end && _esWhitespace.contains(s[start])) {
    start++;
  }
  while (end > start && _esWhitespace.contains(s[end - 1])) {
    end--;
  }
  return s.substring(start, end);
}

/// מפתח-הפירוק של תומך: ‏forWho הגזום; ריק/רווחים/חסר/null ⇒ sharedSupKey.
/// המרה נאמנת-ביט של new/atoms/sup-key-of.mjs (‏supKeyOf).
dynamic supKeyOf(dynamic sp, dynamic sharedSupKey) {
  final String f = _jsTrim((sp['forWho'] ?? '') as String);
  return f.isEmpty ? sharedSupKey : f;
}

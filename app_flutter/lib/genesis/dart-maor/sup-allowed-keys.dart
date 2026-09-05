// ⚛️ אטום-Dart (דרגת-חוזה) · supAllowedKeys — ערכי where('skey','in',…) לעובד/ת מוגבל/ת.
// מוצא: maor/src/lib/supporterPartition.ts:61-69 · המקור: new/atoms/sup-allowed-keys.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). הקבוע-השכן SHARED_SUP_KEY הוזרק כשקע sharedKey
//        (חוק-1) — האטום עיוור לערכו, רק מצרף אותו אחרון.
//
// תפקיד: הייעודים המותרים — מנוקים (trim), ריקים מסוננים, כפולים מאוחדים (הופעה ראשונה
//        קובעת), נחתכים ל-29 — ועליהם המפתח-המשותף בסוף. Firestore מגביל `in` ל-30 ערכים
//        ⇒ 29 ייעודים + המשותף. סדר-הקלט נשמר (אין מיון).
// קלט:  allowed: List של String · השקע sharedKey. פלט: List (אורך ≤ 30).
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • `s.trim()` → `_jsTrim` (חוק-16): trim של Dart גוזם גם U+0085 (NEL) ו-U+180E — JS לא.
//    מומש בקבוצת-הרווחים המדויקת של ECMAScript (TAB/LF/VT/FF/CR/SP/NBSP/Zs/LS/PS/BOM).
//  • `.filter(Boolean)` (חוק-7): פלט-ה-trim הוא תמיד String ⇒ Boolean(t) ≡ t.isNotEmpty
//    ('' היא ה-String הפולסי היחיד) — אין צורך ב-_truthy כללי.
//  • `new Set(...)` של JS שומר סדר-הכנסה — כמוהו ה-Set הדיפולטי של Dart (LinkedHashSet);
//    הדדופ ממומש בלולאה (seen.add) ⇒ הופעה-ראשונה קובעת, זהה.
//  • `.slice(0, 29)` של JS קוטם-סלחני (רשימה קצרה ⇒ כולה); `sublist(0,29)` של Dart זורק
//    RangeError על אורך<29 ⇒ גידור-אורך מפורש (חוק-5, משפחת slice-שלילי/חורג).
//  • הטיוטה (sup-allowed-keys.dart.draft) שגתה בדיוק כאן: sublist בלי-גידור + where(Boolean)
//    לא-קיים — נכתב מחדש לפי הכללים.

/// קבוצת-הרווחים של ECMAScript (TrimString/WhiteSpace+LineTerminator) — בלי U+0085/U+180E.
bool _isJsWhitespace(int c) =>
    (c >= 0x0009 && c <= 0x000D) || // TAB LF VT FF CR
    c == 0x0020 || // SPACE
    c == 0x00A0 || // NBSP
    c == 0x1680 || // OGHAM SPACE MARK (Zs)
    (c >= 0x2000 && c <= 0x200A) || // Zs range
    c == 0x2028 || // LINE SEPARATOR
    c == 0x2029 || // PARAGRAPH SEPARATOR
    c == 0x202F || // NARROW NO-BREAK SPACE (Zs)
    c == 0x205F || // MEDIUM MATHEMATICAL SPACE (Zs)
    c == 0x3000 || // IDEOGRAPHIC SPACE (Zs)
    c == 0xFEFF; // BOM / ZWNBSP

/// `String.prototype.trim` של JS (חוק-16) — גוזם אך ורק את קבוצת-ה-ES.
String _jsTrim(String s) {
  var start = 0;
  var end = s.length;
  while (start < end && _isJsWhitespace(s.codeUnitAt(start))) {
    start++;
  }
  while (end > start && _isJsWhitespace(s.codeUnitAt(end - 1))) {
    end--;
  }
  return s.substring(start, end);
}

/// The where('skey','in',…) value list for a restricted employee: allowed designations —
/// trimmed (JS trim set), empties filtered, deduped (first occurrence wins), cut to 29 —
/// with the shared key appended last (Firestore `in` caps at 30 ⇒ 29 + shared).
/// Verbatim port of new/atoms/sup-allowed-keys.mjs (`supAllowedKeys`); the neighbour
/// constant SHARED_SUP_KEY is injected as the `sharedKey` socket (Law 1).
List<dynamic> supAllowedKeys(dynamic allowed, dynamic sharedKey) {
  final seen = <String>{};
  final clean = <String>[];
  for (final s in allowed as List) {
    final t = _jsTrim(s as String); // map(s => s.trim())
    if (t.isEmpty) continue; // filter(Boolean) — '' הוא ה-String הפולסי היחיד
    if (seen.add(t)) clean.add(t); // new Set — הופעה ראשונה קובעת, סדר נשמר
  }
  final cut = clean.length > 29 ? clean.sublist(0, 29) : clean; // slice(0, 29) סלחני
  return <dynamic>[...cut, sharedKey];
}

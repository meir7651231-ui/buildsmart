// ⚛️ אטום-Dart (דרגת-חוזה) · resolveLocalized — פתרון טקסט רב-לשוני.
// מוצא: maor/src/lib/publicSite.ts:177-190 (resolveLocalized) · הקבוע SITE_LANGS
//        מ-maor/src/types/config.ts:65 הוטמע פנימה (סדר-הנפילה) ומיוצא.
//        המקור: new/atoms/resolve-localized.mjs (חוק-4 — התנהגות זהה-ביט, המקור קדוש).
// טוהר: פונקציות top-level עצמאיות, אפס import של אטום אחר (רק שפה/סטנדרט: dart:core).
//
// תפקיד: שפה מבוקשת ⇒ נפילה לעברית ('he') ⇒ ערך ראשון לא-ריק בסדר SITE_LANGS.
//        מחרוזת עוברת כמות-שהיא (השפה לא נבדקת); null/מפה-ריקה ⇒ ''.
// קלט:  t — מחרוזת או מפה {he?, en?, yi?} או null · lang — 'he'/'en'/'yi'.
// פלט:  String (ייתכן '').
//
// הערות-המרה (מקור→Dart):
//  • undefined/null של JS ⇒ שניהם null ב-Dart; `t == null` שקול ל-`t == null` במקור
//    (המקור בודק `t == null` הרפוי שתופס גם undefined) — זהה-ביט.
//  • truthiness (חוק-7): `pick.trim()` ב-JS = "לא-ריק אחרי trim". לא ממופה ל-
//    `trim().isNotEmpty` של Dart כי קבוצת-הרווחים שונה: Dart מקלף גם NEL (U+0085)
//    שאינו WhiteSpace של ECMAScript ⇒ מחרוזת "" הייתה מוחזרת ב-JS ונפסלת
//    ב-Dart. ⇒ עוזר מקומי _jsTrimNonEmpty שמשקף במדויק את קבוצת-הרווחים של JS
//    (WhiteSpace: TAB/VT/FF/SP/NBSP/BOM + קטגוריית Zs · LineTerminator: LF/CR/LS/PS).
//  • גישת-מאפיין `t[lang]` על אובייקט ב-JS: מפתח-חסר ⇒ undefined; ב-Dart —
//    `t is Map ? t[lang] : null` (מפתח-חסר במפה ⇒ null). קלט שאינו מחרוזת ואינה
//    מפה (למשל מספר) נופל ב-JS דרך undefined-ים ל-'' — אותו מסלול כאן דרך null.
//  • השוואת `typeof === 'string'` ⇒ `is String` (בדיקת-טיפוס ריצה שקולה).

/// Fallback language order, verbatim from maor/src/types/config.ts:65
/// (`SITE_LANGS = ['he','en','yi']`). Exported like the JS source.
List<String> get siteLangs => const ['he', 'en', 'yi'];

/// True when [c] is a whitespace code unit per ECMAScript `String.prototype.trim`
/// (WhiteSpace + LineTerminator). Deliberately NOT Dart's `trim` set — see the
/// conversion note above (U+0085 NEL is trimmed by Dart but not by JS).
bool _isJsWhitespace(int c) =>
    c == 0x09 || // TAB
    c == 0x0A || // LF
    c == 0x0B || // VT
    c == 0x0C || // FF
    c == 0x0D || // CR
    c == 0x20 || // SPACE
    c == 0xA0 || // NBSP
    c == 0x1680 || // OGHAM SPACE MARK (Zs)
    (c >= 0x2000 && c <= 0x200A) || // Zs range
    c == 0x2028 || // LS
    c == 0x2029 || // PS
    c == 0x202F || // NARROW NBSP (Zs)
    c == 0x205F || // MEDIUM MATHEMATICAL SPACE (Zs)
    c == 0x3000 || // IDEOGRAPHIC SPACE (Zs)
    c == 0xFEFF; // BOM / ZWNBSP

/// JS-truthiness of `s.trim()`: does [s] contain any non-whitespace (JS set)?
bool _jsTrimNonEmpty(String s) {
  for (final c in s.codeUnits) {
    if (!_isJsWhitespace(c)) return true;
  }
  return false;
}

/// Resolve a localized text: requested language ⇒ Hebrew ('he') ⇒ first
/// non-blank value in [siteLangs] order. A plain string passes through as-is;
/// null / empty map ⇒ ''. Verbatim behaviour of new/atoms/resolve-localized.mjs.
String resolveLocalized(dynamic t, dynamic lang) {
  if (t == null) return '';
  if (t is String) return t;
  final dynamic pick = t is Map ? t[lang] : null;
  if (pick is String && _jsTrimNonEmpty(pick)) return pick;
  final dynamic he = t is Map ? t['he'] : null;
  if (he is String && _jsTrimNonEmpty(he)) return he;
  for (final l in siteLangs) {
    final dynamic v = t is Map ? t[l] : null;
    if (v is String && _jsTrimNonEmpty(v)) return v;
  }
  return '';
}

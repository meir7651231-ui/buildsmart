// ⚛️ אטום-Dart (דרגת-חוזה) · supporterVisibleForDesignations — ראוּת-תורם לפי ייעודים.
// מוצא: maor/src/components/supporters/lib.ts:55-74 · המקור: new/atoms/supporter-visible-for-designations.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). אין שכנים — אפס שקעים.
//
// תפקיד: הכרעת-בעלים 19.8 (היפוך #8) — עובד-סגור-לייעוד רואה **רק** את הייעוד שלו:
//        allowed ריק/חסר ⇒ הכול גלוי (true); תורם בלי forWho (אחרי trim) ⇒ לא-גלוי
//        (false; קודם: משותף); אחרת ⇒ גלוי רק אם forWho-הגזום ∈ allowed-הגזומים.
// קלט:  sup (Map עם forWho, או כל ערך — הקלטות-ה-Golden מזרימות String) ·
//        allowed (List/String/null). פלט: bool.
//
// הערות-המרה (מקור→Dart):
//  • truthiness של JS ⇒ _falsy מפורש (חוק-7 בתקציר): '' ו-null כוזבים; allowed=''
//    (String ריק, כמו בהקלטות) ⇒ true; List ריק אמת ב-JS אבל !allowed.length תופס
//    ⇒ _lengthOf דוק-טייפינג (חוק-15: String/List .length; Map = מפתח 'length';
//    פרימיטיב-אחר ⇒ undefined ⇒ כוזב ⇒ true — כמו JS).
//  • `sup.forWho` על String ב-JS = undefined (לא זריקה) ⇒ _forWhoOf: רק Map ניגש
//    למפתח; כל ערך אחר ⇒ null (≈undefined). `?? ''` תופס גם null וגם חסר-מפתח —
//    זהה ל-`??` של JS על undefined/null (חוק-2 לא רלוונטי: אין הבחנה כאן).
//  • `.trim()` של JS ⇒ _jsTrim בקבוצת-ES בלבד (חוק-16): U+0085/U+180E **לא** נגזמים
//    (Dart.trim כן גוזם אותם — לכן לא משתמשים בו).
//  • `new Set(...).has(fw)` ⇒ Set<String> של Dart — שוויון-מחרוזות זהה (SameValueZero
//    על מחרוזות ≡ == של Dart).
//  • `const fw` → `final fw`. אין תאריכים/מספרים/locale.

/// Is a supporter visible to a member restricted to [allowed] designations?
/// Empty/absent allowed ⇒ everything visible; supporter without a (trimmed)
/// forWho ⇒ hidden; otherwise visible iff trimmed forWho ∈ trimmed allowed.
/// Verbatim port of new/atoms/supporter-visible-for-designations.mjs.
bool supporterVisibleForDesignations(dynamic sup, dynamic allowed) {
  if (_falsy(allowed) || _falsy(_lengthOf(allowed))) return true;
  final fw = _jsTrim((_forWhoOf(sup) ?? '') as String);
  if (fw.isEmpty) return false;
  final set = <String>{};
  for (final s in allowed as List) {
    set.add(_jsTrim(s as String));
  }
  return set.contains(fw);
}

/// truthiness של JS (חוק-7): null/false/0/-0/NaN/'' כוזבים; אובייקט/מערך אמת.
bool _falsy(dynamic v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false;
}

/// `.length` בדוק-טייפינג של JS (חוק-15): String/List ⇒ length; Map (אובייקט-JS)
/// ⇒ המפתח 'length' אם קיים, אחרת undefined (null); כל ערך אחר ⇒ undefined.
dynamic _lengthOf(dynamic v) {
  if (v is String) return v.length;
  if (v is List) return v.length;
  if (v is Map) return v.containsKey('length') ? v['length'] : null;
  return null;
}

/// `sup.forWho` של JS: על Map = המפתח (חסר ⇒ undefined≈null); על פרימיטיב
/// (String וכו') = undefined — לא זריקה.
dynamic _forWhoOf(dynamic sup) => sup is Map ? sup['forWho'] : null;

/// קבוצת-הרווחים ש-`String.prototype.trim` של ES גוזם (WhiteSpace ∪ LineTerminator).
/// חוק-16: U+0085 (NEL) ו-U+180E (Mongolian VS) **אינם** בקבוצה — בניגוד ל-Dart.trim.
const String _esWs = '\u0009\u000A\u000B\u000C\u000D\u0020\u00A0\u1680'
    '\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A'
    '\u2028\u2029\u202F\u205F\u3000\uFEFF';

/// trim זהה-ביט ל-JS (קבוצת-ES בלבד).
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

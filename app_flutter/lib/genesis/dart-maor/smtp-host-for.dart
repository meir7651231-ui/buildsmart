// ⚛️ אטום-Dart (דרגת-חוזה) · smtpHostFor — שרת-היציאה (host:port) לפי דומיין כתובת-המייל.
// מוצא: maor/src/lib/smtpUrl.ts:21-26 · המקור: new/atoms/smtp-host-for.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: ספק-מייל מוכר ⇒ 'host:port' (‏465=TLS מלא · 587=STARTTLS); ספק לא-מוכר /
//        כתובת שבורה ⇒ '' (נדרש שרת ידני). הדומיין = אחרי ה-@ האחרון, נגזם ומונמך;
//        ‏@ בעמדה 0 או היעדר @ ⇒ ''.
// נתון-פנימי: SMTP_HOSTS הוטבע כקבוע-פרטי — נתון של האטום, לא קריאת-שכן (חוק-1;
//        קיים גם כאטום-קבוע smtp-hosts).
//
// 🔧 תיקון-הסגר (חוק-16): ‏Dart ‏String.trim() גוזם ‏U+0085 (NEL) ו-U+180E, ‏JS-‏trim לא
//    (אינם ב-ECMAScript WhiteSpace/LineTerminator). "user@gmail.com" ⇒ ‏JS מחזיר ''
//    (הדומיין 'gmail.com' לא-במפה) בעוד Dart גזם ל-'gmail.com' והדליק ספק-מוכר.
//    ⇒ הוחלף ‏.trim() בשקע-trim נאמן-ES (_jsTrim/_esWs) המוטבע INLINE (חוק-1: אטום לא-מייבא).
//
// הערות-המרה נוספות (מקור→Dart):
// · ‏slice(at+1) של JS ⇒ substring(at+1) — בטוח כאן: at>=1 מובטח ⇒ at+1<=length.
// · ‏SMTP_HOSTS[domain] ?? '' — Map של Dart מחזיר null למפתח-חסר ⇒ ‏?? '' זהה-ביט.
// · חוק-13 (toLowerCase): ‏JS ממפה ‏U+0130 ‏(İ) ל-'i'+U+0307; ‏Dart-VM בולע את הנקודה ⇒ 'i'.
//   ⇒ קדם-מיפוי ‏U+0130→'i̇' לפני ה-toLowerCase של Dart.

/// ספקים מוכרים — דומיין-המייל ⇒ שרת-היציאה שלו. לא מוכר ⇒ שדה-שרת ידני.
const Map<String, String> _smtpHosts = {
  'gmail.com': 'smtp.gmail.com:465',
  'googlemail.com': 'smtp.gmail.com:465',
  'outlook.com': 'smtp-mail.outlook.com:587',
  'hotmail.com': 'smtp-mail.outlook.com:587',
  'yahoo.com': 'smtp.mail.yahoo.com:465',
  'walla.co.il': 'out.walla.co.il:465',
};

/// חוק-16 · קבוצת-הרווחים של ECMAScript (trim). **בלי** U+0085/U+180E
/// (ש-Dart.trim גוזם אך JS לא). כולל WhiteSpace + LineTerminator של ES.
const Set<int> _esWs = {
  0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x20, 0xA0, 0x1680,
  0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007,
  0x2008, 0x2009, 0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000, 0xFEFF,
};

/// חוק-16 · trim נאמן-ES (String.prototype.trim). גוזם רק את _esWs.
String _jsTrim(String s) {
  var start = 0, end = s.length;
  while (start < end && _esWs.contains(s.codeUnitAt(start))) start++;
  while (end > start && _esWs.contains(s.codeUnitAt(end - 1))) end--;
  return s.substring(start, end);
}

/// הנמכה נאמנת-JS (חוק-13): ‏U+0130 ⇒ 'i'+U+0307 כמו מיפוי-full של JS, ואז toLowerCase.
String _jsToLowerCase(String s) => s.replaceAll('İ', 'i̇').toLowerCase();

/// שרת-היציאה 'host:port' של ספק-מייל מוכר לפי דומיין הכתובת; לא-מוכר/שבורה ⇒ ''.
/// Verbatim behaviour of the JS source `smtpHostFor`.
dynamic smtpHostFor(dynamic email) {
  final int at = ((email.lastIndexOf('@')) as int);
  if (at < 1) return '';
  final String domain = _jsToLowerCase(_jsTrim(((email.substring(at + 1)) as String)));
  return _smtpHosts[domain] ?? '';
}

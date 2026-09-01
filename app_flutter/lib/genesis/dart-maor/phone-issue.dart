// ⚛️ אטום-Dart (דרגת-חוזה) · phoneIssue — אבחון תקינות מספר-טלפון (null=תקין).
// מוצא: maor/src/lib/audit.ts:56-68 · המקור: new/atoms/phone-issue.mjs (כולל העוזר-הפרטי digits).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: מחזיר תיאור-בעיה בעברית או null כשתקין. סדר-הדינים כלשונו מהמקור:
//   ריק/'-' ⇒ null · 9-10 ספרות שמתחילות ב-0 ⇒ null · 8 ⇒ 'חסרה 0 מובילה' ·
//   <7 ⇒ 'קצר מדי' · לא-מתחיל-ב-0 ⇒ 'לא מתחיל ב-0' · אחרת ⇒ 'אורך חריג (<N> ספרות)'.
// קלט: String? p. פלט: String? (הודעה או null).
//
// הערות-המרה (מקור→Dart) — כללי DART-PORTING-RULES + מה שהמנוע פספס:
//  • truthiness (כלל 7): JS `!p` נכון ל-'' וגם undefined/null. ⇒ תנאי-מפורש
//    `p == null || p == '' || p == '-'` (null-של-Dart מכסה את undefined-של-JS, כלל 2).
//  • החלפה-גלובלית: JS `.replace(/\D/g,'')` הוא global ⇒ Dart `replaceAll` (לא replaceFirst —
//    המנוע פלט replaceFirst, שהיה מסיר לא-ספרה אחת בלבד. באג-מנוע שתוקן).
//  • locale/פורמט (כלל 6): אין — ההודעה מצטטת את p כלשונו, ללא toLocaleString.
//  • שרשור-מספר: JS `+ d.length` מסתמך על casting; Dart דורש טקסט מפורש ⇒ interpolation
//    `${d.length}` (המנוע פלט `+ d.length` — שגיאת-קומפילציה. תוקן).
//  • d[0]==='0' ⇒ `d.startsWith('0')`: כשמגיעים לבדיקה d כבר באורך ≥7 (הענף <7 קדם),
//    ולבדיקת-ה-null d באורך 9/10 — לעולם לא ריק, אין substring שלילי (כלל 5).

String _digits(String x) => x.replaceAll(RegExp(r'\D'), '');

/// Verbatim port of new/atoms/phone-issue.mjs (`phoneIssue`).
String? phoneIssue(String? p) {
  if (p == null || p == '' || p == '-') return null;
  final d = _digits(p);
  if ((d.length == 9 || d.length == 10) && d.startsWith('0')) return null;
  if (d.length == 8) return 'כנראה חסרה ספרת 0 מובילה: $p';
  if (d.length < 7) return 'קצר מדי: $p';
  if (!d.startsWith('0')) return 'לא מתחיל ב-0: $p';
  return 'אורך חריג (${d.length} ספרות): $p';
}

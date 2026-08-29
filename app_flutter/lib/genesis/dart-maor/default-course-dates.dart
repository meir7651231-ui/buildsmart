// חוט · default-course-dates — טווח-ברירת-מחדל לחוג = שנה"ל הנוכחית (1.9–31.7). חוזה: default-course-dates.contract.md
// המרה מ-JS (new/atoms/default-course-dates.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// מוצא: maor/src/components/courses/lib.ts:32-46 (defaultCourseDates). השכן isoTodayLocal
// (ברירת-מחדל-הפרמטר) הוסר — today מוזרק ע"י הקופסה (חוק-1 — אפס import פנימי). אפס-import (dart-core בלבד).
//
// תיקון-הסגר (גלישת-יום): הבאג הקודם השתמש ב-round-trip-guard שדחה גלישת-יום
// (‏'2026-02-30' ⇒ now() במקום Mar-2), בעוד V8 מגלגל את היום (Feb 30 ⇒ Mar 2, תקין).
// **התיקון:** _parseV8Local (הועתק INLINE מ-js-compat-reference, קידומת _, חוק-1) —
// מגלגל גלישת-יום כמו V8 אך דוחה חודש-13/00 ויום-00 (≡ Invalid Date ⇒ now()).

/// חוקים 3+4 · _parseV8Local — מחקה `new Date("YYYY-MM-DDThh:mm:ss")` של V8 (מקומי,
/// בלי אזור-זמן). מחזיר DateTime (מקומי) או null (≡ Invalid Date/NaN).
/// יום-גולש מתגלגל (Feb 30 ⇒ Mar 2), אך רק אם day∈[1,31] month∈[1,12] (אחרת NaN).
DateTime? _parseV8Local(String iso) {
  final m = RegExp(r'^([+-]?\d{4,6})-(\d{2})-(\d{2})(?:[T ](\d{2}):(\d{2})(?::(\d{2})(?:\.\d+)?)?)?$')
      .firstMatch(iso);
  if (m == null) return null;
  final year = int.parse(m.group(1)!);
  final mon = int.parse(m.group(2)!);
  final day = int.parse(m.group(3)!);
  final hour = m.group(4) != null ? int.parse(m.group(4)!) : 0;
  final min = m.group(5) != null ? int.parse(m.group(5)!) : 0;
  final sec = m.group(6) != null ? int.parse(m.group(6)!) : 0;
  // אימות-טווח נאמן-V8: חודש 1–12 · יום 1–31 · שעה 0–24 · דקה/שנייה 0–59.
  if (mon < 1 || mon > 12) return null;
  if (day < 1 || day > 31) return null;
  if (hour > 24 || min > 59 || sec > 59) return null;
  if (hour == 24 && (min != 0 || sec != 0)) return null;
  // בנייה: DateTime של Dart מגלגל גלישת-יום כמו JS (Feb 30 ⇒ Mar 2), ושעה-24 ⇒ מחרת.
  return DateTime(year, mon, day, hour, min, sec);
}

Map<String, String> defaultCourseDates(String today) {
  // JS: today.slice(0, 10) — סלחן לקצר; Dart substring זורק ⇒ שומרים אורך (כלל-המרה 5).
  final head = today.length > 10 ? today.substring(0, 10) : today;
  // JS: new Date(head + 'T12:00:00') — צהריים-מקומי (מוסכמת-maor). תאריך-שבור ⇒ NaN ⇒ נפילה לשעון.
  final DateTime base = _parseV8Local('${head}T12:00:00') ?? DateTime.now();
  final y = base.year;
  // JS getMonth() 0-based: אוגוסט=7, והתנאי m>=7. Dart month 1-based: אוגוסט=8 ⇒ month>=8 (זהה).
  // שנת-הלימודים פותחת ב-1.9. באוגוסט ואילך פותחים את השנה שמתחילה השנה;
  // בספטמבר–יולי אנחנו בתוך השנה שנפתחה בספטמבר הקודם.
  final startYear = base.month >= 8 ? y : y - 1;
  return {'start': '$startYear-09-01', 'end': '${startYear + 1}-07-31'};
}

// ⚛️ אטום-Dart (דרגת-חוזה) · buildIcs — בניית קובץ ICS ‏(RFC 5545) שלם ממופעים.
// מוצא: maor/src/lib/ics.ts:96-132 דרך new/atoms/build-ics.mjs (חוק-4 — התנהגות
//        זהה-לחלוטין למקור-ה-JS, לא-משופרת). חוזה: new/atoms/build-ics.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). העוזרים הפרטיים של
//        המקור (basicDate · basicLocal · stampUtc · nextIso) נשארים כאן — עוזר-פנימי.
// שקעים (חוק-3): icsEscape · foldIcsLine מוזרקים כפרמטרי-פונקציה.
//
// 🐛 תיקון-הסגר (24:00 — תפס אימות-עוין): המקור מפרסר את השעה עם `new Date(...)`
//    ומוודא `!Number.isNaN(getTime())`. ‏V8 מקבל '24:00' (⇒ מחרת 00:00) אך דוחה
//    '24:01'/'25:00'/'12:60'. ה-guard הישן `hh<24 && mm<60` דחה 24:00 בטעות ⇒ נפילה
//    שגויה ליום-שלם. התיקון: הזרקת `_parseV8Local` (העתק מ-machtzev/emit/js-compat)
//    שמחקה במדויק את `new Date("YYYY-MM-DDThh:mm:00")` — כולל שעה-24⇒מחרת. חוק-1:
//    אטום לא-מייבא — העוזר מוזרק INLINE בקידומת _.

String _basicDate(String iso) => iso.replaceAll('-', '');

String _p(int n, [int w = 2]) => n.toString().padLeft(w, '0');

/// תאריך+שעה מקומיים בפורמט בסיסי צף: YYYYMMDDTHHMMSS.
String _basicLocal(DateTime d) =>
    d.year.toString() + _p(d.month) + _p(d.day) +
    'T' + _p(d.hour) + _p(d.minute) + _p(d.second);

/// DTSTAMP ב-UTC: YYYYMMDDTHHMMSSZ.
String _stampUtc(DateTime now) {
  final u = now.toUtc();
  return u.year.toString() + _p(u.month) + _p(u.day) +
      'T' + _p(u.hour) + _p(u.minute) + _p(u.second) + 'Z';
}

/// יום-המחרת של ISO (ל-DTEND של אירוע יום-שלם).
String _nextIso(String iso) {
  final d = DateTime.parse(iso + 'T12:00:00');
  final n = DateTime(d.year, d.month, d.day + 1);
  return n.year.toString() + '-' + _p(n.month) + '-' + _p(n.day);
}

/// חוקים 3+4 · parseV8Local — מחקה `new Date("YYYY-MM-DDThh:mm:ss")` של V8 (מקומי,
/// בלי אזור-זמן). מחזיר DateTime (מקומי) או null (≡ Invalid Date/NaN).
/// (הועתק verbatim מ-machtzev/emit/js-compat-reference.dart — חוק-1: אטום לא-מייבא.)
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

String buildIcs(
  List<Map<String, String?>> occurrences,
  String calName,
  DateTime now,
  String Function(String) icsEscape,
  List<String> Function(String) foldIcsLine,
) {
  final lines = <String>[
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//maor-system//he//',
    'CALSCALE:GREGORIAN',
    'METHOD:PUBLISH',
    'X-WR-CALNAME:' + icsEscape(calName),
  ];
  final stamp = _stampUtc(now);
  final timeRe = RegExp(r'^\d{2}:\d{2}$');
  for (final oc in occurrences) {
    lines.add('BEGIN:VEVENT');
    lines.add('UID:' + icsEscape(oc['uid'] ?? ''));
    lines.add('DTSTAMP:' + stamp);
    // שעה שאינה HH:MM תקין ⇒ Invalid Date ⇒ נפילה בטוחה ליום-שלם (ביקורת 4.8 · נחיל 13.8).
    // המקור: /^\d{2}:\d{2}$/ ואז new Date(...)+isNaN. `_parseV8Local` = אותה סמנטיקה
    // בדיוק (24:00⇒מחרת · 24:01/25:00/12:60⇒null). לא guard-hh<24 השבור.
    final time = oc['time'];
    DateTime? parsedStart;
    if (time != null && time.isNotEmpty && timeRe.hasMatch(time)) {
      parsedStart = _parseV8Local((oc['date'] ?? '') + 'T' + time + ':00');
    }
    if (parsedStart != null) {
      final end = parsedStart.add(const Duration(milliseconds: 3600000)); // שעה — כולל גלגול-חצות
      lines.add('DTSTART:' + _basicLocal(parsedStart));
      lines.add('DTEND:' + _basicLocal(end));
    } else {
      lines.add('DTSTART;VALUE=DATE:' + _basicDate(oc['date'] ?? ''));
      lines.add('DTEND;VALUE=DATE:' + _basicDate(_nextIso(oc['date'] ?? '')));
    }
    lines.add('SUMMARY:' + icsEscape(oc['title'] ?? ''));
    final notes = oc['notes'];
    if (notes != null && notes.isNotEmpty) {
      lines.add('DESCRIPTION:' + icsEscape(notes));
    }
    final location = oc['location'];
    if (location != null && location.isNotEmpty) {
      lines.add('LOCATION:' + icsEscape(location));
    }
    lines.add('END:VEVENT');
  }
  lines.add('END:VCALENDAR');
  return lines.expand(foldIcsLine).join('\r\n') + '\r\n';
}

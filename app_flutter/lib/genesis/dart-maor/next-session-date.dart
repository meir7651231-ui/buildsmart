// ⚛️ אטום-Dart (דרגת-חוזה) · nextSessionDate — מועד-המפגש הקרוב הבא של חוג.
// מוצא: maor/src/components/courses/lib.ts:376-390 · המקור: new/atoms/next-session-date.mjs
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שקעים (חוק-1 — אפס import פנימי):
//   • sessionsOf — מחזיר את מערך-המפגשים של החוג (השכן שהוזרק כפרמטר).
//   • now — הזמן-הנוכחי מוזרק ⇒ דטרמיניסטי (default = DateTime.now()).
// קלט: c (החוג) · now · sessionsOf. פלט: DateTime? — המועד-הקרוב, או null אם אין מפגשים.
//
// הערות-המרה (מקור→Dart, לפי DART-PORTING-RULES):
//   • getMonth: JS `new Date(y, getMonth(), d, ...)` — חודש 0-אינדקסי מוחזר לבנאי 0-אינדקסי
//     ⇒ אותו חודש. ב-Dart `DateTime(y, month, d, ...)` (1-אינדקסי) נותן בדיוק אותו חודש.
//   • getDay: JS 0=ראשון..6=שבת. ב-Dart weekday 1=שני..7=ראשון ⇒ `weekday % 7` = getDay של JS.
//   • truthiness (`ss.time || '17:00'`): JS נופל ל-'17:00' גם ל-null וגם למחרוזת-ריקה.
//   • דקות `+(t[1] ?? 0) || 0`: חלק-חסר/לא-מספרי ⇒ 0 (int.tryParse ?? 0).
//   • setDate: JS מגלגל חודשים; ב-Dart בנאי-DateTime מנרמל גלישה זהה.
//   • השוואות: `d <= n` ⇒ `compareTo(n) <= 0`; `d < best` ⇒ `isBefore(best)`; `!best` ⇒ null.
//   • מוטביליות: DateTime חסר-שינוי ב-Dart ⇒ בנייה-מחדש במקום setDate.

/// Returns the next upcoming session DateTime for a course, or null if it has no
/// sessions. Verbatim behaviour of the JS source `nextSessionDate`.
DateTime? nextSessionDate(
    dynamic c, DateTime? now, dynamic Function(dynamic) sessionsOf) {
  final n = now ?? DateTime.now();
  DateTime? best;
  for (final ss in sessionsOf(c)) {
    final rawTime = ss['time'];
    // JS `ss.time || '17:00'` — null או מחרוזת-ריקה נופלים ל-ברירת-המחדל.
    final timeStr =
        (rawTime == null || rawTime == '') ? '17:00' : rawTime as String;
    final t = timeStr.split(':');
    final hours = int.parse(t[0]); // `+t[0]`
    // `+(t[1] ?? 0) || 0` — חלק-דקות חסר/לא-מספרי ⇒ 0.
    final minutes = t.length > 1 ? (int.tryParse(t[1]) ?? 0) : 0;
    var d = DateTime(n.year, n.month, n.day, hours, minutes);
    final targetDay = ss['day'] as int;
    var add = (targetDay - (d.weekday % 7) + 7) % 7;
    if (add == 0 && d.compareTo(n) <= 0) add = 7;
    // setDate(getDate()+add) — בנייה-מחדש (DateTime חסר-שינוי); שימור שעה/דקה.
    d = DateTime(d.year, d.month, d.day + add, d.hour, d.minute);
    if (best == null || d.isBefore(best)) best = d;
  }
  return best;
}

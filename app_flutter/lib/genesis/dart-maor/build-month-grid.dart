// חוט · build-month-grid — גריד חודשי לועזי/עברי מרשימת-אירועים עם שדה date.
// המרה מ-JS (new/atoms/build-month-grid.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// מוצא: maor/src/lib/monthGrid.ts:54-114 (buildMonthGrid — הגריד המשותף לקופות/חנות).
// חוזה: new/atoms/build-month-grid.contract.md.
//
// שקעים (חוק-1, אפס import פנימי):
//   cellOf(d, inMonth, hebMode, byDate) ⇒ תא (Map עם שדה 'iso' — ריפוד-הסוף נשען עליו)
//   isoOf(d) ⇒ 'YYYY-MM-DD' · hpOf(iso, d) ⇒ {day, month, year} · gemYear(y) ⇒ String.
//
// הערת-המרה (מקור→Dart): שלושת פורמטרי-ה-Intl של המקור
//   (fmtMonthYear='he' · fmtHebMonth/fmtHebYear='he-u-ca-hebrew') נשארו באטום-ה-JS
//   כ"שפה/סטנדרט". ל-dart:core אין לוח-עברי ב-Intl, לכן הם הופכים לשקעי-הצבה
//   (fmtMonthYear/fmtHebMonth/fmtHebYear) — ההזרקה מספקת התנהגות זהה. אין שינוי-לוגיקה.
//   getMonth() 0-אינדקס של JS ⇒ DateTime.month 1-אינדקס (new Date(y,m,d) ⇒ DateTime(y,m+1,d));
//   getDay() (0=ראשון) ⇒ (weekday % 7). DateTime(y,m,d) מנרמל עודף/חוסר בדיוק כמו new Date.
// אפס-import (dart:core בלבד).

Map<String, dynamic> buildMonthGrid(
  List<Map<String, dynamic>> events,
  String anchorIso,
  bool hebMode,
  Map<String, dynamic> Function(
          DateTime d, bool inMonth, bool hebMode, Map<String, List<Map<String, dynamic>>> byDate)
      cellOf,
  String Function(DateTime d) isoOf,
  Map<String, dynamic> Function(String iso, DateTime d) hpOf,
  String Function(String y) gemYear,
  String Function(DateTime d) fmtMonthYear,
  String Function(DateTime d) fmtHebMonth,
  String Function(DateTime d) fmtHebYear,
) {
  final byDate = <String, List<Map<String, dynamic>>>{};
  for (final ev in events) {
    final date = ev['date'];
    if (date == null || date == '') continue; // JS: !ev.date (undefined/'' — מדולג)
    (byDate[date as String] ??= <Map<String, dynamic>>[]).add(ev);
  }
  final anchor = DateTime.parse('${anchorIso}T12:00:00');
  if (!hebMode) {
    final first = DateTime(anchor.year, anchor.month, 1);
    final start = DateTime(first.year, first.month, 1 - (first.weekday % 7));
    final cells = <Map<String, dynamic>>[];
    for (var i = 0; i < 42; i++) {
      final d = DateTime(start.year, start.month, start.day + i);
      cells.add(cellOf(d, d.month == anchor.month, false, byDate));
    }
    return {
      'cells': cells,
      'label': fmtMonthYear(first),
      'subLabel': fmtHebMonth(first) +
          '–' +
          fmtHebMonth(DateTime(anchor.year, anchor.month + 1, 0)),
      'prevIso': isoOf(DateTime(first.year, first.month - 1, 15)),
      'nextIso': isoOf(DateTime(first.year, first.month + 1, 15)),
    };
  }
  // עברי: אחורה עד א׳ בחודש, ואז קדימה עד סוף החודש העברי
  var d = anchor;
  while (hpOf(isoOf(d), d)['day'] != 1) {
    d = DateTime(d.year, d.month, d.day - 1);
  }
  final first = d;
  final monthName = hpOf(isoOf(first), first)['month'];
  final days = <DateTime>[];
  var cur = first;
  while (hpOf(isoOf(cur), cur)['month'] == monthName && days.length < 31) {
    days.add(cur);
    cur = DateTime(cur.year, cur.month, cur.day + 1);
  }
  final last = days[days.length - 1];
  // ריפוד לתחילת השבוע (ראשון) — תאים מחוץ לחודש
  final cells = <Map<String, dynamic>>[];
  for (var i = first.weekday % 7; i > 0; i--) {
    cells.add(cellOf(
        DateTime(first.year, first.month, first.day - i), false, true, byDate));
  }
  for (final day in days) {
    cells.add(cellOf(day, true, true, byDate));
  }
  while (cells.length % 7 != 0) {
    final lastCell = DateTime.parse('${cells[cells.length - 1]['iso']}T12:00:00');
    cells.add(cellOf(
        DateTime(lastCell.year, lastCell.month, lastCell.day + 1),
        false,
        true,
        byDate));
  }
  return {
    'cells': cells,
    'label': '$monthName ${gemYear(fmtHebYear(first))}',
    'subLabel': fmtMonthYear(first) + ' – ' + fmtMonthYear(last),
    'prevIso': isoOf(DateTime(first.year, first.month, first.day - 1)),
    'nextIso': isoOf(DateTime(last.year, last.month, last.day + 1)),
  };
}

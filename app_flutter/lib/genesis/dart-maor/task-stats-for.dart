// חוט · task-stats-for — סטטיסטיקת-מנהל פר-עובד/ת: פתוחות/באיחור/בוצעו/בוצעו-השבוע.
// המרה מ-JS (new/atoms/task-stats-for.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// חולץ כלשונו מ-maor/src/lib/worktasks.ts:45-64; השכנים taskIdentity ו-taskOverdue
// הוזרקו כשקעים (חוק-1 — אפס import פנימי). אפס-import (dart-core בלבד).
//
// DART-PORTING-RULES שהוחלו:
//  · כלל-7 (truthiness): JS `!t.doneAt` = falsy (undefined/null/''/0/false/NaN) ⇒ _falsy מפורש.
//    גם תוצאת taskOverdue נבחנת כ-truthiness (`if (taskOverdue(...))`) ⇒ !_falsy.
//  · כלל-3+4 (תאריכים, לשקף V8): `new Date('YYYY-MM-DDT12:00:00')` — פרסר-ISO של V8:
//    חודש 01-12 ויום 01-31 בלבד (00/13+ ⇒ Invalid Date), יום-גולש בתוך 01-31 מגלגל
//    (למשל 2026-02-30 ⇒ 2 במרץ). Invalid Date ⇒ getTime()=NaN ⇒ ההשוואות diff>=0/diff<7
//    כוזבות (doneWeek לא נספר) — משוקף ב-double.nan, לא בזריקה (DateTime.parse זורק — אסור).
//  · JS `.slice(0, 10)` על מחרוזת קצרה מ-10 מחזיר את כולה ⇒ substring מגודר-אורך (כלל-5).
//  · `t.assignee`/`t.doneAt` — גישת-שדה על אובייקט-JS ⇒ גישת-מפתח על Map (חסר ⇒ null ≡ undefined).

bool _falsy(dynamic v) =>
    v == null || v == false || v == '' || (v is num && (v == 0 || v.isNaN));

/// חצות-צהריים מקומי של תאריך ‎YYYY-MM-DD‎ במילישניות, כמו
/// ‏`new Date(datePart + 'T12:00:00').getTime()` ב-V8; לא-תקין ⇒ NaN.
double _noonMs(String datePart) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(datePart);
  if (m == null) return double.nan;
  final y = int.parse(m.group(1)!);
  final mo = int.parse(m.group(2)!);
  final d = int.parse(m.group(3)!);
  if (mo < 1 || mo > 12 || d < 1 || d > 31) return double.nan; // V8: חודש-00/13, יום-00/32+ ⇒ Invalid
  return DateTime(y, mo, d, 12).millisecondsSinceEpoch.toDouble(); // יום-גולש 01-31 מגלגל, כמו V8
}

dynamic taskStatsFor(dynamic tasks, dynamic identity, dynamic todayIso,
    dynamic taskIdentity, dynamic taskOverdue) {
  final me = taskIdentity(identity);
  final mine =
      (tasks as List).where((t) => taskIdentity(t['assignee']) == me).toList();
  final t0 = _noonMs(todayIso is String ? todayIso : '$todayIso');
  var open = 0, overdue = 0, done = 0, doneWeek = 0;
  for (final t in mine) {
    if (_falsy(t['doneAt'])) {
      open++;
      if (!_falsy(taskOverdue(t, todayIso))) overdue++;
    } else {
      done++;
      final s = (t['doneAt'] ?? '') as String; // לא-מחרוזת truthy ⇒ זריקה, כמו .slice ב-JS
      final d = _noonMs(s.length > 10 ? s.substring(0, 10) : s);
      final diff = (t0 - d) / 86400000;
      if (diff >= 0 && diff < 7) doneWeek++;
    }
  }
  return {'open': open, 'overdue': overdue, 'done': done, 'doneWeek': doneWeek};
}

// חוט · open-tasks-for — המשימות הפתוחות של עובד/ת, ממוינות עדיפות⇒יעד⇒יצירה.
// המרה מ-JS (new/atoms/open-tasks-for.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// חולץ כלשונו מ-maor/src/lib/worktasks.ts:15-27; השכן taskIdentity מוזרק כשקע (חוק-1).
// אפס-import (dart-core בלבד).
//
// DART-PORTING-RULES שהוחלו:
//  · כלל-1 (מיון-יציב): Dart List.sort לא-יציב ל-≥32; JS Array.sort יציב. המקור נשען על
//    יציבות כדי לשמר סדר-הופעה בשוויון-מלא ⇒ decorate-sort-undecorate עם אינדקס-מקורי
//    כשובר-שוויון סופי.
//  · כלל-6/7 (locale/truthiness): JS `a.due || '9999'` נופל ל-'9999' על falsy (undefined/null/'').
//    ⇒ שקע `_orDef`. `!t.doneAt` = falsy ⇒ שקע `_falsy`. localeCompare על מחרוזות-תאריך ISO
//    שקול-סימן ל-compareTo — מוחזר כסימן בלבד (`_cmp`) כדי לחקות את חוזה-הסימן של localeCompare.
bool _falsy(dynamic v) => v == null || v == '' || v == false || v == 0;

String _orDef(dynamic v, String def) => (v == null || v == '') ? def : v as String;

int _cmp(String a, String b) {
  final c = a.compareTo(b);
  return c < 0 ? -1 : (c > 0 ? 1 : 0);
}

List<Map<String, dynamic>> openTasksFor(
  List<Map<String, dynamic>> tasks,
  dynamic identity,
  String Function(dynamic) taskIdentity,
) {
  final me = taskIdentity(identity);

  // סינון: !doneAt (falsy) וגם זהות-משובץ === me
  final filtered = <Map<String, dynamic>>[];
  for (final t in tasks) {
    if (_falsy(t['doneAt']) && taskIdentity(t['assignee']) == me) {
      filtered.add(t);
    }
  }

  // decorate-sort-undecorate — אינדקס-מקורי כשובר-שוויון סופי (חיקוי יציבות-JS)
  final indexed = <MapEntry<int, Map<String, dynamic>>>[];
  for (var i = 0; i < filtered.length; i++) {
    indexed.add(MapEntry(i, filtered[i]));
  }
  indexed.sort((ea, eb) {
    final a = ea.value;
    final b = eb.value;
    final pa = a['pri'] as int;
    final pb = b['pri'] as int;
    if (pa != pb) return pa - pb; // JS: a.pri - b.pri
    final d = _cmp(_orDef(a['due'], '9999'), _orDef(b['due'], '9999'));
    if (d != 0) return d; // JS: (a.due||'9999').localeCompare(...)
    final c = _cmp(a['createdAt'] as String, b['createdAt'] as String);
    if (c != 0) return c; // JS: a.createdAt.localeCompare(...)
    return ea.key - eb.key; // יציבות: סדר-מקורי
  });

  return [for (final e in indexed) e.value];
}

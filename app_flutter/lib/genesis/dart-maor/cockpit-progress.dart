// ⚛️ אטום-Dart (דרגת-חוזה) · cockpitProgress — התקדמות-היום מול קבוצת-מזהים-שטופלה.
// מוצא: maor/src/components/supporters/cockpit.ts:263 · המקור-הקדוש: new/atoms/cockpit-progress.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). חוק-4 — זהה-ביט למקור-JS.
//
// תפקיד: סופר כמה ממשימות התור טופלו (id ב-doneIds), ומחזיר {done, total}.
// קלט:  queue (Map{tasks:List<Map{id}>, total}) · doneIds (Set — בעל has/contains).
//        פלט: Map בסדר done → total (Map-literal = LinkedHashMap).
//
// הערות-המרה: JS `doneIds.has(t.id)` ⇒ Dart `doneIds.contains(t['id'])`. `queue.total`
//  מועבר-כמות (לא נספר). אין מיון ⇒ אין שאלת-יציבות.

/// Day progress vs. a set of handled ids. Returns {done, total}.
/// Verbatim port of new/atoms/cockpit-progress.mjs.
Map<String, dynamic> cockpitProgress(Map queue, Set doneIds) {
  int done = 0;
  for (final t in (queue['tasks'] as List)) {
    if (doneIds.contains((t as Map)['id'])) done++;
  }
  return {'done': done, 'total': queue['total']};
}

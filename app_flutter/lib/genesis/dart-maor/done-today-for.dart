// ⚛️ אטום-Dart (דרגת-חוזה) · doneTodayFor — כמה משימות סגר/ה עובד/ת היום.
// מוצא: maor/src/lib/worktasks.ts:28-31 · המקור: new/atoms/done-today-for.mjs —
//   export function doneTodayFor(tasks, identity, todayIso, taskIdentity) {
//     const me = taskIdentity(identity);
//     return tasks.filter((t) => taskIdentity(t.assignee) === me
//       && (t.doneAt ?? '').slice(0, 10) === todayIso).length;
//   }
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: סופר משימות שזהות-המשויך שלהן שווה לזהות המבוקשת **וגם** doneAt מתחיל
//        ב-todayIso (10 תווים). משימה פתוחה (בלי doneAt) לעולם לא נספרת.
// שקע (חוק-1 — במקור שכן באותו קובץ): taskIdentity — מנרמל-זהות (email) ⇒ String,
//        מופעל גם על identity וגם על t['assignee'] ⇒ השוואה חסינת-רישיות.
//
// הערות-המרה (DART-PORTING-RULES):
//  • כלל-2 (null מול undefined): JS `t.assignee`/`t.doneAt` חסרים ⇒ undefined; ה-`??`
//    של המקור מתייחס ל-null ול-undefined זהה, ולכן ב-Dart `t['assignee']`/`t['doneAt']`
//    (null כשחסר) עוברים דרך אותו `??` בדיוק — סמנטיקה זהה.
//  • כלל-5 (substring שלילי/קצר): JS `''.slice(0,10)` מחזיר '' ו-`'abc'.slice(0,10)`='abc';
//    Dart `substring(0,10)` זורק כשהאורך<10 ⇒ slice-בטוח (min-אורך) שמחקה את JS.

/// Counts how many tasks the given worker closed today. A task counts only when
/// its normalized assignee identity equals the requested identity AND its
/// `doneAt` begins with `todayIso` (first 10 chars). Open tasks (no `doneAt`)
/// never count. Verbatim behaviour of the JS source `doneTodayFor`.
int doneTodayFor(
  List<Map<String, Object?>> tasks,
  Object? identity,
  String todayIso,
  String Function(Object?) taskIdentity,
) {
  final me = taskIdentity(identity);
  var count = 0;
  for (final t in tasks) {
    final assigneeId = taskIdentity(t['assignee']);
    // (t.doneAt ?? '').slice(0, 10) — slice בטוח: JS מחזיר את המחרוזת כולה כשקצרה מ-10.
    final doneAt = (t['doneAt'] ?? '') as String;
    final day = doneAt.length >= 10 ? doneAt.substring(0, 10) : doneAt;
    if (assigneeId == me && day == todayIso) count++;
  }
  return count;
}

// ⚛️ אטום-Dart · tasksFor
// מוצא: buildsmart/app_flutter/lib/data/persona_data.dart:153-158 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: `PersonaTask` (:12) הוטבע בצורת-מינימום — רק השדות שהליטרל-הקבוע מציב
//        (id/name/worker/status/days/steps/note/orderId); getters/שדות-הזהות-השרתיים
//        (employerId/assignedWorkerUid) הושמטו. שרשרת-שער `kProfileEmptySeeds`
//        (app_profile.dart:47-52,116) + הקבוע `kPersonaTasks` (:87-135) הוטבעו verbatim.

/// צורת-מינימום של משימת-פרסונה — הפונקציה נוגעת ב-`worker`/`status`;
/// שאר השדות מוצבים ע"י ליטרל-הזרעים (נשמרים כדי שהזרע יישאר ביט-זהה).
class PersonaTask {
  const PersonaTask({
    required this.id,
    required this.name,
    required this.worker,
    required this.status,
    required this.days,
    required this.steps,
    this.note = '',
    this.orderId,
  });

  final int id;
  final String name;
  final int worker;
  final String status;
  final int days;
  final int steps;
  final String note;
  final String? orderId;
}

// ── שרשרת-השער (verbatim מ-app_profile.dart) ────────────────────────────────


/// Tasks of [worker] whose status is in [statuses] — the bucket filter
/// (current = active|rejected · queue = pending · submitted = review|done).
List<PersonaTask> tasksFor(int worker, Set<String> statuses, {required List<PersonaTask> kPersonaTasks}) =>
    kPersonaTasks
        .where((t) => t.worker == worker && statuses.contains(t.status))
        .toList();

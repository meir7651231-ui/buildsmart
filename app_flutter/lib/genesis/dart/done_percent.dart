// ⚛️ אטום-Dart (דרגת-חוזה) · donePercent
// תפקיד: אחוז-השלמה של משימה (0..100) — לפי צעדים-שהושלמו אם יש צעדים,
//        אחרת נגזר מסטטוס-המשימה (done/review=100, active=50, אחרת=0).
// מוצא: buildsmart/app_flutter/lib/logic/tasks_gantt.dart:94-126 (‏_donePercent; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). פרטי-במקור ⇒ public.
// אחים-שהוטבעו: השדות הרלוונטיים של `TaskItem` (‏steps/doneSteps/status) הוטבעו
//        כפרמטרים-בשם (טיפוס-שכן ⇒ inline verbatim; רק אורכי-הרשימות + הסטטוס נצרכים).
//        אחים-שסוקטו: — (‏layoutGantt ושאר-הקובץ אינם חלק מהאטום).
//
// קלט:  steps      — צעדי-המשימה (List); רק `isNotEmpty`/`length` נצרכים.
//       doneSteps  — הצעדים-שהושלמו (List); רק `length` נצרך.
//       status     — סטטוס-המשימה (String): 'done'/'review'/'active'/אחר.
// פלט:  int 0..100.

/// Task completion percent. Steps present ⇒ `round(done/total*100)` clamped 0..100;
/// else status-derived (done/review→100, active→50, other→0). Verbatim behaviour
/// of tasks_gantt.dart:94-126.
int donePercent({
  required List<Object?> steps,
  required List<Object?> doneSteps,
  required String status,
}) {
  if (steps.isNotEmpty) {
    final pct = (doneSteps.length / steps.length * 100).round();
    return pct < 0 ? 0 : (pct > 100 ? 100 : pct);
  }
  switch (status) {
    case 'done':
    case 'review':
      return 100;
    case 'active':
      return 50;
    default: // pending · rejected · proposed
      return 0;
  }
}

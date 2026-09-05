// ⚛️ אטום-Dart (דרגת-חוזה) · buildTasksGantt
// תפקיד: פורס משימות ל-Gantt — משימות-מעוגנות (scheduledStart!=null) הופכות ל-GanttBar
//        עם startDay יחסי ליום-המוקדם-ביותר, lenDays≥1, מיון לפי startDay ואז taskId;
//        spanDays = הקצה-הרחוק-ביותר; משימות-לא-מעוגנות מוחזרות בנפרד.
// מוצא: buildsmart/app_flutter/lib/logic/tasks_gantt.dart:127-187 (חוק-4).
// אחים שהוטבעו/סוקטו (חוק-3):
//   • _dateOnly(d) (עוזר-פרטי, "time-of-day dropped") ⇒ הוטבע inline כ-DateTime(y,m,d).
//   • _donePercent(t) (עוזר-פרטי, נוסחה לא-בטיוטה) ⇒ שקע-פונקציה `donePercent`.
//   • daysBetweenDst(a,b) (הפרש-ימים DST-בטוח) ⇒ שקע-פונקציה `daysBetweenDst`.
//   • טיפוסי TaskItem/GanttBar/TasksGanttLayout ⇒ הוטבעו inline (status כ-String).
// טוהר: dart:core בלבד.

/// verbatim tasks_gantt.dart:127-187 (_dateOnly מוטבע; _donePercent/daysBetweenDst כשקעים).
TasksGanttLayout buildTasksGantt(
  List<TaskItem> tasks, {
  required int Function(DateTime a, DateTime b) daysBetweenDst,
  required int Function(TaskItem t) donePercent,
}) {
  final scheduled = <TaskItem>[];
  final unscheduled = <TaskItem>[];
  for (final t in tasks) {
    if (t.scheduledStart != null) {
      scheduled.add(t);
    } else {
      unscheduled.add(t);
    }
  }

  if (scheduled.isEmpty) {
    return TasksGanttLayout(
      bars: const [],
      spanDays: 0,
      unscheduled: unscheduled,
    );
  }

  var earliest = _dateOnly(scheduled.first.scheduledStart!);
  for (final t in scheduled) {
    final d = _dateOnly(t.scheduledStart!);
    if (d.isBefore(earliest)) earliest = d;
  }

  final bars = <GanttBar>[
    for (final t in scheduled)
      GanttBar(
        taskId: t.id,
        name: t.name,
        startDay: () {
          final off = daysBetweenDst(earliest, t.scheduledStart!);
          return off < 0 ? 0 : off;
        }(),
        lenDays: t.days < 1 ? 1 : t.days,
        donePercent: donePercent(t),
        status: t.status,
      ),
  ]..sort((a, b) {
      final byStart = a.startDay.compareTo(b.startDay);
      return byStart != 0 ? byStart : a.taskId.compareTo(b.taskId);
    });

  var spanDays = 0;
  for (final b in bars) {
    final end = b.startDay + b.lenDays;
    if (end > spanDays) spanDays = end;
  }

  return TasksGanttLayout(
    bars: bars,
    spanDays: spanDays,
    unscheduled: unscheduled,
  );
}

// עוזר-פרטי מוטבע: יום-בלבד (זמן-היום מושמט) — כמתואר בהערות-המקור.
DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

// — טיפוסי-שכן מוטבעים (השדות הנקראים ע"י האטום בלבד) —
class TaskItem {
  const TaskItem({
    required this.id,
    required this.name,
    required this.days,
    required this.status,
    this.scheduledStart,
  });
  final String id;
  final String name;
  final int days;
  final String status;
  final DateTime? scheduledStart;
}

class GanttBar {
  const GanttBar({
    required this.taskId,
    required this.name,
    required this.startDay,
    required this.lenDays,
    required this.donePercent,
    required this.status,
  });
  final String taskId;
  final String name;
  final int startDay;
  final int lenDays;
  final int donePercent;
  final String status;
}

class TasksGanttLayout {
  const TasksGanttLayout({
    required this.bars,
    required this.spanDays,
    required this.unscheduled,
  });
  final List<GanttBar> bars;
  final int spanDays;
  final List<TaskItem> unscheduled;
}

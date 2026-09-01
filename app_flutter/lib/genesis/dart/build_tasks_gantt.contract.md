# חוזה · `buildTasksGantt` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/tasks_gantt.dart:127-187`.

## תפקיד
פורס משימות ל-Gantt: מעוגנות (scheduledStart≠null) ⇒ GanttBar עם startDay יחסי ליום-המוקדם-ביותר; לא-מעוגנות מוחזרות בנפרד.

## חתימה
```dart
TasksGanttLayout buildTasksGantt(List<TaskItem> tasks, {
  required int Function(DateTime a, DateTime b) daysBetweenDst,
  required int Function(TaskItem t) donePercent,
})
// TaskItem{id,name,days,status,scheduledStart?} · GanttBar{taskId,name,startDay,lenDays,donePercent,status}
// · TasksGanttLayout{bars,spanDays,unscheduled} — מוטבעים inline (status=String)
```

## התנהגות (עוגן tasks_gantt.dart:127-187)
1. חלוקה ל-scheduled/unscheduled.
2. scheduled ריק ⇒ `TasksGanttLayout(bars:[], spanDays:0, unscheduled)`.
3. `earliest` = ה-`_dateOnly(scheduledStart)` המוקדם (‏`_dateOnly(d)=DateTime(y,m,d)` מוטבע).
4. לכל scheduled ⇒ GanttBar: `startDay = max(0, daysBetweenDst(earliest, scheduledStart))`; `lenDays = days<1?1:days`; `donePercent(t)`; `status`.
5. bars ממוינים לפי `startDay` ואז `taskId`.
6. `spanDays` = max(`startDay+lenDays`).

## שקעים
- `daysBetweenDst(a,b)` — הפרש-ימים DST-בטוח (סופר תאריכי-UTC) ⇒ שקע.
- `donePercent(t)` — עוזר-פרטי (נוסחה לא-בטיוטה) ⇒ שקע.
- `_dateOnly` — עוזר-פרטי ("time-of-day dropped") הוטבע inline.

## דוגמאות-מחייבות (daysBetweenDst=הפרש-תאריך; donePercent=done?100:50)
| # | קלט | קובע |
|---|------|------|
| 0 | 2 לא-מעוגנות | bars=[], span=0, unscheduled=2 |
| 1 | T1(Jan5,3,active), T2(Jan1,2,done), T3(null), T4(Jan1,0) | unscheduled=[T3]; סדר bars=[T2,T4,T1]; T2(start0,len2,done100); T4(len1 מ-days0); T1(start4,len3,done50); span=7 |
| 2 | S(Mar10,5) יחיד | start0, span=5 |

## DoD
```
dart run --enable-asserts new/dart/build_tasks_gantt_test.dart  ⇒ exit 0 + "OK buildTasksGantt: 8 asserts passed"
```

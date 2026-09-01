# חוזה · `buildCohort` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/intel/segments.dart:222-248` (‏`_buildCohort`).

## תפקיד
בונה `RetentionCohort` ליום-בסיס: לכל offset-ימים קדימה סופר כמה מקבוצות-החברים "חזרו" באותו יום.

## חתימה
```dart
RetentionCohort buildCohort(DateTime day, List<Set<DateTime>> members)
// RetentionCohort{ DateTime cohortDay; int size; Map<int,int> returningByDay } — מוטבע inline
```

## התנהגות (עוגן segments.dart:222-248)
1. `maxOffset` = ה-`d.difference(day).inDays` הגדול-ביותר על פני כל התאריכים בכל החברים (מתחיל מ-0).
2. לכל `n` מ-0 עד `maxOffset`: `target = day.add(Duration(days:n))`; `returningByDay[n]` = מס' קבוצות-חברים שמכילות את `target`.
3. `size = members.length`; `cohortDay = day`.
4. members ריק ⇒ maxOffset=0 ⇒ returningByDay={0:0}, size=0.

## שקעים
אין. טיפוס-התוצאה מוטבע inline verbatim.

## דוגמאות-מחייבות
עם `day=UTC(2026-01-01)`, `plus(k)=day+k ימים`:
| # | members | ⇒ |
|---|---------|---|
| 1 | [{p0,p2},{p1,p2},{}] | size=3 · rbd={0:1,1:1,2:2} |
| 2 | [] | size=0 · rbd={0:0} |
| 3 | [{p3}] | size=1 · rbd={0:0,1:0,2:0,3:1} |

## DoD
```
dart run --enable-asserts new/dart/build_cohort_test.dart  ⇒ exit 0 + "OK buildCohort: 9 asserts passed"
```

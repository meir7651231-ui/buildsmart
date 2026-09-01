# חוזה · `tasksFor`

מוצא: `buildsmart/app_flutter/lib/data/persona_data.dart:153-158`.

## חתימה
```dart
List<PersonaTask> tasksFor(int worker, Set<String> statuses)
```

## התנהגות
מסנן את קבוע-הזרעים `kPersonaTasks` לפי שני תנאים ‏(AND): ‏`t.worker == worker`
**וגם** ‏`statuses.contains(t.status)` — מסנן-הדלי של תצוגת-הפרסונה
(נוכחי = active|rejected · תור = pending · הוגש = review|done). שומר על סדר-המקור.

## מפל-מינימום
- `PersonaTask` — צורת-מינימום: רק השדות שהליטרל מציב. השדות השרתיים
  (`employerId`/`assignedWorkerUid`) הושמטו (לא-בליטרל, לא-נגועים).
- שרשרת-השער `kProfileEmptySeeds` = `_clean || _c2` הוטבעה verbatim; בברירת-המחדל
  ‏(`APP_PROFILE=demo`) שווה `false` ⇒ ‏`kPersonaTasks` = הרשימה המלאה.
- `kPersonaTasks` (5 רשומות) הוטבע byte-verbatim.

## שוליים
- worker ללא-משימות-תואמות ⇒ רשימה ריקה.
- `statuses` ריק ⇒ רשימה ריקה (אף status לא נכלל).

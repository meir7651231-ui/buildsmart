# חוזה · `donePercent` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/tasks_gantt.dart:94-126`
(‏`_donePercent`, פרטי-במקור ⇒ public). שדות-`TaskItem` הרלוונטיים (steps/doneSteps/status)
הוטבעו כפרמטרים-בשם (חוק-3: טיפוס-שכן ⇒ inline). אין קריאה-לשכן ⇒ אין שקע.

## חתימה
```dart
int donePercent({required List<Object?> steps, required List<Object?> doneSteps, required String status})
```

## קלט
- `steps` — צעדי-המשימה. נצרכים רק `isNotEmpty` (‏:95) ו-`length` (‏:97).
- `doneSteps` — צעדים-שהושלמו. נצרך רק `length` (‏:97).
- `status` — סטטוס-המשימה (String).

## פלט / התנהגות (עוגני-שורה)
- `:95-99` — יש צעדים ⇒ `pct = round(doneSteps.length / steps.length * 100)`, נחתך ל-0..100.
- `:100-107` — אין צעדים ⇒ switch על `status`: `'done'`/`'review'` ⇒ `100`;
  `'active'` ⇒ `50`; ברירת-מחדל (pending/rejected/proposed/אחר) ⇒ `0`.
- **קדימות**: מסלול-הצעדים גובר על הסטטוס — משימה עם צעדים מתעלמת מ-status.

## דוגמאות מספריות
| # | steps | doneSteps | status | ⇒ |
|---|-------|-----------|--------|---|
| 1 | `[a,b,c,d]` | `[a]` | `'active'` | `25` (צעדים גוברים) |
| 2 | `[a,b]` | `[a,b]` | `'pending'` | `100` |
| 3 | `[a,b,c]` | `[]` | `'done'` | `0` (צעדים גוברים) |
| 4 | `[]` | `[]` | `'done'` | `100` |
| 5 | `[]` | `[]` | `'review'` | `100` |
| 6 | `[]` | `[]` | `'active'` | `50` |
| 7 | `[]` | `[]` | `'pending'` | `0` |
| 8 | `[]` | `[]` | `'proposed'` | `0` |
| 9 | `[a,b,c]` | `[a,b,c,d]` | `'x'` | `100` (‏133→נחתך ל-100) |
| 10 | `[a,b,c]` | `[a]` | `'x'` | `33` (‏33.3→round) |

## שקעים
- אין. `List.isNotEmpty`/`length`/`num.round` — שפה/סטנדרט.

## DoD
```
dart run --enable-asserts new/dart/done_percent_test.dart  ⇒ exit 0 + "OK donePercent: N asserts passed"
```

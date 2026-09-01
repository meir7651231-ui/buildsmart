# חוזה · `conditionMatches` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/rules_model.dart:401-419`
(‏`_conditionMatches`, פרטי-במקור ⇒ public).

**שקע:** `_fieldValue(field, order, now)` (מיצוי הערך-המספרי של השדה — READ-ONLY;
במקור `ageDays`=`now-createdAt` בימים, `sum`/`items` שדות-ההזמנה) הומר לשקע `fieldValue`.
**הוטבע:** שדות-`RuleCondition` (‏field/op/value) כ-record inline.

## חתימה
```dart
bool conditionMatches<T>(
  ({String field, String op, num value}) c,
  T order,
  DateTime now, {
  required num Function(String field, T order, DateTime now) fieldValue,
})
```

## קלט
- `c` — התנאי: `field` (איזה שדה), `op` (אופרטור), `value` (סף מספרי).
- `order`, `now` — מועברים אל השקע `fieldValue` בלבד.
- `fieldValue` — **שקע** (חוק-3): הערך-המספרי של `c.field` על ההזמנה.

## פלט / התנהגות (עוגני-שורה)
- `:402` — `v = fieldValue(c.field, order, now)`.
- `:403-417` — switch על `c.op`: `'>'`⇒`v>value` · `'>='`⇒`v>=value` · `'<'`⇒`v<value` ·
  `'<='`⇒`v<=value` · `'='`⇒`v==value`.
- `:418` — אופרטור לא-מוכר (או ריק) ⇒ `false` (ברירת-מחדל-סגורה).

## דוגמאות (‏fieldValue מחזיר קבוע `v`)
| # | v | op | value | ⇒ |
|---|---|----|-------|---|
| 1 | 10 | `'>'` | 5 | `true` |
| 2 | 10 | `'>='` | 10 | `true` |
| 3 | 10 | `'<'` | 5 | `false` |
| 4 | 5 | `'<='` | 5 | `true` |
| 5 | 5 | `'='` | 5 | `true` |
| 6 | 5 | `'='` | 6 | `false` |
| 7 | 10 | `'!='` | 5 | `false` (op לא-מוכר) |
| 8 | 10 | `''` | 5 | `false` (op ריק) |

## שקעים
- `fieldValue` — הזרקת מיצוי-הערך. הבדיקה מזריקה מחזיר-קבוע ומוודאת שהשדה/order/now עוברים.

## DoD
```
dart run --enable-asserts new/dart/condition_matches_test.dart  ⇒ exit 0 + "OK conditionMatches: N asserts passed"
```

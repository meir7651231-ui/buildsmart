# חוזה · `matchConditionField` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/rules_model.dart:201-202`
(‏`matchConditionField`). האח private `_matchClosed` (‏`registry_view.dart:237-260`) הוטבע verbatim inline (חוק-1).

## הכרעת-שקע (שקיפות)
המקור: `matchConditionField(reply) => _matchClosed(kRuleConditionFields, reply)`.
הקבוע `kRuleConditionFields` **אינו בגוף-הטיוטה**, ו-grep-יחיד במקור-הנוכחי
(`app_flutter/lib`) החזיר ריק (קבצי-המקור נמחקו/הוזזו). לכן — לפי המגילה
("ערכי-const חסרים … רק אם ממש חסר ⇒ grep יחיד") — הקבוע הופך לשקע-נתון
`conditionFields` (חוק-3). התנהגות-האטום זהה-ביט בהינתן הקבוצה.

## חתימה
```dart
String? matchConditionField(String reply, {required Set<String> conditionFields})
```

## קלט
- `reply` — תשובת-המודל הגולמית.
- `conditionFields` — **שקע**: `kRuleConditionFields` verbatim (קבוצת שדות-התנאי הסגורה, למשל `ageDays`/`sum`/`count`).

## פלט / התנהגות (עוגני-שורה)
- `:201-202` — `_matchClosed(kRuleConditionFields, reply)`.
- `_matchClosed`: מדויק גובר → מוכל-ארוך-ביותר → null; reply-ריק ⇒ null.

## דוגמאות מספריות (‏conditionFields: `{'ageDays','sum','count'}`)
| # | reply | ⇒ |
|---|-------|---|
| 1 | `'ageDays'` | `'ageDays'` (מדויק) |
| 2 | `'התנאי sum גדול'` | `'sum'` (מוכל) |
| 3 | `'zzz'` | `null` (אין-התאמה, drop) |
| 4 | `'   '` | `null` (ריק) |
| 5 | (conditionFields ריק) `'sum'` | `null` (fail-closed) |

## שקעים
- `conditionFields` — הזרקת-קבוצה (חוק-3, בגלל היעדר-ערכי-הקבוע במקור).

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/match_condition_field_test.dart  ⇒ exit 0 + "OK matchConditionField: N asserts passed"
```

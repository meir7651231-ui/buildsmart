# חוזה · `freeValueOk` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:231-286`
(‏`_freeValueOk` — 6 השורות הראשונות בבלוק; `_resolveStyle`/`_resolveToken` הן שכנים
נפרדים שאינם חלק מהאטום). שתי קריאות-השכן (`reg.allowedValues`, `matchValue`) הפכו
לשקעים (חוק-3).

## חתימה
```dart
bool freeValueOk(String target, String prop, String? value, {
  required Iterable<String> Function(String target, String prop) allowedValues,
  required String? Function(String target, String prop, String value) matchValue,
})
```

## קלט
- `target`, `prop` — מזהי אלמנט/מאפיין.
- `value` — הערך לבדיקה (nullable).
- `allowedValues` — **שקע**: במקור `reg.allowedValues(target, prop)` (אוסף-סגור).
- `matchValue` — **שקע**: במקור `matchValue(reg, target, prop, value)` (String? — value מובטח לא-null בקריאה).

## פלט / התנהגות (עוגני-שורה)
- `edit_intent.dart:232` — `value == null` ⇒ `true` (אין ערך לבדוק).
- `edit_intent.dart:233` — `allowedValues(target, prop).isEmpty` ⇒ `true` (תוכן-חופשי, אין אוסף-סגור).
- `edit_intent.dart:234` — אחרת ⇒ `matchValue(...) != null` (חייב להיפתר מול האוסף-הסגור).
- **סדר-הבדיקות קדוש:** null גובר על ריק-אוסף גובר על matchValue (short-circuit).

## דוגמאות מספריות
| # | value | allowedValues | matchValue | ⇒ |
|---|-------|---------------|-----------|---|
| 1 | `null` | (לא-נקרא) | (לא-נקרא) | true |
| 2 | `'x'` | `[]` (ריק) | (לא-נקרא) | true (חופשי) |
| 3 | `'red'` | `['red','blue']` | `'red'` | true (נפתר) |
| 4 | `'pink'` | `['red','blue']` | `null` | false (המצאה) |
| 5 | `null` | `['red']` | (לא-נקרא) | true (null ראשון) |

## שקעים
- `allowedValues`, `matchValue` — הזרקת-ריאדרים (חוק-3). הבדיקה מזריקה מפות/פונקציות
  סינתטיות ומוודאת שכל שקע נקרא רק כשצפוי (short-circuit).

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/free_value_ok_test.dart  ⇒ exit 0 + "OK freeValueOk: N asserts passed"
```

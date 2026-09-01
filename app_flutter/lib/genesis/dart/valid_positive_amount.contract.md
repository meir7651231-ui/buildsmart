# חוזה · `validPositiveAmount` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/input_validators.dart:91-92`
(‏docstring :89-90). אטום-טהור — אפס תלות-שכן, אפס שקע (אופרטורים + `num.isFinite` בלבד).

## חתימה
```dart
bool validPositiveAmount(num? value)
```

## קלט
- `value` — `num?` (‏int או double, עשוי `null`). הכוונה: התוצאה הישירה של
  `int.tryParse` / `double.tryParse`, ש-`null` שלה = "לא-מספר".

## פלט / התנהגות (עוגני-שורה)
- `input_validators.dart:91-92` — `value != null && value.isFinite && value > 0`:
  שרשור-`&&` עם קצר-מעגל, בסדר קבוע:
  1. `value != null` — `null` ⇒ מיד `false` (בלי הערכת `.isFinite`, שהיה זורק על null).
  2. `value.isFinite` — פוסל `double.infinity`, `double.negativeInfinity`, `double.nan`
     (`NaN.isFinite == false`). ‏int תמיד סופי.
  3. `value > 0` — גדול-**ממש** מ-0: `0` ו-`-0.0` ⇒ `false` (השוואה 0 > 0 = false);
     שלילי ⇒ `false`; חיובי כלשהו (גם `double.minPositive`) ⇒ `true`.

## דוגמאות מספריות (מקריאת-הקוד + הבדיקה החיה :148-168)
| # | value | ⇒ | סיבה |
|---|-------|---|------|
| 1 | `500` | `true` | int חיובי סופי |
| 2 | `0.5` | `true` | double חיובי סופי |
| 3 | `-500` | `false` | שלילי ⇒ `> 0` false |
| 4 | `0` | `false` | 0 אינו גדול-ממש מ-0 |
| 5 | `null` | `false` | `!= null` false ⇒ קצר-מעגל |
| 6 | `double.infinity` | `false` | `isFinite` false |
| 7 | `double.nan` | `false` | `NaN.isFinite` false |
| 8 | `double.negativeInfinity` | `false` | `isFinite` false (עדשה-עוינת) |
| 9 | `-0.5` | `false` | double שלילי (עדשה-עוינת) |
| 10 | `0.0` | `false` | אפס-double, לא גדול-ממש (עדשה-עוינת) |
| 11 | `double.minPositive` | `true` | הקטן-ביותר-חיובי עדיין `> 0` (עדשה-עוינת) |

## עדשה-עוינת (CURRICULUM #6)
קלטי-הקצה שהמקור מטפל בהם מאומתים כאן: `null` (כשל-tryParse) ⇒ false ולא חריגה,
תודות לקצר-המעגל של `!= null`; שלושת הלא-סופיים (`infinity`/`-infinity`/`nan`) ⇒ false
דרך `isFinite`; ו-0/`-0.0`/שלילי ⇒ false דרך ה-`> 0` המחמיר (לא `>=`). `double.minPositive`
מוכיח שהגבול הוא אפס-בלבד, לא סף כלשהו.

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/valid_positive_amount_test.dart  ⇒ exit 0 + "OK validPositiveAmount: N asserts passed"
```

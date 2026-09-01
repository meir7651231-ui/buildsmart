# חוזה · `dayBucket` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/intel/segments.dart:249-252`
(‏`_dayBucket`, פרטי-במקור ⇒ public). אין קריאה-לשכן ⇒ אין שקע.

## חתימה
```dart
DateTime dayBucket(DateTime at, Duration offset)
```

## קלט
- `at` — הרגע (DateTime). מנורמל ל-UTC דרך `at.toUtc()` (‏segments.dart:250).
- `offset` — היסט-האזור העסקי (Duration), מתווסף לפני חיתוך-היום.

## פלט / התנהגות (עוגני-שורה)
- `:250` — `shifted = at.toUtc().add(offset)`.
- `:251` — `return DateTime.utc(shifted.year, shifted.month, shifted.day)` ⇒
  תמיד `DateTime.utc` ב-00:00:00.000Z של יום-הרגע-המוסט.
- ה-offset יכול להעביר את הרגע ליום-הקלנדרי הבא/הקודם (ה-UTC-מוסט קובע את היום).

## דוגמאות מספריות
| # | at (UTC) | offset | ⇒ |
|---|----------|--------|---|
| 1 | 2026-08-26 22:30Z | +3h | `2026-08-27 00:00:00.000Z` (חוצה חצות ⇒ יום הבא) |
| 2 | 2026-08-26 01:00Z | -3h | `2026-08-25 00:00:00.000Z` (נסוג ⇒ יום קודם) |
| 3 | 2026-08-26 12:00Z | 0 | `2026-08-26 00:00:00.000Z` |

## שקעים
- אין. `DateTime.toUtc`/`add`/`DateTime.utc` — שפה/סטנדרט.

## DoD
```
dart run --enable-asserts new/dart/day_bucket_test.dart  ⇒ exit 0 + "OK dayBucket: N asserts passed"
```

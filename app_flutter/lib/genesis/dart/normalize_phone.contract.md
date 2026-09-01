# חוזה · `normalizePhone` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/input_validators.dart:48-58`
(‏`normalizePhone`). נירמול טלפון: ספרות-בלבד ואז פירוק קידומת-חיוג-בינלאומי.

## חתימה
```dart
String normalizePhone(String input)
```

## קלט
- `input` — מחרוזת-טלפון חופשית (מקפים/רווחים/‎+‎/אותיות מותרים בקלט).

## התנהגות (עוגני-שורה)
- `input_validators.dart:49` — `digits = input.replaceAll(RegExp(r'\D'), '')` (הסרת כל לא-ספרה).
- `:50` — ריק ⇒ `''`.
- `:51` — `startsWith('00')` ⇒ `substring(2)` (הסרת 00 הבינ"ל).
- `:52` — `startsWith('972')` ⇒ `'0' + substring(3)` (קידומת-ישראל ⇒ 0 מקומי).
- הסדר משמעותי: "00972…" עובר קודם פירוק-00 ואז פירוק-972 (פירוק-כפול).

## דוגמאות מספריות
| # | input | ⇒ |
|---|-------|---|
| 1 | `'050-123-4567'` | `'0501234567'` |
| 2 | `'+972-50-1234567'` | `'0501234567'` |
| 3 | `'00972501234567'` | `'0501234567'` (00 ואז 972) |
| 4 | `''` | `''` |
| 5 | `'abc!!'` | `''` (אין ספרות) |
| 6 | `'972'` | `'0'` (‏972 ⇒ 0 + ריק) |
| 7 | `'00'` | `''` (הסרת-00 ⇒ ריק) |

## שקעים
אין. `String.replaceAll`/`RegExp`/`startsWith`/`substring` — שפה בלבד.

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/normalize_phone_test.dart  ⇒ exit 0 + "OK normalizePhone: N asserts passed"
```

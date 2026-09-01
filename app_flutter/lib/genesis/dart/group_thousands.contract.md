# חוזה · `groupThousands` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/money_format.dart:19-30`.

## חתימה
```dart
String groupThousands(int n)
```

## פלט / התנהגות (עוגני-שורה)
- `money_format.dart:20` — `s = n.abs().toString()` (ערך-מוחלט; הסימן נעלם).
- `:22-25` — לולאה: פסיק לפני מיקום `i>0` שבו `(s.length - i) % 3 == 0`, ואז הספרה.
- `:26` — `buf.toString()`.

## דוגמאות מספריות
| # | n | ⇒ |
|---|---|---|
| 1 | `0` | `'0'` |
| 2 | `5` | `'5'` |
| 3 | `100` | `'100'` |
| 4 | `1000` | `'1,000'` |
| 5 | `3150` | `'3,150'` |
| 6 | `1000000` | `'1,000,000'` |
| 7 | `-3150` | `'3,150'` (הסימן מושמט — `abs`) |
| 8 | `12345` | `'12,345'` |
| 9 | `999` | `'999'` |

## שקעים
- אין. `int.abs`, `int.toString`, `StringBuffer` — שפה/סטנדרט.

## DoD
```
dart run --enable-asserts new/dart/group_thousands_test.dart  ⇒ exit 0 + "OK groupThousands: N asserts passed"
```

# חוזה · `band` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/customer_score.dart:61-64` (‏`_band`).

## תפקיד
מדרג ערך-מספרי ל-3 רמות לפי שני ספים. פונקציה עצמאית, אפס שקע.

## חתימה
```dart
int band(int value, int high, int mid)
```

## התנהגות (עוגן customer_score.dart:61-64)
`value >= high ? 2 : (value >= mid ? 1 : 0)` — השוואות `>=` בלבד, ללא מגן על סדר הספים.

## דוגמאות-מחייבות
| # | value | high | mid | ⇒ |
|---|-------|------|-----|---|
| 1 | 100 | 90 | 50 | 2 (‏≥high) |
| 2 | 90 | 90 | 50 | 2 (‏==high) |
| 3 | 89 | 90 | 50 | 1 (‏high>val≥mid) |
| 4 | 50 | 90 | 50 | 1 (‏==mid) |
| 5 | 49 | 90 | 50 | 0 (‏<mid) |
| 6 | 5 | 5 | 5 | 2 (‏high==mid ⇒ ≥high מכריע ל-2) |
| 7 | 4 | 5 | 5 | 0 (אין רמת-1 כש-high==mid) |

## שקעים
אין.

## DoD
```
dart run --enable-asserts new/dart/band_test.dart  ⇒ exit 0 + "OK band: 9 asserts passed"
```

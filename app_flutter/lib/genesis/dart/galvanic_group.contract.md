# חוזה · `galvanicGroup` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:46-69`
(‏`_galvanicGroup`). ה-const-האחיות `copper`/`iron` הוטבעו inline verbatim מגוף-הטיוטה.

## חתימה
```dart
String? galvanicGroup(String m)
```

## פלט / התנהגות (עוגני-שורה)
- `plumbing_trade_seed.dart:47` — `const copper = {'נחושת', 'פליז'}`.
- `:48` — `const iron = {'פלדה', 'נירוסטה'}`.
- `:49` — `copper.contains(m) ⇒ 'copper-group'`.
- `:50` — `iron.contains(m) ⇒ 'iron-group'`.
- `:51` — אחרת ⇒ `null`.

## דוגמאות מספריות
| # | m | ⇒ |
|---|---|---|
| 1 | `'נחושת'` | `'copper-group'` |
| 2 | `'פליז'` | `'copper-group'` |
| 3 | `'פלדה'` | `'iron-group'` |
| 4 | `'נירוסטה'` | `'iron-group'` |
| 5 | `'PVC'` | `null` |
| 6 | `''` | `null` |
| 7 | `'נחושת '` (רווח-נספח) | `null` (התאמה מדויקת בלבד) |

## שקעים
- אין. `Set.contains` — שפה/סטנדרט. הקבוצות = const מוטבע verbatim.

## DoD
```
dart run --enable-asserts new/dart/galvanic_group_test.dart  ⇒ exit 0 + "OK galvanicGroup: N asserts passed"
```

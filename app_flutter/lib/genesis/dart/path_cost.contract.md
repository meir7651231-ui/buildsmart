# חוזה · `pathCost` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/install_engine.dart:496-502`
(‏`_pathCost`, פרטי-במקור). מקודם ל-public (כלל-הגלגול). סוכם עלות-קשת על-פני
נתיב-מוצרים; משמש את `findAlternativePaths` (Yen) לדירוג-חלופות.

## חתימה
```dart
int pathCost<T>(List<T> path, {required int Function(T a, T b) edgeCost})
```

## שקעים (חוק-3)
- `edgeCost` — העוזר-השכן `_edgeCost(a, b)` (install_engine.dart; במקור
  `10·(חלקים) + מעברי-חומר`). הבדיקה מזריקה עלות דטרמיניסטית.
- טיפוס `T` — במקור `LipskeyCatalogProduct` ⇒ גנרי (חוק-1).

## התנהגות (עוגני-שורה)
- `install_engine.dart:671-674` — `c = 0`; לכל `i` מ-0 עד `length-2`:
  `c += edgeCost(path[i], path[i+1])`.
- נתיב באורך `< 2` ⇒ אין קשתות ⇒ `0`.

## דוגמאות (‏edgeCost קבוע `(a,b) => 10`, כמו בסיס-המקור)
| # | path | ⇒ |
|---|------|---|
| 1 | `[]` | `0` |
| 2 | `['a']` | `0` (אין זוגות) |
| 3 | `['a','b']` | `10` (קשת אחת) |
| 4 | `['a','b','c']` | `20` |
| 5 | `['a','b','c','d']` | `30` |

## דוגמאות (‏edgeCost תלוי-אורך `(a,b) => a.length + b.length`)
| # | path | ⇒ |
|---|------|---|
| 6 | `['ab','c']` | `3` (2+1) |
| 7 | `['a','bb','ccc']` | `8` ((1+2)+(2+3)) |

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/path_cost_test.dart  ⇒ exit 0 + "OK pathCost: N asserts passed"
```

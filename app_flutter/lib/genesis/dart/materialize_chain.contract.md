# חוזה · `materializeChain` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/install_engine.dart:1319-1329`
(‏`materializeChain`). משלים שרשרת-התקנה: בין כל שני עוגנים סמוכים מזריק את
מוצר-המחבר. הקורא היחיד: `buildInstallation` (שקע-מועמד בטיוטה — לא נדרש כאן).

## חתימה
```dart
List<T> materializeChain<T>(List<T> chain, {required T? Function(T a, T b) pipeBetween})
```

## שקעים (חוק-3)
- `pipeBetween` — העוזר-השכן `_pipeBetween(a, b)` (install_engine.dart). מחזיר את
  מוצר-המחבר בין שני עוגנים, או `null` כשאין מחבר. הבדיקה מזריקה כלל דטרמיניסטי.
- טיפוס `T` — במקור `LipskeyCatalogProduct` (טיפוס-קטלוג גדול). האטום נוגע רק
  במבנה-הרשימה ⇒ גנרי (חוק-1).

## התנהגות (עוגני-שורה)
- `install_engine.dart:1320` — `chain.length < 2` ⇒ מחזיר **עותק** `List.of(chain)`.
- `:1321` — מתחיל מ-`[chain.first]`.
- `:1322-1326` — לכל `i` מ-0 עד `length-2`: `pipe = pipeBetween(chain[i], chain[i+1])`;
  אם `pipe != null` מוסיף אותו; ואז תמיד מוסיף `chain[i+1]`.

## דוגמאות (‏pipeBetween: `a == b ? null : '($a>$b)'`)
| # | chain | ⇒ |
|---|-------|---|
| 1 | `[]` | `[]` (עותק) |
| 2 | `['solo']` | `['solo']` (‏length<2 ⇒ עותק) |
| 3 | `['x','y']` | `['x','(x>y)','y']` |
| 4 | `['a','b','c']` | `['a','(a>b)','b','(b>c)','c']` |
| 5 | `['x','x']` | `['x','x']` (‏pipe=null ⇒ מדולג) |
| 6 | `['a','a','b']` | `['a','a','(a>b)','b']` (מחבר רק בזוג-השונה) |

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/materialize_chain_test.dart  ⇒ exit 0 + "OK materializeChain: N asserts passed"
```

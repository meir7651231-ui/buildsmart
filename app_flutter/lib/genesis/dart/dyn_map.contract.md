# חוזה · `dynMap` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/trade_schema.dart:41-42`
(‏`_dynMap`, פרטי-במקור ⇒ public). אין קריאה-לשכן ⇒ אין שקע.

## חתימה
```dart
Map<String, dynamic> dynMap(Object? v)
```

## קלט
- `v` — ערך כלשהו (Object?). בד"כ ערך שנשלף מ-JSON מפוענח.

## פלט / התנהגות (עוגני-שורה)
- `trade_schema.dart:42` — `v is Map ? v.cast<String, dynamic>() : const {}`:
  - `v` הוא `Map` ⇒ מוחזר `v.cast<String, dynamic>()` (view ממופה — לא עותק).
  - אחרת (null / List / מספר / מחרוזת / bool) ⇒ `const {}` (מפה-ריקה קבועה).
- **הערת cast**: `cast` הוא lazy — קריאה מ-Map עם מפתח לא-String תזרוק בזמן-הגישה
  (נאמנות-מקור). מפתחות-String תקינים ⇒ נגישים כרגיל.

## דוגמאות
| # | v | ⇒ |
|---|---|---|
| 1 | `{'a': 1, 'b': 'x'}` | `{'a': 1, 'b': 'x'}` (מומר ל-Map<String,dynamic>) |
| 2 | `null` | `{}` |
| 3 | `[1, 2, 3]` | `{}` |
| 4 | `42` | `{}` |
| 5 | `'טקסט'` | `{}` |
| 6 | `<String, dynamic>{}` (ריק) | `{}` |

## שקעים
- אין. `is Map`/`Map.cast` — שפה/סטנדרט.

## DoD
```
dart run --enable-asserts new/dart/dyn_map_test.dart  ⇒ exit 0 + "OK dynMap: N asserts passed"
```

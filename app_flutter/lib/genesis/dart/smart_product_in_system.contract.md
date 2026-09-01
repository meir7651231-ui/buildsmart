# חוזה · `smartProductInSystem` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/system_division.dart:118-124`
(‏`smartProductInSystem`). `filterSmartBySystem` שבטיוטה אינו היעד. הקובץ אינו קיים עוד ⇒
הטיוטה = מקור-האמת.

## חתימה
```dart
bool smartProductInSystem<S>(Set<S> systems, S? system)
```

## שקעים (חוק-3)
- `systems` — פלט העוזר-השכן `smartProductSystems(sp)` (קבוצת-המערכות של המוצר), מוזרק ישירות.
- גנרי מעל `S` (במקור `S = WaterSystem`): האטום משתמש רק ב-`isEmpty`/`contains` ⇒ ה-enum
  הקונקרטי מיותר (טוהר מלא, אין תלות-שכן).

## פלט / התנהגות (עוגני-שורה)
- `system_division.dart:119` — `system == null` ⇒ `true` (אין סינון).
- `:121-122` — אחרת `systems.isEmpty || systems.contains(system)`:
  - `systems` ריק ⇒ `true` (מוצר לא-פתיר נשאר גלוי בכל מערכת — לא מסתירים על-חוסר-נתונים).
  - אחרת ⇒ `true` רק אם `system` בקבוצה.

## דוגמאות (S = String, מייצג WaterSystem)
| # | systems | system | ⇒ |
|---|---------|--------|---|
| 1 | `{'hot','cold'}` | `null` | `true` (אין סינון) |
| 2 | `{}` | `'hot'` | `true` (לא-פתיר ⇒ גלוי) |
| 3 | `{'hot','cold'}` | `'hot'` | `true` (חבר) |
| 4 | `{'cold'}` | `'hot'` | `false` (לא-חבר) |
| 5 | `{}` | `null` | `true` (שני-התנאים ⇒ true) |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart analyze new/dart/smart_product_in_system.dart                    ⇒ No issues found!
dart run --enable-asserts new/dart/smart_product_in_system_test.dart  ⇒ exit 0 + "OK smartProductInSystem: N asserts passed"
```

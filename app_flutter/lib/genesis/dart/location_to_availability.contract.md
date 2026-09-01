# חוזה · `locationToAvailability` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/equipment_stock_join.dart:69-72`
(‏`_locationToAvailability`, private-במקור). קודם לפונקציה top-level ציבורית `locationToAvailability`.

## הטבעת-שכן (שקיפות)
ה-enum `StockAvailability` הוא טיפוס-שכן-קטן ⇒ הוטבע verbatim inline (חוק-2/דיבר-3).
⚠️ סדר-הערכים והחבר `unknown` **אינם בגוף-הטיוטה** וקבצי-המקור אינם נגישים (grep-יחיד ריק);
הוסקו מהשימוש בשכן `availabilityFor` המחזיר `.warehouse`/`.site`/`.unknown`. הסדר
`warehouse → site → unknown` הוא **הסקה מתועדת** — הפונקציה עצמה מחזירה רק warehouse/site.

## חתימה
```dart
enum StockAvailability { warehouse, site, unknown }
StockAvailability locationToAvailability(String location)
```

## קלט
- `location` — מחרוזת-מיקום-מלאי (‏`EmployerStockItem.location` במקור).

## פלט / התנהגות (עוגני-שורה)
- `:69-72` — `location == 'warehouse' ? StockAvailability.warehouse : StockAvailability.site`.
- כל-ערך-שאינו-`'warehouse'` (כולל `''`, `'site'`, `'Warehouse'` בשונה-רישיות) ⇒ `site`.
- לעולם לא זורק; לעולם אינו מחזיר `unknown` (זה החבר של שכבת-`availabilityFor`, לא של אטום זה).

## דוגמאות
| # | location | ⇒ |
|---|----------|---|
| 1 | `'warehouse'` | `StockAvailability.warehouse` |
| 2 | `'site'` | `StockAvailability.site` |
| 3 | `''` | `StockAvailability.site` |
| 4 | `'Warehouse'` | `StockAvailability.site` (case-sensitive; שונה-רישיות) |
| 5 | `'anything'` | `StockAvailability.site` |

## שקעים
- אין. `location` = פרמטר-נתון; `==` מחרוזתי — שפה.

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/location_to_availability_test.dart  ⇒ exit 0 + "OK locationToAvailability: N asserts passed"
```

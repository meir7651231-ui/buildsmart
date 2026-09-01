# חוזה · `criticalBusinessKind` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_safety.dart:189-212`
(‏`_criticalBusinessKind`, פרטי-במקור ⇒ public).

**הוטבע:** ה-enum `_CriticalKind{confirmOrder,price}` הוטבע verbatim כ-`CriticalKind`;
שדות-`ElementDescriptor` (‏id/labelHe) כפרמטרים-בשם (חוק-3). אין קריאה-לשכן ⇒ אין שקע.

## חתימה
```dart
enum CriticalKind { confirmOrder, price }
CriticalKind? criticalBusinessKind({required String id, required String labelHe})
```

## קלט
- `id` — מזהה-הרכיב. **מומר ל-lowercase** לפני בדיקות (‏edit_safety.dart:190).
- `labelHe` — התווית העברית, נבדקת כפי-שהיא (ללא-נרמול).

## פלט / התנהגות (עוגני-שורה)
- `:193-197` — `labelHe` מכיל `'אשר הזמנה'` **או** id(lc) מכיל `'confirmorder'`/`'approveorder'`
  ⇒ `CriticalKind.confirmOrder`.
- `:199-201` — אחרת id(lc) מכיל `'price'` **או** `labelHe` מכיל `'מחיר'` ⇒ `CriticalKind.price`.
- `:203` — אחרת ⇒ `null`.
- **קדימות**: confirmOrder נבדק ראשון וגובר על price.

## דוגמאות
| # | id | labelHe | ⇒ |
|---|----|---------|---|
| 1 | `'confirmOrderBtn'` | `'כפתור'` | `confirmOrder` (id-lc contains) |
| 2 | `'x'` | `'אשר הזמנה'` | `confirmOrder` (label) |
| 3 | `'approveOrder'` | `''` | `confirmOrder` |
| 4 | `'priceField'` | `''` | `price` (id-lc) |
| 5 | `'x'` | `'מחיר מוצר'` | `price` (label) |
| 6 | `'navbar'` | `'ניווט'` | `null` |
| 7 | `'priceConfirmOrder'` | `''` | `confirmOrder` (קדימות על price) |
| 8 | `'PRICE'` | `''` | `price` (‏lowercase) |

## שקעים
- אין. `String.toLowerCase`/`contains` — שפה/סטנדרט.

## DoD
```
dart run --enable-asserts new/dart/critical_business_kind_test.dart  ⇒ exit 0 + "OK criticalBusinessKind: N asserts passed"
```

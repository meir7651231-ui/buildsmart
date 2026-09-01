# חוזה · `isPipeProductE` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/install_engine.dart:1198-1207`
(‏`_isPipeProductE`). `p.productType` קופל לשקע-מחרוזת nullable `productType` (חוק-3;
LipskeyCatalogProduct טיפוס-שכן גדול, לא-inline).

## חתימה
```dart
bool isPipeProductE(String? productType)
```

## פלט / התנהגות (עוגני-שורה)
- `:1199` — `t = p.productType ?? ''` (null ⇒ מחרוזת-ריקה).
- `:1200` — `t == 'צינור' || t == 'צנרת' || t == 'גמיש' || t == 'מאריך'`.

## דוגמאות מספריות
| # | productType | ⇒ |
|---|-------------|---|
| 1 | `'צינור'` | `true` |
| 2 | `'צנרת'` | `true` |
| 3 | `'גמיש'` | `true` |
| 4 | `'מאריך'` | `true` |
| 5 | `null` | `false` |
| 6 | `''` | `false` |
| 7 | `'ברז'` | `false` |
| 8 | `'צינור '` (רווח-נספח) | `false` (התאמה-מדויקת) |

## שקעים
- `productType` — הזרקת-שדה nullable (חוק-3).
- `??`, `String ==` — שפה/סטנדרט.

## DoD
```
dart run --enable-asserts new/dart/is_pipe_product_e_test.dart  ⇒ exit 0 + "OK isPipeProductE: N asserts passed"
```

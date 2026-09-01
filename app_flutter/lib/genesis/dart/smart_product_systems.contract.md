# חוזה · `smartProductSystems` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/system_division.dart:101-117`
(‏`smartProductSystems`; הקובץ אינו קיים עוד ב-checkout — אומת מול
`git show claude/align-main:app_flutter/lib/logic/system_division.dart`, זהה-ביט לטיוטה).

## חתימה
```dart
Set<S> smartProductSystems<P, S>(
  Iterable<String?> brandSkus, {
  required List<P> allProducts,
  required String Function(P) skuOf,
  required Set<S> Function(P) divisionSystemsOf,
})
```

## שקעים (חוק-3 — כל קריאת-שכן הפכה לפרמטר)
- `sp.brands` (מקור:103) שימש **רק** ל-`b.sku` (‏`SmartBrand.sku` הוא `String?` —
  ‏smart_tree.dart:86) ⇒ הורם ל-`Iterable<String?> brandSkus`
  (תקדים: productDivisionSystems הרים `p.brand`).
- `catalogRepo().allProducts()` (מקור:106) — דאטה-לא-מוזרקת ⇒ שקע `allProducts`.
  במקור הקריאה חוזרת פר-מותג, אך היא טהורה מעל קטלוג-const ⇒ הזרקת רשימה-אחת
  זהת-התנהגות (אותם אלמנטים, אותו סדר, בכל איטרציה).
- `p.sku` (מקור:107; ‏`LipskeyCatalogProduct.sku` הוא `String` non-null —
  lipskey_catalog.dart:5) ⇒ שקע-ריאדר `skuOf`.
- `productDivisionSystems(p)` (מקור:108 — אטום-שכן, כבר קודם:
  `new/dart/product_division_systems.dart`) ⇒ שקע `divisionSystemsOf`.
- גנרי מעל `P` (במקור `LipskeyCatalogProduct`) ו-`S` (במקור `WaterSystem`) —
  האטום נוגע רק בשוויון-String וב-`Set` ⇒ אפס טיפוסי-שכן (תקדים: smartProductInSystem).

## התנהגות (עוגני-שורה, מקור 101-117)
- `:102` — מתחילים מקבוצה ריקה.
- `:103-105` — לכל sku-מותג; `sku == null` ⇒ דילוג (continue).
- `:106-112` — סריקה-קווית על הקטלוג; **ההתאמה הראשונה מנצחת** (`break` ב-:110):
  מוסיפים את `divisionSystemsOf(p)` של המוצר-הראשון-התואם בלבד.
- sku ללא-התאמה ⇒ תורם כלום; כל-המותגים בלתי-פתירים ⇒ קבוצה **ריקה**
  (= system-agnostic במורד-הזרם — לא מסתירים על-חוסר-נתונים, doc :98-100).
- איחוד על-פני מותגים: `Set.addAll` ⇒ כפילויות נבלעות.

## דוגמאות (S = String; P = רשומת-(sku,systems))
קטלוג: `A→{supply}` · `B→{drainage}` · `A→{drainage}` (כפול-שני — לעולם לא נבחר).
| # | brandSkus | ⇒ |
|---|-----------|---|
| 1 | `[]` | `{}` (אין מותגים) |
| 2 | `[null, null]` | `{}` (כל ה-sku-ים null — דילוג) |
| 3 | `['X']` | `{}` (אין התאמה בקטלוג) |
| 4 | `['A']` | `{'supply'}` (התאמה-ראשונה בלבד — לא `drainage` של הכפול) |
| 5 | `['A','B']` | `{'supply','drainage'}` (איחוד) |
| 6 | `[null,'B','X']` | `{'drainage'}` (מעורב: דילוג + התאמה + אין-התאמה) |
| 7 | `['A','A']` | `{'supply'}` (כפילות-מותג — הקבוצה בולעת) |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart analyze new/dart/smart_product_systems.dart                    ⇒ No issues found!
dart run --enable-asserts new/dart/smart_product_systems_test.dart  ⇒ exit 0 + "OK smartProductSystems: N asserts passed"
```

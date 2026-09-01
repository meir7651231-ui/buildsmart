# חוזה · `catNodeProductCount` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/category_division.dart:110-126` (הפונקציה + ה-closure הפנימי `collect`).

## תפקיד
סופר כמה מוצרים (מתוך רשימה) שייכים לאחת מקטגוריות-העלים (lipskeyCategory) שמתחת ל-CatalogNode.

## חתימה
```dart
int catNodeProductCount(CatalogNode node, {required Iterable<CatProduct> allProducts})
// CatalogNode{ bool isLeaf; String? lipskeyCategory; List<CatalogNode> children } — מוטבע
// CatProduct{ String categoryHe } — מוטבע
```

## התנהגות (עוגן category_division.dart:110-126)
1. `collect` רקורסיבי: עלה ⇒ מוסיף `lipskeyCategory` (אם ≠null) ל-`cats`; פנימי ⇒ רקורסיה על הילדים.
2. מחזיר `allProducts.where((p) => cats.contains(p.categoryHe)).length`.

## שקעים
- `allProducts` — **שקע** (חוק-3): במקור `catalogRepo().allProducts()` (מאגר-מוצרים חיצוני).
- ה-closure `collect` הוטבע inline verbatim (עוזר-מקומי).

## דוגמאות-מחייבות
| # | עץ | products | ⇒ |
|---|-----|----------|---|
| 1 | פנימי[עלה'צנרת', עלה'ברזים', עלה-null] | 2×צנרת,ברזים,חשמל | 3 |
| 2 | עלה'צנרת' | (כנ"ל) | 2 |
| 3 | פנימי[פנימי[עלה'חשמל']] | (כנ"ל) | 1 |
| 4 | (עץ-1) | [] | 0 |
| 5 | עלה בלי-קטגוריה | (כנ"ל) | 0 |

## DoD
```
dart run --enable-asserts new/dart/cat_node_product_count_test.dart  ⇒ exit 0 + "OK catNodeProductCount: 5 asserts passed"
```

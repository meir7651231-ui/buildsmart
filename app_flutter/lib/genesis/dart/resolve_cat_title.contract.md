# חוזה · `resolveCatTitle` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/category_division.dart:84-107`
(הפונקציה + ה-closure הפנימי `walk`; ענף `origin/claude/whats-happening-LyY9G` — הקובץ אינו ב-main).

## תפקיד
פותר כותרת-מדור (heading title) לצומת-עץ-קטלוג: צומת אמיתי כשהכותרת היא title או
lipskeyCategory של צומת; עלה-סינתטי כשהיא categoryHe חשופה של מוצר; אחרת null.

## חתימה
```dart
CatalogNode? resolveCatTitle(String title, {
  required List<CatalogNode> tree,
  required Iterable<CatProduct> allProducts,
})
// CatalogNode{ String id; String title; String emoji; List<CatalogNode> children;
//              String? lipskeyCategory; bool get isLeaf } — מוטבע (catalog_tree.dart:10-34)
// CatProduct{ String categoryHe } — מוטבע (מוסכמת-האח cat_node_product_count)
```

## התנהגות (עוגן category_division.dart:84-107)
1. `walk` רקורסיבי pre-order על שורשי [tree] לפי הסדר: צומת פוגע כאשר
   `n.title == title || n.lipskeyCategory == title` (שורה 90); **הפגיעה הראשונה
   בסדר pre-order מנצחת** (שומר `hit != null` בשורה 89 עוצר את ההמשך).
2. נמצא צומת ⇒ מוחזר כמות-שהוא (שורה 101).
3. לא נמצא, אך `allProducts.any((p) => p.categoryHe == title)` (שורה 103) ⇒ עלה-סינתטי:
   `CatalogNode(id: 'catdept.$title', title: title, emoji: '📦', lipskeyCategory: title)`
   (שורות 104-105; children ריק ⇒ isLeaf).
4. אחרת ⇒ `null` (שורה 106).

## שקעים
- `tree` — **שקע** (חוק-1): במקור `kCatalogTree` (דאטה-קטלוג גלובלית, data/catalog_tree.dart:36).
- `allProducts` — **שקע** (חוק-3): במקור `catalogRepo().allProducts()` (מאגר-שכן,
  data/repositories/catalog_local.dart).
- ה-closure `walk` הוטבע inline verbatim (עוזר-מקומי).

## דוגמאות-מחייבות
| # | title | עץ | products | ⇒ |
|---|-------|-----|----------|---|
| 1 | 'ניקוז וצנרת' | שורש בשם זה | [] | הצומת-השורש עצמו |
| 2 | 'מחסומי רצפה' | עלה-עמוק עם lipskeyCategory זה | [] | העלה (id 'drainage.traps.floor') |
| 3 | 'צנרת' | שני צמתים תואמים (title בשורש-א׳, lipskey בעץ-ב׳) | [] | הראשון ב-pre-order (שורש-א׳) |
| 4 | 'ברזי כיור' | אף צומת לא תואם | מוצר עם categoryHe='ברזי כיור' | סינתטי: id='catdept.ברזי כיור', emoji='📦', lipskeyCategory='ברזי כיור', isLeaf |
| 5 | 'לא קיים' | (עץ-1) | (מוצרי-4) | null |
| 6 | 'כלום' | [] | [] | null |

## DoD
```
dart run --enable-asserts new/dart/resolve_cat_title_test.dart  ⇒ exit 0 + "OK resolveCatTitle: 7 asserts passed"
```

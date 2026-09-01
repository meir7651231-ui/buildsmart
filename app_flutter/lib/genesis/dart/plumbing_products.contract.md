# חוזה · plumbing_products

> אטום-Dart · מנוע-זריעה טהור (מיפוי-קטלוג→מוצרי-מקצוע + מיון-יציב). חוק-4: ההתנהגות verbatim מהמקור.

## מקור
buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:156-168 (ענף `claude/align-main` — הענף היחיד המכיל את הקובץ; אומת ב-git cat-file)

## הכרעת-הקידום (טיוטה-"קשה")
🔌 **הכרעה 1 — שכנים ⇒ שקעי-פרמטר** (חוק-1: חוט לא מייבא חוט):
| במקור | באטום |
|---|---|
| `kCatalogProducts` (data/polyroll_catalog) | פרמטר `catalogProducts` |
| `_lipskeyCategoryToId()` (resolver-שכן, :91-94) | פרמטר `lipskeyCategoryToId` (המפה המוכנה; האטום-האח `lipskey_category_to_id` בונה אותה) |
| `tradeProductFromLegacy` (domain/trade_product_adapter) | שקע-פונקציה `tradeProductFromLegacy` — **אותה חתימה בדיוק** `(p, {tradeId, categoryId})` |
| `p.categoryHe` (שדה על CatalogProduct) | שקע-ריאדר `categoryHe(p)` (דפוס estimate_price) |
| `kPlumbingTradeId` (:30 — 'plumbing') | פרמטר `tradeId` (דאטה מוזרקת — אפס-דאטה-במנוע) |
| `kUncategorizedCategoryId` (:61) | פרמטר `uncategorizedCategoryId` |
| `a.id.compareTo(b.id)` (שדה על TradeProduct) | שקע-ריאדר `idOf(r)` — המיון נשאר `String.compareTo` |

## קלט
- `catalogProducts: List<P>` — מוצרי-הקטלוג.
- `lipskeyCategoryToId: Map<String,String>` — ‏`categoryHe` → מזהה-קטגוריה.
- `categoryHe: String Function(P)` — ריאדר שם-הקטגוריה של מוצר.
- `tradeProductFromLegacy: R Function(P, {required String tradeId, required String categoryId})` — המתאם.
- `tradeId: String` · `uncategorizedCategoryId: String`.
- `idOf: String Function(R)` — ריאדר-מזהה למיון.

## פלט
`List<R>` — כל מוצר עבר דרך המתאם; ממוין עולה לפי `idOf` (‏`compareTo`).

## התנהגות (עוגני-שורה)
1. ‏:158-165 — כל מוצר ממופה דרך המתאם עם `tradeId` המוזרק ו-`categoryId = lipskeyCategoryToId[categoryHe(p)] ?? uncategorizedCategoryId`.
2. ‏:163 — קטגוריה שאינה במפה ⇒ נפילה ל-`uncategorizedCategoryId` (שלמות-FK).
3. ‏:167 — מיון בסוף: `..sort((a,b) => a.id.compareTo(b.id))` ⇒ כאן `idOf(a).compareTo(idOf(b))`.
4. רשימה ריקה ⇒ רשימה ריקה (map על ריק).

## דוגמאות מספריות (המוכחות בבדיקה)
- קלט `[{sku:'B', cat:'ברזים'}, {sku:'A', cat:'לא-קיימת'}]`, מפה `{'ברזים':'plumbing.cat.faucets'}`, ‏trade='plumbing', ‏unc='plumbing.cat._uncategorized' ⇒ פלט ממוין `['A','B']`; ‏A קיבל `plumbing.cat._uncategorized`, ‏B קיבל `plumbing.cat.faucets`, שניהם `tradeId='plumbing'`.
- קלט ריק ⇒ `[]`.

## DoD (נכתב לפני הקוד)
`dart run --enable-asserts new/dart/plumbing_products_test.dart` ⇒ exit 0 + `✓ plumbingProducts: 9`.

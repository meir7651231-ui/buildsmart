# חוזה · plumbingFixtures

> אטום-Dart (דרגת-חוזה) · קודם מטיוטת-מחצבה קשה (חוק-4 — verbatim מהמקור, אפס-שיפור).

## מקור
buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:204-246 (ענף-החי `claude/whats-happening-LyY9G`)

## הכרעת-הקידום (דיבר 3 / חוק-1: חוט לא מייבא חוט)
| תלות-במקור | עוגן | ⇒ שקע |
|---|---|---|
| `_smartKeyToId()` — פותר-קטגוריות שכן | plumbing_trade_seed.dart:205 | `smartKeyToId: Map<String,String>` |
| `kSmartProducts` — דאטה-קטלוג | plumbing_trade_seed.dart:206 | `products: List<SmartProduct>` |
| `kPlumbingTradeId` ('plumbing') | plumbing_trade_seed.dart:30 | `kPlumbingTradeId: String` (מוסכמת category_id) |
| `kUncategorizedCategoryId` | plumbing_trade_seed.dart:61 | `kUncategorizedCategoryId: String` |

טיפוסים-מוטבעים מינימליים (verbatim-שדות, רק מה שהפונקציה נוגעת בו):
`SmartProduct`/`SmartBrand`/`SmartAcc`/`SmartStage` (smart_tree.dart:5-136) ·
`SmartFixture`/`SmartBrandRef`/`InstallStage` (trade_schema.dart:458-599).

## קלט
- `products` — רשימת SmartProduct (מוזרקת; במקור kSmartProducts).
- `smartKeyToId` — מפה `SmartProduct.key` → category-id (מוזרקת; במקור `_smartKeyToId()`).
- `kPlumbingTradeId` · `kUncategorizedCategoryId` — מזהי-הצבה מוזרקים.

## פלט
`List<SmartFixture>` ממוינת לפי `id` (compareTo), פריט לכל מוצר:
- `id` = `'$kPlumbingTradeId.fixture.${sp.key}'` (שורה 209)
- `categoryId` = `smartKeyToId[sp.key] ?? kUncategorizedCategoryId` (שורה 211)
- `brandRefs` — מיפוי 1:1 של `sp.brands` ל-SmartBrandRef (name/tag/rec/sku/imageAsset/price; שורות 215-226)
- `accessoryRuleIds` = `'$kPlumbingTradeId.acc.${sp.key}.$i'` לכל אינדקס ב-`sp.acc` (שורות 227-230)
- `stages` — מיפוי 1:1 של `sp.stages` ל-InstallStage (emoji · label→labelHe · sub→subHe · isFinal · match→matchTokens; שורות 231-241)

## דוגמאות מספריות
1. מוצר `key='basinTrap'`, במפה `{'basinTrap':'plumbing.cat.k1'}` ⇒ `id='plumbing.fixture.basinTrap'`, `categoryId='plumbing.cat.k1'`.
2. מוצר `key='zz'` שאינו במפה ⇒ `categoryId='plumbing.cat._uncategorized'` (fallback).
3. מוצר עם 2 אביזרים ⇒ `accessoryRuleIds=['plumbing.acc.<key>.0','plumbing.acc.<key>.1']`.
4. קלט לא-ממוין (`zz` לפני `basinTrap`) ⇒ פלט ממוין לפי id (`...basinTrap` ראשון).
5. `products=[]` ⇒ `[]`.

## אימות (DoD — נכתב לפני הקוד)
`dart run --enable-asserts new/dart/plumbing_fixtures_test.dart` ⇒ exit 0, מדפיס `✓ plumbingFixtures`.

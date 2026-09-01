# חוזה · `smartKeyToId` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:97-100`
(‏`_smartKeyToId`) + החצי-החכם של `_buildCategoryResolvers` (‏:70-88, השורות 72·76-88).
חולץ מ-commit `dea7af3f` — הקובץ אינו בעץ-העבודה הנוכחי של buildsmart.

## תפקיד
המפה `SmartProduct.key → מזהה-קטגוריה` של עץ-הקטלוג, מחושבת **פעם-אחת** (memoized):
הליכת-יער קדם-סדר; כל צומת עם `smartKey != null` תורם רשומה
`smartKey → categoryIdOf(n.id)`. משמשת את `plumbingFixtures`/`plumbingAccessories`
(‏:175, :205) כדי שהפניות-קטגוריה לעולם לא יתדלדלו (FK integrity, הערת-המקור :63-66).

## חתימה
```dart
Map<String, String> smartKeyToId(
  List<CatalogNode> tree, {
  required String Function(String key) categoryIdOf,
  required SmartKeyToIdCache cache,
})
// SmartKeyToIdCache{ Map<String,String>? map }                       — מוטבע (מחזיק-מטמון)
// CatalogNode{ String id; String? smartKey; List<CatalogNode> children } — מוטבע
```

## התנהגות (עוגן plumbing_trade_seed.dart)
- `cache.map == null` ⇒ בנייה (שורה 98: `if (_smartKeyToIdCache == null) _buildCategoryResolvers();`):
  - הליכת-יער קדם-סדר על `tree` (‏:83-85 ⇒ ‏:73-81): הצומת נבדק, אחר-כך ילדיו בסדרם.
  - `n.smartKey != null` ⇒ `map[smartKey] = categoryIdOf(n.id)` (‏:76-77); צומת בלי
    smartKey לא תורם — אבל ילדיו כן נסרקים.
  - **כפילות-מפתח: הכתיבה האחרונה בקדם-סדר גוברת** (השמת-Map; בדאטה האמיתית
    `drainageFittings` מופיע 3×, `visibleTrap` 2×).
  - התוצאה נשמרת ב-`cache.map` (‏:87).
- `cache.map != null` ⇒ מוחזר **אותו אובייקט** כמות-שהוא; `tree` לא נסרק ו-`categoryIdOf`
  לא נקרא כלל (זהו ה-memo של המקור — במקור העץ const, כאן זה נצפה ומתועד).
- יער ריק ⇒ מפה ריקה (ונשמרת במטמון — הריקנות עצמה ממוטמנת).

## שקעים
- `tree` — במקור הגלובל `kCatalogTree` (‏:83) ⇒ פרמטר (חוק-1: דאטה מוזרקת).
- `categoryIdOf` — במקור `_categoryId(n.id)` = `'$kPlumbingTradeId.cat.$key'` (‏:32, :77)
  ⇒ שקע-פונקציה; הקופסה מזריקה את האטום-האח `categoryId` עם `kPlumbingTradeId='plumbing'`.
- `cache` — במקור הגלובל `_smartKeyToIdCache` (‏:68) ⇒ מחזיק מוזרק (תקדים
  end_pair_memoized + walk.CatalogHit). הקופסה מחזיקה מחזיק-יחיד לחיי-הריצה.
- החצי-lipskey של הבנאי (‏:74-75, `_lipskeyCategoryToIdCache`) שייך לאטום-האח
  `lipskey_category_to_id`; "שתי המפות בהליכה-אחת" = חיווט-קופסה (חוק-5, כלל-העצירה).

## דוגמאות-מחייבות (ids/keys אמיתיים מ-catalog_tree.dart)
עם `categoryIdOf = (k) => 'plumbing.cat.$k'`:
| # | קלט | ⇒ פלט |
|---|-----|-------|
| 1 | תת-עץ drainage.traps האמיתי | `map['floorDrain'] == 'plumbing.cat.drainage.traps.floor'` · `'visibleTrap' → 'plumbing.cat.drainage.traps.visible'` |
| 2 | drainage.collectors: roof (עם smartKey) + floor (בלי) | `'roofCollector'` נכנס; אין מפתח לצומת-בלי-smartKey; ההורה 'drainage.collectors' לא במפה |
| 3 | `drainageFittings` ב-3 צמתים (couplers→couplings→accessories.connect) | האחרון גובר: `'plumbing.cat.drainage.accessories.connect'` |
| 4 | יער ריק `[]` | `{}` — וגם הריק ממוטמן (`cache.map != null`) |
| 5 | קריאה שנייה, אותו מחזיק | אותו אובייקט (identical) · `categoryIdOf` לא נקרא שוב |
| 6 | קריאה שנייה עם **עץ אחר** ואותו מחזיק | העץ החדש לא נסרק — הפלט הישן מוחזר |
| 7 | מחזיק שהוזן-מראש (`SmartKeyToIdCache({'x':'y'})`) | מוחזר כמות-שהוא, אפס קריאות-`categoryIdOf` |
| 8 | יער 2 שורשים, לכל אחד smartKey | שני המפתחות במפה (לולאת-היער :83-85) |

## DoD
```
dart run --enable-asserts new/dart/smart_key_to_id_test.dart  ⇒ exit 0 + "OK smart_key_to_id: 8 asserts passed"
```

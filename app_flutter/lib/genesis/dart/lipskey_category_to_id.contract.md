# חוזה · `lipskeyCategoryToId` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:91-94`
(‏`_lipskeyCategoryToId`) + החצי-lipskey של `_buildCategoryResolvers` (‏:70-88, השורות 71·74-75·78-88).
חולץ מ-commit `dea7af3f` — הקובץ אינו בעץ-העבודה הנוכחי של buildsmart.

## תפקיד
המפה `lipskeyCategory → מזהה-קטגוריה` של עץ-הקטלוג, מחושבת **פעם-אחת** (memoized):
הליכת-יער קדם-סדר; כל צומת עם `lipskeyCategory != null` תורם רשומה
`lipskeyCategory → categoryIdOf(n.id)`. משמשת את `plumbingProducts` (‏:157, :163 —
`lipskeyMap[p.categoryHe] ?? kUncategorizedCategoryId`) כדי שהפניות-קטגוריה של מוצרי-
הלגאסי לעולם לא יתדלדלו (FK integrity, הערת-המקור :63-66).

## חתימה
```dart
Map<String, String> lipskeyCategoryToId(
  List<CatalogNode> tree, {
  required String Function(String key) categoryIdOf,
  required LipskeyCategoryToIdCache cache,
})
// LipskeyCategoryToIdCache{ Map<String,String>? map }                          — מוטבע (מחזיק-מטמון)
// CatalogNode{ String id; String? lipskeyCategory; List<CatalogNode> children } — מוטבע
```

## התנהגות (עוגן plumbing_trade_seed.dart)
- `cache.map == null` ⇒ בנייה (שורה 92: `if (_lipskeyCategoryToIdCache == null) _buildCategoryResolvers();`):
  - הליכת-יער קדם-סדר על `tree` (‏:83-85 ⇒ ‏:73-81): הצומת נבדק, אחר-כך ילדיו בסדרם.
  - `n.lipskeyCategory != null` ⇒ `map[lipskeyCategory] = categoryIdOf(n.id)` (‏:74-75);
    צומת בלי lipskeyCategory לא תורם — אבל ילדיו כן נסרקים.
  - **כפילות-מפתח: הכתיבה האחרונה בקדם-סדר גוברת** (השמת-Map; בדאטה האמיתית של
    catalog_tree.dart כל ערכי-lipskeyCategory ייחודיים — הקצה נבדק כסמנטיקת-השמה).
  - התוצאה נשמרת ב-`cache.map` (‏:86).
- `cache.map != null` ⇒ מוחזר **אותו אובייקט** כמות-שהוא; `tree` לא נסרק ו-`categoryIdOf`
  לא נקרא כלל (זהו ה-memo של המקור — במקור העץ const, כאן זה נצפה ומתועד).
- יער ריק ⇒ מפה ריקה (ונשמרת במטמון — הריקנות עצמה ממוטמנת).

## שקעים
- `tree` — במקור הגלובל `kCatalogTree` (‏:83) ⇒ פרמטר (חוק-1: דאטה מוזרקת).
- `categoryIdOf` — במקור `_categoryId(n.id)` = `'$kPlumbingTradeId.cat.$key'` (‏:32, :75)
  ⇒ שקע-פונקציה; הקופסה מזריקה את האטום-האח `categoryId` עם `kPlumbingTradeId='plumbing'`.
- `cache` — במקור הגלובל `_lipskeyCategoryToIdCache` (‏:67) ⇒ מחזיק מוזרק (תקדים
  end_pair_memoized + walk.CatalogHit). הקופסה מחזיקה מחזיק-יחיד לחיי-הריצה.
- החצי-smart של הבנאי (‏:76-77, `_smartKeyToIdCache`) שייך לאטום-האח
  `smart_key_to_id` (כבר-מקודם); "שתי המפות בהליכה-אחת" = חיווט-קופסה (חוק-5, כלל-העצירה).

## דוגמאות-מחייבות (ids/ערכים אמיתיים מ-catalog_tree.dart)
עם `categoryIdOf = (k) => 'plumbing.cat.$k'`:
| # | קלט | ⇒ פלט |
|---|-----|-------|
| 1 | תת-עץ drainage.traps האמיתי (‏:44-72) | `map['מחסומי רצפה'] == 'plumbing.cat.drainage.traps.floor'` · `'מחסומים גלויים' → 'plumbing.cat.drainage.traps.visible'` |
| 2 | drainage.collectors: roof (smart-בלבד, בלי lipskey) + floor (עם) | `'מאספי רצפה'` נכנס; roof לא תורם; ההורה 'drainage.collectors' לא במפה |
| 3 | אותו lipskeyCategory ב-3 צמתים (סינתטי — בדאטה אין כפילות) | האחרון בקדם-סדר גובר |
| 4 | יער ריק `[]` | `{}` — וגם הריק ממוטמן (`cache.map != null`) |
| 5 | קריאה שנייה, אותו מחזיק | אותו אובייקט (identical) · `categoryIdOf` לא נקרא שוב |
| 6 | קריאה שנייה עם **עץ אחר** ואותו מחזיק | העץ החדש לא נסרק — הפלט הישן מוחזר |
| 7 | מחזיק שהוזן-מראש (`LipskeyCategoryToIdCache({'x':'y'})`) | מוחזר כמות-שהוא, אפס קריאות-`categoryIdOf` |
| 8 | יער 2 שורשים, לכל אחד lipskeyCategory | שני המפתחות במפה (לולאת-היער :83-85) |

## DoD
```
dart run --enable-asserts new/dart/lipskey_category_to_id_test.dart  ⇒ exit 0 + "OK lipskey_category_to_id: 8 asserts passed"
```

# חוזה · `nodeHasSystem` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/system_division.dart:70-95`
(‏`nodeHasSystem` + ה-closure הפנימי `walk`). הקובץ אינו בעץ-העבודה — שוחזר מלא מ-**main
של buildsmart** (קו-האמת, L16: `git show main:app_flutter/lib/logic/system_division.dart`).
הטיוטה במחצבה נקטעה אחרי 6 שורות; החוזה נכתב מול המקור המלא.

## חתימה
```dart
bool nodeHasSystem(
  CatalogNode node,
  WaterSystem system, {
  required Set<String> fixtureTitles,
  required Map<String, ({int sup, int dr})> catSystemTally,
  required Map<String, bool> cache,
})
```

## שקעים (חוק-3 + הכרעה-13)
- `fixtureTitles` — במקור הדאטה-const `_fixtureTitles` (‏`system_division.dart:40` —
  `{'אסלות', 'מקלחות ואמבטיות', 'גופי תברואה'}`). דאטה בקופסה, לא במנוע.
- `catSystemTally` — במקור `_catSystemTallyIndex` (‏`:47-60`): אינדקס קטגוריה ⇒
  `(sup, dr)` הנבנה פעם-אחת מעל `catalogRepo().allProducts()` (שכן ⇒ הקופסה בונה ומזריקה).
- `cache` — במקור `_nodeHasSystemCache` (‏`:65`, מצב-מודול memo). הקופסה מחזיקה Map
  מתמיד ⇒ memoization זהה-מקור; Map ריק בכל קריאה ⇒ אותן תוצאות, בלי memo (byte-equivalent).
- טיפוסי-שכן מוטבעים: `CatalogNode` (‏`catalog_tree.dart:10-33` — id·title·children·
  lipskeyCategory·`isLeaf => children.isEmpty` verbatim) · `WaterSystem {supply, drainage}`.

## התנהגות (עוגני-שורה)
- `:71` — `node.title` ∈ `fixtureTitles` ⇒ `true` מיידי (קבועות גם-וגם), **לפני** ה-cache.
- `:72-74` — מפתח-memo `'${node.id}|${system.name}'`; פגיעה ב-cache ⇒ הערך השמור.
- `:76-91` — `walk` רקורסיבי: עלה עם `lipskeyCategory` שקיים ב-tally ⇒ צובר `sup`/`dr`;
  עלה בלי קטגוריה / קטגוריה-חסרה-ב-tally ⇒ מדולג; לא-עלה ⇒ ירידה לילדים.
- `:92-93` — `(sup != 0 || dr != 0)` **וגם** `(sup >= dr ? supply : drainage) == system`.
  שוויון (`sup == dr`, לא-אפס) ⇒ הדומיננטית היא **supply** (‏`>=`). אפס-נתונים ⇒ `false` לשתיהן.
- `:94` — התוצאה נכתבת ל-cache ומוחזרת.

## דוגמאות מספריות (tally: 'צנרת'=(5,2) · 'מרזבים'=(0,7) · 'ברזים'=(3,3))
| # | node | system | ⇒ |
|---|------|--------|---|
| 1 | title='אסלות' (fixture, בלי דאטה) | drainage | `true` (קבועה ⇒ תמיד) |
| 2 | title='אסלות' | supply | `true` |
| 3 | עלה cat='צנרת' (5,2) | supply | `true` (5≥2 ⇒ דומיננטית supply) |
| 4 | עלה cat='צנרת' (5,2) | drainage | `false` |
| 5 | עלה cat='מרזבים' (0,7) | drainage | `true` |
| 6 | עלה cat='מרזבים' (0,7) | supply | `false` |
| 7 | עלה cat='ברזים' (3,3) | supply | `true` (תיקו ⇒ supply, ‏`>=`) |
| 8 | עלה cat='ברזים' (3,3) | drainage | `false` |
| 9 | עלה cat=null | supply/drainage | `false` (אפס-נתונים) |
| 10 | עלה cat='לא-קיים-ב-tally' | supply | `false` |
| 11 | הורה{צנרת, מרזבים} ⇒ sup=5,dr=9 | drainage | `true` (סכימה על תת-העץ) |
| 12 | הורה{צנרת, מרזבים} | supply | `false` |
| 13 | cache קדום `{'x\|supply': true}`, צומת id='x' בלי דאטה | supply | `true` (memo גובר) |
| 14 | אחרי קריאה על id='leaf1' | — | `cache['leaf1\|supply']` == התוצאה (נכתב) |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/node_has_system_test.dart  ⇒ exit 0 + "OK nodeHasSystem: N asserts passed"
```

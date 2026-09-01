# חוזה · `plumbingCategories` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:114-150`
(‏`plumbingCategories`; commit `dea7af3f` — הקובץ חולץ מהיסטוריית-git, אינו בעץ-העבודה).
הגוף verbatim פרט לשמות-השקעים.

## הכרעת-הקידום (טיוטה-"קשה" — שילוב הכרעות 1+2)
- 🔌 **שכנים ⇒ שקעים** (חוק-1/3 · הכרעה-13 "דאטה=שקע" — אפס דאטה-צרובה במנוע):
  - `kCatalogTree` (‏data/catalog_tree.dart:36) ⇒ פרמטר `catalogTree`.
  - `_categoryId` (‏plumbing_trade_seed.dart:32 — קיים כאטום `category_id.dart`) ⇒ שקע-פונקציה `categoryId`.
  - `kPlumbingTradeId` (‏:30, `'plumbing'`) ⇒ פרמטר `tradeId`.
  - `kUncategorizedCategoryId` (‏:61) ⇒ פרמטר `uncategorizedCategoryId`.
- ⚛️ **טיפוסי-שכן הוטבעו מינימלית**: `CatalogNode` (‏catalog_tree.dart:10-33 — id/title/emoji/children/smartKey)
  ו-`TradeCategory` (‏trade_schema.dart:107-165 — בנאי+שדות; json/equality של המקור תלויים
  ב-flutter/foundation והושמטו — הקופסה מחווטת את מחלקת-הסכמה המלאה).
- המחרוזות `'ללא קטגוריה'`/`'❓'` = התנהגות-דלי-ה-fallback של המקור (‏:139-146) — נשארות verbatim
  (תקדים `galvanic_group`: ליטרל אינטגרלי-להתנהגות ≠ דאטה-קטלוג).

## חתימה
```dart
List<TradeCategory> plumbingCategories(
  List<CatalogNode> catalogTree, {
  required String Function(String key) categoryId,
  required String tradeId,
  required String uncategorizedCategoryId,
})
```

## התנהגות (עוגני-שורה, plumbing_trade_seed.dart)
- `:116-131` — DFS קדם-סדר: כל צומת ⇒ `TradeCategory(id: categoryId(n.id), tradeId, titleHe: n.title,
  emoji: n.emoji, parentId, sortIndex, smartFixtureId: n.smartKey)`; לילדים מועבר
  `parentId = categoryId(n.id)` ו-`sortIndex = i` (מקום-בין-האחים).
- `:133-135` — שורשים: `parentId = null`, `sortIndex = i` לפי סדר-העץ.
- `:136-146` — דלי-fallback (שלמות-FK): `id = uncategorizedCategoryId`, `titleHe: 'ללא קטגוריה'`,
  `emoji: '❓'`, `parentId: null`, `sortIndex: out.length` (= מספר-הצמתים, לפני-הצירוף — יציב).
- `:148` — מיון סופי `a.id.compareTo(b.id)` (דטרמיניזם: "two buildPlumbingSeed() calls must stay
  byte-equal", ‏:37-38); ה-sortIndex שנקבע-בהכנסה **נשמר** ואינו מושפע מהמיון.
- `attributeSchemaIds` לעולם ריק (ברירת-מחדל הסכמה — האטום לא מציב).

## דוגמאות מספריות (הדאטה = תת-עץ verbatim מ-kCatalogTree, catalog_tree.dart:36-71)
עץ: `drainage('ניקוז וצנרת','🕳️')` → `drainage.traps('סיפונים ומחסומים','🌀')` →
`floor(smartKey:'floorDrain')` · `visible(smartKey:'visibleTrap')` · `manifold(smartKey:'drainageManifold')`;
שקעים: `categoryId=k⇒'plumbing.cat.$k'` · `tradeId='plumbing'` · `uncat='plumbing.cat._uncategorized'`.

| # | קלט | פלט | נימוק |
|---|-----|-----|-------|
| 1 | העץ הנ"ל (5 צמתים) | 6 רשומות; סדר-ids: `_uncategorized` · `drainage` · `drainage.traps` · `…floor` · `…manifold` · `…visible` | ‏`'_'`(0x5F)<`'d'`; קידומת-קצרה לפני ארוכה; `f`<`m`<`v` |
| 2 | — | דלי: `sortIndex=5` (מספר-הצמתים), `titleHe='ללא קטגוריה'`, `emoji='❓'` | ‏:139-146 |
| 3 | — | `floor.parentId='plumbing.cat.drainage.traps'`, `si=0`; `visible.si=1`; `manifold.si=2`; `floor.smartFixtureId='floorDrain'` | קישור-הורים + מקום-בין-אחים |
| 4 | עץ ריק `[]` | רשומה אחת: הדלי בלבד, `sortIndex=0` | ‏out ריק בצירוף |
| 5 | שורשים `[z, a]` | סדר-פלט `_u`·`a`·`z`; אך `a.si=1`, `z.si=0`, דלי `si=2` | המיון משנה-סדר, sortIndex-הכנסה נשמר |
| 6 | קריאה-כפולה על אותו-עץ | סדרות ids/sortIndex זהות | דטרמיניזם (‏:37-38) |

## שקעים
- `catalogTree` — עץ-הדאטה (במקור `kCatalogTree` — const-קטלוג; הקופסה מזריקה).
- `categoryId` — סכימת-המזהים (במקור `_categoryId`; האטום `category_id.dart` מתחבר כאן בקופסה).
- `tradeId` / `uncategorizedCategoryId` — מזהי-ההצבה (במקור `'plumbing'` / `'$kPlumbingTradeId.cat._uncategorized'`).

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/plumbing_categories_test.dart  ⇒ exit 0 + "OK plumbingCategories: 30 asserts passed"
```

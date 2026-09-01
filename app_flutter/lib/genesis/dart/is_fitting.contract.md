# חוזה · isFitting

**מוצא (קדוש, L4):** `install_engine.dart:816-818` (origin/main, verbatim).
עוגן: `:816-818` = `bool isFitting(p) => _fittingCats.contains(p.categoryHe) || (companyCatalogActive && _fittingTypes.contains(p.productType));` — **שני** סעיפים.
נתונים: `_fittingCats` (:801-806, 16 קטגוריות) · `_fittingTypes` (:811-813, 12 מונחי-סוג).

## חתימה
```dart
class FittingPart { final String categoryHe; final String? productType;
    const FittingPart(this.categoryHe, {this.productType}); }
bool isFitting(FittingPart p, {bool companyCatalogActive = false});
```

## קלט
- `p` — `FittingPart`: `categoryHe` (String) · `productType` (String?) — שני השדות ש-isFitting קורא (במקור `p.categoryHe`/`p.productType`).
- `companyCatalogActive` — שקע `bool`; מגלם את הדגל-הגלובלי (install_engine.dart:7). **חסר ⇒ false** ⇒ הסעיף-השני כבוי, מסלול demo/off ביט-זהה.

## פלט
`bool` — `_fittingCats.contains(categoryHe) || (companyCatalogActive && _fittingTypes.contains(productType))`.

## התנהגות (עוגני-שורה למקור)
1. `categoryHe` באחת מ-16 קטגוריות-המחבר ⇒ `true` (install_engine.dart:801-806,817).
2. אחרת, **רק אם** `companyCatalogActive==true` **וגם** `productType` באחד מ-12 מונחי-הסוג ⇒ `true` (install_engine.dart:811-813,818).
3. אחרת ⇒ `false`.

## דוגמאות מספריות (מוכחות ב-is_fitting_test.dart)
| # | קלט | פלט | עוגן |
|---|-----|-----|------|
| 1 | categoryHe='אביזרי נחושת' | `true` | :801,817 |
| 2 | categoryHe='ברכיים' | `true` | :802,817 |
| 3 | categoryHe='צינורות PP' | `true` | :804,817 |
| 4 | categoryHe='אסלות וכיורים' | `false` (קבוע-תפקודי) | :817 |
| 5 | categoryHe='חבקי תליה' | `false` (מבני) | :817 |
| 6 | categoryHe='' | `false` | :817 |
| 7 | categoryHe='X' · productType='מצמד' · companyCatalogActive=**false** | `false` (סעיף-2 כבוי) | :818 |
| 8 | categoryHe='X' · productType='מצמד' · companyCatalogActive=**true** | `true` (name-fallback) | :811,818 |
| 9 | categoryHe='X' · productType='ברז' · companyCatalogActive=**true** | `false` (סוג לא-מחבר) | :818 |
| 10 | categoryHe='X' · productType=null · companyCatalogActive=**true** | `false` (null∉_fittingTypes) | :818 |

## עדשה-עוינת (קלטי-קצה — CURRICULUM #6)
- ברירת-המחדל של השקע = false ⇒ קטלוג-חברה-כבוי מתנהג ביט-זהה ל-snapshot הישן (#7).
- הסעיף-השני נשען על שני תנאים ב-AND: דגל-דלוק **וגם** productType-מחבר; כל אחד לבדו ⇒ false (#7,#9).
- `productType==null` נופל תמיד (Set.contains(null)==false), גם כשהדגל דלוק (#10).

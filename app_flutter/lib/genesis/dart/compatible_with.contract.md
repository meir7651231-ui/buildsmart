# חוזה · compatibleWith

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/logic/install_engine.dart:437-443`
**אטום:** `new/dart/compatible_with.dart` — `List<CompatNode> compatibleWith(CompatNode anchor, {catalog, canConnect, suitableForTemp, tempC})`

## קלט
- `anchor` — `CompatNode`: `sku` (String) · `categoryHe` (String).
- `catalog` — `List<CompatNode>` — מרחב-החיפוש (היה `kCompatCatalog` הגלובלי, :439).
- `canConnect` — שקע `bool Function(CompatNode a, CompatNode b)` — היה `canConnect(anchor,p)` (:440, האטום can_connect.dart).
- `suitableForTemp` — שקע `bool Function(CompatNode p, int tempC)` — היה `productSuitableForTemp(p,tempC)` (:440).
- `tempC` — `int` (ברירת-מחדל 20, :438).

## פלט
`List<CompatNode>` — כל `p` ב-catalog ש-`canConnect(anchor,p) && suitableForTemp(p,tempC)` (:440), ממוין כך שמוצרים באותה `categoryHe` כמו-העוגן קודמים (:442-443).

## התנהגות (עוגני-שורה למקור)
1. סינון: `where((p) => canConnect(anchor,p) && suitableForTemp(p,tempC))` (:440).
2. מיון: מפתח בינארי `a.categoryHe == anchor.categoryHe ? 0 : 1`, `compareTo` (:442-443) — 0 (אותה-קטגוריה) קודם 1. טעם-הקשירה בין שני-פריטים באותו-מפתח אינו מובטח (List.sort אינו יציב) — verbatim.
3. **מטמון `_compatCache` (:436-439) הושמט:** אופטימיזציה בלבד, פלט זהה-ביט; מטמון חוצה-קטלוגים היה לא-נכון עם catalog מוזרק.

## דוגמאות מספריות (מוכחות ב-compatible_with_test.dart)
| # | קלט | פלט | עוגן |
|---|-----|-----|------|
| 1 | anchor cat='ברזים'; n5 canConnect=false, n3 temp=false | אורך 3; n5,n3 מסוננים | :440 |
| 2 | n2,n4 cat='ברזים' (עוגן), n1 cat='X' | n2,n4 (מפתח0) קודמים, res[2]=n1 | :442-443 |
| 3 | catalog ריק | `[]` | :439-441 |
| 4 | canConnect ⇒ false-לכול | `[]` | :440 |
| 5 | 2 פריטים cat='ברזים', הכול-עובר | אורך 2 | :440-443 |

## עדשה-עוינת
- הסינון קורא לשני-השקעים עם `&&` — קצר-דרך: canConnect=false ⇒ suitableForTemp לא-נקרא (#4).
- מפתח-המיון בינארי בלבד; אין דירוג פנימי בתוך-קבוצה (טעם-הקשירה לא-נבדק ב-#2 → set).
- catalog מוזרק (לא גלובלי) ⇒ אין מטמון; כל-קריאה מחשבת מחדש, פלט זהה.

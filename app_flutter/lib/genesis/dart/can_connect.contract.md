# חוזה · canConnect

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/logic/install_engine.dart:498-521`
**אטום:** `new/dart/can_connect.dart` — `bool canConnect(ConnPart a, ConnPart b, {verifiedCompat})`

## קלט
- `a`, `b` — `ConnPart`: `sku` (String) · `connectionSizes` (List&lt;String&gt; גדלי-DN) · `connectionGender` (String? — 'male'/'female'/null) · `connectionMethod` (String? — 'thread'/'glue'/'electrofusion'/null).
- `verifiedCompat` — שקע `bool? Function(String skuA, String skuB)`. מייצג את `kVerifiedSpecs[sku]` + `VerifiedSpec.compatibleWith` (install_engine.dart:502-503): מחזיר `null` כשלא-לשניהם ספק-מאומת, אחרת `vA.compatibleWith(vB)`. חסר ⇒ `null` (name-inference).

## פלט
`bool` — האם המוצרים יכולים להתחבר.

## התנהגות (עוגני-שורה למקור)
1. `a.sku == b.sku` ⇒ `false` (install_engine.dart:499).
2. שקע-האימות מחזיר לא-null ⇒ מחזירים אותו verbatim, ללא בדיקת גדלים (install_engine.dart:502-503).
3. אחרת (`null`) — name-inference:
   - `sA` או `sB` ריקים, **או** אין חיתוך-גדלים ⇒ `false` (install_engine.dart:506-508).
   - שני המינים מפורשים ושווים ⇒ `false`; צד-אחד null ⇒ מותר (install_engine.dart:514-515).
   - שתי השיטות מפורשות ושונות ⇒ `false`; צד-אחד null ⇒ מותר (install_engine.dart:517-518).
   - אחרת ⇒ `true` (install_engine.dart:520).

## דוגמאות מספריות (מוכחות ב-can_connect_test.dart)
| # | קלט | פלט | עוגן |
|---|-----|-----|------|
| 1 | a.sku='X', b.sku='X' | `false` | :499 |
| 2 | skus שונים · verifiedCompat=(_,_)⇒true · sizes ריקים | `true` | :503 |
| 3 | skus שונים · verifiedCompat=(_,_)⇒false · sizes=['20']&['20'] | `false` | :503 |
| 4 | sizes=['20']&['20'] · gender=null · method=null (אין שקע) | `true` | :520 |
| 5 | sizes=[]&['20'] | `false` | :508 |
| 6 | sizes=['20']&['25'] (זרים) | `false` | :508 |
| 7 | sizes=['20']&['20'] · gender='male'&'male' | `false` | :515 |
| 8 | sizes=['20']&['20'] · gender='male'&null | `true` | :514-515 |
| 9 | sizes=['20']&['20'] · method='thread'&'glue' | `false` | :518 |
| 10 | sizes=['20']&['20'] · method='thread'&null | `true` | :517-518 |

## עדשה-עוינת (קלטי-קצה — CURRICULUM #6)
- sku-זהה גובר על הכול, גם כשגדלים/שקע היו מתירים (#1).
- שקע-מאומת גובר על name-inference: מחזיר גם `false` וגם `true` verbatim, בלי לגעת בגדלים (#2,#3).
- גדלים-ריקים = חוסם (isEmpty לפני intersection, מונע חיתוך-ריק-כוזב) (#5).
- שער-המין/שיטה חוסם **רק** כששני הצדדים מפורשים; null בצד-אחד = מותר (חפיפת-הגדלים היא השומר) (#8,#10).

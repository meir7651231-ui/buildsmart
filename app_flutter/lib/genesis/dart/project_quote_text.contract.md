# חוזה · projectQuoteText

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/state/card_projects.dart:81-95`
**טיפוס:** `ProjectItem` (card_projects.dart:14)
**אטום:** `new/dart/project_quote_text.dart` — `String projectQuoteText(String project, List<QuoteLineItem> items, {unitPriceOf, brandName})`

## קלט
- `project` — String (שם-הפרויקט).
- `items` — List&lt;QuoteLineItem&gt;: `location` · `brandName` · `sku` · `qty` (int).
- **שקעים:** `unitPriceOf(sku) → int?` — מייצג `catalogProductForSku`+`priceFor` המקוריים; null ⇒ מחיר-יחידה 0 (ברירת-מחדל null). `brandName` — מייצג AppBrand.name (ברירת-מחדל 'BuildSmart').

## פלט
`String` — שורות מחוברות ב-`\n`.

## התנהגות (עוגני-שורה)
1. שורת-כותרת: `הצעת מחיר — פרויקט "<project>"` (:82).
2. לכל פריט: `unit = unitPriceOf(sku) ?? 0`; `sub = unit*qty`; `total += sub`; שורה `• <location>: <brandName> ×<qty> — ~₪<sub>` (:84-90).
3. `סה"כ משוער: ~₪<total>` (:91) · `— נוצר ב-<brandName>` (:92).

## דוגמאות מספריות (מוכחות ב-project_quote_text_test.dart)
נתון: `items=[QuoteLineItem(location:'מטבח',brandName:'מותג-א',sku:'S1',qty:2), QuoteLineItem(location:'אמבטיה',brandName:'מותג-ב',sku:'S2',qty:1)]`, `unitPriceOf: S1→100, S2→null`.

| # | קלט | פלט (`\n`) |
|---|-----|-----|
| 1 | project='דירה 4' · unitPriceOf כנ"ל | `הצעת מחיר — פרויקט "דירה 4"`⏎`• מטבח: מותג-א ×2 — ~₪200`⏎`• אמבטיה: מותג-ב ×1 — ~₪0`⏎`סה"כ משוער: ~₪200`⏎`— נוצר ב-BuildSmart` |
| 2 | items=[] · project='ריק' | `הצעת מחיר — פרויקט "ריק"`⏎`סה"כ משוער: ~₪0`⏎`— נוצר ב-BuildSmart` |
| 3 | פריט יחיד sku ללא-מחיר (null) · qty=3 | שורת-פריט `— ~₪0` · `סה"כ משוער: ~₪0` |
| 4 | brandName='BuildMax' | שורת-סיום `— נוצר ב-BuildMax` |

## עדשה-עוינת
- sku ללא-מחיר (unitPriceOf=null) ⇒ `unit=0`, `sub=0` — זהה לסמנטיקת המקור (prod==null ? 0 : priceFor??0), ששני מסלוליו נותנים 0 (#1 שורה-ב', #3).
- items ריק ⇒ total=0, אך הכותרת+סה"כ+חתימה תמיד נכתבות (#2).
- `total` הוא סכום ה-`sub` (unit*qty), לא unit גולמי (#1).

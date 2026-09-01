# חוזה · quoteTextFor

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/data/related_info.dart:1259-1279`
**טיפוסים:** `SmartProduct` (smart_tree.dart:116) · `SmartBrand` (smart_tree.dart:78)
**אטום:** `new/dart/quote_text_for.dart` — `String quoteTextFor(QuoteProduct sp, int brandIndex, {lineCostEstimate, deepLink, brandName})`

## קלט
- `sp` — `QuoteProduct`: `name` (String) · `brands` (List&lt;QuoteBrand&gt;) · getter `recBrand`= `brands.firstWhere((b)=>b.rec, orElse:()=>brands.first)`.
- `QuoteBrand`: `name` (String) · `price` (int? — null=לפי-ספק) · `rec` (bool).
- `brandIndex` — int. בטווח [0,len) ⇒ נבחר; אחרת ⇒ `brands.indexOf(recBrand)`.
- **שקעים:** `lineCostEstimate(idx) → ({product,accessories,labour,total})?` (מייצג lineCostEstimateFor · ברירת-מחדל null) · `deepLink(idx) → String` (מייצג deepLinkFor · ברירת-מחדל '') · `brandName` (מייצג AppBrand.name · ברירת-מחדל 'BuildSmart').

## פלט
`String` — שורות מחוברות ב-`\n`.

## התנהגות (עוגני-שורה)
1. `idx` — brandIndex בטווח ⇒ הוא-עצמו; אחרת `indexOf(recBrand)` (:1260-1262).
2. שתי שורות-פתיחה: `הצעת מחיר — <name>` · `מותג: <b.name>` (:1264).
3. `cost != null` (:1266): `מוצר: ~₪<product>`; `accessories>0` ⇒ `אביזרים:…`; `labour>0` ⇒ `עבודה (משוער):…`; תמיד `סה"כ משוער: ~₪<total>` (:1267-1271).
4. אחרת אם `b.price != null` ⇒ `מחיר: ~₪<price>` (:1272-1273).
5. `🔗 <deepLink(idx)>` (:1275) · `— נוצר ב-<brandName>` (:1276).

## דוגמאות מספריות (מוכחות ב-quote_text_for_test.dart)
נתון: `sp=QuoteProduct(name:'סיפון', brands:[QuoteBrand('מותג-א',price:100,rec:true), QuoteBrand('מותג-ב',price:200)])`, `deepLink=(i)=>'LINK$i'`.

| # | brandIndex · cost · brandName | פלט (שורות, `\n`) |
|---|---|---|
| 1 | 0 · (product:50,accessories:20,labour:0,total:70) · ברירת-מחדל | `הצעת מחיר — סיפון`⏎`מותג: מותג-א`⏎`מוצר: ~₪50`⏎`אביזרים: ~₪20`⏎`סה"כ משוער: ~₪70`⏎`🔗 LINK0`⏎`— נוצר ב-BuildSmart` |
| 2 | -1 (מחוץ-לטווח) · null · ברירת-מחדל | idx=recBrand=0 ⇒ `…`⏎`מותג: מותג-א`⏎`מחיר: ~₪100`⏎`🔗 LINK0`⏎`— נוצר ב-BuildSmart` |
| 3 | 0 · (product:50,accessories:0,labour:30,total:80) · ברירת-מחדל | `…`⏎`מוצר: ~₪50`⏎`עבודה (משוער): ~₪30`⏎`סה"כ משוער: ~₪80`⏎… (accessories=0 מדלג) |
| 4 | 0 על brand ללא-price · cost=null · ברירת-מחדל | לא `מחיר:` ולא `מוצר:` — רק פתיחה+`🔗`+`— נוצר ב-…` |
| 5 | 0 · null · brandName='BuildMax' | שורת-סיום `— נוצר ב-BuildMax` |

## עדשה-עוינת
- brandIndex מחוץ-לטווח נופל ל-recBrand דרך `indexOf` (זהות-אלמנט; firstWhere מחזיר את האלמנט עצמו) (#2).
- `cost` גובר על `b.price` (else-if): כשיש cost, `מחיר:` לעולם לא נכתב (#1).
- accessories=0/labour=0 מדלגים את שורתם, אך `סה"כ` תמיד נכתב כשיש cost (#3).
- cost=null **וגם** price=null ⇒ אין שורת-מחיר כלל (#4).

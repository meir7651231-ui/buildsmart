# חוזה · `companyComplementsFor`

מוצא: `buildsmart/app_flutter/lib/data/company_categories.dart:74-91`.

`List<LipskeyCatalogProduct> companyComplementsFor(LipskeyCatalogProduct p, List<LipskeyCatalogProduct> pool)` —
משלימי-החברה: `dims['מוצרים משלימים']` (skus מופרד-`|`) נפתרים מול `pool`.

- `dims` חסר / לא-String / ריק ⇒ `[]`.
- סדר נשמר; sku לא-ידוע נופל בשקט; התאמה-ראשונה זוכה.
- טיפוס-שכן מוטבע: `LipskeyCatalogProduct` (sku, dims).
- טהור, אפס import.

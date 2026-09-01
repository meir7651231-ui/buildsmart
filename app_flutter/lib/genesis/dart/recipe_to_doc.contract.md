# חוזה · `recipeToDoc`

מוצא: `buildsmart/app_flutter/lib/data/repositories/recipe_seed.dart:27-66`.

`Map<String, dynamic> recipeToDoc(SmartProduct r)` — שדה-מפה של `recipes/{key}`.

- `brands`/`acc`/`stages` מקוננים, כל אחד שומר את קישור-ה-sku.
- `sku`/`imageAsset` נכתבים רק כשלא-null; המחיר מושמט במכוון.
- טיפוסי-שכן מוטבעים: `SmartStage`, `SmartBrand`, `SmartAcc`, `SmartProduct` (רק השדות הנקראים).
- Map רגילה — בלי Firestore/Timestamp. טהור, אפס import.

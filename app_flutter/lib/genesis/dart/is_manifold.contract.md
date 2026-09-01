# חוזה · isManifold

- **מוצא:** `buildsmart/app_flutter/lib/features/catalog_config/product_config_schema.dart:310-314` (הפונקציה הפרטית `_isManifold`).
- **חתימה:** `bool isManifold(LipskeyCatalogProduct p)`
- **התנהגות (חוק-4, verbatim):** `p.nameHe.contains('מחלק') || p.nameHe.contains('סעפת')` — זיהוי מחלק/סעפת לפי מחרוזת-השם.
- **טוהר:** אפס import. `LipskeyCatalogProduct` הוטבע מ-`lipskey_catalog.dart:4` עם השדה היחיד הנקרא (`nameHe`).
- **אימות:** `dart analyze` נקי + `dart run --enable-asserts is_manifold_test.dart` עובר.

# חוזה · token

- **מוצא:** `buildsmart/app_flutter/lib/features/catalog_config/config_card.dart:200-206` (הפונקציה הפרטית `_token`).
- **חתימה:** `String token(AttributeValue v)`
- **התנהגות (חוק-4, verbatim):** מחזירה `v.canonical ?? v.labelHe` — הטוקן הקנוני של הערך, ובהיעדרו התווית העברית.
- **טוהר:** אפס import. טיפוס-השכן `AttributeValue` הוטבע מ-`trade_schema.dart:168` עם רק שני השדות הנקראים (`canonical` · `labelHe`).
- **אימות:** `dart analyze` נקי + `dart run --enable-asserts token_test.dart` עובר.

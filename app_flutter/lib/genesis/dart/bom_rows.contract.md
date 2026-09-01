# חוזה · bomRows

- **מוצא:** `buildsmart/app_flutter/lib/features/fittings/intel/line_bom.dart:40-45`.
- **חתימה:** `List<BomRow> bomRows(InstallationPlan plan)`
- **התנהגות (חוק-4, verbatim):** לכל רכיב ב-`plan.items` (בסדר-הופעה) בונה `BomRow(p.sku, p.nameHe, plan.qtyOf(p.sku))`. `qtyOf` = `quantities[sku] ?? 1` (רכיב חסר-כמות ⇒ 1).
- **טוהר:** אפס import. שלושה טיפוסי-שכן הוטבעו (`BomRow` verbatim; `LipskeyCatalogProduct` ו-`InstallationPlan` מצומצמים לשדות/מתודה הנקראים בלבד — כלל-1). `qtyOf` אינו קורא סמלים חיצוניים ⇒ הוטבע verbatim.
- **אימות:** `dart analyze` נקי + `dart run --enable-asserts bom_rows_test.dart` עובר.

// ⚛️ אטום-Dart (דרגת-חוזה) · tail
// מוצא: buildsmart/app_flutter/lib/data/repositories/store_inventory.dart:123-128 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
// פרטי-במקור: `_tail` — הוצא לחוזה כ-top-level ציבורי `tail`.
//
// קלט:  sku — מק"ט; n — מספר-ספרות.
// פלט:  n הספרות האחרונות כמספר (או 0 אם אינן מספר).

/// n הספרות האחרונות של [sku] כמספר (בסיס דטרמיניסטי למחיר/מלאי). טהור.
int tail(String sku, int n) {
  final s = sku.length <= n ? sku : sku.substring(sku.length - n);
  return int.tryParse(s) ?? 0;
}

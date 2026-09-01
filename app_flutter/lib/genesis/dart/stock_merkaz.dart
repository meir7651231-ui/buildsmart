// ⚛️ אטום-Dart (דרגת-חוזה) · stockMerkaz
// מוצא: buildsmart/app_flutter/lib/data/repositories/store_inventory.dart:132-135 (חצב-בינה · חוק-3/4).
// שקע: tail ← השכן `_tail(sku, n)` — n הספרות האחרונות של SKU נומרי (int).
// מוטבע verbatim (ערך-נתונים, כלל-1): הקבוע kC1HeadlineSku (store_inventory.dart:28).

const String kC1HeadlineSku = '118220';

int stockMerkaz(String sku, {required int Function(String, int) tail}) =>
    sku == kC1HeadlineSku ? 3 : 1 + (tail(sku, 2) % 7);

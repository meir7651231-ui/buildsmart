// ⚛️ אטום-Dart · od2Of
// מוצא: buildsmart/app_flutter/lib/features/fittings/engine/catalog_map.dart:81-89 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: `LipskeyCatalogProduct` (lipskey_catalog.dart:4) הוטבע בצורת-מינימום — הפונקציה
//        נוגעת רק ב-`nameHe`/`dims`; ה-RegExp `_kReducer` (:27) הוטבע verbatim.

/// צורת-מינימום של מוצר-הקטלוג — הפונקציה נוגעת רק ב-`nameHe`/`dims`.
class LipskeyCatalogProduct {
  final String nameHe;
  final Map<String, dynamic>? dims;
  const LipskeyCatalogProduct({required this.nameHe, this.dims});
}

/// שני קטרים דו-ספרתיים/תלת-ספרתיים מופרדים ב-× / x / X (מצרה: "50x40").
final RegExp _kReducer = RegExp(r'(\d{2,3})\s*[×xX]\s*(\d{2,3})');

/// הקוטר השני של מצרה (הקטן), או `null` אם לא דו-קוטרי.
int? od2Of(LipskeyCatalogProduct p, {required String Function(String) term}) {
  final m = _kReducer.firstMatch(p.nameHe) ??
      _kReducer.firstMatch(p.dims?[term('mydh')]?.toString() ?? '');
  if (m == null || m.group(1) == m.group(2)) return null;
  return int.tryParse(m.group(2)!);
}

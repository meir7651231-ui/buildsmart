// ⚛️ אטום-Dart · groupOf
// מוצא: buildsmart/app_flutter/lib/features/word_finder/category_groups.dart:131-133 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: הפרמטר `LipskeyCatalogProduct` הוטבע בצורת-מינימום — הפונקציה נוגעת רק ב-`.categoryHe`
//        (שאר השדות/גטרים הושמטו). הקבוע `kCategoryGroups` (:12-127) הוטבע verbatim (String→String).

/// צורת-מינימום של מוצר-הקטלוג — הפונקציה נוגעת רק ב-`categoryHe`.
class LipskeyCatalogProduct {
  final String categoryHe;
  const LipskeyCatalogProduct({required this.categoryHe});
}

/// קבוצת-הקטגוריה מול-הבעלים של [p] — מיפוי [kCategoryGroups], או 'אחר' לקטגוריה לא-ממופה.
/// TOTAL: לעולם לא null/ריק. PURE.
String groupOf(LipskeyCatalogProduct p, {required String Function(String) term, required Map<String, dynamic> kCategoryGroups,}) =>
    kCategoryGroups[p.categoryHe] ?? term('achr');

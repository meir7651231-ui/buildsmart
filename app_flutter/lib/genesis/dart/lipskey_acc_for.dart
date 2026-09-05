// ⚛️ אטום-Dart · lipskeyAccFor
// מוצא: buildsmart/app_flutter/lib/data/lipskey_smart_data.dart:330-332 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: הטיפוס `LipskeyCatAcc` (:4-18) הוטבע verbatim; הקבועים `kLipskeyAccBySku` (:327)
//        ו-`kLipskeyAccByCategory` (:97-204) הוטבעו verbatim (נתוני-קטלוג, dart:core בלבד).

class LipskeyCatAcc {
  final String name;
  final String emoji;
  final int? price;
  final String why;
  final bool must;

  const LipskeyCatAcc({
    required this.name,
    required this.emoji,
    this.price,
    required this.why,
    this.must = false,
  });
}




/// אביזרים למוצר: דריסת-SKU → ברירת-קטגוריה → ריק. PURE.
List<LipskeyCatAcc> lipskeyAccFor(String sku, String categoryHe, {required Map<String, List<LipskeyCatAcc>> kLipskeyAccBySku, required Map<String, List<LipskeyCatAcc>> kLipskeyAccByCategory}) =>
    kLipskeyAccBySku[sku] ?? kLipskeyAccByCategory[categoryHe] ?? const [];

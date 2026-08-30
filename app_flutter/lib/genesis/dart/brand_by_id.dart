// ⚛️ אטום-Dart · brandById
// מוצא: buildsmart/app_flutter/lib/data/brands.dart:88-94 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: הטיפוס `Brand` (:4-20) הוטבע verbatim; הקבוע `kBrands` (:25-86) הוטבע verbatim.

class Brand {
  const Brand({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.tagline = '',
    this.productCount = 0,
  });

  final String id;
  final String name;
  final String emoji;
  final int color;
  final String tagline;
  final int productCount;
}


/// מותג לפי [id], או null אם אין. PURE.
Brand? brandById(String id, {required List<Brand> kBrands}) {
  for (final b in kBrands) {
    if (b.id == id) return b;
  }
  return null;
}

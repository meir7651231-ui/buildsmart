// ⚛️ אטום-Dart (דרגת-חוזה) · brandValue
// מוצא: buildsmart/app_flutter/lib/features/word_finder/distinct_label.dart:112-122
//        (_brandValue; חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//
// אח שהוטבע (טיפוס-שכן, כלל-1): ה-class `LipskeyCatalogProduct` — טיפוס-הקלט.
//        הוטבעו שדותיו וה-const constructor verbatim מ-lib/data/lipskey_catalog.dart:4-54.
//        הגטרים/מתודות-ההתנהגות הושמטו במכוון — הם קוראים סמלים חיצוניים
//        (אטומים-אחרים) ולכן היו שוברים את חוק-1; האטום קורא רק את השדה `brand`.
// פרטי-במקור: `_brandValue` → הוצא-לחוזה כ-top-level ציבורי `brandValue`.
//
// קלט:  p — מוצר-קטלוג. פלט: ה-brand מנוקה-רווחים.

/// שדות ה-class + ה-const constructor verbatim (lipskey_catalog.dart:4-54).
class LipskeyCatalogProduct {
  final String sku;
  final String nameHe;
  final String nameEn;
  final String? color;
  final int? qtyPack;
  final int? qtyPallet;
  final String categoryHe;
  final String categoryEn;
  final String categoryEmoji;
  final int page;
  final Map<String, dynamic>? dims;
  final String? imageFile;
  final List<String>? imageFiles;
  final String? specImageFile;
  final List<String>? specImageFiles;
  final String brand;
  final String? imageAssetOverride;

  const LipskeyCatalogProduct({
    required this.sku,
    required this.nameHe,
    required this.nameEn,
    this.color,
    this.qtyPack,
    this.qtyPallet,
    required this.categoryHe,
    required this.categoryEn,
    required this.categoryEmoji,
    required this.page,
    this.dims,
    this.imageFile,
    this.imageFiles,
    this.specImageFile,
    this.specImageFiles,
    this.brand = 'ליפסקי',
    this.imageAssetOverride,
  });
}

/// The brand axis value: the trimmed `brand`, or '' when absent. PURE.
String brandValue(LipskeyCatalogProduct p) => p.brand.trim();

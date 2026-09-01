import '../dart-data/color_value-brand.dart';
// ⚛️ אטום-Dart (דרגת-חוזה) · colorValue
// מוצא: buildsmart/app_flutter/lib/features/word_finder/distinct_label.dart:109-111
//        (_colorValue; חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//
// אח שהוטבע (טיפוס-שכן, כלל-1): ה-class `LipskeyCatalogProduct` — טיפוס-הקלט.
//        הוטבעו שדותיו וה-const constructor verbatim מ-lib/data/lipskey_catalog.dart:4-54.
//        הגטרים/מתודות-ההתנהגות (imageAsset/connectionSizes וכו') הושמטו במכוון —
//        הם קוראים סמלים חיצוניים (אטומים-אחרים) ולכן היו שוברים את חוק-1; האטום
//        קורא רק את השדה `color`, שנשמר ביט-זהה.
// פרטי-במקור: `_colorValue` → הוצא-לחוזה כ-top-level ציבורי `colorValue`.
//
// קלט:  p — מוצר-קטלוג. פלט: ה-color מנוקה-רווחים, או '' כשאין.

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
    this.brand = kDefaultBrand,
    this.imageAssetOverride,
  });
}

/// The colour axis value: the trimmed `color`, or '' when absent. PURE.
String colorValue(LipskeyCatalogProduct p) => p.color?.trim() ?? '';

// ⚛️ אטום-Dart · lipskeyStagesFor
// מוצא: buildsmart/app_flutter/lib/data/lipskey_smart_data.dart:334-336 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: הטיפוס `LipskeyCatStage` (:21-33) הוטבע verbatim; הקבועים `kLipskeyStagesBySku` (:328)
//        ו-`kLipskeyStagesByCategory` (:207-319) הוטבעו verbatim (נתוני-קטלוג, dart:core בלבד).

class LipskeyCatStage {
  final String emoji;
  final String label;
  final String desc;
  final bool isFinal;

  const LipskeyCatStage({
    required this.emoji,
    required this.label,
    this.desc = '',
    this.isFinal = false,
  });
}






/// שלבי-התקנה למוצר: דריסת-SKU → ברירת-קטגוריה → ריק. PURE.
List<LipskeyCatStage> lipskeyStagesFor(String sku, String categoryHe, {required Map<String, List<LipskeyCatStage>> kLipskeyStagesBySku, required Map<String, List<LipskeyCatStage>> kLipskeyStagesByCategory}) =>
    kLipskeyStagesBySku[sku] ?? kLipskeyStagesByCategory[categoryHe] ?? const [];

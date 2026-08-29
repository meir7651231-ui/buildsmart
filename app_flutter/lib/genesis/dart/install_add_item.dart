// ⚛️ אטום-Dart (דרגת-חוזה) · installAddItem
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:1279-1286
//        (הסגור המקומי `add` בתוך buildTreeInstallation) · חוק-4 — התנהגות זהה, לא-משופרת.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). הסגור סגר על שלושה
//        משתני-סביבה (install_engine.dart:1273·1274·1276: items · qty · zones) — כולם הופכו
//        לשקעי-פרמטר (חוק-3). הגישה `p.sku` הופכה לשקע `skuOf` (חוק-3) כדי להסיר את
//        התלות במחלקה LipskeyCatalogProduct — האטום גנרי על T.
//
// קלט:  p      — הפריט להוספה (טיפוס גנרי T; נשמר verbatim ברשימת-items).
//       zone   — תווית-אזור אופציונלית (String?); null ⇒ אין רישום-אזור.
//       skuOf  — שקע: getter טהור T→String (מזהה-הפריט; מקור: p.sku). חייב להיות
//                חסר-תופעות-לוואי כמו גישת-שדה.
//       items  — שקע (מוטבל במקום): רשימת-הפריטים המצטברת. פריט נוסף רק כשה-sku חדש.
//       qty    — שקע (מוטבל במקום): מפת sku→כמות. מוגדלת ב-1 בכל קריאה.
//       zones  — שקע (מוטבל במקום): מפת אזור→רשימת-sku-ים. get-or-create + dedup.
// פלט:  void — האטום מוטבל את שלושת השקעים-האוספים במקום (בדיוק כמקור).

/// Add one unit of product [p] into an installation bill-of-materials.
/// Appends [p] to [items] only the first time its sku is seen; always bumps the
/// sku count in [qty]; when [zone] is non-null records the sku under that zone
/// in [zones] (get-or-create list, sku deduped within the list).
void installAddItem<T>(
  T p, {
  String? zone,
  required String Function(T) skuOf,
  required List<T> items,
  required Map<String, int> qty,
  required Map<String, List<String>> zones,
}) {
  final sku = skuOf(p);
  if (!qty.containsKey(sku)) items.add(p);
  qty[sku] = (qty[sku] ?? 0) + 1;
  if (zone != null) {
    final zl = zones.putIfAbsent(zone, () => <String>[]);
    if (!zl.contains(sku)) zl.add(sku);
  }
}

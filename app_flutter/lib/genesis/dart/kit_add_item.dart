// ⚛️ אטום-Dart (דרגת-חוזה) · kitAddItem
// מוצא: buildsmart/app_flutter/lib/logic/install_kit.dart:159-161
//        (הסגור המקומי `void addItem(String key, KitItem item)` בתוך
//        `recommendedKitFor`). תאום זהה-גוף באותו קובץ: install_kit.dart:114
//        (`void add(String key, KitItem item)` בתוך `recommendedKitForProduct`) —
//        מאשר שזה עוזר-dedup טהור ומשומש-פעמיים, לא רעש-מקומי. חוק-4 — התנהגות
//        זהה, לא-משופרת.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). הסגור סגר על
//        משתנה-הסביבה `out` (install_kit.dart:157: `final out = <String, KitItem>{}`)
//        — הופך לשקע-פרמטר ראשון (חוק-3). טיפוס-הערך `KitItem` הופך לגנרי V כדי
//        להסיר את התלות במחלקת-האתר (חוק-1/5 — האטום לא נושא ידע-הקשר).
//
// קלט:  out  — שקע (מוטבל במקום): מפת מפתח→ערך המצטברת. הערך נוסף רק כשהמפתח חדש.
//       key  — מפתח-הזהות (String). מפתח קיים ⇒ אין-שינוי (first-write-wins).
//       item — הערך להוספה (טיפוס גנרי V; נשמר verbatim תחת key בהוספה ראשונה).
// פלט:  void — האטום מוטבל את `out` במקום (בדיוק כמקור: `out.putIfAbsent`).

/// Insert [item] under [key] into [out] only the first time [key] is seen.
/// If [key] already exists (even with a null value) the existing entry is kept
/// unchanged — first-write-wins deduplication, exactly `Map.putIfAbsent`.
void kitAddItem<V>(Map<String, V> out, String key, V item) {
  out.putIfAbsent(key, () => item);
}

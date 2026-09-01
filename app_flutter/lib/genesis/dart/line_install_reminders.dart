// ⚛️ אטום-Dart (דרגת-חוזה) · lineInstallReminders
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:225-228
//        (‏lineInstallReminders; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי, אפס-קלט, אפס-שקע —
//       מחזירה רשימת-const קבועה של תזכורות-שטח (טקסט מייעץ, לא הקשר/זהות/סוד).
//
// התנהגות (מקור:225-228): תזכורות-שטח שנשארות מייעצות (לא פריטי-קו בני-מעקב).
//
// קלט:  (אין).
// פלט:  List<String> — שתי תזכורות-ההתקנה, בסדר קבוע.

/// Site reminders that remain advisory (not auto-trackable line-items).
List<String> lineInstallReminders() => const [
      'שיפוע לקטע אופקי ארוך',
      'נקודת בדיקה/גישה לתחזוקה',
    ];

// ⚛️ אטום-Dart (דרגת-חוזה) · lineIsSupply
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:68-69
//        (‏lineIsSupply; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט).
//       ‏enum WaterSystem (מחזיק-פלט טהור) מוגדר מקומית — טיפוס-הדומיין נלקח verbatim
//       מ-lipskey_verified_connections.dart:30.
//
// שקע שהוזרק (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • `kVerifiedSpecs[p.sku]?.endSystems`  (install_engine.dart:69)
//     — המפה-הגלובלית + מחלץ-ה-endSystems קורסים לשקע-יחיד
//       `endSystemsOf(p) → Set<WaterSystem>?` (‏null כשאין spec למוצר). ה-
//       `?.contains(supply) ?? false` חי באטום: אין spec ⇒ false לאותו פריט.
//   • טיפוס-המוצר מופשט לגנריקה <P>; במקור P≡LipskeyCatalogProduct.
//
// התנהגות (מקור:68-69): true אם **לפחות מוצר אחד** בקו נושא קצה-אספקה
//   (‏endSystems מכיל WaterSystem.supply) — קו-אספקה בלחץ. קו-ניקוז-כובד טהור
//   (סיפונים + צינור-ניקוז) ⇒ false, ולעולם לא מקבל ברז-ניתוק-אספקה.
//
// קלט:  items        — רשימת מוצרי-הקו.
//       endSystemsOf — שקע: p → קבוצת-מערכות-המים של קצותיו, או null (אין spec).
// פלט:  bool — האם הקו נושא מים בלחץ (אספקה).

/// The plumbing system an end belongs to (verbatim: lipskey_verified_connections.dart:30).
enum WaterSystem { supply, drainage }

/// True when the line carries PRESSURISED SUPPLY water, so supply-side
/// compliance (isolation ball valve, PRV, expansion vessel, TMTV …) applies.
bool lineIsSupply<P>(
  List<P> items, {
  required Set<WaterSystem>? Function(P) endSystemsOf,
}) =>
    items.any(
        (p) => endSystemsOf(p)?.contains(WaterSystem.supply) ?? false);

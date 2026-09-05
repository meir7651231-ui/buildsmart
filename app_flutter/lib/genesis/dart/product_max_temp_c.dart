// ⚛️ אטום-Dart (דרגת-חוזה) · productMaxTempC
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:51
//        (‏productMaxTempC; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט).
//
// שקע שהוזרק (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • `kVerifiedSpecs[p.sku]?.maxTempC`  (install_engine.dart:51)
//     — המפה-הגלובלית קורסת לשקע-חיפוש `specOf(p) → S?` (‏S = מחזיק-spec טהור,
//       null כשאין spec למוצר) + מחלץ-שדה `maxTempCOf(s) → double`. ה-`?.`
//       חי באטום: אין spec ⇒ null; יש spec ⇒ maxTempC שלו.
//   • טיפוסי-הקלט מופשטים לגנריקה <P, S> לשמירת טוהר-מוחלט (אפס תלות
//       ב-LipskeyCatalogProduct/VerifiedSpec); במקור P≡LipskeyCatalogProduct,
//       S≡VerifiedSpec, ו-maxTempC ברירת-מחדל 40 (double).
//
// קלט:  p          — המוצר (במקור בעל .sku לחיפוש; כאן אטום-שקוף שמועבר ל-specOf).
//       specOf     — שקע: p → מחזיק-spec (S) או null כשאין spec (מקור:51 — `?.`).
//       maxTempCOf — שקע: S → טמפרטורת-שירות-מרבית (double, °C).
// פלט:  double? — הטמפרטורה המרבית של חומר-המוצר, או null כשאין spec מאומת.

/// Max service temperature of a product, or null if unknown (no verified spec).
double? productMaxTempC<P, S>(
  P p, {
  required S? Function(P) specOf,
  required double Function(S) maxTempCOf,
}) {
  final s = specOf(p);
  return s == null ? null : maxTempCOf(s);
}

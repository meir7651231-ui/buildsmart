// ⚛️ אטום-Dart (דרגת-חוזה) · productMaterial
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:54
//        (‏productMaterial; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט).
//
// שקע שהוזרק (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • `kVerifiedSpecs[p.sku]?.material`  (install_engine.dart:54)
//     — המפה-הגלובלית קורסת לשקע-חיפוש `specOf(p) → S?` (‏S = מחזיק-spec טהור,
//       null כשאין spec למוצר) + מחלץ-שדה `materialOf(s) → String`. ה-`?.`
//       חי באטום: אין spec ⇒ null; יש spec ⇒ ה-material שלו
//       (‏HDPE / PEX / נחושת / פליז …).
//   • טיפוסי-הקלט מופשטים לגנריקה <P, S> לשמירת טוהר-מוחלט; במקור
//       P≡LipskeyCatalogProduct, S≡VerifiedSpec, material הוא String לא-null בתוך-spec.
//
// קלט:  p          — המוצר (במקור בעל .sku לחיפוש; כאן אטום-שקוף שמועבר ל-specOf).
//       specOf     — שקע: p → מחזיק-spec (S) או null כשאין spec (מקור:54 — `?.`).
//       materialOf — שקע: S → תווית-חומר (String).
// פלט:  String? — תווית-החומר של המוצר, או null כשאין spec מאומת.

/// Material label of a product (HDPE / PEX / נחושת / פליז …), or null.
String? productMaterial<P, S>(
  P p, {
  required S? Function(P) specOf,
  required String Function(S) materialOf,
}) {
  final s = specOf(p);
  return s == null ? null : materialOf(s);
}

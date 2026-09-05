// ⚛️ אטום-Dart (דרגת-חוזה) · productSystems
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:278-286
//        (‏productSystems; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט).
//       ‏enum WaterSystem (מחזיק-פלט טהור) verbatim מ-lipskey_verified_connections.dart:30.
//       ‏supplyCats (מקור:240-247) · drainCats (257-262) · fixtureCats (263-267) ·
//       structuralCats (268-271) · allSystems (273) = דאטה-קבוע פנימי.
//
// שקע שהוזרק (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • `kVerifiedSpecs[p.sku]?.endSystems`  (install_engine.dart:284)
//     — נקרא **רק בענף-הנפילה** (קטגוריה עמומה). מוזרק כשקע-thunk עצל
//       `endSystemsOf() → Set<WaterSystem>?` (‏null כשאין spec) — נקרא רק בעת-הצורך,
//       ומשמר את סדר-ההערכה של המקור (בלי לגעת ב-kVerifiedSpecs כשהקטגוריה מכריעה).
//
// התנהגות (מקור:280-285): קטגוריות-ברורות מקבעות מערכת-אחת (אספקה/ניקוז);
//   קבועים+מבניים פורשים את שתיהן; קטגוריה-עמומה נופלת לקצות-המוצר עצמם,
//   ובהיעדרם ⇒ שתי-המערכות (‏allSystems).
//
// קלט:  categoryHe   — קטגוריית-המוצר בעברית (‏p.categoryHe).
//       endSystemsOf — שקע-thunk: מערכות-הקצוות של המוצר, או null (אין spec).
// פלט:  Set<WaterSystem> — קבוצת-מערכות-המים שהמוצר משתייך אליהן.

/// The plumbing system an end belongs to (verbatim: lipskey_verified_connections.dart:30).
enum WaterSystem { supply, drainage }

/// Categories that pin the SUPPLY system (verbatim: install_engine.dart:240-247).

/// Categories that pin the DRAINAGE system (verbatim: install_engine.dart:257-262).

/// Fixture categories — span both systems (verbatim: install_engine.dart:263-267).

/// Structural categories — span both systems (verbatim: install_engine.dart:268-271).


/// The plumbing systems a product belongs to, by engineering logic.
Set<WaterSystem> productSystems(
  String categoryHe, {
  required Set<WaterSystem>? Function() endSystemsOf, required Set supplyCats, required Set drainCats, required Set fixtureCats, required Set structuralCats, required Set<WaterSystem> allSystems}) {
  final c = categoryHe;
  if (supplyCats.contains(c)) return {WaterSystem.supply};
  if (drainCats.contains(c)) return {WaterSystem.drainage};
  if (fixtureCats.contains(c) || structuralCats.contains(c)) return allSystems;
  // Ambiguous category → split by context using the product's own ends.
  final ends = endSystemsOf();
  return (ends == null || ends.isEmpty) ? allSystems : ends;
}

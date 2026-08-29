// ⚛️ אטום-Dart (דרגת-חוזה) · productSystems
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:278-286
//        (‏productSystems; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט).
//       ‏enum WaterSystem (מחזיק-פלט טהור) verbatim מ-lipskey_verified_connections.dart:30.
//       ‏_supplyCats (מקור:240-247) · _drainCats (257-262) · _fixtureCats (263-267) ·
//       _structuralCats (268-271) · _allSystems (273) = דאטה-קבוע פנימי.
//
// שקע שהוזרק (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • `kVerifiedSpecs[p.sku]?.endSystems`  (install_engine.dart:284)
//     — נקרא **רק בענף-הנפילה** (קטגוריה עמומה). מוזרק כשקע-thunk עצל
//       `endSystemsOf() → Set<WaterSystem>?` (‏null כשאין spec) — נקרא רק בעת-הצורך,
//       ומשמר את סדר-ההערכה של המקור (בלי לגעת ב-kVerifiedSpecs כשהקטגוריה מכריעה).
//
// התנהגות (מקור:280-285): קטגוריות-ברורות מקבעות מערכת-אחת (אספקה/ניקוז);
//   קבועים+מבניים פורשים את שתיהן; קטגוריה-עמומה נופלת לקצות-המוצר עצמם,
//   ובהיעדרם ⇒ שתי-המערכות (‏_allSystems).
//
// קלט:  categoryHe   — קטגוריית-המוצר בעברית (‏p.categoryHe).
//       endSystemsOf — שקע-thunk: מערכות-הקצוות של המוצר, או null (אין spec).
// פלט:  Set<WaterSystem> — קבוצת-מערכות-המים שהמוצר משתייך אליהן.

/// The plumbing system an end belongs to (verbatim: lipskey_verified_connections.dart:30).
enum WaterSystem { supply, drainage }

/// Categories that pin the SUPPLY system (verbatim: install_engine.dart:240-247).
const _supplyCats = {
  'אביזרי נחושת', 'מחברי NTM', 'מחברי HDPE', 'ברזי מעבר', 'ברזי ניל',
  'ברזי קיר', 'ברזי כיור', 'ברזי מטבח', 'ברזי גן', 'ברזי אמבטיה', 'ברזי מקלחת',
  'ברזי דלי', 'ציוד גן', 'צינורות מקלחת',
  'זרועות דוש', 'מזלפי יד', 'ראשי מקלחת', 'מחלקים', 'נקודות מים',
  'מכשירי לחץ', 'אביזרי ברזים', 'אביזרי מקלחת', 'מנגנונים',
  'מערכות שטיפה',
};

/// Categories that pin the DRAINAGE system (verbatim: install_engine.dart:257-262).
const _drainCats = {
  'אביזרי שקע-תקע', 'צינורות אפורות', 'צינורות PP', 'ברכיים',
  'מסעפים וחיבורי אסלה', 'זקיף אסלה', 'מחסומים גלויים', 'מחסומי רצפה',
  'מאספי רצפה', 'מאספים וקולטים', 'תעלות ניקוז', 'סיפונים', 'מכסים ורשתות',
  'כיסויים', 'ניקוז גג', 'אביזרי ביוב',
};

/// Fixture categories — span both systems (verbatim: install_engine.dart:263-267).
const _fixtureCats = {
  'אסלות וכיורים', 'מושבי אסלה', 'אביזרי אסלה', 'מערכות אמבטיה', 'ערכות רחצה',
  'חלקים סניטריים', 'אביזרי חדר רחצה', 'התקנה נמוכה', 'התקנה גבוהה',
  'התקנה צמודה', 'דיורים ופיות',
};

/// Structural categories — span both systems (verbatim: install_engine.dart:268-271).
const _structuralCats = {
  'חבקי תליה', 'חבקי צינור', 'עוגנים ובנדים', 'כלי עבודה', 'מצופים',
  'ידיות אחיזה', 'ארונות מחלק',
};

const _allSystems = {WaterSystem.supply, WaterSystem.drainage};

/// The plumbing systems a product belongs to, by engineering logic.
Set<WaterSystem> productSystems(
  String categoryHe, {
  required Set<WaterSystem>? Function() endSystemsOf,
}) {
  final c = categoryHe;
  if (_supplyCats.contains(c)) return {WaterSystem.supply};
  if (_drainCats.contains(c)) return {WaterSystem.drainage};
  if (_fixtureCats.contains(c) || _structuralCats.contains(c)) return _allSystems;
  // Ambiguous category → split by context using the product's own ends.
  final ends = endSystemsOf();
  return (ends == null || ends.isEmpty) ? _allSystems : ends;
}

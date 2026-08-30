// ⚛️ אטום-Dart (דרגת-חוזה) · flowRole
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:310-317
//        (‏flowRole; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
//        אימות-עוגן: ‏install_engine.dart:310 = `FlowRole flowRole(p, fixtureCats: fixtureCats, structuralCats: structuralCats) {` וגוף :311-316.
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט).
//       ‏enum FlowRole (מחזיק-פלט טהור) מוגדר מקומית (מקור:295).
//       ‏_accessorySkus (מקור:301-308) · fixtureCats (263-267) · structuralCats
//       (268-271) = דאטה-קבוע פנימי (רשימות-SKU/קטגוריות, לא הקשר/זהות/סוד).
//
// שקע שהוזרק (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • `kHotWaterAccessorySkus`  (install_engine.dart:312, מיובא מ-lipskey_hotwater.dart)
//     — קבוצת-ה-SKU של אביזרי-מים-חמים מוזרקת כשקע `hotWaterAccessorySkus`
//       (ברירת-מחדל {} — ריק ⇒ ללא-אביזרי-מים-חמים).
//
// התנהגות (מקור:311-316):
//   • accessory — SKU ברשימת-אביזרים או ברשימת-אביזרי-מים-חמים, או קטגוריה מבנית:
//                 מתלים/חבקים/עוגנים/כלים — לעולם לא מחבר-זרימה.
//   • fixture   — קטגוריית-קבוע (אסלות/כיורים/מערכות-אמבטיה): התקן-קצה בלבד.
//   • connector — כל השאר: צינורות/אביזרים/פטמות/מתאמים/ברזים — הזרימה עוברת בהם.
//
// קלט:  sku                     — SKU המוצר (‏p.sku).
//       categoryHe              — קטגוריית-המוצר בעברית (‏p.categoryHe).
//       hotWaterAccessorySkus   — שקע: קבוצת-SKU אביזרי-מים-חמים (ברירת-מחדל {}).
// פלט:  FlowRole — connector / fixture / accessory.

/// A product's role in a flow path (verbatim order: install_engine.dart:295).
enum FlowRole { connector, fixture, accessory }

/// Individual non-flow products inside otherwise-flow categories
/// (verbatim: install_engine.dart:301-308).
const _accessorySkus = {
  'HW-INSUL', 'HW-CLIP', 'HW-SEALANT', // בידוד / חבק / איטום PTFE
  '77000026', '77000027', '77980000', '77980001', // אקדחי מים/אצבע לגינה (קצה)
  '77701185', // מתלה מתכוונן
  '77772604', '77772605', // סטי הידוק לברז פרח
  '777M1802', '777M1807', // מנגנוני הדחה (פנים-קבועה)
  '777A5034', '77772410', '77772412', '77772415', // דיורי פיה (קצה)
};

/// Fixture categories — terminal devices (verbatim: install_engine.dart:263-267).

/// Structural categories — hangers/clamps/tools (verbatim: install_engine.dart:268-271).

FlowRole flowRole(
  String sku,
  String categoryHe, {
  Set<String> hotWaterAccessorySkus = const {}, required Set fixtureCats, required Set structuralCats}) {
  if (_accessorySkus.contains(sku) || hotWaterAccessorySkus.contains(sku)) {
    return FlowRole.accessory;
  }
  final c = categoryHe;
  if (structuralCats.contains(c)) return FlowRole.accessory;
  if (fixtureCats.contains(c)) return FlowRole.fixture;
  return FlowRole.connector;
}

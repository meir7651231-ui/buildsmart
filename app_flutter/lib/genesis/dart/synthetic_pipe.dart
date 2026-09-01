// ⚛️ אטום-Dart (דרגת-חוזה) · syntheticPipe
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:1016-1041
//        (‏_syntheticPipe; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט — Map.putIfAbsent).
//
// שקעים שהוזרקו (הגלובליים-השכנים ⇒ פרמטרים · חוק-1/3, דיבר-3):
//   • pipeCache     ← _syntheticPipeCache (install_engine.dart:1012) — מטמון המוצרים-הסינתטיים.
//   • verifiedSpecs ← kVerifiedSpecs — מרשם-המפרטים שעוזרי-התאימות קוראים.
//     הדאטה לא צרובה במנוע — הקופסה מזריקה את המפות החיות.
//
// טיפוסי-שכן מוטבעים (כלל-2 — רק השדות שהפונקציה נוגעת בהם):
//   • EndType / ConnectorEnd — verbatim מ-lipskey_verified_connections.dart:24,32.
//   • VerifiedSpec — sku · ends · material · maxTempC (double, ברירת-מחדל 40).
//   • LipskeyCatalogProduct — 8 השדות המוצבים (lipskey_catalog.dart:4).
//
// קלט:  material, dn · pipeCache · verifiedSpecs (שתי המפות מוטציה-בכוונה — זה המקור).
// פלט:  LipskeyCatalogProduct — צינור "לפי מטר"; פגיעת-מטמון ⇒ אותו מופע, builder מדולג.

/// enum verbatim (lipskey_verified_connections.dart:24).
enum EndType { hdpeCompression, pexPress, copperPress, bspMale, bspFemale, drainOpening }

/// טיפוס-שכן מוטבע (lipskey_verified_connections.dart:32) — רק type + size.
class ConnectorEnd {
  const ConnectorEnd(this.type, this.size);
  final EndType type;
  final String size;
}

/// טיפוס-שכן מוטבע (lipskey_verified_connections.dart:66) — רק השדות שהפונקציה כותבת.
class VerifiedSpec {
  const VerifiedSpec({
    required this.sku,
    required this.ends,
    required this.material,
    this.maxTempC = 40,
  });
  final String sku;
  final List<ConnectorEnd> ends;
  final String material;
  final double maxTempC;
}

/// טיפוס-שכן מוטבע (lipskey_catalog.dart:4) — רק 8 השדות שהפונקציה מציבה.
class LipskeyCatalogProduct {
  const LipskeyCatalogProduct({
    required this.sku,
    required this.nameHe,
    required this.nameEn,
    required this.categoryHe,
    required this.categoryEn,
    required this.categoryEmoji,
    required this.page,
    this.brand = 'ליפסקי',
  });
  final String sku;
  final String nameHe;
  final String nameEn;
  final String categoryHe;
  final String categoryEn;
  final String categoryEmoji;
  final int page;
  final String brand;
}

/// צינור-סינתטי "לפי מטר" (לחומרי-אספקה בלי SKU בקטלוג). המפרט נרשם ב-[verifiedSpecs]
/// כדי שעוזרי-התאימות/תוויות יראו אותו — verbatim install_engine.dart:1016-1041.
LipskeyCatalogProduct syntheticPipe(
  String material,
  String dn, {required String Function(String) term, 
  required Map<String, LipskeyCatalogProduct> pipeCache,
  required Map<String, VerifiedSpec> verifiedSpecs,
}) {
  final sku = 'PIPE-$material-$dn';
  return pipeCache.putIfAbsent(sku, () {
    verifiedSpecs.putIfAbsent(
        sku,
        () => VerifiedSpec(
              sku: sku,
              material: material,
              ends: [
                ConnectorEnd(EndType.hdpeCompression, dn),
                ConnectorEnd(EndType.hdpeCompression, dn),
              ],
              maxTempC: material == 'HDPE' ? 40 : 95,
            ));
    return LipskeyCatalogProduct(
      sku: sku,
      nameHe: '${term('xi_tsynvr')}$material DN$dn${term('xi_lpy-mtr')}',
      nameEn: '$material pipe DN$dn (cut to length)',
      categoryHe: term('tsynvrvt'),
      categoryEn: 'Pipes',
      categoryEmoji: '📏',
      page: 0,
      brand: 'AQUATEC',
    );
  });
}

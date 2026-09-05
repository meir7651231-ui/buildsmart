// ⚛️ אטום-Dart (דרגת-חוזה) · usableConnector
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:322-323
//        (‏_usableConnector; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
//        אימות-עוגן (28.8): ‏:322 `bool _usableConnector(LipskeyCatalogProduct p) =>`
//        ‏:323 `flowRole(p) == FlowRole.connector && kVerifiedSpecs[p.sku] != null;`
//        (כותרת-הטיוטה ציינה 495-497 — צילום ישן של הקובץ; העוגן החי: 322-323.)
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה). הפרטיות-במקור (_) הוסרה —
//        במחסן האטום ציבורי; המשמעות (מתי מסננים) חיה בחיווט-הקופסה (חוק-5).
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-1/3, דיבר-3; דפוס can_connect):
//   • flowRole(p) == FlowRole.connector  (install_engine.dart:323, השכן flowRole :310-317)
//     — קורס לשקע-פרדיקט `isFlowConnector(sku)`, כדי לא להכפיל את enum FlowRole
//       שחי באטום flow_role.dart (אטום לא מייבא אטום). הקופסה מחווטת:
//       `(sku) => flowRole(sku, categoryOf(sku)) == FlowRole.connector`.
//   • kVerifiedSpecs[p.sku] != null  (install_engine.dart:323, המפה הגלובלית)
//     — קורס לשקע-פרדיקט `hasVerifiedSpec(sku)`. הדאטה חיה מחוץ למנוע; הקופסה
//       מחווטת: `(sku) => verifiedSpecs[sku] != null`.
//
// התנהגות (מקור:319-323): מוצר רשאי להיות מוכנס-אוטומטית כמחבר-אמצע-קו רק אם
// הוא מחבר-זרימה אמיתי (לא קבוע/אביזר) וגם בעל גיאומטריה מאומתת. ‏AND קצר-חישוב
// כמו `&&` במקור: isFlowConnector false ⇒ hasVerifiedSpec לא נקרא.
//
// קלט:  sku              — SKU המוצר (‏p.sku).
//       isFlowConnector  — שקע: תפקיד-הזרימה הוא connector.
//       hasVerifiedSpec  — שקע: ל-SKU ספק-גיאומטריה מאומת.
// פלט:  bool — האם המוצר שמיש כמחבר-אמצע-קו אוטומטי.

/// True when a product may be AUTO-INSERTED as a mid-line connector — verbatim
/// behavior of install_engine.dart:322-323 with both neighbours as sockets.
bool usableConnector(
  String sku, {
  required bool Function(String sku) isFlowConnector,
  required bool Function(String sku) hasVerifiedSpec,
}) =>
    isFlowConnector(sku) && hasVerifiedSpec(sku);

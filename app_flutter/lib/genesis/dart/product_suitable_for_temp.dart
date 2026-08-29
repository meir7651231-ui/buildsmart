// ⚛️ אטום-Dart (דרגת-חוזה) · productSuitableForTemp
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:58-61
//        (‏productSuitableForTemp; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט).
//
// שקע שהוזרק (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • `productMaxTempC(p)` (‏= kVerifiedSpecs[p.sku]?.maxTempC, מקור:59)
//     — האטום-השכן productMaxTempC אינו נייבא (חוט-לא-מייבא-חוט); ערכו מוזרק
//       כשקע `maxTempCOf(p) → double?` (‏null כשאין spec מאומת). ‏double נשמר
//       verbatim — במקור maxTempC הוא double (lipskey_verified_connections.dart:78).
//   • טיפוס-הקלט מופשט לגנריקה <P> לשמירת טוהר-מוחלט; במקור P≡LipskeyCatalogProduct.
//
// התנהגות (מקור:59-60): לא-ידוע (‏t==null) ⇒ true — לא מסמנים 400+ פריטי-קטלוג
//   לגאסי שאין להם spec מאומת. ידוע ⇒ true אך ורק כש-tempC ≤ t.
//
// קלט:  p          — המוצר (מועבר ל-maxTempCOf).
//       tempC      — טמפרטורת-הקו הנבנה (int, °C).
//       maxTempCOf — שקע: p → טמפרטורת-שירות-מרבית (double) או null (אין spec).
// פלט:  bool — האם חומר-המוצר יכול לשרת קו בטמפרטורה [tempC].

/// True when the product's material can serve a line at [tempC]. Unknown → true
/// (don't flag the 400+ legacy catalogue items that carry no verified spec).
bool productSuitableForTemp<P>(
  P p,
  int tempC, {
  required double? Function(P) maxTempCOf,
}) {
  final t = maxTempCOf(p);
  return t == null || tempC <= t;
}

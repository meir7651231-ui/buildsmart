// ⚛️ אטום-Dart (דרגת-חוזה) · canConnect
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:498-521
//        (‏canConnect; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט — Set.toSet/intersection).
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-1/3, דיבר-3):
//   • kVerifiedSpecs[sku] + VerifiedSpec.compatibleWith  (install_engine.dart:502-503)
//     — המפה-הגלובלית והמתודה קורסות לשקע-יחיד `verifiedCompat(skuA, skuB) → bool?`:
//       מחזיר null כש**לא** לשני הצדדים ספק-מאומת (⇔ vA==null || vB==null),
//       אחרת את תוצאת `vA.compatibleWith(vB)`. ברירת-המחדל = null (אין נתון-מאומת לזוג).
//   • שדות-המחלקה LipskeyCatalogProduct (sku/connectionSizes/connectionGender/
//     connectionMethod) ⇒ מוחזקים ב-`ConnPart` — מחזיק-קלט טהור, אפס תלות.
//
// קלט:  a, b            — ConnPart (sku · connectionSizes · connectionGender? · connectionMethod?).
//       verifiedCompat  — שקע: bool? Function(String skuA, String skuB). חסר ⇒ null.
// פלט:  bool — האם שני המוצרים יכולים להתחבר.

/// מחזיק-קלט טהור: רק ארבעת השדות ש-canConnect קורא (install_engine.dart:499-518).
/// connectionSizes = רשימת גדלי-DN; gender/method = 'male'/'female'/'thread'/… או null.
class ConnPart {
  final String sku;
  final List<String> connectionSizes;
  final String? connectionGender;
  final String? connectionMethod;
  const ConnPart({
    required this.sku,
    this.connectionSizes = const [],
    this.connectionGender,
    this.connectionMethod,
  });
}

/// ברירת-מחדל לשקע-האימות: אין נתון-מאומת לזוג ⇒ נופלים ל-name-inference.
bool? _noVerified(String skuA, String skuB) => null;

/// האם שני המוצרים יכולים להתחבר — התנהגות verbatim של install_engine.dart:498-521.
bool canConnect(
  ConnPart a,
  ConnPart b, {
  bool? Function(String skuA, String skuB) verifiedCompat = _noVerified,
}) {
  if (a.sku == b.sku) return false;

  // Prefer verified specs — 100% accurate physical data. (‏install_engine.dart:501-503)
  final v = verifiedCompat(a.sku, b.sku);
  if (v != null) return v;

  // Fallback: name-inference (less reliable, no verified data for this pair).
  final sA = a.connectionSizes.toSet();
  final sB = b.connectionSizes.toSet();
  if (sA.isEmpty || sB.isEmpty || sA.intersection(sB).isEmpty) return false;

  // Block only when BOTH ends have explicit, conflicting genders (both male or
  // both female). If either side is unspecified we allow the match — the size
  // overlap is the primary guard. (‏install_engine.dart:510-515)
  final gA = a.connectionGender, gB = b.connectionGender;
  if (gA != null && gB != null && gA == gB) return false;

  final mA = a.connectionMethod, mB = b.connectionMethod;
  if (mA != null && mB != null && mA != mB) return false;

  return true;
}

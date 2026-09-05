// ⚛️ אטום-Dart (דרגת-חוזה) · pipeConnectionDn
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:423-432
//        (‏pipeConnectionDn; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט).
//       ‏enum EndType + מחזיק-הקצה ConnEnd (מחזיקי-קלט טהורים) מוגדרים מקומית
//       verbatim מ-lipskey_verified_connections.dart:24,32-36.
//       ‏pipeSharedWith (מתודה על ConnectorEnd, lvc.dart:50-53) שוכפלה כעוזר-פרטי
//       `_pipeShared` — אטום אינו מייבא טיפוס-דומיין (חוק-1/דיבר-3).
//
// שקע שהוזרק (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • `kVerifiedSpecs[a.sku]?.ends` / `[b.sku]?.ends`  (install_engine.dart:424,426-427)
//     — המפה-הגלובלית קורסת לשקע `endsOf(p) → List<ConnEnd>?` (‏null כשאין spec).
//   • טיפוס-המוצר מופשט לגנריקה <P>; במקור P≡LipskeyCatalogProduct.
//
// התנהגות (מקור:424-431): אחד הצדדים בלי spec ⇒ null. אחרת: הזוג-הראשון
//   (בסדר-הסריקה) של קצוות hdpeCompression בעלי אותו גודל ⇒ גודל-ה-DN המשותף;
//   אין זוג כזה ⇒ null (חיבור-ישיר תבריג/press או אי-התאמה).
//
// קלט:  a, b   — שני המוצרים (מועברים ל-endsOf).
//       endsOf — שקע: p → רשימת-קצוות (List<ConnEnd>) או null כשאין spec.
// פלט:  String? — גודל-ה-DN של קטע-הצינור המשותף, או null.

/// End connection type (verbatim: lipskey_verified_connections.dart:24).
enum EndType { hdpeCompression, pexPress, copperPress, bspMale, bspFemale, drainOpening }

/// Pure input holder for a connector end (verbatim fields: lvc.dart:32-36).
class ConnEnd {
  final EndType type;
  final String size;
  const ConnEnd(this.type, this.size);
}

/// `ConnectorEnd.pipeSharedWith` (verbatim: lvc.dart:50-53): both ends are HDPE
/// compression of the same nominal DN — a pipe segment spans them.
bool _pipeShared(ConnEnd a, ConnEnd b) =>
    a.type == EndType.hdpeCompression &&
    b.type == EndType.hdpeCompression &&
    a.size == b.size;

/// The shared DN string if the two products connect via a pipe segment, null if
/// they connect directly (thread-to-thread) or are incompatible.
String? pipeConnectionDn<P>(
  P a,
  P b, {
  required List<ConnEnd>? Function(P) endsOf,
}) {
  final ea = endsOf(a), eb = endsOf(b);
  if (ea == null || eb == null) return null;
  for (final eA in ea) {
    for (final eB in eb) {
      if (_pipeShared(eA, eB)) return eA.size;
    }
  }
  return null;
}

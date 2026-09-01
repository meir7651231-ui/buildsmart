// ⚛️ אטום-Dart (דרגת-חוזה) · boreMeters
// מוצא: buildsmart/app_flutter/lib/logic/pressure_drop.dart:73-90 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). ה-const-המקומית `inchToMm`
//        (pressure_drop.dart:85-88) הופכה לשקע-פרמטר `bspInchToMm` (חוק-3).
// טיפוסי-הקלט EndType/ConnectorEnd מוגדרים מקומית כערכי-קלט טהורים (מקור:
//        lib/data/lipskey_verified_connections.dart:24 — enum, :32 — class), אפס תלות בשכן.
//
// קלט:  e            — קצה-מחבר: e.type (EndType) + e.size (String, "32" או '1/2"').
//       bspInchToMm  — שקע: מפת אינץ׳-BSP → קוטר-פנימי במ״מ (מקור-אמת יחיד).
// פלט:  קוטר-פנים במטרים (double), או null כשהמידה אינה ניתנת-לפענוח / החוט הוא הברגה לא-מוכרת.

/// מערכת-הקצה — הועתק verbatim מ-lipskey_verified_connections.dart:24 (חוק-4).
enum EndType { hdpeCompression, pexPress, copperPress, bspMale, bspFemale, drainOpening }

/// קצה-מחבר — צורת-קלט טהורה (type + size), verbatim מ-:32.
class ConnectorEnd {
  final EndType type;
  final String size;
  const ConnectorEnd(this.type, this.size);
}

/// Internal nominal-bore of a connector end in metres. Returns null when the
/// end is a thread (which has its own size convention) or unknown.
double? boreMeters(ConnectorEnd e, {required Map<String, int> bspInchToMm}) {
  // Drain/compression sizes are nominal DN in millimetres — "32" → 0.032 m.
  if (e.type == EndType.hdpeCompression ||
      e.type == EndType.pexPress ||
      e.type == EndType.copperPress ||
      e.type == EndType.drainOpening) {
    final dn = int.tryParse(e.size);
    if (dn != null) return dn / 1000.0;
  }
  // BSP thread: rough inside diameter ≈ nominal inches.
  if (e.type == EndType.bspMale || e.type == EndType.bspFemale) {
    final s = e.size.replaceAll('"', '').trim();
    // common conversions: 1/2 ≈ 15, 3/4 ≈ 20, 1 ≈ 25, 1-1/2 ≈ 40, 2 ≈ 50
    final mm = bspInchToMm[s];
    if (mm != null) return mm / 1000.0;
  }
  return null;
}

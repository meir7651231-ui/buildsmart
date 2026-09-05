// ⚛️ אטום-Dart (דרגת-חוזה) · minBoreMmOf
// תפקיד: הקוטר-הפנימי המינימלי (מ"מ) על-פני קצוות-מוצר, לפי סוג-הקצה.
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:852-874
//        (‏_minBoreMmOf, פרטי-במקור). מקודם ל-public (כלל-הגלגול). חוק-4.
// אחים-שסוקטו/הוטבעו:
//   • `kVerifiedSpecs[p.sku]` (const-קטלוג ענק) — במקור מאתר את מפרט-המוצר ואז את
//     קצותיו. **סוקט**: במקום חיפוש-ה-SKU, מזריקים ישירות `ends` (הקצוות).
//     ‏spec חסר במקור ⇒ null; כאן `ends == null` ⇒ null (שקילות-מקור).
//   • `kBspInchToMm` (const-מפה; ערכיה לא בגוף-הטיוטה, המקור לא-מלא בריפו) ⇒
//     **שקע** `bspInchToMm` (חוק-3/8: מפת-נתונים חיצונית ⇒ הזרקה).
//   • enum-האח `EndType` ⇒ **הוטבע verbatim** — כל ששת ה-case מופיעים בגוף-הטיוטה
//     (hdpeCompression/pexPress/copperPress/drainOpening/bspMale/bspFemale) —
//     הסקה-ודאית (דיבר 11).
//   • טיפוס-הקצה (‏.type/.size) ⇒ **record inline** `({EndType type, String size})`.
// טוהר: אפס import (dart:core בלבד).
//
// קלט:  ends        — קצוות-המוצר (רשומות type+size); null ⇒ אין מפרט ⇒ null.
//       bspInchToMm — שקע: מפת "אינץ' BSP" → מ"מ (double).
// פלט:  double? — הקוטר המינימלי מבין הקצוות הניתנים-לפירוק, או null.

// הוטבע verbatim (enum-אח): ששת סוגי-הקצה.
enum EndType {
  hdpeCompression,
  pexPress,
  copperPress,
  drainOpening,
  bspMale,
  bspFemale,
}

/// Minimum internal bore (mm) across a product's [ends].
/// Verbatim behaviour of install_engine.dart:852-874: the spec lookup is
/// replaced by injecting [ends] (null ⇒ no spec ⇒ null), and the BSP inch→mm
/// table is a socket. Metric ends parse the size directly; BSP ends map the
/// inch label (quotes/space stripped) through [bspInchToMm].
double? minBoreMmOf({
  required List<({EndType type, String size})>? ends,
  required Map<String, double> bspInchToMm,
}) {
  if (ends == null) return null;
  double? min;
  for (final e in ends) {
    double? mm;
    switch (e.type) {
      case EndType.hdpeCompression:
      case EndType.pexPress:
      case EndType.copperPress:
      case EndType.drainOpening:
        mm = double.tryParse(e.size);
      case EndType.bspMale:
      case EndType.bspFemale:
        mm = bspInchToMm[e.size.replaceAll('"', '').trim()];
    }
    if (mm == null) continue;
    if (min == null || mm < min) min = mm;
  }
  return min;
}

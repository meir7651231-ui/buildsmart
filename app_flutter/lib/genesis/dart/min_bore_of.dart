// ⚛️ אטום-Dart (דרגת-חוזה) · minBoreOf
// מוצא: buildsmart/app_flutter/lib/logic/pressure_drop.dart:104-114 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). במקור מתודה-פרטית `_minBoreOf`,
//        אך יחידה בעלת קלט/פלט מוגדרים (רדוקציית-מינימום עם דילוג-null) — אטום, לא גלגול-בלבד.
// שני הקריאות-לשכן במקור הופכו לשקעי-פרמטר (חוק-3):
//   • `kVerifiedSpecs[p.sku]?.ends`  → שקע `endsOf`  (מחזיר null כשאין spec — זהה למקור:106).
//   • `_boreMeters(e)`               → שקע `boreOf`   (חוט-שכן, אטום boreMeters הנפרד).
// טיפוסי-הקלט מופשטים לגנריקה <P, E> כדי לשמור טוהר-מוחלט (אפס תלות ב-LipskeyCatalogProduct/
//        VerifiedSpec/ConnectorEnd מהמקור); המקור: P≡LipskeyCatalogProduct, E≡ConnectorEnd.
//
// קלט:  p       — המוצר (במקור בעל שדה .sku המשמש לחיפוש-ה-spec; כאן אטום-שקוף שמועבר ל-endsOf).
//       endsOf  — שקע: p → רשימת-קצוות (List<E>) או null כשאין spec למוצר (מקור:105-106).
//       boreOf  — שקע: קצה E → קוטר-פנים במטרים (double) או null כשאינו ניתן-לפענוח (מקור:109).
// פלט:  הקוטר הקטן-ביותר (double, מטרים) מבין קצוות-המוצר; או null כשאין spec /
//       כשאף קצה אינו בעל קוטר ניתן-לפענוח (מקור:113 — min נשאר null).

/// The smallest bore (m) found across [p]'s ends — pressure drop scales with
/// the narrowest point.
double? minBoreOf<P, E>(
  P p, {
  required List<E>? Function(P) endsOf,
  required double? Function(E) boreOf,
}) {
  final ends = endsOf(p);
  if (ends == null) return null;
  double? min;
  for (final e in ends) {
    final b = boreOf(e);
    if (b == null) continue;
    if (min == null || b < min) min = b;
  }
  return min;
}

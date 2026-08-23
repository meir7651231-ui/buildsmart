// 🔌 מנוע-קטלוג-3D · פאזה B (שלב 31) — פרמטרי ריתוך-שקע (DVS 2207-11).
//
// 🛡️ **בטיחות = אחריות (M5).** הערכים כאן הם **ערכי-ייחוס בלבד**, verbatim מהמקור
// המאומת `knowledge/catalog-3d/prototypes/gen3d.html` (`WELD` + הערת-האזהרה). אין
// כאן שום ערך שהומצא. כל `WeldParams` **חייב-מבנית** לשאת את [caveat] (השדה
// required) — אי-אפשר לקבל פרמטר-ריתוך בלי אזהרת-היצרן. OD לא-בטבלה → `null`,
// לעולם לא ערך-ריתוך משוער. מגודר (`features/fittings/`) ⇒ tree-shaken בכבוי.

import 'package:flutter/foundation.dart' show immutable;

/// טבלת-הריתוך (DVS 2207-11) — verbatim מ-`gen3d.html:362` `WELD`.
/// `od → [חימום(שנ׳), חיבור-מרבי(שנ׳), קירור(דק׳)]`. ראש-ריתוך 260°C.
const Map<int, List<int>> _kWeldTable = {
  16: [5, 4, 2], 20: [5, 4, 2], 25: [7, 4, 2], 32: [8, 6, 4],
  40: [12, 6, 4], 50: [18, 6, 4], 63: [24, 8, 6], 75: [30, 8, 8],
  90: [40, 8, 8], 110: [50, 10, 8], 125: [60, 10, 8],
};

/// אזהרת-היצרן החובה (M5) — verbatim מ-`gen3d.html:417`.
const String kWeldCaveat =
    '⚠️ ערכי-ייחוס לפי DVS 2207-11 / נתוני-יצרן טיפוסיים. יש לאמת מול דף-הנתונים '
    'של הצינור הספציפי ותנאי-הסביבה (מתחת ל-5°C — להאריך חימום). '
    'ריתוך בידי מתקין מוסמך בלבד.';

/// טמפ׳ ראש-הריתוך (°C) — קבוע ל-PP-R לפי DVS 2207-11.
const double kWeldHeadTempC = 260;

/// פרמטרי ריתוך-שקע לקוטר יחיד — **ערכי-ייחוס בלבד**, נושאים תמיד [caveat] (M5).
@immutable
class WeldParams {
  const WeldParams({
    required this.od,
    required this.heatSec,
    required this.joinSec,
    required this.coolMin,
    required this.caveat, // חובה-מבנית: אין WeldParams בלי אזהרת-יצרן (M5)
    this.headTempC = kWeldHeadTempC,
  });

  final int od;
  final int heatSec; // חימום (שניות)
  final int joinSec; // זמן-חיבור מרבי (שניות)
  final int coolMin; // קירור (דקות)
  final double headTempC; // 260°C
  final String caveat; // אזהרת-יצרן חובה

  @override
  bool operator ==(Object other) =>
      other is WeldParams &&
      other.od == od &&
      other.heatSec == heatSec &&
      other.joinSec == joinSec &&
      other.coolMin == coolMin &&
      other.headTempC == headTempC &&
      other.caveat == caveat;

  @override
  int get hashCode => Object.hash(od, heatSec, joinSec, coolMin, headTempC, caveat);
}

/// פרמטרי-הריתוך של [od] מהטבלה המאומתת, או `null` כשאין ערך-ייחוס (M5: לעולם
/// לא ערך משוער). התוצאה **תמיד** נושאת את [kWeldCaveat].
WeldParams? weldParamsFor(int od) {
  final w = _kWeldTable[od];
  if (w == null) return null; // אין מקור מאומת → null, לא המצאה
  return WeldParams(
    od: od,
    heatSec: w[0],
    joinSec: w[1],
    coolMin: w[2],
    caveat: kWeldCaveat,
  );
}

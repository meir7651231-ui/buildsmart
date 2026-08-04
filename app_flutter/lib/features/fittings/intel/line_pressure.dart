// 🧠 מנוע-אביזרים · פאזה E-lite slice 1 — נפילת-לחץ (pressure-drop) לקו-מתוכנן.
// **גשר** בין תוכנית-הקו (`FittingLinePlan.products`) למעריך-הלחץ החי הקיים
// (`estimatePressureDrop`, `lib/logic/pressure_drop.dart`). מגודר · off-live.
//
// 🔒 טהור-שכבה · אף מסך-חי אינו מייבא `intel/` ⇒ tree-shaken ⇒ byte-identical.
// `pressure_drop.dart` כבר בבנייה-החיה ⇒ ייבוא לא מוסיף קוד-חי. אפס תלות חדשה.
// זהו אומדן-הנדסי (הצעות = ייעוץ · לא ערך-בטיחות-מחייב) — לא נדרשת ביקורת-M5.

import 'package:buildsmart/features/fittings/intel/line_planner.dart';
import 'package:buildsmart/logic/pressure_drop.dart';

/// אומדן נפילת-הלחץ של קו-מתוכנן: מריץ את המעריך החי על מוצרי-התוכנית.
/// תוכנית-ריקה (בלי מוצרים) → אומדן על שרשרת-ריקה (לא קורס · M1).
PressureDropResult pressureDropForPlan(
  FittingLinePlan plan, {
  double pipeLengthMeters = 5.0,
  double flowRateLPS = 0.3,
  double verticalRiseMeters = 0.0,
}) =>
    estimatePressureDrop(
      plan.products,
      pipeLengthMeters: pipeLengthMeters,
      flowRateLPS: flowRateLPS,
      verticalRiseMeters: verticalRiseMeters,
    );

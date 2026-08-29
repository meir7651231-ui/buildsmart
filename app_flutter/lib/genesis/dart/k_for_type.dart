// ⚛️ אטום-Dart (דרגת-חוזה) · kForType
// מוצא: buildsmart/app_flutter/lib/logic/pressure_drop.dart:29-69 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). אפס קריאה-לשכן, אפס שדה-מחלקה
//        ⇒ אין שקעים. השם הפרטי במקור (_kForType) הוסר; זהו מיפוי-ערך טהור (לא עוזר-גלגול).
//
// קלט:  productType — סוג-המוצר בעברית (String?, ‏nullable). null/לא-מוכר ⇒ ברירת-מחדל.
// פלט:  מקדם-אובדן K (double) למחבר יחיד. 0.0 כשהחלק אינו תורם אובדן מדיד (אטמים, פקקים).

/// Loss coefficient K for a single fitting, by Hebrew product type.
/// Returns 0 when the part contributes no measurable loss (gaskets, caps).
double kForType(String? productType) {
  switch (productType) {
    case 'ברך':
    case 'זווית':
      return 0.9; // 90° elbow
    case 'מסעף':
    case 'הסתעפות':
    case 'טי':
      return 1.5; // tee (through-run) — branch-run is higher
    case 'מצמד':
    case 'מחבר':
    case 'מופה':
    case 'מקשר':
    case 'רקורד':
      return 0.1; // straight coupling — minimal disturbance
    case 'ניפל':
    case 'מאריך':
      return 0.05; // straight extension
    case 'בושינג':
      return 0.2; // reducer
    case 'ברז':
    case 'ברז גן':
      return 0.05; // ball valve fully open
    case 'אל חזור':
      return 2.0; // swing check valve
    case 'מסנן':
      return 5.0; // Y-strainer with cartridge
    case 'מצוף':
      return 4.0; // float valve, throttled
    case 'מקטין':
      return 10.0; // pressure-reducing valve
    case 'משחרר':
      return 0.0; // air vent
    case 'כפה':
    case 'פקק':
    case 'אטם':
      return 0.0; // terminal — flow stops here, no through-loss
    default:
      return 0.3; // unknown fitting: small conservative estimate
  }
}

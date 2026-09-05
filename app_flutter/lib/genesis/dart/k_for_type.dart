// ⚛️ אטום-Dart (דרגת-חוזה) · kForType
// מוצא: buildsmart/app_flutter/lib/logic/pressure_drop.dart:29-69 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). אפס קריאה-לשכן, אפס שדה-מחלקה
//        ⇒ אין שקעים. השם הפרטי במקור (_kForType) הוסר; זהו מיפוי-ערך טהור (לא עוזר-גלגול).
//
// קלט:  productType — סוג-המוצר בעברית (String?, ‏nullable). null/לא-מוכר ⇒ ברירת-מחדל.
// פלט:  מקדם-אובדן K (double) למחבר יחיד. 0.0 כשהחלק אינו תורם אובדן מדיד (אטמים, פקקים).

/// Loss coefficient K for a single fitting, by Hebrew product type.
/// Returns 0 when the part contributes no measurable loss (gaskets, caps).
double kForType(String? productType, {required Map<String, double> table}) =>
    table[productType] ?? 0.3; // unknown fitting: small conservative estimate

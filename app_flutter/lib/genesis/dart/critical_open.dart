// ⚛️ אטום-Dart (דרגת-חוזה) · criticalOpen
// תפקיד: ספירת פריטי-תאימות קריטיים-שאינם-מסופקים בקו — "כמה בדיקות-בטיחות חמורות
//        עדיין פתוחות". משמש מנוע-ההתקנה כשער "אפס-קריטי-חסר".
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:976-978 (‏criticalOpen — מתודה במקור; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד).
// אחים-שסוקטו: `compliance(tempC, accessories)` (מחשב את צ'ק-ליסט-התאימות) הומר לשקע
//        `compliance` (חוק-3: קריאה-לשכן ⇒ פרמטר-שקע). ה-enum `CheckSeverity.critical`
//        צומצם לשדה-bool `critical` ברשומת-הפריט (טיפוס-שכן ⇒ inline; רק הבחנת "קריטי" נצרכת).
//        אחים-שהוטבעו: — (‏_autoAddCompliance ושאר-המחלקה אינם חלק מהאטום).
//
// קלט:  tempC       — טמפרטורת-הקו (int), מועברת אל השקע.
//       accessories — קבוצת-אביזרים (Set<String>, ברירת-מחדל ריקה), מועברת אל השקע.
//       compliance  — שקע: צ'ק-ליסט-התאימות כרשומות `({bool satisfied, bool critical})`.
// פלט:  int — מספר הפריטים שגם לא-מסופקים וגם קריטיים.

/// Count safety-critical compliance items still unsatisfied. `compliance(...)` is
/// injected (slot); `CheckSeverity.critical` is reduced to the record field
/// `critical`. Verbatim behaviour of install_engine.dart:976-978.
int criticalOpen(
  int tempC, {
  Set<String> accessories = const {},
  required List<({bool satisfied, bool critical})> Function(
          int tempC, Set<String> accessories)
      compliance,
}) =>
    compliance(tempC, accessories)
        .where((c) => !c.satisfied && c.critical)
        .length;

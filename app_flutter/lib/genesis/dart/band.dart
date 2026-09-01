// ⚛️ אטום-Dart (דרגת-חוזה) · band
// תפקיד: מדרג ערך-מספרי ל-3 רמות (0/1/2) לפי שני ספים.
// מוצא: buildsmart/app_flutter/lib/logic/customer_score.dart:61-64 (‏_band; חוק-4 — התנהגות זהה, לא-משופרת).
// אחים: אין — פונקציה עצמאית לחלוטין, אפס שקע, אפס טיפוס-שכן.
// טוהר: dart:core בלבד.

/// value>=high ⇒ 2 · else value>=mid ⇒ 1 · else 0.
/// התנהגות verbatim של customer_score.dart:61-64.
int band(int value, int high, int mid) =>
    value >= high ? 2 : (value >= mid ? 1 : 0);

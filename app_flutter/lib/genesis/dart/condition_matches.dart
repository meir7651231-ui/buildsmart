// ⚛️ אטום-Dart (דרגת-חוזה) · conditionMatches
// תפקיד: הערכת תנאי-כלל בודד מול הזמנה — משווה ערך-שדה-מספרי (מוזרק) אל סף-התנאי
//        לפי אופרטור (>, >=, <, <=, =); אופרטור לא-מוכר ⇒ false. משמש מנוע-כללי-הסטודיו.
// מוצא: buildsmart/app_flutter/lib/logic/studio/rules_model.dart:401-419 (‏_conditionMatches; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). פרטי-במקור ⇒ public.
// אחים-שסוקטו: `_fieldValue(field, order, now)` (מיצוי הערך-המספרי של השדה) הומר לשקע
//        `fieldValue` (חוק-3: קריאה-לשכן ⇒ פרמטר-שקע). אחים-שהוטבעו: שדות-`RuleCondition`
//        (‏field/op/value) כ-record inline (טיפוס-שכן ⇒ inline). האטום גנרי על `T` (סוג-ההזמנה).
//
// קלט:  c          — התנאי: `({String field, String op, num value})`.
//       order      — ההזמנה (T), מועברת אל השקע.
//       now        — הזמן (DateTime), מועבר אל השקע (למשל לחישוב ageDays).
//       fieldValue — שקע: `num Function(String field, T order, DateTime now)` — במקור `_fieldValue`.
// פלט:  bool — האם התנאי מתקיים.

/// Evaluate one rule condition against an order: compare the (injected) numeric
/// field value to `c.value` by `c.op`; unknown op ⇒ false. Verbatim behaviour of
/// rules_model.dart:401-419 with `_fieldValue` injected as [fieldValue].
bool conditionMatches<T>(
  ({String field, String op, num value}) c,
  T order,
  DateTime now, {
  required num Function(String field, T order, DateTime now) fieldValue,
}) {
  final v = fieldValue(c.field, order, now);
  switch (c.op) {
    case '>':
      return v > c.value;
    case '>=':
      return v >= c.value;
    case '<':
      return v < c.value;
    case '<=':
      return v <= c.value;
    case '=':
      return v == c.value;
  }
  return false;
}

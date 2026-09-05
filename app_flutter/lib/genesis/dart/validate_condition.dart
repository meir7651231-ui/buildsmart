// ⚛️ אטום-Dart (דרגת-חוזה) · validateCondition
// מוצא: buildsmart/app_flutter/lib/logic/studio/rules_model.dart:344-384 (‏_validateCondition; חוק-4).
//        פרטי-במקור (`_`) — גולגל לאטום top-level. אחים-שסוקטו: `evalRuleAdvisory`/`_triggerMatches`
//        בטיוטה — אטומים נפרדים, לא הועתקו.
// אחים-שהוזרקו (חוק-3): הפונקציות-השכנות `matchConditionField`/`matchRuleOp` ⇒ שקעים; ה-constructor
//        `RuleCondition(field, op, value)` ⇒ שקע-מפעל `makeCondition`. הטיפוסים
//        `ConditionField`/`RuleOp`/`RuleCondition` (מקור נעדר) הופשטו לגנריים `F`/`O`/`C`.
//
// קלט:  raw                 — ערך-JSON גולמי (Object?).
//       matchConditionField — שקע: מיפוי מחרוזת ⇒ F? (null = שדה לא-חוקי).
//       matchRuleOp         — שקע: מיפוי מחרוזת ⇒ O? (null = אופרטור לא-חוקי).
//       makeCondition       — שקע-מפעל: (F, O, num) ⇒ C.
// פלט:  C תקין, או null בכל אחד מ-4 שערי-הכשל (לא-Map / שדה-פסול / אופרטור-פסול / ערך-לא-מספרי).

/// Validate a raw condition map into a typed condition, or `null` (fail-closed).
/// Verbatim behaviour of rules_model.dart:344-384 with the two field matchers and
/// the `RuleCondition` constructor injected (concrete neighbour types ⇒ `F`/`O`/`C`).
C? validateCondition<F, O, C>(
  Object? raw, {
  required F? Function(String) matchConditionField,
  required O? Function(String) matchRuleOp,
  required C Function(F field, O op, num value) makeCondition,
}) {
  if (raw is! Map) return null;
  final c = raw.map((k, v) => MapEntry(k.toString(), v));
  final field = matchConditionField((c['field'] ?? '').toString());
  if (field == null) return null;
  final op = matchRuleOp((c['op'] ?? '').toString());
  if (op == null) return null;
  final rawValue = c['value'];
  final value =
      rawValue is num ? rawValue : num.tryParse((rawValue ?? '').toString());
  if (value == null) return null; // a non-numeric threshold → drop.
  return makeCondition(field, op, value);
}

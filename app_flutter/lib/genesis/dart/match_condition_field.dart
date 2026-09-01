// ⚛️ אטום-Dart (דרגת-חוזה) · matchConditionField
// תפקיד: מקרקע [reply] לשדה-תנאי אמת מהקבוצה-הסגורה של שדות-הכללים — או null (drop).
// מוצא: buildsmart/app_flutter/lib/logic/studio/rules_model.dart:201-202 (‏matchConditionField; חוק-4).
// אחים: הקבוע-האח `kRuleConditionFields` (rules_model.dart) — ⚠️ ערכיו אינם בגוף-הטיוטה
//       ולא נמצאו ב-grep-יחיד במקור-הנוכחי; לכן הופך לשקע-נתון `conditionFields`
//       (חוק-3, הזרקת-קבוצה — התנהגות-האטום זהה בהינתן הקבוצה). ה-private-האח `_matchClosed`
//       (‏registry_view.dart:237-260) הוטבע verbatim inline (חוק-1).
// טוהר: dart:core בלבד; אפס import, אפס state.

/// מקרקע [reply] לשדה-תנאי מתוך [conditionFields] (= `kRuleConditionFields` verbatim) —
/// מדויק גובר, אחרת מוכל-ארוך; null אם אין. verbatim rules_model.dart:201-202 (הקבוע ⇒ שקע).
String? matchConditionField(
  String reply, {
  required Set<String> conditionFields,
}) =>
    _matchClosed(conditionFields, reply);

// —— _matchClosed הוטבע verbatim (registry_view.dart:237-260) ——
String? _matchClosed(Set<String> closed, String reply) {
  final r = reply.trim();
  if (r.isEmpty) return null;
  for (final k in closed) {
    if (r == k) return k;
  }
  String? best;
  for (final k in closed) {
    if (k.isNotEmpty &&
        r.contains(k) &&
        (best == null || k.length > best.length)) {
      best = k;
    }
  }
  return best;
}

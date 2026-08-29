// ⚛️ אטום-Dart (דרגת-חוזה) · matchActionId
// תפקיד: מקרקע [reply] ל-action-id אמת המותר לרכיב [id] — או null (fail-closed).
// מוצא: buildsmart/app_flutter/lib/logic/studio/registry_view.dart:288-292 (‏matchActionId; חוק-4).
// אחים: `reg.actionIdsFor(id)` (קריאת-מתודה על RegistryView — היררכיה) קופלה לשקע-פונקציה
//       `actionIdsFor` (חוק-3: קריאה-לשכן ⇒ פרמטר-שקע). ה-private-האח `_matchClosed`
//       (‏registry_view.dart:237-260) הוטבע verbatim inline (חוק-1: אטום לא מייבא אטום).
// טוהר: dart:core בלבד; אפס import, אפס state, אפס טיפוס RegistryView.

/// מקרקע [reply] ל-action-id מתוך `actionIdsFor(id)` — מדויק גובר, אחרת מוכל-ארוך; null אם אין.
/// verbatim registry_view.dart:288-292 (עם reg.actionIdsFor ⇒ שקע, _matchClosed inline).
String? matchActionId(
  String id,
  String reply, {
  required Set<String> Function(String id) actionIdsFor,
}) =>
    _matchClosed(actionIdsFor(id), reply);

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

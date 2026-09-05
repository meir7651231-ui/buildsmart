// ⚛️ אטום-Dart (דרגת-חוזה) · matchPropKey
// תפקיד: מקרקע [reply] למפתח-מאפיין (prop) אמת בר-עריכה על רכיב [id] — או null (fail-closed).
// מוצא: buildsmart/app_flutter/lib/logic/studio/registry_view.dart:277-282 (‏matchPropKey; חוק-4).
// אחים: `reg.propKeysFor(id)` (מתודת RegistryView — היררכיה) קופלה לשקע-פונקציה `propKeysFor`
//       (חוק-3). ה-private-האח `_matchClosed` (‏:237-260) הוטבע verbatim inline (חוק-1).
// טוהר: dart:core בלבד; אפס import, אפס state, אפס טיפוס RegistryView.

/// מקרקע [reply] ל-prop-key מתוך `propKeysFor(id)` — מדויק גובר, אחרת מוכל-ארוך; null אם אין.
/// verbatim registry_view.dart:277-282. id לא-מוכר ⇒ קבוצת-props ריקה ⇒ כל reply מתדרדר (fail-closed).
String? matchPropKey(
  String id,
  String reply, {
  required Set<String> Function(String id) propKeysFor,
}) =>
    _matchClosed(propKeysFor(id), reply);

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

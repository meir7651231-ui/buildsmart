// ⚛️ אטום-Dart (דרגת-חוזה) · matchElementId
// תפקיד: מקרקע [reply] ל-element-id אמת מתוך רישום-הרכיבים — או null (fail-closed).
// מוצא: buildsmart/app_flutter/lib/logic/studio/registry_view.dart:272-276 (‏matchElementId; חוק-4).
// אחים: `reg.elementIds()` (מתודת RegistryView — היררכיה) קופלה לשקע-פונקציה `elementIds`
//       (חוק-3). ה-private-האח `_matchClosed` (‏:237-260) הוטבע verbatim inline (חוק-1).
// טוהר: dart:core בלבד; אפס import, אפס state, אפס טיפוס RegistryView.

/// מקרקע [reply] ל-element-id מתוך `elementIds()` — מדויק גובר, אחרת מוכל-ארוך; null אם אין.
/// verbatim registry_view.dart:272-276 (reg.elementIds ⇒ שקע, _matchClosed inline).
String? matchElementId(
  String reply, {
  required Set<String> Function() elementIds,
}) =>
    _matchClosed(elementIds(), reply);

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

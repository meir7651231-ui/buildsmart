// ⚛️ אטום-Dart (דרגת-חוזה) · matchCatalogActionId
// תפקיד: מקרקע [reply] ל-action-id אמת מתת-קבוצת-הקטלוג (‏_catalogActionView) — או null.
// מוצא: buildsmart/app_flutter/lib/logic/studio/action_catalog.dart:266-267 (‏matchCatalogActionId; חוק-4).
// אחים: המקור `matchElementId(_catalogActionView, reply)` = `_matchClosed(_catalogActionView.elementIds(), reply)`.
//       ‏`_catalogActionView` (מופע-RegistryView פרטי — היררכיה+state) קופל לשקע-נתון
//       `catalogActionIds` (= `_catalogActionView.elementIds()` verbatim; חוק-3). ה-private-האח
//       `_matchClosed` (‏registry_view.dart:237-260) הוטבע verbatim inline (חוק-1).
// טוהר: dart:core בלבד; אפס import, אפס state, אפס טיפוס RegistryView.

/// מקרקע [reply] ל-action-id של הקטלוג מתוך [catalogActionIds] — מדויק גובר, אחרת מוכל-ארוך; null אם אין.
/// verbatim action_catalog.dart:266-267 (‏_catalogActionView.elementIds() ⇒ שקע, _matchClosed inline).
/// [elementId]/reply ריק ⇒ fail-closed (null), כמראה-המקרקעים.
String? matchCatalogActionId(
  String reply, {
  required Set<String> catalogActionIds,
}) =>
    _matchClosed(catalogActionIds, reply);

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

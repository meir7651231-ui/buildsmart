// ⚛️ אטום-Dart (דרגת-חוזה) · matchComponentTypeName
// תפקיד: מקרקע [reply] לטיפוס-רכיב אמת מפלטת-הרכיבים (‏_paletteTypeView) — או null.
// מוצא: buildsmart/app_flutter/lib/logic/studio/component_palette.dart:271-272 (‏matchComponentTypeName; חוק-4).
// אחים: המקור `matchComponentType(_paletteTypeView, reply)` = `_matchClosed(_paletteTypeView.componentTypes(), reply)`.
//       ‏`_paletteTypeView` (מופע-RegistryView פרטי — היררכיה+state) קופל לשקע-נתון
//       `componentTypes` (= `_paletteTypeView.componentTypes()` verbatim; חוק-3). ה-private-האח
//       `_matchClosed` (‏registry_view.dart:237-260) הוטבע verbatim inline (חוק-1).
// טוהר: dart:core בלבד; אפס import, אפס state, אפס טיפוס RegistryView.

/// מקרקע [reply] לטיפוס-רכיב מתוך [componentTypes] — מדויק גובר, אחרת מוכל-ארוך; null אם אין.
/// verbatim component_palette.dart:271-272 (‏_paletteTypeView.componentTypes() ⇒ שקע, _matchClosed inline).
String? matchComponentTypeName(
  String reply, {
  required Set<String> componentTypes,
}) =>
    _matchClosed(componentTypes, reply);

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

// ⚛️ אטום-Dart (דרגת-חוזה) · matchComponentType
// תפקיד: מקרקע [reply] לטיפוס-רכיב אמת בר-הוספה מתוך הרישום — או null (fail-closed).
// מוצא: buildsmart/app_flutter/lib/logic/studio/registry_view.dart:293-298 (‏matchComponentType; חוק-4).
// אחים: `reg.componentTypes()` (מתודת RegistryView — היררכיה) קופלה לשקע-פונקציה
//       `componentTypes` (חוק-3). ה-private-האח `_matchClosed` (‏:237-260) הוטבע verbatim inline (חוק-1).
// טוהר: dart:core בלבד; אפס import, אפס state, אפס טיפוס RegistryView.

/// מקרקע [reply] לטיפוס-רכיב מתוך `componentTypes()` — מדויק גובר, אחרת מוכל-ארוך; null אם אין.
/// verbatim registry_view.dart:293-298 (reg.componentTypes ⇒ שקע, _matchClosed inline).
/// ריק עד שהפלטה (step-73) נוחתת ⇒ שום-דבר בר-הוספה (fail-closed).
String? matchComponentType(
  String reply, {
  required Set<String> Function() componentTypes,
}) =>
    _matchClosed(componentTypes(), reply);

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

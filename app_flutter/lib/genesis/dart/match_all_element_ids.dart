// ⚛️ אטום-Dart (דרגת-חוזה) · matchAllElementIds
// תפקיד: מחזיר את *כל* ה-element-ids האמיתיים המוכלים ב-[reply] (addition-a, step-76) —
//        לעולם לא id מומצא (רק מהרישום האמיתי); reply-ריק ⇒ קבוצה-ריקה.
// מוצא: buildsmart/app_flutter/lib/logic/studio/registry_view.dart:299-301 (‏matchAllElementIds; חוק-4).
// אחים: `reg.elementIds()` (מתודת RegistryView — היררכיה) קופלה לשקע-פונקציה `elementIds`
//       (חוק-3). ה-private-האח `_matchAllClosed` (‏:261-271) הוטבע verbatim inline (חוק-1).
// טוהר: dart:core בלבד; אפס import, אפס state, אפס טיפוס RegistryView.

/// כל element-id מ-`elementIds()` המוכל ב-[reply] (לא-רק-הטוב). reply-ריק ⇒ קבוצה-ריקה.
/// verbatim registry_view.dart:299-301 (reg.elementIds ⇒ שקע, _matchAllClosed inline).
Set<String> matchAllElementIds(
  String reply, {
  required Set<String> Function() elementIds,
}) =>
    _matchAllClosed(elementIds(), reply);

// —— _matchAllClosed הוטבע verbatim (registry_view.dart:261-271) ——
Set<String> _matchAllClosed(Set<String> closed, String reply) {
  final r = reply.trim();
  if (r.isEmpty) return const <String>{};
  return {
    for (final k in closed)
      if (k.isNotEmpty && r.contains(k)) k,
  };
}

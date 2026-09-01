// ⚛️ אטום-Dart (דרגת-חוזה) · actionIdsFor
// תפקיד: מחזיר עותק של קבוצת-הפעולות-המותרות לרכיב לפי id — או קבוצה-ריקה אם אין descriptor.
// מוצא: buildsmart/app_flutter/lib/logic/studio/registry_view.dart:198-201 (מתודת actionIdsFor; חוק-4).
// אחים: `findDescriptor(_descriptors, id)?.allowedActions` (חיפוש descriptor על state-מופע +
//       טיפוס-descriptor) קופל לשקע יחיד `allowedActionsOf` (חוק-3: קריאה-לשכן ⇒ פרמטר-שקע).
//       `_empty` (קבוצה-ריקה קבועה) הוטבע inline כ-`<String>{}`.
// טוהר: dart:core בלבד; אפס state-מופע, אפס טיפוס-descriptor.

/// עותק חדש של הפעולות-המותרות ל-[id]; allowedActionsOf(id)==null ⇒ קבוצה-ריקה.
/// verbatim registry_view.dart:198-201 (findDescriptor(...)?.allowedActions ⇒ שקע).
Set<String> actionIdsFor(
  String id, {
  required Iterable<String>? Function(String id) allowedActionsOf,
}) {
  final acts = allowedActionsOf(id);
  return acts == null ? <String>{} : Set<String>.of(acts);
}

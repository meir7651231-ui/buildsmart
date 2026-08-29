// ⚛️ אטום-Dart (דרגת-חוזה) · propKeysFor
// תפקיד: קבוצת-שמות-המאפיינים-העריכים (Set<String>) של הרכיב המזוהה ע"י id —
//        שמות ה-axes של editableProps במתאר. אין מתאר ⇒ קבוצה-ריקה (fail-closed R1-2).
// מוצא: buildsmart/app_flutter/lib/logic/studio/registry_view.dart:185-189
//        (ElementRegistryView.propKeysFor; חוק-4 — Dart-טהור, לא-מתורגם).
//        עיגון: הקובץ אינו בעץ-העבודה הנוכחי אך קיים בהיסטוריה — commit d224432d
//        (claude/align-main); הגוף שם זהה-ביט לטיוטה (git show אומת).
//
// אחים שהוטבעו/סוקטו (חוק-3, במוסכמת האח-המקודם allowed_values מאותה קופסה):
//   · findDescriptor — קריאה-לשכן ⇒ שקע-פרמטר (named required). המתאר המוחזר צומצם
//                      לטיפוס-שכן מבני מינימלי `({Iterable<({String name})> editableProps})`
//                      (רק השדה שהאטום נוגע בו; `a.name` ⇒ כל איבר צומצם לשדה name).
//   · _descriptors   — שדה-מצב של הקופסה ⇒ שקע-פרמטר `descriptors`, אטום/גנרי <D>
//                      (האטום רק מעביר אותו ל-findDescriptor).
//   · _empty         — const-אח פרטי (registry_view.dart:179) ⇒ הוטבע inline
//                      כ-`const <String>{}` (ענף ה-null; ערך verbatim).
//
// חתימה:
//   Set<String> propKeysFor<D>(String id, {
//       required D descriptors,
//       required ({Iterable<({String name})> editableProps})? Function(D, String) findDescriptor,
//   })
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core המובלע). דטרמיניסטית, ללא state/IO.

/// Editable prop-key names for the descriptor found for [id].
/// Verbatim behaviour of the source (d224432d:185-189): `findDescriptor(descriptors, id)`,
/// `null` ⇒ empty set (fail-closed R1-2), else `{for (final a in d.editableProps) a.name}`.
Set<String> propKeysFor<D>(
  String id, {
  required D descriptors,
  required ({Iterable<({String name})> editableProps})? Function(D, String)
      findDescriptor,
}) {
  final d = findDescriptor(descriptors, id);
  if (d == null) return const <String>{}; // fail-closed (R1-2)
  return {for (final a in d.editableProps) a.name};
}

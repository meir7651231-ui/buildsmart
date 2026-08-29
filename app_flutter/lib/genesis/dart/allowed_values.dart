// ⚛️ אטום-Dart (דרגת-חוזה) · allowedValues
// תפקיד: החזרת קבוצת-הערכים-המותרים (Set<String>) של מאפיין propKey על גבי
//        הרכיב שמזוהה ע"י id, מתוך רשומת-מתאר (descriptor). לא-נמצא/חסר ⇒ קבוצה-ריקה.
// מוצא: buildsmart/app_flutter/lib/logic/studio/registry_view.dart:192-197 (6 שורות; Dart-טהור, לא-מתורגם — חוק-4).
//        ⚠️ נאמנות-מקור: קובץ-המקור הנקוב אינו קיים עוד בריפו (grep findDescriptor/_descriptors/
//        allowedValues/Descriptor ב-app_flutter/lib ⇒ ריק). ההתנהגות מעוגנת ב-6 שורות-הטיוטה
//        עצמן (קוד-חלוץ קדוש, חוק-2) — לא בשחזור-מומצא של הקופסה שמסביב.
//
// אחים שהוטבעו/סוקטו (חוק-3):
//   · findDescriptor  — קריאה-לשכן ⇒ שקע-פרמטר (named required). המתאר שהוא מחזיר צומצם
//                       לטיפוס-שכן מבני מינימלי `({Map<String, Iterable<String>> allowedValues})`
//                       (רק השדה שהאטום נוגע בו; `[propKey]` ⇒ Map keyed-String,
//                       `Set<String>.of(vals)` ⇒ הערך הוא Iterable<String>).
//   · _descriptors    — שדה-מצב של הקופסה ⇒ שקע-פרמטר `descriptors`, אטום/גנרי <D>
//                       (האטום רק מעביר אותו ל-findDescriptor; אין לו טיפוס-מוכר בטיוטה).
//   · _empty          — const-אח פרטי (סוכן-קבוצה-ריקה משותף) ⇒ הוטבע inline כ-`const <String>{}`
//                       (ענף ה-null; ערך verbatim = קבוצת-מחרוזות ריקה).
//
// חתימה:
//   Set<String> allowedValues<D>(String id, String propKey, {
//       required D descriptors,
//       required ({Map<String, Iterable<String>> allowedValues})? Function(D, String) findDescriptor,
//   })
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core המובלע). דטרמיניסטית, ללא state/IO.

/// Allowed-values set for property [propKey] of the descriptor found for [id].
/// Verbatim behaviour of the draft: `findDescriptor(descriptors, id)?.allowedValues[propKey]`,
/// then `null ? _empty : Set<String>.of(vals)`. Missing descriptor OR missing propKey ⇒ empty set.
Set<String> allowedValues<D>(
  String id,
  String propKey, {
  required D descriptors,
  required ({Map<String, Iterable<String>> allowedValues})? Function(D, String)
      findDescriptor,
}) {
  final vals = findDescriptor(descriptors, id)?.allowedValues[propKey];
  return vals == null ? const <String>{} : Set<String>.of(vals);
}

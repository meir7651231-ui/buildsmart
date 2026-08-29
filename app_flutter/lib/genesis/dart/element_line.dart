// ⚛️ אטום-Dart (דרגת-חוזה) · elementLine
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_prompt.dart:236-248 (‏_elementLine; חוק-4 — התנהגות זהה).
// טוהר: פונקציית top-level עצמאית, אפס import. שתי קריאות-השכן על ה-RegistryView
//        (`registry.propKeysFor(id)`, `registry.actionIdsFor(id)`) הופכו לשקעי-פרמטר
//        (חוק-3/דיבר-3: קריאה-לשכן ⇒ פרמטר-שקע). המקור לקח `RegistryView registry`;
//        האטום לוקח את שני הריאדרים ישירות, אפס תלות בטיפוס-השכן.
//
// קלט:  id           — מזהה-אלמנט.
//       propKeysFor  — שקע: id ⇒ אוסף מפתחות-מאפיין (במקור registry.propKeysFor).
//       actionIdsFor — שקע: id ⇒ אוסף מזהי-פעולה (במקור registry.actionIdsFor).
// פלט:  שורת-תיאור: אם יש props/actions ⇒ '<id> = props a/b · actions x/y' (ממויין),
//        אחרת ⇒ id בלבד.

/// Compact `id = props … · actions …` line for the Stage-B prompt slice.
/// Verbatim behaviour of edit_prompt.dart:236-248 with the two registry reads injected.
String elementLine(
  String id, {
  required Iterable<String> Function(String id) propKeysFor,
  required Iterable<String> Function(String id) actionIdsFor,
}) {
  final props = propKeysFor(id).toList()..sort();
  final actions = actionIdsFor(id).toList()..sort();
  final rhs = <String>[];
  if (props.isNotEmpty) rhs.add('props ${props.join('/')}');
  if (actions.isNotEmpty) rhs.add('actions ${actions.join('/')}');
  return rhs.isEmpty ? id : '$id = ${rhs.join(' · ')}';
}

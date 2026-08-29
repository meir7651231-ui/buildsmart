// ⚛️ אטום-Dart (דרגת-חוזה) · fewShotExample
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_prompt.dart (‏_fewShotExample; חוק-4 — התנהגות זהה).
// טוהר: פונקציית top-level עצמאית, אפס import. הקריאה-לשכן `registry.propKeysFor(id)`
//        הופכה לשקע-פרמטר (חוק-3). המקור לקח `RegistryView registry`; האטום לוקח את
//        הריאדר ישירות. שם: `_fewShotExample` (פרטי) ⇒ `fewShotExample` (ציבורי).
//
// קלט:  slice        — רשימת מזהי-אלמנט בטווח.
//       propKeysFor  — שקע: id ⇒ אוסף מפתחות-מאפיין (במקור registry.propKeysFor).
// פלט:  String? — דוגמת-JSON תקינה מ-id אמיתי, או null אם slice ריק.
//        מעדיף setText על id שחושף 'text'; אחרת setHidden על ה-id הראשון.

/// ONE valid few-shot op built from a REAL slice id (never invented).
/// Verbatim behaviour of edit_prompt.dart `_fewShotExample` with the registry read injected.
String? fewShotExample(
  List<String> slice, {required String Function(String) term, 
  required Iterable<String> Function(String id) propKeysFor,
}) {
  if (slice.isEmpty) return null;
  for (final id in slice) {
    if (propKeysFor(id).contains('text')) {
      return '[{"op":"setText","id":"$id${term('tkst-ldvgmh')}';
    }
  }
  return '[{"op":"setHidden","id":"${slice.first}","hidden":false}]';
}

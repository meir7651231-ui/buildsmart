// ⚛️ אטום-Dart (דרגת-חוזה) · freeValueOk
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:231-286 (‏_freeValueOk, 6 שורות
//        ראשונות של הבלוק; חוק-4). האחיות `_resolveStyle`/`_resolveToken` (שמופיעות בטיוטה
//        מתחת לחלוקה) אינן חלק מהאטום — הן פונקציות-שכן נפרדות.
// טוהר: פונקציית top-level עצמאית, אפס import. שתי קריאות-השכן על ה-RegistryView הופכו
//        לשקעים (חוק-3): `reg.allowedValues(target, prop)` ו-`matchValue(reg, target, prop, value)`.
//        שם: `_freeValueOk` (פרטי) ⇒ `freeValueOk`.
//
// קלט:  target, prop  — מזהי אלמנט/מאפיין.
//       value         — הערך לבדיקה (nullable).
//       allowedValues — שקע: (target, prop) ⇒ אוסף-סגור (במקור reg.allowedValues).
//       matchValue    — שקע: (target, prop, value) ⇒ הערך-המנורמל או null (במקור matchValue).
// פלט:  bool — value==null ⇒ true; אוסף-סגור ריק ⇒ true (תוכן-חופשי); אחרת matchValue!=null.

/// Is this free-form value acceptable? null / unconstrained prop ⇒ true;
/// a constrained prop ⇒ must resolve via matchValue. Verbatim: edit_intent.dart:231-286.
bool freeValueOk(
  String target,
  String prop,
  String? value, {
  required Iterable<String> Function(String target, String prop) allowedValues,
  required String? Function(String target, String prop, String value) matchValue,
}) {
  if (value == null) return true;
  if (allowedValues(target, prop).isEmpty) return true; // free content.
  return matchValue(target, prop, value) != null;
}

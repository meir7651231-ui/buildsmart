// ⚛️ אטום-Dart (דרגת-חוזה) · configOpEquals
// מוצא: buildsmart/app_flutter/lib/logic/studio/config_op.dart:129-142
//        (‏configOpEquals; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית + גנרית, אפס import פנימי (רק שפה/סטנדרט — ==).
//
// שקעים שהוזרקו (המקור pattern-matches על 6 וריאנטים סגורים של `ConfigOp`
// וקורא שדה-פר-וריאנט — קריאה-לשכן ⇒ פרמטרים-שקע · חוק-1/3, דיבר-3):
//   • ה-switch `(a, b) => (SetText x, SetText y) ...` (config_op.dart:129-141)
//     קורס ל-3 שקעים טהורים שמזקקים את מה שכל ענף עושה:
//       - `kindOf(op)`    — הבחנת-הווריאנט. שני ענפי-מקור מאותו וריאנט ⇒ אותו kind;
//                            וריאנטים שונים ⇒ kind שונה ⇒ ה-`_ => false` של המקור.
//       - `idOf(op)`      — `x.id` (משותף לכל 6 הענפים — ConfigOp.id, config_store.dart:51).
//       - `payloadOf(op)` — השדה-הנשווה-פר-וריאנט: text/emoji/hidden/order/style/action
//                            (config_op.dart:130-140). ההשוואה `==` על ה-payload מאצילה
//                            לשוויון-הערך של הטיפוס (SetStyle⇒CfgStyle==, SetAction⇒CfgAction==).
//   • הטיפוס `ConfigOp` ⇒ פרמטר-גנרי `T` (אטום לא מייבא sealed-שכן — חוק-1/5).
//
// קלט:  a, b       — T: שני ה-ops להשוואה (במקור ConfigOp).
//       kindOf     — שקע: Object? Function(T). מזהה-הווריאנט (למשל runtimeType/enum-kind).
//       idOf       — שקע: Object? Function(T). מזהה-הצומת (ConfigOp.id).
//       payloadOf  — שקע: Object? Function(T). השדה-הנשווה של הווריאנט (nullable מותר).
// פלט:  bool — האם a ו-b שווי-ערך: אותו וריאנט ∧ אותו id ∧ אותו payload; אחרת false.

/// §69 — VALUE equality of two config-ops (המחלקות הסגורות משתמשות ב-identity `==`;
/// זה ה-"value-based compare" ל-undo/diff). וריאנטים-שונים ⇒ `false` ללא-תלות ב-id/payload
/// (ה-`_ => false` של config_op.dart:141). אחרת ⇒ `id`-שווה ∧ `payload`-שווה.
/// Pure — התנהגות verbatim של config_op.dart:129-142.
bool configOpEquals<T>(
  T a,
  T b, {
  required Object? Function(T op) kindOf,
  required Object? Function(T op) idOf,
  required Object? Function(T op) payloadOf,
}) {
  if (kindOf(a) != kindOf(b)) return false; // mismatched variants → false
  return idOf(a) == idOf(b) && payloadOf(a) == payloadOf(b);
}

// ⚛️ אטום-Dart (דרגת-חוזה) · canPlace
// מוצא: buildsmart/app_flutter/lib/logic/studio/component_palette.dart:277-280
//        (‏canPlace; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית + גנרית, אפס import פנימי (רק שפה/סטנדרט — Set.contains).
//
// שקע שהוזרק (קריאה-לשכן ⇒ פרמטר-שקע · חוק-1/3, דיבר-3):
//   • templateFor(type)?.allowedContainers  (component_palette.dart:278-279)
//     — קריאת-השכן `templateFor` + קריאת-שדה `.allowedContainers` קורסות לשקע-יחיד
//       `allowedContainersFor(type) → Set<TKind>?` (אותו דפוס-בית כמו can_connect
//       שקרס `kVerifiedSpecs[sku]+compatibleWith` לשקע-יחיד):
//       מחזיר null כשאין תבנית לסוג (⇔ templateFor==null, fail-closed),
//       אחרת את `t.allowedContainers` (שדה לא-nullable במקור, ⇒ Set לא-null).
//   • הסוגים ComponentType / ElementKind ⇒ פרמטרים גנריים TType / TKind
//     (אטום לא מייבא enum-שכן — חוק-1/5).
//
// קלט:  type                 — TType: הסוג לבדיקה (במקור ComponentType).
//       container            — TKind: מין-המיכל היעד (במקור ElementKind).
//       allowedContainersFor — שקע: Set<TKind>? Function(TType). null ⇒ סוג-לא-מוכר.
// פלט:  bool — האם רכיב מסוג type מותר לשחרור לתוך מיכל מסוג container.

/// §4 — true only when a component of [type] may be dropped INTO a container of
/// kind [container] (`container ∈ allowedContainers`). Fail-closed for an unknown
/// type (השקע מחזיר null). Pure — התנהגות verbatim של component_palette.dart:277-280.
bool canPlace<TType, TKind>(
  TType type,
  TKind container, {
  required Set<TKind>? Function(TType type) allowedContainersFor,
}) {
  final allowed = allowedContainersFor(type);
  return allowed != null && allowed.contains(container);
}

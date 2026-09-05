// ⚛️ אטום-Dart (דרגת-חוזה) · fieldLabelHe
// מוצא: buildsmart/app_flutter/lib/logic/studio/rules_model.dart:444-451 (‏fieldLabelHe; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import. ה-const-האחות `kRuleFields` (רשימת
//        רשומות עם id+labelHe) הופכה לשקע-פרמטר `fields` (חוק-3/דיבר-3 — כמו האקסמפלר
//        branch_label שהפך const-אחות לשקע). טיפוס-האיבר הוטבע כ-record inline
//        `({String id, String labelHe})` (חוק-1: אפס import של טיפוס-שכן).
//        ⚠️ ה-const אינו זמין במקור-הנוכחי (studio/ חסר בצ׳קאאוט) ⇒ שקע, לא ניחוש-ערך.
//
// קלט:  id     — מזהה-שדה.
//       fields — שקע: רשימת (id, labelHe) בסדר; במקור const kRuleFields.
// פלט:  labelHe של השדה הראשון שה-id שלו תואם; אחרת ה-id הגולמי.

/// Hebrew label for a rule-field id, or the raw id when unknown.
/// Verbatim behaviour of rules_model.dart:444-451 with `kRuleFields` injected.
String fieldLabelHe(
  String id, {
  required List<({String id, String labelHe})> fields,
}) {
  for (final f in fields) {
    if (f.id == id) return f.labelHe;
  }
  return id;
}

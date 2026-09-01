// ⚛️ אטום-Dart (דרגת-חוזה) · auditLine
// תפקיד: מרנדר רשומת-חסימה אחת לשורת-ביקורת בטקסט-רגיל (עקבת-החלטה, אפס IO).
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_safety.dart:484-488 (חוק-4 — התנהגות
//        זהה, לא-משופרת). המקור החי אינו בעץ-העבודה הנוכחי; הפורמט (⛔ · תבנית התיחום)
//        חולץ verbatim מטיוטת-המחצב + הטיפוסים-השכנים מטיוטות-אחות מאותו קובץ.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). אין מחלקות.
//
// אחים שסוקטו (חוק-3/דיבר-3: קריאה-לשכן ⇒ פרמטר-שקע):
//   • `_opTag(e.op)` — קריאה-לשכן (אטום-אח `op_tag`, edit_safety.dart:474-483) ⇒ שקע `opTag`
//     (תוצאת-הקריאה מוזרקת כמחרוזת; מיפוי ה-ConfigOp→תגית שייך לאטום-op_tag, לא כאן).
//   • `e.op.id`  — קריאת-שדה על טיפוס-השכן `BlockedEntry`/`ConfigOp` ⇒ שקע `opId`.
//   • `e.reasonHe` — קריאת-שדה על `BlockedEntry` ⇒ שקע `reasonHe`.
//   טיפוס-השכן `BlockedEntry(op, reason)` (edit_safety.dart:~50, מטיוטת-contrast_ratio) עוטף
//   `ConfigOp` — היררכיה-אטומה בת 6 גרסאות (SetText/SetEmoji/SetHidden/SetOrder/SetStyle/
//   SetAction). לא הוטבע verbatim (אי-אפשר-כטהור); שלושת-השדות-הנצרכים דוססו לשקעים-סקלריים.
//
// קלט:  opTag    — תגית-הפעולה (תוצאת _opTag; במקור אחת מ-6, כאן מחרוזת חופשית).
//       opId     — מזהה-הרכיב שנחסם (e.op.id).
//       reasonHe — נימוק-החסימה בעברית (e.reasonHe).
// פלט:  '⛔ '+opTag+' · '+opId+' · '+reasonHe  (⛔=U+26D4; התיחום=' · ' עם U+00B7).

/// Render ONE blocked entry to a plain-text audit line — a decision trace, no IO.
/// Verbatim format of edit_safety.dart:484-488 with the three consumed fields
/// (`_opTag(e.op)`, `e.op.id`, `e.reasonHe`) injected as scalar sockets.
String auditLine({
  required String opTag,
  required String opId,
  required String reasonHe,
}) =>
    '⛔ $opTag · $opId · $reasonHe';

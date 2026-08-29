// ⚛️ אטום-Dart (דרגת-חוזה) · ruleSummaryHe
// מוצא: buildsmart/app_flutter/lib/logic/studio/rules_model.dart:460-469 (חוק-4).
//        האטום = `ruleSummaryHe` בלבד; `advisoryHe` שבטיוטה אינו היעד.
//        קובץ-המקור אינו קיים עוד ב-checkout; הטיוטה = מקור-האמת.
// טוהר: הרכבת-מחרוזת טהורה. שקעים (חוק-3):
//        · `triggerLabelHe(r.trigger)` / `fieldLabelHe(r.condition.field)` /
//          `actionLabelHe(r.action)` — עוזרי-תיוג-שכנים ⇒ תוצאותיהם מוזרקות כמחרוזות
//          `triggerLabel`/`fieldLabel`/`actionLabel`.
//        · `Rule` (טיפוס-שכן גדול, מקונן) ⇒ מפורק לשדות: `opRaw` (‏r.condition.op),
//          `value` (‏r.condition.value).
//        · `kRuleOpLabelsHe` (מפת אופרטור→תווית) ⇒ שקע `opLabels`.
//        הלוגיקה-האינטרינסית היחידה — נפילת-אופרטור `opLabels[opRaw] ?? opRaw` — נשמרת מילה-במילה.
//
// פלט:  '‏<trigger> · <field> <op> <value> · <action>' (הפרדות ` · `, רווחים סביב האופרטור).

/// The Hebrew one-line rule summary:
/// `'<trigger> · <field> <op> <value> · <action>'`, where `<op>` is
/// `opLabels[opRaw] ?? opRaw` (the raw operator falls through un-translated).
/// Verbatim format of rules_model.dart:460-469 with the three label helpers,
/// the `Rule` fields, and the op-label map injected as sockets.
String ruleSummaryHe({
  required String triggerLabel,
  required String fieldLabel,
  required String opRaw,
  required Object value,
  required String actionLabel,
  required Map<String, String> opLabels,
}) {
  final op = opLabels[opRaw] ?? opRaw;
  return '$triggerLabel · $fieldLabel $op $value · $actionLabel';
}

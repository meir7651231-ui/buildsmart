// ⚛️ אטום-Dart (דרגת-חוזה) · ruleActionIsMutating
// מוצא: buildsmart/app_flutter/lib/logic/studio/rules_model.dart:167-179 (חוק-4).
//        קובץ-המקור אינו קיים עוד ב-checkout; הטיוטה = מקור-האמת.
// טוהר: חיפוש-ליניארי טהור. הקטלוג `kRuleActions` (רשימת RuleAction-ים עם id+mutating)
//        הוא const-שכן שהגדרתו **אינה ניתנת לשחזור** (הקובץ נעלם) ⇒ הורם לשקע `actions`
//        (חוק-3), כרשומות `({String id, bool mutating})` — רק שני-השדות שהאטום נוגע בהם.
//
// קלט:  actionId · actions (שקע-הקטלוג).
// פלט:  ה-`mutating` של ההתאמה-הראשונה ל-id; אם אין התאמה ⇒ `false` (fail-safe).

/// True iff the action whose `id == actionId` is marked `mutating`. Linear scan;
/// the FIRST id-match wins; no match ⇒ `false`.
/// Verbatim behaviour of rules_model.dart:167-179 with the `kRuleActions`
/// catalogue injected as the [actions] socket.
bool ruleActionIsMutating(
  String actionId, {
  required List<({String id, bool mutating})> actions,
}) {
  for (final a in actions) {
    if (a.id == actionId) return a.mutating;
  }
  return false;
}

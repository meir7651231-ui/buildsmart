// 🗄️ טבלה-מוקלדת · kRuleActions (const List<RuleAction>) — אטום-דאטה משותף (G69 · חצב-AST, חוק-4 — verbatim מהמקור, כולל סגירת-הטיפוסים).
// מוצא: buildsmart/app_flutter/lib/logic/studio/rules_model.dart:155
// טוהר: אפס-import; 5 הצהרות-סגירה + הטבלה. פונקציות-מדף **מייבאות** את הקובץ הזה (ייבוא-לפי-מוצא בחצב) במקום להטביע עותק.
// גודל: 4 רשומות (נמדד בהרצה).
// ייצוא: kRuleActions ← buildsmart/app_flutter/lib/logic/studio/rules_model.dart
// ייצוא: kActionSuggestReorder ← buildsmart/app_flutter/lib/logic/studio/rules_model.dart
// ייצוא: kActionFlagOrder ← buildsmart/app_flutter/lib/logic/studio/rules_model.dart
// ייצוא: kActionNotifyContractor ← buildsmart/app_flutter/lib/logic/studio/rules_model.dart
// ייצוא: kActionNotifyManager ← buildsmart/app_flutter/lib/logic/studio/rules_model.dart
// ייצוא: RuleAction ← buildsmart/app_flutter/lib/logic/studio/rules_model.dart

/// SUGGEST a reorder — a MUTATING action. `mutating:true` → deferred (as above).
const String kActionSuggestReorder = 'suggest.reorder';

/// FLAG the order — a MUTATING action. In the closed set but `mutating:true` →
/// DEFERRED behind the confirm-gate; NOT wired to any write in Phase-1.
const String kActionFlagOrder = 'flag.order';

/// Surface a notice to the contractor. READ-ONLY advisory.
const String kActionNotifyContractor = 'notify.contractor';

/// Surface a notice to the manager. READ-ONLY advisory (Phase-1 default).
const String kActionNotifyManager = 'notify.manager';

/// One closed-set action: its id + Hebrew label + the [mutating] flag. A mutating
/// action is shown (never dropped — governance transparency) but GREYED / deferred
/// in the picker (§4), and never triggers a write in Phase-1.
class RuleAction {
  const RuleAction(this.id, this.labelHe, {required this.mutating});
  final String id;
  final String labelHe;
  final bool mutating;
}

/// The CLOSED action set — 2 read-only advisory + 2 mutating(deferred). Any action
/// outside it → the rule is dropped.
const List<RuleAction> kRuleActions = <RuleAction>[
  RuleAction(kActionNotifyManager, 'התרע למנהל', mutating: false),
  RuleAction(kActionNotifyContractor, 'התרע לקבלן', mutating: false),
  RuleAction(kActionFlagOrder, 'סמן הזמנה', mutating: true),
  RuleAction(kActionSuggestReorder, 'הצע הזמנה חוזרת', mutating: true),
];

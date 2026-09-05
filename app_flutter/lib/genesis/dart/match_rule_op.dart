// ⚛️ אטום-Dart (דרגת-חוזה) · matchRuleOp
// מוצא: buildsmart/app_flutter/lib/logic/studio/rules_model.dart:205-207 (חצב-בינה · חוק-3/4).
// שקע: matchClosed ← השכן `_matchClosed(closed, reply)` — עיגון מחרוזת לקבוצה-סגורה
//        (exact → longest-contained → null).
// מוטבע verbatim (ערך-נתונים, כלל-1): kRuleOpsList/kRuleOps (rules_model.dart:114-117).
// עיגון תשובת-מודל לאופרטור-אמת, או null (הפלת-הכלל).

const List<String> kRuleOpsList = <String>['>', '>=', '<', '<=', '='];
final Set<String> kRuleOps = kRuleOpsList.toSet();

String? matchRuleOp(String reply,
        {required String? Function(Set<String>, String) matchClosed}) =>
    matchClosed(kRuleOps, reply);

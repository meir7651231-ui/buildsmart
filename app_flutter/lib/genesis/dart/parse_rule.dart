// ⚛️ אטום-Dart (דרגת-חוזה) · parseRule
// מוצא: buildsmart/app_flutter/lib/logic/studio/rules_model.dart:308-343 (חוק-4).
//        קובץ-המקור נעדר מה-checkout; אומת ביט-ביט מול הענף claude/align-main (git show).
// אחים-שהוזרקו (חוק-3): הפונקציות-השכנות `matchTriggerId`/`matchRuleActionId`/`_validateCondition`
//        ⇒ שקעים (כולן קיימות כאטומים: match_trigger_id / match_action_id / validate_condition);
//        ה-constructor ‏`Rule(trigger:, condition:, action:)` ⇒ שקע-מפעל `makeRule`.
//        הטיפוסים `Trigger`/`Action`/`Condition`/`Rule` ⇒ גנריים `T`/`A`/`C`/`R`
//        (מוסכמת-האח validate_condition). ‏`jsonDecode` = ‏dart:convert, ספריית-סטנדרט
//        (מותר באטום — LAW חוק-1; תקדים decode.dart) — לא שקע.
//
// קלט:  raw               — תשובת-מודל גולמית (String).
//       matchTriggerId    — שקע: מחרוזת ⇒ T? (null = טריגר מומצא ⇒ drop).
//       matchRuleActionId — שקע: מחרוזת ⇒ A? (null = פעולה מומצאת ⇒ drop).
//       validateCondition — שקע: ערך-JSON גולמי ⇒ C? (null = תנאי פסול ⇒ drop).
//       makeRule          — שקע-מפעל: (T, C, A) ⇒ R.
// פלט:  R תקין, או null בכל אחד מ-7 שערי-הכשל — טוטאלי, לעולם-לא-זורק.

import 'dart:convert' show jsonDecode;

/// Parse + VALIDATE a rules reply into a trusted rule, or `null` (drop). TOTAL:
/// any failure — non-JSON, malformed, an invented trigger / action, an invalid
/// condition — yields `null`, NEVER a throw and NEVER an un-grounded rule.
/// Brace-extract the outermost `{`…`}`, `jsonDecode` inside a `try`, validate
/// EVERY token via the injected matchers (null → drop), terminal `catch (_) → null`.
/// Verbatim behaviour of rules_model.dart:308-343 with the three neighbour
/// validators and the `Rule` constructor injected as sockets.
R? parseRule<T, A, C, R>(
  String raw, {
  required T? Function(String) matchTriggerId,
  required A? Function(String) matchRuleActionId,
  required C? Function(Object?) validateCondition,
  required R Function(T trigger, C condition, A action) makeRule,
}) {
  final text = raw.trim();
  // Brace-extract the outermost object (a rule is a single JSON object).
  final start = text.indexOf('{');
  if (start < 0) return null; // no JSON at all → prose.
  final end = text.lastIndexOf('}');
  if (end <= start) return null; // opened, never closed → drop.
  final candidate = text.substring(start, end + 1);
  try {
    final decoded = jsonDecode(candidate);
    if (decoded is! Map) return null;
    final m = decoded.map((k, v) => MapEntry(k.toString(), v));

    // TOKEN 1 — trigger must be a REAL closed-set id, else drop.
    final trigger = matchTriggerId((m['trigger'] ?? '').toString());
    if (trigger == null) return null;

    // TOKEN 2 — action must be a REAL closed-set id, else drop. (A mutating action
    // is legal here — it is DEFERRED at execution, not dropped at parse.)
    final action = matchRuleActionId((m['action'] ?? '').toString());
    if (action == null) return null;

    // TOKEN 3/4/5 — the condition (field · op · value), all-or-nothing.
    final condition = validateCondition(m['condition']);
    if (condition == null) return null;

    return makeRule(trigger, condition, action);
  } catch (_) {
    // Malformed / non-JSON → drop, NEVER throw (parseConfigEdit's terminal catch).
    return null;
  }
}

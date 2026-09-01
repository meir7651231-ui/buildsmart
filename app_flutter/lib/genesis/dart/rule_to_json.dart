// ⚛️ אטום-Dart (דרגת-חוזה) · ruleToJson — קודק-JSON של מודל-הכללים (Studio §10)
// מוצא: buildsmart/app_flutter/lib/logic/studio/rules_model.dart
//        (‏RuleCondition ‏:214-249 · Rule ‏:254-295; חוק-4 — verbatim, Dart נשאר Dart).
//        ⚠️ קו-האמת: הקובץ אינו קיים על ה-checkout המקומי — חולץ מ-
//        claude/align-main ≡ origin/claude/whats-happening-LyY9G (הקומיט 6e23aa4c;
//        md5 ‏a174aec58f6915096b2c880900849a4d) — ענף-העבודה החי של app_flutter.
// 🏷️ שם-הטיוטה `to_json` גנרי ⇒ שם-מובחן-דומיין: rule_to_json (הכרעה-4 של
//        הקידום-הקשה; תקדים-אח connection_schema_to_json — ולא skip-dup:
//        ‏config_ops_to_json מקורו ב-config_op.dart:109-111, לא בקובץ-הזה).
// טוהר: אפס import. 2 מחלקות-המודל הוטבעו מינימלית-verbatim (הכרעה-2):
//        שדות + בנאי + toJson + fromJson + ==/hashCode. ‏`identical`/`Object.hash`
//        = ‏dart:core (מותר באטום — LAW חוק-1). ‏@immutable הושמט (תקדים end_pair).
//        הגטר `isMutating` (‏:270) — קריאה-לשכן `ruleActionIsMutating` (‏:167-172)
//        ⇒ **אינו באטום-הזה** (חוק-3); הוא חי כאטום rule_action_is_mutating
//        והחיבור (rule.action ⇒ mutating?) הוא חיווט-קופסה.
//
// התנהגות (עוגני-שורה בחוזה): toJson — מפתחות קבועים בסדר-המקור
// (‏field,op,value · trigger,condition,action), condition מקונן; TOTAL, אפס-mutation.
// ‏fromJson — casts קשיחים verbatim (‏`as String`/`as num`/`as Map`): קלט-פגום
// זורק TypeError — במכוון; הפרסר-הטוטאלי לקלט-מודל הוא האטום parse_rule.
// שוויון — ערכי (identical קיצור-דרך) · hashCode = Object.hash על השדות.
//
// קלט:  מופע בנוי (toJson) · Map<String,dynamic> אמין (fromJson).
// פלט:  Map מוכן-ל-jsonEncode · מופע משוחזר; round-trip משמר-שוויון.

/// A single condition: `field <op> value`, every slot from a CLOSED set (§6).
/// (verbatim: rules_model.dart:214-249 — fields, constructor, codec, equality.)
class RuleCondition {
  const RuleCondition({
    required this.field,
    required this.op,
    required this.value,
  });

  /// One of the closed condition-field set (`kRuleConditionFields`).
  final String field;

  /// One of the closed operator set (`kRuleOps`).
  final String op;

  /// The numeric threshold (`ageDays > 2`, `sum >= 1000`, …).
  final num value;

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'field': field, 'op': op, 'value': value};

  factory RuleCondition.fromJson(Map<String, dynamic> j) => RuleCondition(
        field: j['field'] as String,
        op: j['op'] as String,
        value: j['value'] as num,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuleCondition &&
          other.field == field &&
          other.op == op &&
          other.value == value;

  @override
  int get hashCode => Object.hash(field, op, value);
}

/// One automation rule: `trigger → condition → action`, every slot CLOSED-SET (§6).
/// Phase-1: READ-ONLY ADVISORY — a rule COUNTS + SURFACES; it never mutates.
/// (verbatim: rules_model.dart:254-295; the `isMutating` getter is NOT here —
/// it is a neighbour call, living as the `rule_action_is_mutating` atom.)
class Rule {
  const Rule({
    required this.trigger,
    required this.condition,
    required this.action,
  });

  /// One of the closed trigger set (`kRuleTriggerIds`).
  final String trigger;

  final RuleCondition condition;

  /// One of the closed action set (`kRuleActionIds`).
  final String action;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'trigger': trigger,
        'condition': condition.toJson(),
        'action': action,
      };

  factory Rule.fromJson(Map<String, dynamic> j) => Rule(
        trigger: j['trigger'] as String,
        condition:
            RuleCondition.fromJson((j['condition'] as Map).cast<String, dynamic>()),
        action: j['action'] as String,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rule &&
          other.trigger == trigger &&
          other.condition == condition &&
          other.action == action;

  @override
  int get hashCode => Object.hash(trigger, condition, action);
}

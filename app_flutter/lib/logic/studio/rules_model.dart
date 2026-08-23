// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 4 · Step 84 — the CLOSED-SET rules/automation model
// + `parseRule` (another instance of the TOTAL anti-hallucination parser) + a PURE
// read-only advisory evaluator. Pure Dart — no Widget, no gateway, no provider, no
// direct Firebase symbol (it only imports the `Order` / `ManagerAnalytics` DATA
// types the eval reads — both plain immutable value classes constructible with no
// Firebase init, exactly as `orders_engine_test.dart` constructs them).
//
// THE INVARIANT (§4/§8 · Phase-1 rules are READ-ONLY ADVISORY):
//   A [Rule] EVALUATES over the live engines and SURFACES a notice
//   ("כרגע N הזמנות תואמות", §9) — it NEVER mutates orders/tasks/anything.
//   [evalRuleAdvisory] is a PURE COUNT (trigger ∧ condition) over an IMMUTABLE
//   `List<Order>`; it holds no notifier, calls no setter, returns an `int`. The
//   MUTATING actions (`flag.order` / `suggest.reorder`) exist in the closed action
//   set but are flagged `mutating:true` → DEFERRED behind the same confirm-gate as
//   the co-editor (`ai_assistant_screen.dart:208-229`); they are NOT wired to any
//   write in Phase-1. The DoD (§8) greps this file to prove no orders mutation.
//
// RECONCILIATION #1 — the 🔒 כללים tab was a PLACEHOLDER framed as a "safety floor"
// (`studio_screen.dart` `_RulesPane` / "what the Studio may change"). Step 84's
// actual content is AUTOMATION RULES (trigger → condition → action). The tab now
// hosts `StudioRulesScreen`; the safety-floor framing survives only as a sub-note.
//
// RECONCILIATION #2 — Pillar-1's frozen `ConfigDoc` carries NO `rules` slot (grep
// of config_node.dart / config_doc.dart / config_store.dart confirms). Because
// Phase-1 rules are READ-ONLY ADVISORY they need not round-trip through P1's frozen
// draft, so this model owns its OWN [Rule.toJson]/[Rule.fromJson] (§10 — for a
// FUTURE P1 integration) and the working rules live in a simple local/provider
// state in the screen. We do NOT modify P1's frozen ConfigDoc.
//
// STRUCTURAL COPY of `parseConfigEdit` (edit_intent.dart:117) + the step-71 matcher
// idiom (registry_view.dart:237 `_matchClosed` — exact → longest-contained → null):
// brace-extract (indexOf/lastIndexOf), `jsonDecode` inside a `try`, validate EVERY
// token (trigger · condition.field · condition.op · action) against its CLOSED set
// via a matcher (null → DROP the whole rule), and a terminal `catch (_) → null`.
// An invented trigger / condition-field / action / op yields `null` — NEVER a throw,
// NEVER an un-grounded rule.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:buildsmart/logic/manager_dashboard.dart' show ManagerAnalytics;
import 'package:buildsmart/state/orders_engine.dart' show Order;
import 'package:flutter/foundation.dart' show immutable;

// ─── CLOSED SET 1 — the trigger ids (§6) ─────────────────────────────────────
// Each trigger names a base predicate over a live [Order]. The set is CLOSED: a
// model-emitted trigger outside it is dropped (fail-closed). Grounded in the real
// order stages (`kManagerOrderFlow`) + the `isOpen` predicate the engine exposes.

/// A newly-placed order (`stage == 'new'`).
const String kTriggerOrderNew = 'order.new';

/// An OPEN order that has been sitting — the "stuck" candidate. The base predicate
/// is `isOpen` (not delivered); the [RuleCondition] (`ageDays > N`) refines it to
/// the ones that are actually old. This is the canonical §5 example's trigger.
const String kTriggerOrderStuck = 'order.stuck';

/// Any open order (`stage != 'delivered'` — the engine's `isOpen`).
const String kTriggerOrderOpen = 'order.open';

/// A delivered order (`stage == 'delivered'`).
const String kTriggerOrderDelivered = 'order.delivered';

/// One closed-set trigger: its id + a Hebrew label for the manual picker (§2).
class RuleTrigger {
  const RuleTrigger(this.id, this.labelHe);
  final String id;
  final String labelHe;
}

/// The CLOSED trigger set (order-shape drivers). Any other trigger → dropped.
const List<RuleTrigger> kRuleTriggers = <RuleTrigger>[
  RuleTrigger(kTriggerOrderStuck, 'הזמנה תקועה'),
  RuleTrigger(kTriggerOrderNew, 'הזמנה חדשה'),
  RuleTrigger(kTriggerOrderOpen, 'הזמנה פתוחה'),
  RuleTrigger(kTriggerOrderDelivered, 'הזמנה שנמסרה'),
];

/// The trigger id closed set the matcher grounds against.
final Set<String> kRuleTriggerIds = {for (final t in kRuleTriggers) t.id};

// ─── CLOSED SET 2 — the condition fields + operators (§6) ─────────────────────

/// Days the order has been open (`now - createdAt`, in days). A seed order with a
/// null `createdAt` reads 0 (the legacy array had no timestamp).
const String kFieldAgeDays = 'ageDays';

/// The order total in ₪ (`Order.sum`).
const String kFieldSum = 'sum';

/// The order line-item count (`Order.items`).
const String kFieldItems = 'items';

/// One closed-set condition field: its id + Hebrew label + a unit suffix.
class RuleField {
  const RuleField(this.id, this.labelHe);
  final String id;
  final String labelHe;
}

/// The CLOSED condition-field set. A `field` outside it → the rule is dropped.
const List<RuleField> kRuleFields = <RuleField>[
  RuleField(kFieldAgeDays, 'ימים פתוחה'),
  RuleField(kFieldSum, 'סכום (₪)'),
  RuleField(kFieldItems, 'פריטים'),
];

/// The condition-field closed set the matcher grounds against.
final Set<String> kRuleConditionFields = {for (final f in kRuleFields) f.id};

/// The CLOSED comparison-operator set. Exact-match wins (`>` ⊂ `>=` handled by the
/// exact-first pass in `_matchClosed`, mirroring the registry matcher).
const List<String> kRuleOpsList = <String>['>', '>=', '<', '<=', '='];

/// The operator closed set.
final Set<String> kRuleOps = kRuleOpsList.toSet();

/// The Hebrew label for an operator (the manual picker).
const Map<String, String> kRuleOpLabelsHe = <String, String>{
  '>': 'גדול מ',
  '>=': 'גדול/שווה',
  '<': 'קטן מ',
  '<=': 'קטן/שווה',
  '=': 'שווה ל',
};

// ─── CLOSED SET 3 — the action ids (§6 · mutating flagged/deferred) ───────────

/// Surface a notice to the manager. READ-ONLY advisory (Phase-1 default).
const String kActionNotifyManager = 'notify.manager';

/// Surface a notice to the contractor. READ-ONLY advisory.
const String kActionNotifyContractor = 'notify.contractor';

/// FLAG the order — a MUTATING action. In the closed set but `mutating:true` →
/// DEFERRED behind the confirm-gate; NOT wired to any write in Phase-1.
const String kActionFlagOrder = 'flag.order';

/// SUGGEST a reorder — a MUTATING action. `mutating:true` → deferred (as above).
const String kActionSuggestReorder = 'suggest.reorder';

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

/// The action id closed set the matcher grounds against.
final Set<String> kRuleActionIds = {for (final a in kRuleActions) a.id};

/// True when [actionId] is a MUTATING action (deferred behind the confirm-gate).
/// An unknown id reads false (fail-closed — an unknown action is never "mutating").
bool ruleActionIsMutating(String actionId) {
  for (final a in kRuleActions) {
    if (a.id == actionId) return a.mutating;
  }
  return false;
}

// ─── the closed-set matcher (COPY of registry_view.dart:237 `_matchClosed`) ────

/// Resolve [reply] to a member of [closed] — exact first, else the LONGEST key
/// CONTAINED in the trimmed reply, else `null`. Blank reply / empty set → `null`
/// (fail-closed). NEVER throws. Empty keys are skipped so a stray `''` can't
/// spuriously "contain". The ONE path from a model string to a real closed-set id.
String? _matchClosed(Set<String> closed, String reply) {
  final r = reply.trim();
  if (r.isEmpty) return null;
  for (final k in closed) {
    if (r == k) return k; // exact wins outright (`>` isn't shadowed by `>=`).
  }
  String? best;
  for (final k in closed) {
    if (k.isNotEmpty &&
        r.contains(k) &&
        (best == null || k.length > best.length)) {
      best = k;
    }
  }
  return best;
}

/// Ground [reply] to a REAL trigger id, or `null` (drop the rule).
String? matchTriggerId(String reply) => _matchClosed(kRuleTriggerIds, reply);

/// Ground [reply] to a REAL condition field, or `null` (drop).
String? matchConditionField(String reply) =>
    _matchClosed(kRuleConditionFields, reply);

/// Ground [reply] to a REAL operator, or `null` (drop).
String? matchRuleOp(String reply) => _matchClosed(kRuleOps, reply);

/// Ground [reply] to a REAL action id, or `null` (drop).
String? matchRuleActionId(String reply) => _matchClosed(kRuleActionIds, reply);

// ─── the model ────────────────────────────────────────────────────────────────

/// A single condition: `field <op> value`, every slot from a CLOSED set (§6).
@immutable
class RuleCondition {
  const RuleCondition({
    required this.field,
    required this.op,
    required this.value,
  });

  /// One of [kRuleConditionFields].
  final String field;

  /// One of [kRuleOps].
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
@immutable
class Rule {
  const Rule({
    required this.trigger,
    required this.condition,
    required this.action,
  });

  /// One of [kRuleTriggerIds].
  final String trigger;

  final RuleCondition condition;

  /// One of [kRuleActionIds]. A `mutating:true` action is DEFERRED (§4).
  final String action;

  /// True when this rule's action is mutating (deferred behind the confirm-gate).
  bool get isMutating => ruleActionIsMutating(action);

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

// ─── parseRule — the TOTAL parser (mirror of `parseConfigEdit`) ────────────────

/// Parse + VALIDATE a rules reply into a trusted [Rule], or `null` (drop). TOTAL:
/// any failure — non-JSON, malformed, an invented trigger / condition-field / op /
/// action, a non-numeric value — yields `null`, NEVER a throw and NEVER an
/// un-grounded rule. Mirrors `parseConfigEdit` (edit_intent.dart:117): brace-extract
/// the outermost `{`…`}`, `jsonDecode` inside a `try`, validate EVERY token against
/// its closed set via a matcher (null → drop), terminal `catch (_) → null`.
///
/// The model NAMES closed tokens; this Dart grounds them — the anti-hallucination
/// seam for the rules path (the same guarantee the config editor gives).
Rule? parseRule(String raw) {
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
    final condition = _validateCondition(m['condition']);
    if (condition == null) return null;

    return Rule(trigger: trigger, condition: condition, action: action);
  } catch (_) {
    // Malformed / non-JSON → drop, NEVER throw (parseConfigEdit's terminal catch).
    return null;
  }
}

/// Validate ONE condition entry against the closed sets, returning the RESOLVED
/// condition or `null` (drop). All-or-nothing: an invented field, an invented op,
/// or a non-numeric value drops the whole rule.
RuleCondition? _validateCondition(Object? raw) {
  if (raw is! Map) return null;
  final c = raw.map((k, v) => MapEntry(k.toString(), v));
  final field = matchConditionField((c['field'] ?? '').toString());
  if (field == null) return null;
  final op = matchRuleOp((c['op'] ?? '').toString());
  if (op == null) return null;
  final rawValue = c['value'];
  final value =
      rawValue is num ? rawValue : num.tryParse((rawValue ?? '').toString());
  if (value == null) return null; // a non-numeric threshold → drop.
  return RuleCondition(field: field, op: op, value: value);
}

// ─── evalRuleAdvisory — the PURE READ-ONLY count (§9 · the invariant) ──────────

/// COUNT how many of [orders] currently match [rule] (trigger ∧ condition). PURE +
/// READ-ONLY (§4/§8/§9): it takes an IMMUTABLE list, reads fields, returns an `int`
/// — it holds NO notifier, calls NO setter, mutates NOTHING. The action is
/// IRRELEVANT to the count (even a mutating action only COUNTS in Phase-1 — the
/// mutation is deferred). [analytics] is reserved for future engine-level fields
/// (store/catalog conditions); [now] is injectable so tests are deterministic.
int evalRuleAdvisory(
  Rule rule, {
  required List<Order> orders,
  ManagerAnalytics? analytics,
  DateTime? now,
}) {
  final ref = now ?? DateTime.now();
  var count = 0;
  for (final o in orders) {
    if (_triggerMatches(rule.trigger, o) &&
        _conditionMatches(rule.condition, o, ref)) {
      count++;
    }
  }
  return count;
}

/// The base predicate for [trigger] over one [order]. An unknown trigger → false
/// (fail-closed). READ-ONLY — reads `stage` / `isOpen`, mutates nothing.
bool _triggerMatches(String trigger, Order order) {
  switch (trigger) {
    case kTriggerOrderNew:
      return order.stage == 'new';
    case kTriggerOrderStuck:
      return order.isOpen; // "stuck" = open (the ageDays condition refines it).
    case kTriggerOrderOpen:
      return order.isOpen;
    case kTriggerOrderDelivered:
      return order.stage == 'delivered';
  }
  return false;
}

/// Evaluate a condition [c] against one [order]. READ-ONLY. An unknown field / op
/// reads a 0 value / returns false (fail-closed).
bool _conditionMatches(RuleCondition c, Order order, DateTime now) {
  final v = _fieldValue(c.field, order, now);
  switch (c.op) {
    case '>':
      return v > c.value;
    case '>=':
      return v >= c.value;
    case '<':
      return v < c.value;
    case '<=':
      return v <= c.value;
    case '=':
      return v == c.value;
  }
  return false;
}

/// The numeric value of [field] on [order] (READ-ONLY). `ageDays` is `now-createdAt`
/// in days (a null seed `createdAt` reads 0); `sum`/`items` are the order fields.
num _fieldValue(String field, Order order, DateTime now) {
  switch (field) {
    case kFieldAgeDays:
      final created = order.createdAt;
      return created == null ? 0 : now.difference(created).inDays;
    case kFieldSum:
      return order.sum;
    case kFieldItems:
      return order.items;
  }
  return 0;
}

// ─── Hebrew helpers for the screen (§2/§9) ────────────────────────────────────

/// The Hebrew label for a trigger id (or the raw id if unknown).
String triggerLabelHe(String id) {
  for (final t in kRuleTriggers) {
    if (t.id == id) return t.labelHe;
  }
  return id;
}

/// The Hebrew label for a condition field id (or the raw id).
String fieldLabelHe(String id) {
  for (final f in kRuleFields) {
    if (f.id == id) return f.labelHe;
  }
  return id;
}

/// The Hebrew label for an action id (or the raw id).
String actionLabelHe(String id) {
  for (final a in kRuleActions) {
    if (a.id == id) return a.labelHe;
  }
  return id;
}

/// A one-line Hebrew summary of a rule (the saved-list row).
String ruleSummaryHe(Rule r) {
  final op = kRuleOpLabelsHe[r.condition.op] ?? r.condition.op;
  return '${triggerLabelHe(r.trigger)} · '
      '${fieldLabelHe(r.condition.field)} $op ${r.condition.value} · '
      '${actionLabelHe(r.action)}';
}

/// The §9 advisory line: "כרגע N הזמנות תואמות".
String advisoryHe(int matches) => 'כרגע $matches הזמנות תואמות';

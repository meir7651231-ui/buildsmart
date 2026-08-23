// Studio Pillar 4 · step 84 — the closed-set rules/automation model + `parseRule`
// (another instance of the TOTAL anti-hallucination parser) + the PURE read-only
// advisory evaluator. Pins `logic/studio/rules_model.dart`.
//
// Mirrors the `studio_edit_intent_test` discipline (§5/§8): a valid reply grounds to
// a fully-validated [Rule] + a toJson→fromJson round-trip identity; each invented
// TOKEN (trigger · condition-field · op · action) DROPS the whole rule (null),
// NEVER throwing; and `evalRuleAdvisory` returns a COUNT while mutating NOTHING (the
// orders-engine state is byte-identical after the eval — the §4/§8 read-only
// invariant the DoD greps to prove).
//
// Pure — no gateway, no widget pump (like assistant_intent_test / describe_to_cart).
import 'package:buildsmart/logic/studio/rules_model.dart';
import 'package:buildsmart/state/orders_engine.dart'
    show Order, OrdersEngineNotifier, kOrdersEngineSeed;
import 'package:flutter_test/flutter_test.dart';

/// The canonical §5 rule as the model's grounded JSON reply:
/// "תקועה >2 ימים→התרע למנהל".
const String _canonicalReply =
    '{"trigger":"order.stuck","condition":{"field":"ageDays","op":">","value":2},'
    '"action":"notify.manager"}';

/// The canonical [Rule] the reply must build.
const Rule _canonicalRule = Rule(
  trigger: kTriggerOrderStuck,
  condition: RuleCondition(field: kFieldAgeDays, op: '>', value: 2),
  action: kActionNotifyManager,
);

void main() {
  group('parseRule — round-trip (§5): "תקועה >2 ימים→התרע למנהל"', () {
    test('grounds to Rule(order.stuck, ageDays>2, notify.manager)', () {
      final rule = parseRule(_canonicalReply);
      expect(rule, isNotNull);
      expect(rule!.trigger, kTriggerOrderStuck);
      expect(rule.condition.field, kFieldAgeDays);
      expect(rule.condition.op, '>');
      expect(rule.condition.value, 2);
      expect(rule.action, kActionNotifyManager);
      expect(rule, _canonicalRule, reason: 'value-equality on the whole rule');
    });

    test('toJson → fromJson is identity', () {
      final rule = parseRule(_canonicalReply)!;
      final round = Rule.fromJson(rule.toJson());
      expect(round, rule, reason: 'a Rule round-trips through JSON unchanged');
      // The nested condition round-trips too (field · op · value).
      expect(round.condition, rule.condition);
      expect(round.toJson(), rule.toJson());
    });

    test('prose-wrapped JSON is still extracted (tolerant, like parseConfigEdit)',
        () {
      final rule = parseRule('בטח! הנה הכלל: $_canonicalReply — זהו.');
      expect(rule, _canonicalRule);
    });

    test('the closed-set matcher grounds a wrapped token to its real id', () {
      // A verbose action value that CONTAINS the real id resolves to it (longest-
      // contained), mirroring the registry matcher; the field/op are exact.
      final rule = parseRule(
        '{"trigger":"order.stuck","condition":{"field":"ageDays","op":">",'
        '"value":2},"action":"please do notify.manager now"}',
      );
      expect(rule, isNotNull);
      expect(rule!.action, kActionNotifyManager);
    });
  });

  group('parseRule — each invented TOKEN drops the rule (§5/§8, never throws)', () {
    test('invented TRIGGER → drop (null)', () {
      late Rule? r;
      expect(
        () => r = parseRule(
          '{"trigger":"order.teleport","condition":{"field":"ageDays","op":">",'
          '"value":2},"action":"notify.manager"}',
        ),
        returnsNormally,
      );
      expect(r, isNull, reason: 'order.teleport ∉ kRuleTriggerIds → drop');
    });

    test('invented CONDITION-FIELD → drop (null)', () {
      late Rule? r;
      expect(
        () => r = parseRule(
          '{"trigger":"order.stuck","condition":{"field":"phaseOfMoon","op":">",'
          '"value":2},"action":"notify.manager"}',
        ),
        returnsNormally,
      );
      expect(r, isNull, reason: 'phaseOfMoon ∉ kRuleConditionFields → drop');
    });

    test('invented ACTION → drop (null)', () {
      late Rule? r;
      expect(
        () => r = parseRule(
          '{"trigger":"order.stuck","condition":{"field":"ageDays","op":">",'
          '"value":2},"action":"delete.everything"}',
        ),
        returnsNormally,
      );
      expect(r, isNull, reason: 'delete.everything ∉ kRuleActionIds → drop');
    });

    test('invented OPERATOR → drop (null)', () {
      late Rule? r;
      expect(
        () => r = parseRule(
          '{"trigger":"order.stuck","condition":{"field":"ageDays","op":"≈",'
          '"value":2},"action":"notify.manager"}',
        ),
        returnsNormally,
      );
      expect(r, isNull, reason: '≈ ∉ kRuleOps → drop');
    });

    test('a non-numeric VALUE → drop (null)', () {
      late Rule? r;
      expect(
        () => r = parseRule(
          '{"trigger":"order.stuck","condition":{"field":"ageDays","op":">",'
          '"value":"soon"},"action":"notify.manager"}',
        ),
        returnsNormally,
      );
      expect(r, isNull, reason: 'a non-numeric threshold → drop');
    });

    test('malformed / non-JSON / empty → null, NEVER throws', () {
      for (final raw in <String>[
        '',
        '   ',
        'סתם תשובה בעברית בלי JSON',
        '{}', // no trigger/condition/action
        '{"trigger":"order.stuck"}', // missing condition + action
        '{"trigger": }', // balanced braces but malformed JSON → jsonDecode throws
        '{"trigger":"order.stuck","condition":{"field":"ageDays"},"action":"notify.manager"}', // condition missing op/value
      ]) {
        late Rule? r;
        expect(() => r = parseRule(raw), returnsNormally,
            reason: 'must NEVER throw on: "$raw"');
        expect(r, isNull, reason: 'no rule from: "$raw"');
      }
    });

    test('a MUTATING action parses (deferred at execution, NOT dropped at parse)',
        () {
      // flag.order / suggest.reorder ARE in the closed set — they parse to a valid
      // rule flagged mutating (§4: deferred behind the confirm-gate, not dropped).
      for (final id in <String>[kActionFlagOrder, kActionSuggestReorder]) {
        final rule = parseRule(
          '{"trigger":"order.open","condition":{"field":"sum","op":">=",'
          '"value":1000},"action":"$id"}',
        );
        expect(rule, isNotNull, reason: '$id is a real closed-set action');
        expect(rule!.action, id);
        expect(rule.isMutating, isTrue, reason: '$id is mutating → deferred');
      }
    });
  });

  group('evalRuleAdvisory — READ-ONLY count (§9), mutates NOTHING (§4/§8)', () {
    // A fixed "now" so ageDays is deterministic.
    final now = DateTime(2026, 7, 7, 12);
    List<Order> makeOrders() => <Order>[
          // open + 5 days old → matches order.stuck ∧ ageDays>2.
          Order(
            id: 'A',
            who: 'יוסי',
            site: 's',
            items: 5,
            sum: 1200,
            stage: 'new',
            createdAt: now.subtract(const Duration(days: 5)),
          ),
          // open + 1 day old → order.stuck but NOT ageDays>2.
          Order(
            id: 'B',
            who: 'אבי',
            site: 's',
            items: 3,
            sum: 680,
            stage: 'preparing',
            createdAt: now.subtract(const Duration(days: 1)),
          ),
          // delivered → not open → not order.stuck (even though 10 days old).
          Order(
            id: 'C',
            who: 'משה',
            site: 's',
            items: 6,
            sum: 3150,
            stage: 'delivered',
            createdAt: now.subtract(const Duration(days: 10)),
          ),
        ];

    test('counts current matches (trigger ∧ condition) — a pure int', () {
      final n = evalRuleAdvisory(_canonicalRule, orders: makeOrders(), now: now);
      expect(n, 1, reason: 'only A is open AND older than 2 days');
    });

    test('a different condition re-counts over the SAME orders', () {
      // sum >= 1000 over OPEN orders (order.open) → A(1200) + not C(delivered) → 1.
      const rule = Rule(
        trigger: kTriggerOrderOpen,
        condition: RuleCondition(field: kFieldSum, op: '>=', value: 1000),
        action: kActionNotifyManager,
      );
      expect(evalRuleAdvisory(rule, orders: makeOrders(), now: now), 1);
    });

    test('the eval MUTATES NOTHING — the orders-engine state is unchanged', () {
      // Build a real engine (no persistence) and eval over its LIVE state.
      final engine = OrdersEngineNotifier(persist: false, seed: makeOrders());
      final before = engine.state; // the live list reference + contents
      final beforeStages = [for (final o in before) '${o.id}:${o.stage}'];

      final n = evalRuleAdvisory(_canonicalRule, orders: engine.state, now: now);
      expect(n, 1);

      // READ-ONLY: same list instance, same length, same per-order stage — the
      // eval never routed through `.notifier` / never called a setter.
      expect(identical(engine.state, before), isTrue,
          reason: 'no new state was pushed — the eval is read-only');
      expect(engine.state.length, 3);
      expect([for (final o in engine.state) '${o.id}:${o.stage}'], beforeStages);
    });

    test('idempotent — evaluating twice yields the same count (pure)', () {
      final orders = makeOrders();
      final a = evalRuleAdvisory(_canonicalRule, orders: orders, now: now);
      final b = evalRuleAdvisory(_canonicalRule, orders: orders, now: now);
      expect(a, b);
      expect(orders.length, 3, reason: 'the input list is not mutated');
    });

    test('runs over the real engine seed without mutation (count is honest)', () {
      // The seed orders carry a null createdAt → ageDays reads 0, so order.stuck ∧
      // ageDays>2 matches none; the point is it COUNTS (0) and never throws/mutates.
      final engine = OrdersEngineNotifier(persist: false);
      final before = engine.state;
      final n = evalRuleAdvisory(_canonicalRule, orders: engine.state);
      expect(n, isA<int>());
      expect(identical(engine.state, before), isTrue);
      expect(engine.state.length, kOrdersEngineSeed.length);
    });
  });

  group('rules_model — closed sets are well-formed (governance)', () {
    test('every trigger/field/action id is in its closed set + has a Hebrew label',
        () {
      for (final t in kRuleTriggers) {
        expect(kRuleTriggerIds.contains(t.id), isTrue);
        expect(triggerLabelHe(t.id), t.labelHe);
      }
      for (final f in kRuleFields) {
        expect(kRuleConditionFields.contains(f.id), isTrue);
        expect(fieldLabelHe(f.id), f.labelHe);
      }
      for (final a in kRuleActions) {
        expect(kRuleActionIds.contains(a.id), isTrue);
        expect(actionLabelHe(a.id), a.labelHe);
      }
    });

    test('exactly the two mutating actions are flagged (deferred set)', () {
      final mutating =
          kRuleActions.where((a) => a.mutating).map((a) => a.id).toSet();
      expect(mutating, {kActionFlagOrder, kActionSuggestReorder});
      expect(ruleActionIsMutating(kActionNotifyManager), isFalse);
      expect(ruleActionIsMutating(kActionFlagOrder), isTrue);
    });

    test('ruleSummaryHe / advisoryHe render Hebrew', () {
      expect(ruleSummaryHe(_canonicalRule), contains('הזמנה תקועה'));
      expect(ruleSummaryHe(_canonicalRule), contains('התרע למנהל'));
      expect(advisoryHe(3), 'כרגע 3 הזמנות תואמות');
    });
  });
}

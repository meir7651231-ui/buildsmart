// STAGE-3.3 St3 — org stamping on records: CREATE-only, round-trip-preserved,
// byte-identical when no claim exists (the additive contract).
//
// The designed-out trap this pins: the org stamp lives on the ORDER MODEL at
// creation and round-trips through toJson/fromJson — it is NEVER injected at
// toDoc time from session state, so a store/courier stage-advance keeps its
// diff == {stage, claim-field} (the rules hasOnly gate) and a manager setStage
// on a foreign org's legacy doc can't clobber a stamp that isn't there.

import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Order.orgId — additive model field', () {
    test('default is empty — a claimless order serializes WITHOUT the key '
        '(seed/legacy docs byte-identical)', () {
      const o = Order(
        id: 'BS-ORG0',
        who: 'קבלן',
        site: 'אתר',
        items: 1,
        sum: 10,
        stage: 'new',
      );
      expect(o.orgId, '');
      expect(o.toJson().containsKey('orgId'), isFalse,
          reason: 'empty org must not appear in the payload');
    });

    test('a stamped order round-trips the org through toJson/fromJson', () {
      const o = Order(
        id: 'BS-ORG1',
        who: 'קבלן',
        site: 'אתר',
        items: 1,
        sum: 10,
        stage: 'new',
        orgId: 'acme',
      );
      final back = Order.fromJson(o.toJson());
      expect(back.orgId, 'acme');
    });

    test('fromJson tolerates a legacy payload with no orgId key', () {
      const o = Order(
        id: 'BS-ORG2',
        who: 'קבלן',
        site: 'אתר',
        items: 1,
        sum: 10,
        stage: 'new',
      );
      final legacy = o.toJson()..remove('orgId');
      expect(Order.fromJson(legacy).orgId, '');
    });
  });

  group('engine create-path — the stamp enters at placeOrder only', () {
    test('placeOrder with an org stamps it; stage mutations preserve it', () async {
      SharedPreferences.setMockInitialValues({});
      final n = OrdersEngineNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 30));

      n.placeOrder(
        who: 'קבלן ארגון',
        site: 'אתר',
        items: 1,
        sum: 100,
        id: 'BS-ORG3',
        orgId: 'acme',
      );
      expect(
        n.state.firstWhere((o) => o.id == 'BS-ORG3').orgId,
        'acme',
      );

      // A stage mutation (the advance path) must PRESERVE the stamp — the
      // copyWith threading, not a session re-stamp.
      n.setStage('BS-ORG3', 'preparing');
      expect(
        n.state.firstWhere((o) => o.id == 'BS-ORG3').orgId,
        'acme',
        reason: 'advances round-trip the stamp, never drop or re-derive it',
      );
    });

    test('placeOrder without an org leaves the field empty (no claim ⇒ '
        'byte-identical)', () async {
      SharedPreferences.setMockInitialValues({});
      final n = OrdersEngineNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      n.placeOrder(who: 'קבלן', site: 'אתר', items: 1, sum: 50, id: 'BS-ORG4');
      expect(n.state.firstWhere((o) => o.id == 'BS-ORG4').orgId, '');
    });
  });
}

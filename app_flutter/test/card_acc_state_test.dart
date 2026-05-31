// Roadmap step 7 — persisted per-product accessory selection + qty.
import 'package:buildsmart/state/card_acc_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('default empty + get returns null', () {
    SharedPreferences.setMockInitialValues({});
    final n = CardAccStateNotifier();
    expect(n.state, isEmpty);
    expect(n.get('faucet', 'gasket'), isNull);
  });

  test('setSelected creates entry with default qty 1', () {
    SharedPreferences.setMockInitialValues({});
    final n = CardAccStateNotifier();
    n.setSelected('faucet', 'gasket', true);
    expect(n.get('faucet', 'gasket')?.selected, isTrue);
    expect(n.get('faucet', 'gasket')?.qty, 1);
  });

  test('setQty updates qty; preserves selected flag', () {
    SharedPreferences.setMockInitialValues({});
    final n = CardAccStateNotifier();
    n.setSelected('faucet', 'gasket', true);
    n.setQty('faucet', 'gasket', 3);
    expect(n.get('faucet', 'gasket')?.qty, 3);
    expect(n.get('faucet', 'gasket')?.selected, isTrue);
  });

  test('setQty < 1 is clamped to 1', () {
    SharedPreferences.setMockInitialValues({});
    final n = CardAccStateNotifier();
    n.setQty('faucet', 'gasket', 0);
    expect(n.get('faucet', 'gasket')?.qty, 1);
    n.setQty('faucet', 'gasket', -5);
    expect(n.get('faucet', 'gasket')?.qty, 1);
  });

  test('different products keep separate entries', () {
    SharedPreferences.setMockInitialValues({});
    final n = CardAccStateNotifier();
    n.setSelected('a', 'g', true);
    n.setSelected('b', 'g', false);
    expect(n.get('a', 'g')?.selected, isTrue);
    expect(n.get('b', 'g')?.selected, isFalse);
  });

  test('persists across a fresh notifier', () async {
    SharedPreferences.setMockInitialValues({});
    final n1 = CardAccStateNotifier();
    n1.setSelected('faucet', 'gasket', true);
    n1.setQty('faucet', 'gasket', 4);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final n2 = CardAccStateNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(n2.get('faucet', 'gasket')?.selected, isTrue);
    expect(n2.get('faucet', 'gasket')?.qty, 4);
  });
}

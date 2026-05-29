// Roadmap step 7 — persisted per-product brand selection.
import 'package:buildsmart/state/card_selection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('unknown product → null', () {
    SharedPreferences.setMockInitialValues({});
    final n = CardSelectionNotifier();
    expect(n.brandFor('faucet'), isNull);
  });

  test('setBrand persists across a fresh notifier', () async {
    SharedPreferences.setMockInitialValues({});
    final n1 = CardSelectionNotifier();
    n1.setBrand('faucet', 'AQUATEC');
    n1.setBrand('drain', 'Wisa');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final n2 = CardSelectionNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(n2.brandFor('faucet'), 'AQUATEC');
    expect(n2.brandFor('drain'), 'Wisa');
  });

  test('re-setting the same brand is a no-op (no state churn)', () {
    SharedPreferences.setMockInitialValues({});
    final n = CardSelectionNotifier();
    n.setBrand('faucet', 'AQUATEC');
    final before = n.state;
    n.setBrand('faucet', 'AQUATEC');
    expect(identical(before, n.state), isTrue);
  });
}

// Roadmap step 92 — built-in A/B experiment infrastructure.
import 'package:buildsmart/state/ab_experiments.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AbExperimentsNotifier', () {
    test('variantOf returns null when no assignment exists', () {
      SharedPreferences.setMockInitialValues({});
      final n = AbExperimentsNotifier();
      expect(n.variantOf('exp-checkout'), isNull);
    });

    test('ensure assigns deterministically; same experiment → same variant',
        () {
      SharedPreferences.setMockInitialValues({});
      final n = AbExperimentsNotifier();
      const variants = ['A', 'B', 'C'];
      final first = n.ensure('cart-layout', variants);
      expect(variants, contains(first));
      // expected: hashCode.abs() % len picks this index on a fresh notifier.
      final expected =
          variants['cart-layout'.hashCode.abs() % variants.length];
      expect(first, expected);
      // Second call returns the same variant (sticky).
      final second = n.ensure('cart-layout', variants);
      expect(second, first);
      expect(n.variantOf('cart-layout'), first);
    });

    test('override changes the assignment', () async {
      SharedPreferences.setMockInitialValues({});
      final n = AbExperimentsNotifier();
      n.ensure('checkout', const ['A', 'B']);
      n.override('checkout', 'B');
      expect(n.variantOf('checkout'), 'B');
      n.override('checkout', 'A');
      expect(n.variantOf('checkout'), 'A');
    });

    test('clear removes the assignment', () {
      SharedPreferences.setMockInitialValues({});
      final n = AbExperimentsNotifier();
      n.ensure('banner', const ['X', 'Y']);
      expect(n.variantOf('banner'), isNotNull);
      n.clear('banner');
      expect(n.variantOf('banner'), isNull);
    });

    test('assignment survives a fresh notifier (persisted)', () async {
      SharedPreferences.setMockInitialValues({});
      final n1 = AbExperimentsNotifier();
      n1.ensure('persisted-exp', const ['red', 'green', 'blue']);
      n1.override('persisted-exp', 'green');
      // Let the async _persist write to mock prefs.
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final n2 = AbExperimentsNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(n2.variantOf('persisted-exp'), 'green');
    });

    test('ensure throws ArgumentError on empty variant list', () {
      SharedPreferences.setMockInitialValues({});
      final n = AbExperimentsNotifier();
      expect(() => n.ensure('x', const []), throwsArgumentError);
    });
  });
}

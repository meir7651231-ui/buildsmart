// Roadmap step 48 (quoteTextFor) + step 47 (saved configs).
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/state/saved_configs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('quoteTextFor', () {
    test('mentions the product + brand, and a total when costable', () {
      var withTotal = 0;
      for (final sp in kSmartProducts) {
        for (var i = 0; i < sp.brands.length; i++) {
          final q = quoteTextFor(sp, i);
          expect(q, contains(sp.name));
          expect(q, contains(sp.brands[i].name));
          expect(q, contains('BuildSmart'));
          if (q.contains('סה"כ משוער')) withTotal++;
        }
      }
      expect(withTotal, greaterThan(0));
    });

    test('out-of-range index falls back to the recommended brand', () {
      final sp = kSmartProducts.first;
      final q = quoteTextFor(sp, 999);
      expect(q, contains(sp.recBrand.name));
    });
  });

  group('saved configs', () {
    test('toggle saves then unsaves and persists across a fresh notifier',
        () async {
      SharedPreferences.setMockInitialValues({});
      final n1 = SavedConfigsNotifier();
      n1.toggle('faucet', 'AQUATEC');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(n1.isSaved('faucet', 'AQUATEC'), isTrue);

      final n2 = SavedConfigsNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(n2.isSaved('faucet', 'AQUATEC'), isTrue);
      expect(n2.isSaved('faucet', 'other'), isFalse);

      n2.toggle('faucet', 'AQUATEC');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(n2.isSaved('faucet', 'AQUATEC'), isFalse);
    });
  });
}

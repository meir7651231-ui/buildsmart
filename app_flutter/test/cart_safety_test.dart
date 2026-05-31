// Roadmap step 46 — buildSafetyAccessories (engine SKUs → SmartCartAcc).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/state/cart_safety.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty input → empty list', () {
    expect(buildSafetyAccessories(const [], (_) => 0), isEmpty);
  });

  test('maps each item to a safety SmartCartAcc (🛡, qty 1, name = nameHe)', () {
    final items = kLipskeyCatalog.take(3).toList();
    final r = buildSafetyAccessories(items, (p) => 17);
    expect(r.length, items.length);
    for (var i = 0; i < items.length; i++) {
      expect(r[i].name, items[i].nameHe);
      expect(r[i].emoji, '🛡');
      expect(r[i].qty, 1);
      expect(r[i].price, 17);
    }
  });

  test('price lookup is respected per item', () {
    final items = kLipskeyCatalog.take(2).toList();
    final r =
        buildSafetyAccessories(items, (p) => p == items[0] ? 100 : 250);
    expect(r[0].price, 100);
    expect(r[1].price, 250);
  });
}

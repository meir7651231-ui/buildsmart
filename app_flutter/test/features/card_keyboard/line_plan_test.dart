// P10.93: planLineFromPicks adapts the pick basket to the frozen buildInstallation
// signature. Two picks plan a line that contains both products.

import 'package:buildsmart/features/card_keyboard/card_picks.dart';
import 'package:buildsmart/features/card_keyboard/line_plan.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show divePoolBySku;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('two picks plan a line that contains both products', () {
    final products = divePoolBySku.values.take(2).toList();
    final picks = [
      for (final p in products) CardPick(sku: p.sku, label: p.nameHe),
    ];
    final plan = planLineFromPicks(picks);
    final skus = plan.items.map((p) => p.sku).toSet();
    for (final p in products) {
      expect(skus.contains(p.sku), isTrue, reason: '${p.sku} missing from the line');
    }
  });

  test('an empty pick list plans an empty line', () {
    expect(planLineFromPicks(const []).items, isEmpty);
  });
}

// P10.97: betweenRailFor surfaces the top related products to jump to from a scan list —
// hop-graph neighbours of the shown products, deduped, excluding the shown ones, capped at
// the budget. Lets "choose from N" pivot to a nearby option without restarting.

import 'package:buildsmart/features/card_keyboard/line_plan.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show divePoolBySku;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the between rail is capped, excludes the shown products, and is deduped', () {
    final shown = divePoolBySku.values.take(3).toList();
    final rail = betweenRailFor(shown);
    expect(rail.length, lessThanOrEqualTo(6));

    final railSkus = rail.map((p) => p.sku).toList();
    expect(railSkus.toSet().length, railSkus.length, reason: 'no duplicates');

    final shownSkus = {for (final p in shown) p.sku};
    for (final p in rail) {
      expect(shownSkus.contains(p.sku), isFalse, reason: 'excludes shown');
    }
  });

  test('the rail is non-empty for shown products (the hub guarantees neighbours)', () {
    expect(betweenRailFor(divePoolBySku.values.take(2).toList()), isNotEmpty);
  });

  test('the budget is honoured', () {
    final shown = divePoolBySku.values.take(2).toList();
    expect(betweenRailFor(shown, budget: 3).length, lessThanOrEqualTo(3));
  });
}

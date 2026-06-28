// P10.94: the temp chip (kLineColdTempC / kLineHotTempC) and the compliance checklist
// (autoCompliance) flow through planLineFromPicks to the install engine — the
// install_studio capability, absorbed. Every mode plans a valid line; compliance only ADDS
// safety items, never removes.

import 'package:buildsmart/features/card_keyboard/card_picks.dart';
import 'package:buildsmart/features/card_keyboard/line_plan.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show divePoolBySku;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final products = divePoolBySku.values.take(4).toList();
  final picks = [
    for (final p in products) CardPick(sku: p.sku, label: p.nameHe),
  ];

  test('cold, hot and compliant modes each plan a line with the picks', () {
    for (final plan in [
      planLineFromPicks(picks), // cold (the default is kLineColdTempC)
      planLineFromPicks(picks, tempC: kLineHotTempC),
      planLineFromPicks(picks, autoCompliance: true),
    ]) {
      final skus = plan.items.map((p) => p.sku).toSet();
      for (final p in products) {
        expect(skus.contains(p.sku), isTrue, reason: '${p.sku} missing');
      }
    }
  });

  test('autoCompliance only ADDS safety items — never shrinks the line', () {
    final base = planLineFromPicks(picks);
    final compliant = planLineFromPicks(picks, autoCompliance: true);
    expect(compliant.items.length, greaterThanOrEqualTo(base.items.length));
  });

  test('the hot mode is a distinct temperature from the cold default', () {
    expect(kLineHotTempC, greaterThan(kLineColdTempC));
  });
}

import 'package:buildsmart/features/card_keyboard/decisions.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('divePoolBySku indexes every pool sku', () {
    expect(divePoolBySku.length, kDivePool.length);
    for (final p in kDivePool) {
      expect(divePoolBySku[p.sku]?.sku, p.sku);
    }
  });

  test('kReachUniverse is the uncapped distinct-card fold', () {
    // Same fold as distinctCardCount -> equal by construction (content invariant).
    expect(kReachUniverse.length, distinctCardCount(kDivePool));
    expect(reachUniverseSize(), kReachUniverse.length);
    // A LOWER-BOUND band (not an equality pin) so ingestion drift cannot red-gate.
    expect(kReachUniverse.length, greaterThanOrEqualTo(kReachLowerBound));
    // No silent shrink to the 30-cap foot-gun (round-2/3 blocker).
    expect(kReachUniverse.length, greaterThan(kShowProductsCap));
    // Hot-water family (synthetic HW- skus) is included — kDivePool fixes the
    // kCatalogProducts omission.
    expect(kReachUniverse.any((p) => p.sku.startsWith('HW-')), isTrue);
  });

  test('collapseKeyOf gives one distinct key per reach-universe card', () {
    final keys = kReachUniverse.map(collapseKeyOf).toSet();
    expect(keys.length, kReachUniverse.length);
  });
}

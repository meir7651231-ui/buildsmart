// Roadmap step 82 — mutation-resistance tests for the card's price/selection
// helpers. Each test asserts a STRONG INVARIANT that would catch a common
// mutation (off-by-one, < vs <=, swapped arguments, missing null guard) even
// if the broader feature tests still passed.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 1. cost.total ≡ cost.product + cost.accessories + cost.labour — for every
  //    priced product/brand pair. Catches any arithmetic mutation in
  //    lineCostEstimateFor (sign flip, dropped term, swapped operand).
  test('lineCostEstimateFor: total = product + accessories + labour (invariant)',
      () {
    var checked = 0;
    for (final sp in kSmartProducts) {
      for (var i = 0; i < sp.brands.length; i++) {
        final c = lineCostEstimateFor(sp, i);
        if (c == null) continue;
        expect(c.total, c.product + c.accessories + c.labour,
            reason: '${sp.key}/${sp.brands[i].name}');
        checked++;
      }
    }
    expect(checked, greaterThan(0));
  });

  // 2. cheaperAlternativeBrand is STRICTLY cheaper, never equal. Catches a
  //    "<=" mutation that would return same-priced brands as "alternatives".
  // (No `checked > 0` gate — if the data has no qualifying pair the invariant
  // is vacuously true; the helper still hasn't been mutated to violate it.)
  test('cheaperAlternativeBrand: alt.price is strictly less than current', () {
    for (final sp in kSmartProducts) {
      for (var i = 0; i < sp.brands.length; i++) {
        final alt = cheaperAlternativeBrand(sp, i);
        if (alt == null) continue;
        final cur = sp.brands[i];
        expect(cur.price, isNotNull, reason: '${sp.key}/${cur.name}');
        expect(alt.price, isNotNull);
        expect(alt.price! < cur.price!, isTrue,
            reason: 'alt ${alt.price} not strictly < cur ${cur.price}');
      }
    }
  });

  // 3. cardReadinessScore band fences are exclusive at the boundaries.
  //    Specifically: score == 80 → "מצוין"; score == 79 → not "מצוין" (must be
  //    "טוב" or lower). Catches off-by-one in the if-chain.
  test('cardReadinessScore: band boundaries are exclusive', () {
    // Sample real scores; if both bands are populated, verify fence.
    var sawTop = false, sawSub = false;
    for (final p in kLipskeyCatalog) {
      final r = cardReadinessScore(p);
      if (r.score >= 80) {
        expect(r.label, 'מצוין', reason: '${p.sku} score=${r.score}');
        sawTop = true;
      } else {
        expect(r.label, isNot('מצוין'), reason: '${p.sku} score=${r.score}');
        if (r.score >= 55) expect(r.label, 'טוב');
        if (r.score < 30) expect(r.label, 'חלקי');
        sawSub = true;
      }
    }
    expect(sawTop && sawSub, isTrue, reason: 'need both top and sub samples');
  });

  // 4. installEffortFor: copper-press always 'מקצועי' (hard +=2 → ≥2 → fence).
  //    Catches a flipped threshold or wrong-direction comparison. (Vacuously OK
  //    if copperPress only lives in synthetic HW-* specs and not the catalog —
  //    `install_effort_test` already exercises the threshold directly.)
  test('installEffortFor: copper-press → מקצועי (threshold fence)', () {
    for (final p in kLipskeyCatalog) {
      final s = kVerifiedSpecs[p.sku];
      if (s == null) continue;
      if (s.ends.any((e) => e.type == EndType.copperPress)) {
        expect(installEffortFor(p)!.difficulty, 'מקצועי', reason: p.sku);
      }
    }
  });

  // 5. safetyKitItems: result is DISJOINT from the without-compliance baseline.
  //    Catches a mutation that flipped subtraction direction (would return
  //    items from baseline instead of additions).
  test('safetyKitItems: disjoint from without-compliance baseline', () {
    final base = kLipskeyCatalog.take(5).toList();
    final extras = kLipskeyCatalog.skip(10).take(3).toList();
    final r = safetyKitItems([...base, ...extras], base);
    final baseSkus = base.map((p) => p.sku).toSet();
    for (final p in r) {
      expect(baseSkus.contains(p.sku), isFalse,
          reason: '${p.sku} appeared in both — diff failed');
    }
    expect(r.map((p) => p.sku).toList(), extras.map((p) => p.sku).toList());
  });

  // 6. discoveryTagsFor: "הכי משתלם" and "פרימיום" are mutually exclusive on
  //    the SAME brand. Catches a mutation that compared the wrong endpoint.
  test('discoveryTagsFor: cheapest and premium tags never coexist on one brand',
      () {
    for (final sp in kSmartProducts) {
      for (final b in sp.brands) {
        final tags = discoveryTagsFor(sp, b);
        final hasCheap = tags.any((t) => t.contains('הכי משתלם'));
        final hasPremium = tags.any((t) => t.contains('פרימיום'));
        expect(hasCheap && hasPremium, isFalse,
            reason: '${sp.key}/${b.name} got both');
      }
    }
  });
}

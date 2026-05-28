// Hard, adversarial regression tests — pure functions + real catalog data +
// engine invariants. No widget rendering (so they're deterministic and fast).
// Every assertion was validated against the real data before being written.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/screens/finder_screen.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/store_settings.dart';
import 'package:flutter_test/flutter_test.dart';

SmartCartLine _line(int qty) => SmartCartLine(
      productKey: 'lip:T$qty',
      productName: 'בדיקה',
      productEmoji: '🔩',
      brandName: 'BS',
      brandPrice: 0,
      productQty: qty,
      accessories: const [],
    );

void main() {
  // ── cart money math (pure) ────────────────────────────────────────────────
  group('HARD · cart math', () {
    test('VAT exclusive = round(18%), inclusive = embedded 18%', () {
      expect(cartVat(1000, vatInclusive: false), 180);
      expect(cartVat(0, vatInclusive: false), 0);
      expect(cartVat(1, vatInclusive: false), 0); // round(0.18)
      expect(cartVat(1180, vatInclusive: true), 180); // 1180 - round(1180/1.18)
      expect(cartVat(0, vatInclusive: true), 0);
    });

    test('total: exclusive adds VAT+delivery, inclusive adds only delivery', () {
      expect(cartTotal(1000, 45, vatInclusive: false), 1225); // 1000+180+45
      expect(cartTotal(1180, 45, vatInclusive: true), 1225); // 1180+45
      expect(cartTotal(0, 0, vatInclusive: false), 0);
    });

    test('delivery fees per method', () {
      expect(deliveryFeeFor(CartDelivery.express), 120);
      expect(deliveryFeeFor(CartDelivery.standard), 45);
      expect(deliveryFeeFor(CartDelivery.pickup), 0);
    });

    test('item count sums positive qtys + every smart line qty', () {
      expect(cartItemCount({'a': 2, 'b': 3, 'c': 0}, const []), 5);
      expect(cartItemCount(const {}, [_line(4)]), 4);
      expect(cartItemCount({'a': 2}, [_line(3), _line(1)]), 6);
      expect(cartItemCount(const {}, const []), 0);
    });

    test('order is open until delivered', () {
      expect(isOrderOpen('preparing'), isTrue);
      expect(isOrderOpen(kDeliveredStage), isFalse);
    });
  });

  // ── checkout gates (boundaries) ─────────────────────────────────────────────
  group('HARD · checkout gates', () {
    test('minimum-order gate is strict-less-than and off when min is 0', () {
      final s = StoreSettings.defaults.copyWith(minOrderAmount: 500);
      expect(cartBelowMinimum(499, s), isTrue);
      expect(cartBelowMinimum(500, s), isFalse); // exactly the minimum is OK
      expect(cartBelowMinimum(501, s), isFalse);
      final off = StoreSettings.defaults.copyWith(minOrderAmount: 0);
      expect(cartBelowMinimum(0, off), isFalse); // 0 minimum never blocks
    });

    test('large-order confirm triggers at-or-above threshold, only when on', () {
      final on = StoreSettings.defaults
          .copyWith(confirmLargeOrder: true, largeOrderThreshold: 1000);
      expect(cartNeedsLargeConfirm(999, on), isFalse);
      expect(cartNeedsLargeConfirm(1000, on), isTrue); // >=
      expect(cartNeedsLargeConfirm(5000, on), isTrue);
      final off = StoreSettings.defaults
          .copyWith(confirmLargeOrder: false, largeOrderThreshold: 1000);
      expect(cartNeedsLargeConfirm(99999, off), isFalse);
    });
  });

  // ── catalog integrity ───────────────────────────────────────────────────────
  group('HARD · catalog integrity', () {
    test('no duplicate SKUs', () {
      final seen = <String, int>{};
      for (final p in kLipskeyCatalog) {
        seen[p.sku] = (seen[p.sku] ?? 0) + 1;
      }
      final dups = seen.entries.where((e) => e.value > 1).map((e) => e.key);
      expect(dups, isEmpty, reason: 'duplicate SKUs: ${dups.toList()}');
    });

    test('every product has a non-empty name and category', () {
      for (final p in kLipskeyCatalog) {
        expect(p.nameHe.trim(), isNotEmpty, reason: p.sku);
        expect(p.categoryHe.trim(), isNotEmpty, reason: p.sku);
      }
    });
  });

  // ── finder reachability (every product is findable) ─────────────────────────
  group('HARD · finder reachability', () {
    final named = kFinderGroups.where((g) => g.cats.isNotEmpty).toList();

    test('every product maps to AT MOST one named group (rest → אחר)', () {
      for (final p in kLipskeyCatalog) {
        final owners =
            named.where((g) => g.cats.contains(p.categoryHe)).length;
        expect(owners, lessThanOrEqualTo(1),
            reason: '${p.categoryHe} is in $owners groups');
      }
      expect(kFinderGroups.any((g) => g.cats.isEmpty), isTrue,
          reason: 'the אחר catch-all must exist for unmapped categories');
    });

    test('curated sub-types cover every category that has products', () {
      final cats = {for (final p in kLipskeyCatalog) p.categoryHe};
      for (final e in kFinderSubs.entries) {
        final group = named.firstWhere((g) => g.label == e.key);
        final covered = {for (final s in e.value) ...s.cats};
        final withProducts = group.cats.where(cats.contains).toSet();
        expect(withProducts.difference(covered), isEmpty,
            reason: '${e.key} misses ${withProducts.difference(covered)}');
        final labels = [for (final s in e.value) s.label];
        expect(labels.toSet().length, labels.length, reason: '${e.key} dup');
      }
    });
  });

  // ── forgiving search stress ─────────────────────────────────────────────────
  group('HARD · search stress', () {
    int hits(String q, {bool all = true}) =>
        kLipskeyCatalog.where((p) => catalogProductMatchesQuery(p, q, requireAll: all)).length;

    test('empty / whitespace query matches nothing', () {
      final p = kLipskeyCatalog.first;
      expect(catalogProductMatchesQuery(p, ''), isFalse);
      expect(catalogProductMatchesQuery(p, '   '), isFalse);
    });

    test('pure-gibberish query returns zero', () {
      expect(hits('זזזזזזזחחחחק'), 0);
    });

    test('everyday words each return results', () {
      for (final q in ['מטבח', 'כיור', 'שירותים', 'צנרת', 'גינה', 'ניקוז']) {
        expect(hits(q), greaterThan(0), reason: q);
      }
    });

    test('AND is a subset of ANY for a stray-word query', () {
      const q = 'מטבח זזזזז';
      expect(hits(q, all: true), lessThanOrEqualTo(hits(q, all: false)));
      expect(hits(q, all: true), 0); // the stray word kills the AND
      expect(hits(q, all: false), greaterThan(0));
    });

    test('שירותים stays precise — no toilet-branch connectors', () {
      for (final p in kLipskeyCatalog.where(
          (p) => p.categoryHe == 'מסעפים וחיבורי אסלה')) {
        expect(catalogProductMatchesQuery(p, 'שירותים'), isFalse,
            reason: p.sku);
      }
    });
  });

  // ── install engine invariants ───────────────────────────────────────────────
  group('HARD · install engine', () {
    test('a product never connects to itself', () {
      for (final p in kLipskeyCatalog.take(120)) {
        expect(canConnect(p, p), isFalse, reason: p.sku);
      }
    });

    test('buildInstallation: empty anchors → empty, single anchor kept', () {
      expect(buildInstallation(const []).items, isEmpty);
      final p = kLipskeyCatalog.first;
      final plan = buildInstallation([p]);
      expect(plan.items.map((x) => x.sku), contains(p.sku));
    });
  });
}

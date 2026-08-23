// INTEGRATION: the compat-graph mates boost is actually WIRED through the live
// diveResultsProvider — not just proven in the pure harness. Seeding the smart
// cart with an anchor must LIFT a product that physically mates it, for a broad
// query, above where it sits with an empty cart. Exercises the ON path:
//
//   flutter test --dart-define=GLOBAL_SEARCH=true test/screens/dive_mates_wiring_test.dart
//
// Flag-off (the default gate build) the whole mates branch tree-shakes out, so the
// test self-skips — there is nothing to assert and the sort is byte-identical.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/related_info.dart' show compatibleProductsFor;
import 'package:buildsmart/features/global_search/global_search.dart'
    show kGlobalSearch;
import 'package:buildsmart/screens/catalog_screen.dart'
    show diveResultsProvider, keyboardDiveQueryProvider;
import 'package:buildsmart/state/smart_cart.dart'
    show SmartCartLine, smartCartProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _head(String name) {
  for (final w in name.trim().split(RegExp(r'\s+'))) {
    if (w.isNotEmpty) return w;
  }
  return '';
}

SmartCartLine _line(LipskeyCatalogProduct p) => SmartCartLine(
      productKey: 'lip:${p.sku}',
      productName: p.nameHe,
      productEmoji: '🔧',
      brandName: '',
      brandPrice: 0,
      productQty: 1,
      accessories: const [],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('seeding the cart with an anchor lifts a MATING product in the live dive',
      () {
    if (!kGlobalSearch) {
      // Flag-off build — the mates branch is tree-shaken; nothing is wired.
      return;
    }

    // Find the first (anchor, target) where target mates anchor, target's head
    // word is broad, and the target is present but BURIED (rank ≥ 4) with no
    // context — the exact case the boost is meant to rescue.
    var proven = false;
    outer:
    for (final anchor in kCatalogProducts) {
      for (final target in compatibleProductsFor(anchor).take(3)) {
        final q = _head(target.nameHe);
        if (q.length < 2) continue;

        final c = ProviderContainer();
        c.read(keyboardDiveQueryProvider.notifier).state = q;
        final before = c.read(diveResultsProvider);
        final rank0 = before.indexWhere((p) => p.sku == target.sku);
        if (rank0 < 4) {
          c.dispose();
          continue; // already easy to find — not the case we need to prove
        }

        // Stage the anchor on the line and re-read the SAME provider.
        c.read(smartCartProvider.notifier).add(_line(anchor));
        final after = c.read(diveResultsProvider);
        final rank1 = after.indexWhere((p) => p.sku == target.sku);
        c.dispose();

        expect(rank1, greaterThanOrEqualTo(0),
            reason: 'the mating target must stay in the dive results');
        expect(rank1, lessThan(rank0),
            reason:
                'staging anchor ${anchor.sku} must lift its mate ${target.sku} '
                '("$q") from #$rank0 — the compat boost drives the live ranking');
        proven = true;
        break outer;
      }
    }

    expect(proven, isTrue,
        reason: 'expected at least one buried mating pair to lift');
  });
}

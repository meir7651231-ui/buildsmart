// Pins the per-SKU memoisation added to `compatibleProductsFor` (#perf-memo
// wave). The function is pure over the COMPILE-TIME-const catalog (kVerifiedSpecs
// + the memoised `_skuIndex`), so its result is cached per SKU. The black-box
// proof the cache is LIVE: a second call returns the *same list instance* — a
// freshly built `out` list is never `identical` across calls unless it was
// stored and replayed. Contents must also stay byte-equivalent (same elements,
// same order) so the optimisation never changes what the user sees. If the cache
// store is dropped, `identical(first, second)` goes red.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compatibleProductsFor memoises per SKU — same instance on re-call', () {
    // A plain Lipskey product with a non-empty mate list (no polyroll setup
    // needed — mirrors line_fit_test / build_line_bom_test anchoring).
    final p =
        kLipskeyCatalog.firstWhere((x) => compatibleProductsFor(x).isNotEmpty);
    final first = compatibleProductsFor(p);
    final second = compatibleProductsFor(p);

    expect(identical(first, second), isTrue,
        reason: 'the per-SKU cache replays the SAME list instance (memo live)');
    expect(second, equals(first),
        reason: 'memoised result is byte-equivalent to the first computation');
    expect(second.map((e) => e.sku), isNot(contains(p.sku)),
        reason: 'memoisation never changes the contract (no self-mate)');
  });

  test('the spec-less (empty) result is memoised to the canonical const []', () {
    // 220943 ("seat") has no verified spec → zero mates (same anchor the
    // existing compat_index_test uses for the empty path).
    final seat = kLipskeyCatalog.firstWhere((p) => p.sku == '220943');
    final a = compatibleProductsFor(seat);
    final b = compatibleProductsFor(seat);

    expect(a, isEmpty);
    expect(identical(a, b), isTrue,
        reason: 'spec-less SKUs replay the cached const [] too');
  });
}

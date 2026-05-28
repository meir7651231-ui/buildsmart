// Coverage audit for the compatibility engine: how many catalog products
// have a verified connection spec, and which categories are under-covered.
// This tells us where to invest next to make תאימות more complete.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compat coverage by category', () {
    final total = kLipskeyCatalog.length;
    final withSpec =
        kLipskeyCatalog.where((p) => kVerifiedSpecs.containsKey(p.sku)).length;
    print('TOTAL catalog products: $total');
    print('WITH verified spec:     $withSpec  '
        '(${(withSpec * 100 / total).toStringAsFixed(0)}%)');
    print('WITHOUT spec:           ${total - withSpec}');
    print('');

    // Per-category coverage
    final byCat = <String, ({int total, int covered})>{};
    for (final p in kLipskeyCatalog) {
      final cur = byCat[p.categoryHe] ?? (total: 0, covered: 0);
      byCat[p.categoryHe] = (
        total: cur.total + 1,
        covered: cur.covered +
            (kVerifiedSpecs.containsKey(p.sku) ? 1 : 0),
      );
    }
    // Sort by most-uncovered first (biggest gap)
    final sorted = byCat.entries.toList()
      ..sort((a, b) => (b.value.total - b.value.covered)
          .compareTo(a.value.total - a.value.covered));
    print('Categories with the biggest coverage gap:');
    for (final e in sorted.take(20)) {
      final gap = e.value.total - e.value.covered;
      if (gap == 0) continue;
      print('  ${e.key.padRight(28)} '
          '${e.value.covered}/${e.value.total} covered  '
          '(gap: $gap)');
    }
    print('');
    final fullyCovered =
        sorted.where((e) => e.value.covered == e.value.total).length;
    print('Fully-covered categories: $fullyCovered / ${sorted.length}');
  });

  // ── The gate: every REAL flow-connector must carry a verified spec ─────────
  // Headline coverage (~86%) is diluted by non-connector accessories. Measured
  // over real connectors only (kNonConnectorCategories + kSpecExemptSkus
  // excluded), coverage must be 100% — and any NEW connector added without a
  // spec turns this red, forcing an explicit classify-or-spec decision.
  test('connector coverage is 100% (real flow-connectors only)', () {
    final connectors =
        kLipskeyCatalog.where(needsConnectionSpec).toList();
    final missing = connectors
        .where((p) => !kVerifiedSpecs.containsKey(p.sku))
        .toList();

    print('Real connectors: ${connectors.length} / ${kLipskeyCatalog.length} '
        'catalog products');
    print('Connector coverage: '
        '${connectors.length - missing.length}/${connectors.length}');
    if (missing.isNotEmpty) {
      print('\nConnectors WITHOUT a spec (classify or spec them):');
      for (final p in missing.take(20)) {
        print('  ${p.sku.padRight(12)} ${p.categoryHe} — ${p.nameHe}');
      }
    }
    expect(missing, isEmpty,
        reason: '${missing.length} flow-connectors have no VerifiedSpec — '
            'add a spec, or exempt them via kNonConnectorCategories / '
            'kSpecExemptSkus if they are not connectors');
  });

  test('non-connector classification stays honest', () {
    // (a) No product in a non-connector category was given a spec by mistake.
    final miscategorised = kLipskeyCatalog
        .where((p) =>
            kNonConnectorCategories.contains(p.categoryHe) &&
            kVerifiedSpecs.containsKey(p.sku))
        .map((p) => '${p.sku} (${p.categoryHe})')
        .toList();
    expect(miscategorised, isEmpty,
        reason: 'specced products sit in a non-connector category: '
            '$miscategorised');

    // (b) Every exempt SKU is a real catalog SKU (no typos / stale entries)…
    final skus = {for (final p in kLipskeyCatalog) p.sku};
    final unknown = kSpecExemptSkus.where((s) => !skus.contains(s)).toList();
    expect(unknown, isEmpty, reason: 'exempt SKUs not in catalog: $unknown');

    // …and is genuinely without a spec (otherwise drop it from the exempt set).
    final stale =
        kSpecExemptSkus.where(kVerifiedSpecs.containsKey).toList();
    expect(stale, isEmpty,
        reason: 'exempt SKUs that actually HAVE a spec (remove them): $stale');
  });
}

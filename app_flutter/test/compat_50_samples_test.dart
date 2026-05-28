// Audit the תאימות logic on 50 diverse catalog products. For each sample
// product, pull the full compat list via [compatibleProductsFor] and verify
// every hit really mates with the source. Failures are printed so they can
// be inspected.
//
// Verification rule (mirrors related_info._reallyMates):
//   • directMatesWith — thread/press/drain joint, always real
//   • pipeSharedWith  — counts only when exactly one of {source, other} is a
//                       pipe-product (productType ∈ {צינור, צנרת, גמיש, מאריך})
// A hit is INVALID when none of its end-pairs satisfy either rule.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

bool _isPipe(LipskeyCatalogProduct p) {
  final t = p.productType ?? '';
  return t == 'צינור' || t == 'צנרת' || t == 'גמיש' || t == 'מאריך';
}

({bool ok, String reason}) _verifyHit(LipskeyCatalogProduct src, VerifiedSpec s,
    LipskeyCatalogProduct oth, VerifiedSpec o) {
  final srcIsPipe = _isPipe(src);
  final othIsPipe = _isPipe(oth);
  for (final eA in s.ends) {
    for (final eB in o.ends) {
      if (eA.directMatesWith(eB)) {
        return (
          ok: true,
          reason: 'direct ${eA.type}|${eA.size} ↔ ${eB.type}|${eB.size}'
        );
      }
      if (eA.pipeSharedWith(eB) && srcIsPipe != othIsPipe) {
        return (
          ok: true,
          reason:
              'pipe-shared ${eA.type}|${eA.size} (pipe=${srcIsPipe ? "src" : "other"})'
        );
      }
    }
  }
  return (ok: false, reason: 'no matching end pair found');
}

void main() {
  test('50 samples — every compat hit is a real physical mate', () {
    // Sample 50 catalog SKUs with verified specs, spread by category for
    // diversity. Use a deterministic step so the sample is reproducible.
    final specced = kLipskeyCatalog
        .where((p) => kVerifiedSpecs.containsKey(p.sku))
        .toList();
    expect(specced.length, greaterThan(50));

    final samples = <LipskeyCatalogProduct>[];
    final step = specced.length ~/ 50;
    for (var i = 0; i < specced.length && samples.length < 50; i += step) {
      samples.add(specced[i]);
    }

    var totalHits = 0;
    var totalFails = 0;
    final failures = <String>[];

    for (final src in samples) {
      final spec = kVerifiedSpecs[src.sku]!;
      final hits = compatibleProductsFor(src);
      totalHits += hits.length;

      for (final h in hits) {
        final hSpec = kVerifiedSpecs[h.sku]!;
        final v = _verifyHit(src, spec, h, hSpec);
        if (!v.ok) {
          totalFails++;
          failures.add(
              '  ❌ ${src.sku} (${src.productType}) ↔ ${h.sku} (${h.productType}) — ${v.reason}');
        }
      }

      // print a short row per sample
      final first3 =
          hits.take(3).map((h) => '${h.sku}:${h.productType ?? "?"}').join(' · ');
      print(
          '${src.sku.padRight(12)} ${(src.productType ?? "?").padRight(8)} hits=${hits.length.toString().padLeft(3)}   top: $first3');
    }

    print('\nTOTAL hits across 50 samples: $totalHits');
    print('INVALID hits: $totalFails');
    if (failures.isNotEmpty) {
      print('\nFailures:');
      for (final f in failures.take(20)) print(f);
    }
    expect(totalFails, 0,
        reason: 'Found $totalFails compat hits that do not actually mate');
  });
}

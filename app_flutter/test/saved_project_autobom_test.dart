// Pins the #autobom glue (install_studio _loadProject→_assemble): a SavedProject's
// anchorSkus resolve back to catalog products via kLipskeyCatalog (the exact
// resolution _loadProject does), the `found.length >= 2` gate decides build-vs-
// stay-on-canvas, and the resolved anchors produce a non-empty InstallationPlan
// containing both anchors. The engine half is pinned elsewhere
// (install_plan_coverage_test); this pins the saved-job → catalog resolution glue.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:buildsmart/state/saved_projects.dart';
import 'package:flutter_test/flutter_test.dart';

// Mirrors install_studio _loadProject's anchor resolution verbatim.
List<LipskeyCatalogProduct> _resolve(List<String> skus) {
  final found = <LipskeyCatalogProduct>[];
  for (final sku in skus) {
    final hits = kLipskeyCatalog.where((q) => q.sku == sku);
    if (hits.isNotEmpty) found.add(hits.first);
  }
  return found;
}

SavedProject _job(List<String> skus) => SavedProject(
      id: 't',
      name: 'בדיקה',
      anchorSkus: skus,
      tempC: 20,
      accessories: const {},
      savedAt: DateTime(2024),
    );

void main() {
  test('2-anchor saved job: resolves + the >=2 gate passes + builds a real BOM',
      () {
    // The proven-connectable pair from install_plan_coverage_test.
    final p = _job(const ['779096G', '77778071']);
    final anchors = _resolve(p.anchorSkus);

    expect(anchors.length, 2,
        reason: 'both saved SKUs resolve → found.length >= 2 → auto-BOM fires');
    final plan =
        buildInstallation(anchors, tempC: p.tempC, autoCompliance: true);
    expect(plan.items, isNotEmpty, reason: 'auto-BOM produces a real bill');
    expect(plan.items.map((x) => x.sku), containsAll(p.anchorSkus),
        reason: 'the BOM contains both anchors of the job');
  });

  test('single-anchor saved job: gate is false (stays on canvas, no auto-BOM)',
      () {
    final anchors = _resolve(const ['779096G']);
    expect(anchors.length, 1,
        reason: 'one anchor → found.length < 2 → _loadProject does NOT _assemble');
  });

  test('a saved SKU absent from the catalog is silently dropped (glue is safe)',
      () {
    final anchors = _resolve(const ['779096G', 'GONE-SKU-999']);
    expect(anchors.length, 1,
        reason: 'an unresolvable SKU shrinks `found` without throwing');
  });
}

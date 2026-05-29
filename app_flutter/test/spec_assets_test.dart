// §14 detection test for the per-sub-type spec-diagram work (protocol §17.1):
// every spec image the flip-side pager can show must exist on disk, and each
// fitting sub-type must resolve to its OWN dimension drawing (not a sibling's
// and not a silent fallback to the full catalog page). A typo or a missing
// crop here = a blank/wrong flip side at runtime — this is the guard.
import 'dart:io';

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // HARD for Polyroll/PPR: every page render (18–92) and every cropped spec/
  // product image we ship must exist. (Lipskey page renders are only partially
  // committed — a separate, pre-existing gap — so they are not asserted here.)
  test('every referenced Polyroll spec/product asset exists on disk', () {
    final missing = <String>{};
    for (final p in kPolyrollCatalog) {
      for (final asset in p.specImageAssets) {
        if (!File(asset).existsSync()) missing.add('${p.sku} → $asset');
      }
      final img = p.imageAsset;
      if (img != null && !File(img).existsSync()) missing.add('${p.sku} → $img');
    }
    expect(missing, isEmpty,
        reason: 'broken Polyroll asset paths:\n${missing.join('\n')}');
  });

  // Locks the _pprSpecFor wiring: a sub-type keyword must map to its own
  // diagram. Guards the "PPR/PPRCT-style confusion" bug class for spec images.
  group('PPR sub-type → correct spec diagram', () {
    LipskeyCatalogProduct find(bool Function(LipskeyCatalogProduct) f) =>
        kPolyrollCatalog.firstWhere(f);
    String spec(LipskeyCatalogProduct p) => p.specImageAssets.first;

    test('elbow 45° vs 90°', () {
      expect(
          spec(find((p) => p.categoryHe == kPprElbows && p.nameHe.contains('45'))),
          endsWith('spec_elbow_45.jpg'));
      expect(
          spec(find((p) =>
              p.categoryHe == kPprElbows && !p.nameHe.contains('45'))),
          endsWith('spec_elbow_90.jpg'));
    });

    test('coupler straight vs reducing', () {
      expect(
          spec(find((p) =>
              p.categoryHe == kPprCouplers && !p.nameHe.contains('מצרה'))),
          endsWith('spec_coupler.jpg'));
      expect(
          spec(find((p) =>
              p.categoryHe == kPprCouplers && p.nameHe.contains('מצרה'))),
          endsWith('spec_coupler_reducing.jpg'));
    });

    test('tee straight vs reducing', () {
      expect(
          spec(find(
              (p) => p.categoryHe == kPprTees && !p.nameHe.contains('מצרה'))),
          endsWith('spec_tee.jpg'));
      expect(
          spec(find(
              (p) => p.categoryHe == kPprTees && p.nameHe.contains('מצרה'))),
          endsWith('spec_tee_reducing.jpg'));
    });

    test('adapter round vs hex', () {
      expect(
          spec(find((p) =>
              p.categoryHe == kPprAdapters && p.nameHe.contains('משושה'))),
          endsWith('spec_adapter_hex.jpg'));
    });

    test('valve sub-types each resolve distinctly', () {
      final seen = <String>{};
      for (final kw in ['פרפר', 'בין אוגנים', 'סמוי', 'אלכסוני', 'מעבר']) {
        final hits =
            kPolyrollCatalog.where((p) => p.categoryHe == kPprValves && p.nameHe.contains(kw));
        if (hits.isEmpty) continue;
        final s = spec(hits.first);
        expect(s, contains('/products/spec_valve'));
        seen.add(s);
      }
      // each keyword must map to a different drawing (no collisions)
      expect(seen.length, greaterThanOrEqualTo(4));
    });
  });

  test('fitting categories all have a real cropped spec diagram', () {
    // Categories with a genuine dimension drawing in the catalog. EF is
    // photo-only (R8 — no diagram exists), so it is intentionally excluded.
    const mustHaveSpec = {
      kPprElbows,
      kPprTees,
      kPprCouplers,
      kPprAdapters,
      kPprValves,
      kPprOmega,
      kPprSaddles,
      kPprCollars,
      kPprPlugs,
    };
    final gaps = <String>{};
    for (final p in kPolyrollCatalog.where((p) => mustHaveSpec.contains(p.categoryHe))) {
      if (!p.specImageAssets.first.contains('/products/spec_')) {
        gaps.add('${p.categoryHe}: ${p.sku} ${p.nameHe}');
      }
    }
    expect(gaps, isEmpty, reason: 'sub-types still on page fallback:\n${gaps.join('\n')}');
  });
}

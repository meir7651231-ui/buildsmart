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

  // No orphan product photos: every ppr_pNN_* file we ship must be referenced
  // by at least one product. Catches dead weight left after re-mapping (§16).
  test('no orphan Polyroll product images on disk', () {
    final used = <String>{};
    for (final p in kPolyrollCatalog) {
      // Front-side images (pager handles the 1/N) AND spec-side pager.
      for (final a in p.imageAssets) used.add(a.split('/').last);
      for (final s in p.specImageAssets) used.add(s.split('/').last);
    }
    final onDisk = Directory('assets/polyroll/products')
        .listSync()
        .map((e) => e.path.split('/').last)
        .where((f) =>
            (f.startsWith('ppr_') || f.startsWith('pipe_')) && f.endsWith('.jpg'))
        .toSet();
    final orphans = onDisk.difference(used).toList()..sort();
    expect(orphans, isEmpty, reason: 'unused photos:\n${orphans.join('\n')}');
  });

  // §14 detection test for the merged-sub-types bug class (the one that bit
  // p22/p30/p92/p25/p26/p27/p28/p32/p72): a page with ≥2 ppr_pNN_* photos on
  // disk represents ≥2 distinct sub-types in the catalog, so the products on
  // that page must resolve to ≥2 distinct images. If they all collapse to one,
  // the catalog has merged sub-types that the photos distinguish → silent
  // "wrong product photo" at runtime.
  test('multi-photo pages must split: products resolve to all photos', () {
    final filesByPage = <int, Set<String>>{};
    final re = RegExp(r'^ppr_p(\d+)_[a-z]\.jpg$');
    for (final e in Directory('assets/polyroll/products').listSync()) {
      final f = e.path.split('/').last;
      final m = re.firstMatch(f);
      if (m != null) {
        filesByPage.putIfAbsent(int.parse(m.group(1)!), () => {}).add(f);
      }
    }
    final usedByPage = <int, Set<String>>{};
    for (final p in kPolyrollCatalog) {
      // Count every photo wired to the product — front pager (imageAssets)
      // and spec pager (specImageAssets).
      final refs = <String>[
        ...p.imageAssets.map((a) => a.split('/').last),
        ...p.specImageAssets.map((a) => a.split('/').last),
      ];
      for (final f in refs) {
        if (re.hasMatch(f)) {
          usedByPage.putIfAbsent(p.page, () => {}).add(f);
        }
      }
    }
    final gaps = <String>[];
    for (final e in filesByPage.entries) {
      if (e.value.length < 2) continue; // single-photo page — nothing to split
      final used = usedByPage[e.key] ?? const <String>{};
      if (used.length < e.value.length) {
        final missing = e.value.difference(used).toList()..sort();
        gaps.add('p${e.key}: ${e.value.length} photos on disk, '
            '${used.length} used → unused: ${missing.join(", ")}');
      }
    }
    expect(gaps, isEmpty,
        reason: 'merged sub-types — distinct catalog photos are not being '
            'routed to (page has photos but products collapse to fewer):\n${gaps.join('\n')}');
  });

  // §18.1 — confirmed PPRCT SKU patterns (catalog evidence: P-CT/P-HLCT/-FCT/-FRCT
  // mfr codes OR "PP-R-CT" branding visible on photo OR explicit "HELIROMA"
  // header). Any matching product MUST carry "PPRCT" in nameHe.
  // Confirmed pages:
  //   p48–p52 — brass-threaded fittings (SKU 6602080/120/090/320/330 prefix)
  //   p53/p54 small sizes only (200,250,260,320,330 endings) — MIX pages
  //   p86–p87 — PPRCT faser pipes for AC (SKU 6091*, 600130*, 600140*)
  // Excluded pending verification: 6604/6605/6702/6706/6006/6005/6701.
  test('SKU PPRCT pattern ⇒ name must say PPRCT', () {
    bool isConfirmedPprct(String sku) {
      if (RegExp(r'^(6091|6001301|6001302|6001403|6001404)').hasMatch(sku)) {
        return true; // p86/p87 PPRCT pipes
      }
      if (RegExp(r'^6602(080|090|120|320|330)').hasMatch(sku)) return true; // p48-52
      if (RegExp(r'^660234[0-9]?(200|250|260|320|330)$').hasMatch(sku)) {
        return true; // p53 small
      }
      if (RegExp(r'^660235[0-9]?(200|250|260|320|330)$').hasMatch(sku)) {
        return true; // p54 small
      }
      if (RegExp(r'^670234[0-9]?(200|250|260|320|330)$').hasMatch(sku)) {
        return true; // p55 small (mfr P-HLCT*)
      }
      return false;
    }
    final misnamed = <String>[];
    for (final p in kPolyrollCatalog) {
      if (!isConfirmedPprct(p.sku)) continue;
      if (!p.nameHe.contains('PPRCT')) {
        misnamed.add('${p.sku} p${p.page}: ${p.nameHe}');
      }
    }
    expect(misnamed, isEmpty,
        reason: 'SKU confirmed PPRCT but name says PPR:\n${misnamed.join('\n')}');
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

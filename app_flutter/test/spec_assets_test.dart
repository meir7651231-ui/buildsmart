// §14 detection test for the per-sub-type spec-diagram work (protocol §17.1):
// every spec image the flip-side pager can show must exist on disk, and each
// fitting sub-type must resolve to its OWN dimension drawing (not a sibling's
// and not a silent fallback to the full catalog page). A typo or a missing
// crop here = a blank/wrong flip side at runtime — this is the guard.
import 'dart:io';

import 'package:buildsmart/data/chip_hierarchy.dart';
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

  // §14 / §21 — brass-threaded PPRCT/PPR pages (48-60) carry multi-level
  // catalog headers like "ברך ריתוך/הברגה לנקודת מים - תבריג פנימי".
  // If our nameHe stops at "ברך ... הברגה {size}" the chip breadcrumb collapses
  // to 2 chips and loses the welding method ("ריתוך") and thread direction
  // ("תבריג פנימי/חיצוני"). This guard asserts at least 3 path chips
  // (connection + something + size) for every product on those pages.
  test('brass-threaded pages keep ≥3 chip-path levels (§21 verbatim)', () {
    final affected = <int>{
      48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 59, 60,
    };
    final thin = <String>[];
    for (final p in kPolyrollCatalog) {
      if (!affected.contains(p.page)) continue;
      final path = parseChips(p.nameHe).path;
      if (path.length < 3) thin.add('${p.sku} p${p.page} (${path.length}): ${p.nameHe}');
    }
    expect(thin, isEmpty,
        reason: 'breadcrumb collapsed — name is missing verbatim qualifiers '
            'from the catalog header:\n${thin.take(8).join('\n')}');
  });

  // §14 / §21 — chip hierarchy parser must classify every nameHe token.
  // A leftover token = a missing vocabulary entry (must be added to one of
  // kChipLevel{1..4} sets). The parser is the foundation of the new
  // external-card breadcrumb chips — if it fails here, the card breaks.
  test('chip hierarchy parser: no leftover tokens, every product has a type', () {
    final leftovers = <String, int>{};
    final noType = <String>[];
    for (final p in kPolyrollCatalog) {
      final c = parseChips(p.nameHe);
      if (c.type == null) noType.add('${p.sku}: ${p.nameHe}');
      for (final l in c.leftover) {
        leftovers.update(l, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    expect(noType, isEmpty,
        reason: 'products missing a hierarchy type:\n${noType.take(5).join('\n')}');
    expect(leftovers, isEmpty,
        reason: 'unclassified tokens — add to chip_hierarchy.dart vocab:\n'
            '${leftovers.entries.map((e) => "${e.value} | ${e.key}").join("\n")}');
  });

  // §14 — embedded mfr-code in nameHe (e.g. "צווארון PPR פנים P-PBRIDA160H").
  // Manufacturer codes belong in nameEn / dims['מק"ט יצרן'], never in nameHe.
  test('nameHe contains no embedded mfr code', () {
    final bad = <String>[];
    final pat = RegExp(r'\bP-[A-Z]{2,}\d|\bP-\d{3,}|\bES\d{4,}|\bDMTR\d');
    for (final p in kPolyrollCatalog) {
      if (pat.hasMatch(p.nameHe)) bad.add('${p.sku}: ${p.nameHe}');
    }
    expect(bad, isEmpty,
        reason: 'mfr code leaked into nameHe (verbatim header preferred):\n'
            '${bad.join('\n')}');
  });

  // §14 — products the catalog photographs from multiple angles or with
  // included accessories must surface ALL views via the pagers (front 1/N or
  // spec 1/N), not just one. Locks the §17.3 wiring for p29 union (assembled
  // + dismantled) and p33 collar (collar + gasket "כולל אטם").
  test('multi-view products surface all views', () {
    final union = kPolyrollCatalog.firstWhere(
        (p) => p.sku == '98415840',
        orElse: () => throw 'union 98415840 not in catalog');
    expect(union.imageAssets.length, greaterThanOrEqualTo(2),
        reason: 'p29 union should show assembled + dismantled in front pager');

    final collar = kPolyrollCatalog.firstWhere(
        (p) => p.sku == '98417805',
        orElse: () => throw 'p33 collar 98417805 not in catalog');
    final hasGasket = collar.specImageAssets
        .any((a) => a.endsWith('ppr_p33_c.jpg'));
    expect(hasGasket, isTrue,
        reason: 'p33 collar should show gasket in spec pager (כולל אטם)');
  });

  // §14 — pipe wall thickness must match OD/SDR (within ±15% — catalogs give
  // a min-max range). Catches the p86/p87 bug where SDR labels were 7.4 for
  // all sizes but the actual walls implied SDR 11 / SDR 17 per row.
  test('pipe wall ≈ OD / SDR', () {
    double? num(dynamic v) {
      if (v == null) return null;
      final s = v.toString().split('–').first.trim();
      return double.tryParse(s);
    }
    final mismatches = <String>[];
    for (final p in kPolyrollCatalog) {
      final d = p.dims;
      if (d == null) continue;
      final od = num(d['de קוטר חיצוני'] ?? d['קוטר חיצוני']);
      final wall = num(d['e עובי דופן'] ?? d['עובי דופן']);
      final sdrStr = d['SDR']?.toString();
      if (od == null || wall == null || sdrStr == null) continue;
      final sdr = double.tryParse(sdrStr);
      if (sdr == null) continue;
      final expected = od / sdr;
      final diff = (wall - expected).abs() / expected;
      if (diff > 0.15) {
        mismatches.add('${p.sku} p${p.page}: OD=$od wall=$wall SDR=$sdr '
            '⇒ expected≈${expected.toStringAsFixed(2)} (off ${(diff*100).round()}%)');
      }
    }
    expect(mismatches, isEmpty,
        reason: 'wall thickness inconsistent with SDR — SDR label is probably '
            'wrong for that row:\n${mismatches.take(8).join('\n')}'
            '${mismatches.length > 8 ? "\n(total ${mismatches.length})" : ""}');
  });

  // Locks the _pprSpecFor wiring: a sub-type keyword must map to its own
  // diagram. Guards the "PPR/PPRCT-style confusion" bug class for spec images.
  group('PPR sub-type → correct spec diagram', () {
    LipskeyCatalogProduct find(bool Function(LipskeyCatalogProduct) f) =>
        kPolyrollCatalog.firstWhere(f);
    String spec(LipskeyCatalogProduct p) => p.specImageAssets.first;

    test('elbow 45° vs 90°', () {
      // Either the generic spec or any per-page elbow_45/elbow_90 variant.
      // (§22 introduced page-specific specs that supersede the generic ones.)
      expect(
          spec(find((p) => p.categoryHe == kPprElbows && p.nameHe.contains('45'))),
          matches(r'spec_elbow_45(?:_p\d+)?\.jpg$'));
      expect(
          spec(find((p) =>
              p.categoryHe == kPprElbows && !p.nameHe.contains('45'))),
          matches(r'spec_elbow_90(?:_p\d+)?\.jpg$'));
    });

    test('coupler straight vs reducing', () {
      // §22: page-specific spec_coupler/spec_coupler_reducing variants are
      // also valid endings.
      expect(
          spec(find((p) =>
              p.categoryHe == kPprCouplers && !p.nameHe.contains('מצרה'))),
          matches(r'spec_coupler(?:_p\d+)?\.jpg$'));
      expect(
          spec(find((p) =>
              p.categoryHe == kPprCouplers && p.nameHe.contains('מצרה'))),
          matches(r'spec_coupler_reducing(?:_p\d+)?\.jpg$'));
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
          matches(r'spec_adapter_hex(?:_p\d+)?\.jpg$'));
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

  // §22 — every catalog page with its own dimension diagram routes its products
  // to a page-specific spec. Families currently cropped: elbow 90°, tee, saddle.
  // When you crop a new family, add its expected (category, pageNumber → spec
  // filename) row here and the test will guarantee no regression.
  test('§22 per-page spec routing — products land on their page-specific crop',
      () {
    const expected = <String, Map<int, String>>{
      kPprElbows: {
        // 90° per-page (handles non-45 elbows)
        19: 'spec_elbow_90_p19.jpg',
        20: 'spec_elbow_90_p20.jpg',
        25: 'spec_elbow_90_p25.jpg',
        38: 'spec_elbow_90_p38.jpg',
        39: 'spec_elbow_90_p39.jpg',
        48: 'spec_elbow_90_p48.jpg',
        49: 'spec_elbow_90_p49.jpg',
        50: 'spec_elbow_90_p50.jpg',
        81: 'spec_elbow_90_p81.jpg',
      },
      // 45° elbow per-page (separate dict keyed by page → expected 45° asset).
      // We check this distinctly so both 45 and 90 on the same page (p19, p20)
      // each land on their own spec.
      '${kPprElbows}_45': {
        19: 'spec_elbow_45_p19.jpg',
        20: 'spec_elbow_45_p20.jpg',
        36: 'spec_elbow_45_p36.jpg',
        37: 'spec_elbow_45_p37.jpg',
      },
      kPprTees: {
        26: 'spec_tee_p26.jpg',
        40: 'spec_tee_p40.jpg',
        41: 'spec_tee_p41.jpg',
        51: 'spec_tee_p51.jpg',
        52: 'spec_tee_p52.jpg',
        82: 'spec_tee_p82.jpg',
      },
      kPprSaddles: {
        29: 'spec_saddle_p29.jpg',
        58: 'spec_saddle_p58.jpg',
        59: 'spec_saddle_p59.jpg',
        60: 'spec_saddle_p60.jpg',
        84: 'spec_saddle_p84.jpg',
      },
      kPprPlugs: {
        22: 'spec_plug_p22.jpg',
        70: 'spec_plug_p70.jpg',
        71: 'spec_plug_p71.jpg',
        83: 'spec_plug_p83.jpg',
      },
      kPprCouplers: {
        // straight (non-reducing)
        44: 'spec_coupler_p44.jpg',
      },
      '${kPprCouplers}_reducing': {
        23: 'spec_coupler_reducing_p23.jpg',
        45: 'spec_coupler_reducing_p45.jpg',
        47: 'spec_coupler_reducing_p47.jpg',
        83: 'spec_coupler_reducing_p83.jpg',
      },
      kPprAdapters: {
        // round (non-hex)
        27: 'spec_adapter_round_p27.jpg',
        29: 'spec_adapter_round_p29.jpg',
        53: 'spec_adapter_round_p53.jpg',
        54: 'spec_adapter_round_p54.jpg',
        55: 'spec_adapter_round_p55.jpg',
      },
      '${kPprAdapters}_hex': {
        28: 'spec_adapter_hex_p28.jpg',
        56: 'spec_adapter_hex_p56.jpg',
        57: 'spec_adapter_hex_p57.jpg',
      },
    };
    final gaps = <String>[];
    expected.forEach((key, perPage) {
      final is45Elbow = key == '${kPprElbows}_45';
      final isReducingCoupler = key == '${kPprCouplers}_reducing';
      final isHexAdapter = key == '${kPprAdapters}_hex';
      String cat;
      if (is45Elbow) {
        cat = kPprElbows;
      } else if (isReducingCoupler) {
        cat = kPprCouplers;
      } else if (isHexAdapter) {
        cat = kPprAdapters;
      } else {
        cat = key;
      }
      perPage.forEach((page, spec) {
        final hits = kPolyrollCatalog.where((p) {
          if (p.categoryHe != cat || p.page != page) return false;
          // Reducing tees use a different spec family — skip.
          if (cat == kPprTees && p.nameHe.contains('מצרה')) return false;
          // Elbows: 45° products live under the synthetic '_45' key; the
          // base kPprElbows key covers everything else (the 90° variants).
          if (cat == kPprElbows) {
            final is45 = p.nameHe.contains('45');
            if (is45 != is45Elbow) return false;
          }
          // Couplers: reducing live under the synthetic '_reducing' key.
          if (cat == kPprCouplers) {
            final isRed = p.nameHe.contains('מצרה');
            if (isRed != isReducingCoupler) return false;
          }
          // Adapters: hex live under the synthetic '_hex' key.
          if (cat == kPprAdapters) {
            final isHex = p.nameHe.contains('משושה');
            if (isHex != isHexAdapter) return false;
          }
          return true;
        });
        if (hits.isEmpty) return;
        for (final p in hits) {
          final s = p.specImageAssets.first;
          if (!s.endsWith(spec)) {
            gaps.add('$key p$page ${p.sku}: $s ≠ $spec');
          }
        }
      });
    });
    expect(gaps, isEmpty, reason: gaps.join('\n'));
  });
}

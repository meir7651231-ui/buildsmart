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
          matches(r'spec_tee(?:_p\d+)?\.jpg$'));
      expect(
          spec(find(
              (p) => p.categoryHe == kPprTees && p.nameHe.contains('מצרה'))),
          matches(r'spec_tee_reducing(?:_p\d+)?\.jpg$'));
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
        // p39 is model-split (§22.C) — tested separately.
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
        // p37 is intentionally excluded from this static map because it
        // routes by model (size 160-315 → _a, 355-400 → _b). The §22.C
        // model split is asserted in its own test below.
      },
      kPprTees: {
        20: 'spec_tee_p20.jpg',
        26: 'spec_tee_p26.jpg',
        40: 'spec_tee_p40.jpg',
        41: 'spec_tee_p41.jpg',
        51: 'spec_tee_p51.jpg',
        52: 'spec_tee_p52.jpg',
        82: 'spec_tee_p82.jpg',
      },
      kPprSaddles: {
        24: 'spec_saddle_p24.jpg',
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
        22: 'spec_coupler_p22.jpg',
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
        // p53, p54, p55 all model-split by §22.C — tested separately below.
      },
      '${kPprAdapters}_hex': {
        28: 'spec_adapter_hex_p28.jpg',
        56: 'spec_adapter_hex_p56.jpg',
        57: 'spec_adapter_hex_p57.jpg',
      },
      '${kPprTees}_reducing': {
        21: 'spec_tee_reducing_p21.jpg',
        42: 'spec_tee_reducing_p42.jpg',
        82: 'spec_tee_reducing_p82.jpg',
      },
      kPprCollars: {
        // Plain-collar per-page (excludes p66/67/68 which use sub-type logic).
        34: 'spec_collar_p34.jpg',
        69: 'spec_collar_p69.jpg',
        85: 'spec_collar_p85.jpg',
      },
      '${kPprValves}_concealed': {
        // p30 split into _a (with handle) and _b (no handle) by §22.D —
        // tested in §22.D test below, excluded here.
        62: 'spec_valve_concealed_p62.jpg',
        63: 'spec_valve_concealed_p63.jpg',
      },
      '${kPprValves}_ball': {
        32: 'spec_valve_p32.jpg',
        64: 'spec_valve_p64.jpg',
        65: 'spec_valve_p65.jpg',
      },
      kPprOmega: {
        22: 'spec_omega_p22.jpg',
        74: 'spec_omega_p74.jpg',
      },
    };
    final gaps = <String>[];
    expected.forEach((key, perPage) {
      final is45Elbow = key == '${kPprElbows}_45';
      final isReducingCoupler = key == '${kPprCouplers}_reducing';
      final isReducingTee = key == '${kPprTees}_reducing';
      final isHexAdapter = key == '${kPprAdapters}_hex';
      final isConcealedValve = key == '${kPprValves}_concealed';
      final isBallValve = key == '${kPprValves}_ball';
      String cat;
      if (is45Elbow) {
        cat = kPprElbows;
      } else if (isReducingCoupler) {
        cat = kPprCouplers;
      } else if (isReducingTee) {
        cat = kPprTees;
      } else if (isHexAdapter) {
        cat = kPprAdapters;
      } else if (isConcealedValve || isBallValve) {
        cat = kPprValves;
      } else {
        cat = key;
      }
      perPage.forEach((page, spec) {
        final hits = kPolyrollCatalog.where((p) {
          if (p.categoryHe != cat || p.page != page) return false;
          // Tees: reducing live under synthetic '_reducing' key.
          if (cat == kPprTees) {
            final isRed = p.nameHe.contains('מצרה');
            if (isRed != isReducingTee) return false;
          }
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
          // Valves: concealed under '_concealed', ball under '_ball';
          // butterfly/wafer/angle/straight have category-wide sub-type specs
          // that the §22 per-page map deliberately skips. p32 polypropylene
          // ball valves route to §22.D split.
          if (cat == kPprValves) {
            final isConc = p.nameHe.contains('סמוי');
            final isBall = !p.nameHe.contains('פרפר') &&
                !p.nameHe.contains('בין אוגנים') &&
                !p.nameHe.contains('סמוי') &&
                !p.nameHe.contains('אלכסוני') &&
                !p.nameHe.contains('מעבר');
            if (isConcealedValve && !isConc) return false;
            if (isBallValve && !isBall) return false;
            // p32 polypropylene → §22.D split.
            if (p.page == 32 && p.nameHe.contains('פוליפרופילן')) return false;
          }
          // Collars: skip products handled by sub-type logic (פרפר, פנים,
          // שקע תקע) — those don't use the page-based map.
          if (cat == kPprCollars) {
            if (p.nameHe.contains('פרפר') ||
                (p.nameHe.contains('פנים') && !p.nameHe.contains('פרפר')) ||
                p.nameHe.contains('שקע תקע')) {
              return false;
            }
            // p34 non-flange + p85 non-collar route via §22.D sub-type logic.
            if (p.page == 34 && !p.nameHe.startsWith('אוגן')) return false;
            if (p.page == 85 && !p.nameHe.startsWith('צווארון')) return false;
          }
          // Saddles: p84 'תבריג' (threaded) routes to §22.D variant.
          if (cat == kPprSaddles && p.page == 84 && p.nameHe.contains('תבריג')) {
            return false;
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

  // §22 stage D complementary check: no spec asset may serve more than two
  // (category, page) combos. Universally-shared geometries (pipes whose
  // dimension diagram is one circular cross-section regardless of size) are
  // allow-listed. Anything else hitting >2 pages means a per-page crop is
  // missing.
  test('§22 sharing — no spec serves >2 catalog pages (allowlist exempt)', () {
    const allowlistSharedAcrossPages = {
      // Pipes: one cross-section spec is geometrically correct for every
      // diameter (just scaled). Catalog itself doesn't draw it per page.
      'spec_faser_20.jpg',
      'spec_pprct_pipe.jpg',
      'spec_pprct_pipe_sdr17.jpg',
    };
    final usage = <String, Set<String>>{};
    for (final p in kPolyrollCatalog) {
      final s = p.specImageAssets.first.split('/').last;
      usage.putIfAbsent(s, () => {}).add('${p.categoryHe}|${p.page}');
    }
    final offenders = <String>[];
    usage.forEach((spec, pages) {
      if (allowlistSharedAcrossPages.contains(spec)) return;
      if (pages.length > 2) {
        offenders.add('$spec → ${pages.length} pages: ${pages.join(", ")}');
      }
    });
    expect(offenders, isEmpty,
        reason:
            'Specs shared across >2 pages — crop a per-page variant or add '
            'to allowlistSharedAcrossPages with a reason:\n${offenders.join("\n")}');
  });

  // §22.C — pages where two geometric models live on the same catalog page
  // and the model is picked per-product by size. p37 ברך 45° לריתוך פנים:
  // Model A = 160-315, Model B = 355-400. The card MUST show only the
  // model that applies to the product's size.
  test('§22.C p37 elbow_45 — Model A for 160-315, Model B for 355-400', () {
    const expectModel = {
      '6002020160': 'A',
      '6002020200': 'A',
      '6002020250': 'A',
      '6002020315': 'A',
      '6002020355': 'B',
      '6002020400': 'B',
    };
    final gaps = <String>[];
    for (final entry in expectModel.entries) {
      final p = kPolyrollCatalog.firstWhere((x) => x.sku == entry.key);
      final wantedSpec = 'spec_elbow_45_p37_${entry.value.toLowerCase()}.jpg';
      if (!p.specImageAssets.first.endsWith(wantedSpec)) {
        gaps.add('${entry.key} (${p.nameHe}) → ${p.specImageAssets.first} ≠ $wantedSpec');
      }
      // R8 verbatim: 'מודל' dim must match the catalog table.
      if (p.dims?['מודל'] != entry.value) {
        gaps.add('${entry.key}: dims[\'מודל\']=${p.dims?['מודל']} ≠ ${entry.value}');
      }
    }
    expect(gaps, isEmpty, reason: gaps.join('\n'));
  });

  // §22.C — p39 brass 90° elbow פ.פ: 2 models on one page (smooth A vs
  // segmented B). A = 160-315, B = 355-400 per catalog "מודל" column.
  test('§22.C p39 elbow_90 — Model A 160-315, B 355-400', () {
    const expectModel = {
      '6002060160': 'A', '6002060200': 'A', '6002060250': 'A', '6002060315': 'A',
      '6002060355': 'B', '6002060400': 'B',
    };
    final gaps = <String>[];
    for (final entry in expectModel.entries) {
      final p = kPolyrollCatalog.firstWhere((x) => x.sku == entry.key);
      final wantedSpec = 'spec_elbow_90_p39_${entry.value.toLowerCase()}.jpg';
      if (!p.specImageAssets.first.endsWith(wantedSpec)) {
        gaps.add('${entry.key} → ${p.specImageAssets.first} ≠ $wantedSpec');
      }
      if (p.dims?['מודל'] != entry.value) {
        gaps.add('${entry.key}: dims[\'מודל\']=${p.dims?['מודל']} ≠ ${entry.value}');
      }
    }
    expect(gaps, isEmpty, reason: gaps.join('\n'));
  });

  // §22.C — p53 round adapter internal-thread: 2 models on one page.
  // Model A = sizes 20-32 (PPRCT line), Model B = sizes 40-110 (PPR line).
  test('§22.C p53 adapter — Model A 20-32, B 40-110', () {
    const expectModel = {
      '6602340200': 'A', '6602340250': 'A', '6602340260': 'A',
      '6602340330': 'A', '6602340320': 'A',
      '6602340400': 'B', '6602340500': 'B', '6602340630': 'B',
      '6602340750': 'B', '6602340900': 'B', '6602340110': 'B',
    };
    final gaps = <String>[];
    for (final entry in expectModel.entries) {
      final p = kPolyrollCatalog.firstWhere((x) => x.sku == entry.key);
      final wantedSpec = 'spec_adapter_round_p53_${entry.value.toLowerCase()}.jpg';
      if (!p.specImageAssets.first.endsWith(wantedSpec)) {
        gaps.add('${entry.key} (${p.nameHe}) → ${p.specImageAssets.first} ≠ $wantedSpec');
      }
      if (p.dims?['מודל'] != entry.value) {
        gaps.add('${entry.key}: dims[\'מודל\']=${p.dims?['מודל']} ≠ ${entry.value}');
      }
    }
    expect(gaps, isEmpty, reason: gaps.join('\n'));
  });

  // §22.C — p55 adapter with rekord: 2 models on one page.
  test('§22.C p55 adapter rekord — Model A 20-32, B 40-75', () {
    const expectModel = {
      '6702340200': 'A', '6702340260': 'A', '6702340250': 'A',
      '6702340320': 'A', '6702340330': 'A',
      '6702340400': 'B', '6702340500': 'B', '6702340630': 'B',
      '6702340750': 'B',
    };
    final gaps = <String>[];
    for (final entry in expectModel.entries) {
      final p = kPolyrollCatalog.firstWhere((x) => x.sku == entry.key);
      final wantedSpec = 'spec_adapter_round_p55_${entry.value.toLowerCase()}.jpg';
      if (!p.specImageAssets.first.endsWith(wantedSpec)) {
        gaps.add('${entry.key} (${p.nameHe}) → ${p.specImageAssets.first} ≠ $wantedSpec');
      }
      if (p.dims?['מודל'] != entry.value) {
        gaps.add('${entry.key}: dims[\'מודל\']=${p.dims?['מודל']} ≠ ${entry.value}');
      }
    }
    expect(gaps, isEmpty, reason: gaps.join('\n'));
  });

  // §22.C — p54 PPRCT round adapter external-thread: 3 models on one page.
  // Model A = 20-32, Model B = 40-50, Model C = 63-110 (per catalog table).
  test('§22.C p54 adapter — Model A 20-32, B 40-50, C 63-110', () {
    const expectModel = {
      '6602350200': 'A', '6602350250': 'A', '6602350260': 'A',
      '6602350330': 'A', '6602350320': 'A',
      '6602350400': 'B', '6602350500': 'B',
      '6602350630': 'C', '6602350750': 'C', '6602350900': 'C', '6602350110': 'C',
    };
    final gaps = <String>[];
    for (final entry in expectModel.entries) {
      final p = kPolyrollCatalog.firstWhere((x) => x.sku == entry.key);
      final wantedSpec = 'spec_adapter_round_p54_${entry.value.toLowerCase()}.jpg';
      if (!p.specImageAssets.first.endsWith(wantedSpec)) {
        gaps.add('${entry.key} (${p.nameHe}) → ${p.specImageAssets.first} ≠ $wantedSpec');
      }
      if (p.dims?['מודל'] != entry.value) {
        gaps.add('${entry.key}: dims[\'מודל\']=${p.dims?['מודל']} ≠ ${entry.value}');
      }
    }
    expect(gaps, isEmpty, reason: gaps.join('\n'));
  });

  // §22.D — p33 has 3 sub-types each with own dim diagram (previously
  // claimed photo-only or generic-spec):
  // - 11 EF shrouds were on page_33.jpg → now spec_shroud_p33.jpg
  // - 7 collars were on spec_collar.jpg (p34 flange — wrong) → spec_collar_p33.jpg
  // - 1 plug was on spec_plug.jpg → spec_plug_p92.jpg (dim is on p92 for same SKU)
  test('§22.D p33 sub-type split — shroud/collar/plug each get own diagram', () {
    final gaps = <String>[];
    for (final p in kPolyrollCatalog.where((p) => p.page == 33)) {
      final s = p.specImageAssets.first.split('/').last;
      String expected;
      if (p.nameHe.contains('שרוול')) {
        expected = 'spec_shroud_p33.jpg';
      } else if (p.nameHe.contains('צווארון')) {
        expected = 'spec_collar_p33.jpg';
      } else if (p.nameHe.contains('פקק')) {
        expected = 'spec_plug_p92.jpg';
      } else {
        continue;
      }
      if (s != expected) gaps.add('${p.sku} ${p.nameHe} → $s ≠ $expected');
    }
    expect(gaps, isEmpty, reason: gaps.join('\n'));
  });

  // §22 — p61 butterfly valve: spec_valve_butterfly.jpg was previously just a
  // tiny bonnet exploded view (missing the main 3-view dim diagram). New
  // spec_valve_butterfly_p61.jpg now carries the full diagram.
  test('§22 p61 butterfly — uses full 3-view diagram, not the bonnet detail', () {
    final p = kPolyrollCatalog.firstWhere((p) =>
        p.page == 61 && p.nameHe.contains('פרפר'));
    expect(p.specImageAssets.first, endsWith('spec_valve_butterfly_p61.jpg'));
  });

  // §22.D — p32 ball valve split: regular vs polypropylene get distinct specs.
  test('§22.D p32 valve split — regular ball vs polypropylene', () {
    final regular = kPolyrollCatalog.firstWhere((p) =>
        p.page == 32 && !p.nameHe.contains('פוליפרופילן'));
    final pp = kPolyrollCatalog.firstWhere((p) =>
        p.page == 32 && p.nameHe.contains('פוליפרופילן'));
    expect(regular.specImageAssets.first, endsWith('spec_valve_p32.jpg'));
    expect(pp.specImageAssets.first, endsWith('spec_valve_p32_pp.jpg'));
  });

  // §22.D — p34 three sub-types: אוגן / סעפת / לוחית each get distinct specs.
  test('§22.D p34 sub-type split — flange/manifold/plate', () {
    final flange = kPolyrollCatalog.firstWhere((p) =>
        p.page == 34 && p.nameHe.startsWith('אוגן'));
    final manifold = kPolyrollCatalog.firstWhere((p) =>
        p.page == 34 && p.nameHe.contains('סעפת'));
    final plate = kPolyrollCatalog.firstWhere((p) =>
        p.page == 34 && p.nameHe.contains('לוחית'));
    expect(flange.specImageAssets.first, endsWith('spec_collar_p34.jpg'));
    expect(manifold.specImageAssets.first, endsWith('spec_manifold_p34.jpg'));
    expect(plate.specImageAssets.first, endsWith('spec_plate_p34.jpg'));
  });

  // §22.D — p85 three sub-types: collar / flange / shroud each get distinct
  // specs. Previously spec_collar_p85.jpg was misassigned (was the shroud
  // diagram going to collar products); now it correctly carries the gasket
  // collar diagram.
  test('§22.D p85 sub-type split — collar/flange/shroud', () {
    final collar = kPolyrollCatalog.firstWhere((p) =>
        p.page == 85 && p.nameHe.startsWith('צווארון'));
    final flange = kPolyrollCatalog.firstWhere((p) =>
        p.page == 85 && p.nameHe.contains('אוגן'));
    final shroud = kPolyrollCatalog.firstWhere((p) =>
        p.page == 85 && p.nameHe.contains('שרוול'));
    expect(collar.specImageAssets.first, endsWith('spec_collar_p85.jpg'));
    expect(flange.specImageAssets.first, endsWith('spec_collar_p85_flange.jpg'));
    expect(shroud.specImageAssets.first, endsWith('spec_shroud_p85.jpg'));
  });

  // §22.D — p84 saddle sub-type split: plain saddle ("רוכב לריתוך") shares
  // page with threaded saddle ("רוכב לריתוך תבריג פנימי"). 6 threaded SKUs
  // must show the threaded diagram, not the plain saddle one.
  test('§22.D p84 saddle sub-type split — plain vs threaded', () {
    const threadedSkus = ['98318381', '98318382', '98318368',
                          '98318371', '98318373', '98318369'];
    final gaps = <String>[];
    for (final sku in threadedSkus) {
      final p = kPolyrollCatalog.firstWhere((x) => x.sku == sku);
      if (!p.specImageAssets.first.endsWith('spec_saddle_p84_threaded.jpg')) {
        gaps.add('$sku (${p.nameHe}) → ${p.specImageAssets.first} ≠ threaded');
      }
    }
    // Plain saddles on p84 must NOT route to threaded.
    final plain = kPolyrollCatalog.firstWhere(
        (x) => x.page == 84 && !x.nameHe.contains('תבריג'));
    if (plain.specImageAssets.first.contains('threaded')) {
      gaps.add('${plain.sku} (${plain.nameHe}) wrongly routed to threaded');
    }
    expect(gaps, isEmpty, reason: gaps.join('\n'));
  });

  // §22.D — p30 valve sub-type split: 3 distinct dim drawings on one page,
  // separated by Hebrew suffix in the product nameHe.
  test('§22.D p30 valve sub-type split — with/without handle, wafer', () {
    const expectSpec = {
      // ברז סמוי (ציפוי כרום) - with handle → _a
      '99040858': 'spec_valve_concealed_p30_a.jpg',
      '99040860': 'spec_valve_concealed_p30_a.jpg',
      '99040862': 'spec_valve_concealed_p30_a.jpg',
      // ברז סמוי (ציפוי כרום - ללא ידית) - no handle → _b
      '99040888': 'spec_valve_concealed_p30_b.jpg',
      '99040890': 'spec_valve_concealed_p30_b.jpg',
      '99040892': 'spec_valve_concealed_p30_b.jpg',
      // ברז כדורי בין אוגנים → wafer (page-specific crop)
      '99041602': 'spec_valve_wafer_p30.jpg',
      '99041604': 'spec_valve_wafer_p30.jpg',
      '99041607': 'spec_valve_wafer_p30.jpg',
    };
    final gaps = <String>[];
    for (final entry in expectSpec.entries) {
      final p = kPolyrollCatalog.firstWhere((x) => x.sku == entry.key);
      if (!p.specImageAssets.first.endsWith(entry.value)) {
        gaps.add('${entry.key} (${p.nameHe}) → ${p.specImageAssets.first} ≠ ${entry.value}');
      }
    }
    expect(gaps, isEmpty, reason: gaps.join('\n'));
  });

  // §22.E — finish parenthetical (ציפוי כרום, ציפוי כרום - ללא ידית, etc.)
  // must appear verbatim in nameHe per R8.
  test('§22.E finish suffix verbatim — p30/p62/p63 carry their catalog parenthetical', () {
    const expectContains = {
      // p30 with handle
      '99040858': 'ציפוי כרום',
      '99040860': 'ציפוי כרום',
      '99040862': 'ציפוי כרום',
      // p30 without handle
      '99040888': 'ציפוי כרום - ללא ידית',
      '99040890': 'ציפוי כרום - ללא ידית',
      '99040892': 'ציפוי כרום - ללא ידית',
      // p62 with handle
      '6006224420': 'ציפוי כרום - כולל ידית',
      '6006224425': 'ציפוי כרום - כולל ידית',
      '6006224432': 'ציפוי כרום - כולל ידית',
      // p63 without handle
      '6006324420': 'ציפוי כרום - ללא ידית',
      '6006324425': 'ציפוי כרום - ללא ידית',
      '6006324432': 'ציפוי כרום - ללא ידית',
    };
    final gaps = <String>[];
    for (final entry in expectContains.entries) {
      final p = kPolyrollCatalog.firstWhere((x) => x.sku == entry.key);
      if (!p.nameHe.contains(entry.value)) {
        gaps.add('${entry.key}: nameHe="${p.nameHe}" missing "${entry.value}"');
      }
    }
    expect(gaps, isEmpty, reason: gaps.join('\n'));
  });
}

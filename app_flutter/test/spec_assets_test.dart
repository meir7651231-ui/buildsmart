// §14 detection test for the per-sub-type spec-diagram work (protocol §17.1):
// every spec image the flip-side pager can show must exist on disk, and each
// fitting sub-type must resolve to its OWN dimension drawing (not a sibling's
// and not a silent fallback to the full catalog page). A typo or a missing
// crop here = a blank/wrong flip side at runtime — this is the guard.
import 'dart:io';

import 'package:buildsmart/data/chip_hierarchy.dart';
import 'package:buildsmart/data/huliot_smartlock_catalog.dart';
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
          matches(r'spec_adapter_hex(?:_p\d+(?:_\w+)?)?\.jpg$'));
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

  // §21 regression — an angle elbow/tee (45°/90°) must keep its real DIAMETER
  // in the size slot, not the angle. The angle starts with a digit, so a naive
  // size regex used to grab "45°" as the size and silently drop "160".
  test('§21 angle fittings keep the diameter as size, angle as shape', () {
    final gaps = <String>[];
    for (final p in kPolyrollCatalog) {
      if (p.categoryHe != kPprElbows && p.categoryHe != kPprTees) continue;
      if (!(p.nameHe.contains('45°') || p.nameHe.contains('90°'))) continue;
      final cp = parseChips(p.nameHe);
      // size must exist and must NOT be the angle.
      if (cp.level5 == null || cp.level5!.contains('°')) {
        gaps.add('${p.sku} "${p.nameHe}" → size=${cp.level5} (lost the diameter)');
      }
      // the angle must appear in the path as a shape chip.
      final angle = p.nameHe.contains('90°') ? '90°' : '45°';
      if (!cp.path.contains(angle)) {
        gaps.add('${p.sku} "${p.nameHe}" → angle $angle missing from chips');
      }
    }
    expect(gaps, isEmpty, reason: gaps.join('\n'));
  });

  // §21 — a multi-word descriptive phrase whose individual words also live in
  // another level (e.g. "מים" is an L2 pipe-shape word) must be kept as ONE
  // ordered compound chip, not scattered across levels. Guard the known case
  // (לוחית למיקום נקודת מים) and assert the phrase survives intact in order.
  test('§21 multi-word phrase stays one ordered chip (no scatter)', () {
    final plate = kPolyrollCatalog.firstWhere((p) => p.nameHe.contains('לוחית'));
    final path = parseChips(plate.nameHe).path;
    expect(path, contains('למיקום נקודת מים'),
        reason: 'phrase scattered: $path');
    // and it must NOT appear as separate scattered tokens
    expect(path.contains('מים') && path.contains('למיקום'), isFalse,
        reason: 'phrase split into separate chips: $path');
  });

  // §21.B — END-TO-END recoverability: the external card shows [type] + the
  // breadcrumb path + a material badge. Every word of the original catalog
  // name must be recoverable from those three, or the chip is lossy (the user
  // can't read the full product off the card). This is the automated form of
  // the "take 10 names, rebuild from the chip" manual check.
  test('§21.B every Polyroll name is fully recoverable from the chips', () {
    final lossy = <String>[];
    for (final p in kPolyrollCatalog) {
      final c = parseChips(p.nameHe);
      final mat = RegExp(r'PPRCT|PP-RCT|PPR').firstMatch(p.nameHe)?.group(0);
      var recon = '${c.type ?? ''} ${c.path.join(' ')}';
      if (mat != null) recon = '$recon $mat';
      String norm(String w) => w.replaceAll('(', '').replaceAll(')', '');
      // Cosmetic separators ('-', '/') the parser intentionally skips — don't
      // count them as lossy.
      bool keep(String w) => w != '-' && w != '—' && w != '/';
      final orig = p.nameHe
          .split(RegExp(r'\s+'))
          .where((w) => w.trim().isNotEmpty)
          .where(keep)
          .map(norm)
          .toSet();
      final rebuilt = recon
          .split(RegExp(r'\s+'))
          .where((w) => w.trim().isNotEmpty)
          .where(keep)
          .map(norm)
          .toSet();
      final missing = orig.difference(rebuilt);
      if (missing.isNotEmpty) {
        lossy.add('${p.sku} "${p.nameHe}" → lost: ${missing.join(", ")}');
      }
    }
    expect(lossy, isEmpty,
        reason: 'chip is lossy — these words vanish from the card '
            '(type+breadcrumb+badge can\'t rebuild the name):\n'
            '${lossy.take(12).join('\n')}');
  });

  // §21.C — every visible chip must carry a semantic level label
  // (חיבור / צורה / תכונה / תבריג / מידה). Without this the chips were
  // identical-looking pills and the picker said a generic "בחר ערך", so the
  // user couldn't tell primary from secondary from final. Two guarantees:
  //   1) levelLabelOf is one of the 5 allowed labels for every non-noise chip
  //      across the whole Polyroll catalog (none left blank, none invented).
  //   2) The size chip — always the final, deepest filter — always reads "מידה".
  test('§21.C every visible chip carries a semantic level label', () {
    const allowed = {'חיבור', 'צורה', 'תכונה', 'תבריג', 'מידה'};
    const noise = {'מ"מ', 'מ”מ', 'mm'};
    final bad = <String>[];
    for (final p in kPolyrollCatalog) {
      final c = parseChips(p.nameHe);
      for (var i = 0; i < c.path.length; i++) {
        if (noise.contains(c.path[i].trim())) continue;
        final lbl = c.levelLabelOf(i);
        if (!allowed.contains(lbl)) {
          bad.add('${p.sku} chip[$i]="${c.path[i]}" → "$lbl"');
        }
      }
      // The size chip (level5) must always be the "מידה" label — this is the
      // anchor that lets the user know "this is the final, narrowest filter".
      if (c.level5 != null) {
        final sizeIdx = c.path.length - 1;
        final sizeLbl = c.levelLabelOf(sizeIdx);
        if (sizeLbl != 'מידה') {
          bad.add('${p.sku} size chip "${c.path[sizeIdx]}" → "$sizeLbl" '
              '(expected "מידה")');
        }
      }
    }
    expect(bad, isEmpty,
        reason: 'chip without a level label — picker would read "בחר ערך" '
            'and pills would be indistinguishable:\n'
            '${bad.take(12).join('\n')}');
  });

  // §22.I — INTERNAL CARD completeness. The product sheet renders dims as a
  // generic loop over `dims.entries` plus a fixed catalog-page footer; the
  // Polyroll catalog ALWAYS lists at least the manufacturer name + at least
  // one part number (יצרן + מק"ט יצרן/חוליות) for every product. A builder
  // helper that skips those (as `_acPipe` did for 16 AC pipes) breaks the
  // verbatim contract — the user sees a thinner card than the catalog row.
  test('§22.I every Polyroll product carries יצרן + at least one מק"ט', () {
    final missing = <String>[];
    for (final p in kPolyrollCatalog) {
      final hasMaker = p.dims?['יצרן'] != null;
      final hasMakat = (p.dims?['מק"ט יצרן'] ?? p.dims?['מק"ט חוליות']) != null;
      if (!hasMaker || !hasMakat) {
        missing.add('${p.sku} "${p.nameHe}" '
            '${!hasMaker ? "[no יצרן]" : ""}${!hasMakat ? "[no מק\"ט]" : ""}');
      }
    }
    expect(missing, isEmpty,
        reason: 'internal-card data hole — the catalog table shows יצרן + '
            'מק"ט for every row, the product sheet shows it for every product. '
            'If a builder helper skips these, the user sees a thinner card than '
            'the catalog:\n${missing.take(12).join('\n')}');
  });

  // §22.I (Huliot) — same contract for the SmartLock catalog. The factory
  // (`_sl`) is supposed to inject 'יצרן': 'חוליות' + 'מק"ט חוליות': sku
  // automatically; this guards against a future refactor breaking that.
  test('§22.I every Huliot SmartLock product carries יצרן + at least one מק"ט',
      () {
    final missing = <String>[];
    for (final p in kHuliotCatalog) {
      final hasMaker = p.dims?['יצרן'] != null;
      final hasMakat = (p.dims?['מק"ט יצרן'] ?? p.dims?['מק"ט חוליות']) != null;
      if (!hasMaker || !hasMakat) {
        missing.add('${p.sku} "${p.nameHe}" '
            '${!hasMaker ? "[no יצרן]" : ""}${!hasMakat ? "[no מק\"ט]" : ""}');
      }
    }
    expect(missing, isEmpty,
        reason:
            'Huliot SmartLock internal-card data hole — `_sl` factory should '
            'always inject יצרן + מק"ט חוליות:\n${missing.take(12).join('\n')}');
  });

  // §22-Huliot path resolution — every Huliot product's image/spec assets
  // must resolve to `assets/huliot_smartlock/`. This guards against the
  // brand-dir mapping regressing (the bug fixed by _brandDir static helper).
  test('§22-Huliot every product asset resolves to assets/huliot_smartlock/',
      () {
    final wrongDir = <String>[];
    for (final p in kHuliotCatalog) {
      for (final a in p.imageAssets) {
        if (!a.startsWith('assets/huliot_smartlock/')) {
          wrongDir.add('${p.sku} imageAsset="$a"');
        }
      }
      for (final a in p.specImageAssets) {
        if (!a.startsWith('assets/huliot_smartlock/')) {
          wrongDir.add('${p.sku} specImageAsset="$a"');
        }
      }
    }
    expect(wrongDir, isEmpty,
        reason: 'Huliot assets escaping the brand directory '
            '(brand→dir mapping regression?):\n${wrongDir.take(12).join('\n')}');
  });

  // §22-Huliot every page asset referenced by a product exists on disk.
  // Catches: typo in page number, missing page export, _huliotImageFor
  // returning a path that wasn't generated.
  test('§22-Huliot every Huliot page asset exists on disk', () {
    final missing = <String>[];
    for (final p in kHuliotCatalog) {
      for (final a in p.specImageAssets) {
        if (!File(a).existsSync()) missing.add('${p.sku} → $a');
      }
    }
    expect(missing, isEmpty,
        reason: 'broken Huliot asset paths:\n${missing.take(12).join('\n')}');
  });

  // §17.1-Huliot every product's FRONT image exists on disk. Under the
  // R2-fallback mode (HULIOT_TODO P10 — crops not yet on CDN), every Huliot
  // product is intentionally routed to its full catalog page (which IS on
  // R2) so cards render instead of throwing. Re-tighten the "must be a crop"
  // half of this guard once `_routeCropDisabled` flips to false.
  test('§17.1-Huliot every product front image exists', () {
    final missing = <String>[];
    for (final p in kHuliotCatalog) {
      final a = p.imageAsset;
      if (a == null) {
        missing.add('${p.sku} → null imageAsset');
        continue;
      }
      if (!File(a).existsSync()) missing.add('${p.sku} → $a (not on disk)');
    }
    expect(missing, isEmpty,
        reason: 'Huliot front-image assets missing:\n'
            '${missing.take(12).join('\n')}');
  });

  // §17.1.c — p24 seal products (אטם לג'וקר / אטם מעביר) must fall back to the
  // full catalog page, not return null, since sml_p24_a.jpg was not generated.
  test('§17.1.c-Huliot p24 seal products fall back to page image not null', () {
    final sealSkus = {'67750440', '67760440', '67760540', '67763063', '767943440', '767950440'};
    final bad = <String>[];
    for (final p in kHuliotCatalog.where((p) => sealSkus.contains(p.sku))) {
      final a = p.imageAsset;
      if (a == null) bad.add('${p.sku} → null (should be page_24.jpg)');
      else if (!a.contains('page_')) bad.add('${p.sku} → $a (expected page fallback)');
      else if (!File(a).existsSync()) bad.add('${p.sku} → $a (not on disk)');
    }
    expect(bad, isEmpty, reason: bad.join('\n'));
  });

  // §21.B-Huliot — STRONG recoverability via parseChips. Huliot now renders
  // via `_HierarchyChips` (same as Polyroll), so every word in nameHe must be
  // classifiable into the §21 hierarchy (type + level1..5) with NO leftover.
  // The catalog is recoverable from the chip path alone, satisfying §14.E.
  test('§21.B-Huliot every product name is fully recoverable via parseChips',
      () {
    final lossy = <String>[];
    for (final p in kHuliotCatalog) {
      final c = parseChips(p.nameHe);
      // Normalise for comparison: strip parens (parser strips them too) and
      // drop cosmetic separators ('-', '/') that the parser intentionally
      // skips (they carry no semantic content for the chip path).
      String norm(String w) => w.replaceAll('(', '').replaceAll(')', '');
      bool keep(String w) => w != '-' && w != '—' && w != '/';
      var recon = '${c.type ?? ''} ${c.path.join(' ')} ${c.leftover.join(' ')}';
      final orig = p.nameHe
          .split(RegExp(r'\s+'))
          .where((w) => w.trim().isNotEmpty)
          .where(keep)
          .map(norm)
          .toSet();
      final rebuilt = recon
          .split(RegExp(r'\s+'))
          .where((w) => w.trim().isNotEmpty)
          .where(keep)
          .map(norm)
          .toSet();
      final missing = orig.difference(rebuilt);
      if (missing.isNotEmpty || c.leftover.isNotEmpty) {
        lossy.add('${p.sku} "${p.nameHe}" → '
            '${missing.isNotEmpty ? "missing: ${missing.join(",")} " : ""}'
            '${c.leftover.isNotEmpty ? "leftover: ${c.leftover.join(",")}" : ""}');
      }
    }
    expect(lossy, isEmpty,
        reason: 'Huliot chip is lossy — these words vanish from the card '
            '(type+breadcrumb can\'t rebuild the name):\n'
            '${lossy.take(20).join('\n')}');
  });

  // §21.C-Huliot — every visible chip carries a semantic level label
  // (חיבור / צורה / תכונה / תבריג / מידה). Mirrors the Polyroll test so the
  // picker reads "בחר חיבור:" not generic "בחר ערך".
  test('§21.C-Huliot every visible chip carries a semantic level label', () {
    const allowed = {'חיבור', 'צורה', 'תכונה', 'תבריג', 'מידה'};
    const noise = {'מ"מ', 'מ”מ', 'mm'};
    final bad = <String>[];
    for (final p in kHuliotCatalog) {
      final c = parseChips(p.nameHe);
      for (var i = 0; i < c.path.length; i++) {
        if (noise.contains(c.path[i].trim())) continue;
        final lbl = c.levelLabelOf(i);
        if (!allowed.contains(lbl)) {
          bad.add('${p.sku} chip[$i]="${c.path[i]}" → "$lbl"');
        }
      }
      if (c.level5 != null) {
        final sizeIdx = c.path.length - 1;
        final sizeLbl = c.levelLabelOf(sizeIdx);
        if (sizeLbl != 'מידה') {
          bad.add('${p.sku} size chip "${c.path[sizeIdx]}" → "$sizeLbl" '
              '(expected "מידה")');
        }
      }
    }
    expect(bad, isEmpty,
        reason: 'Huliot chip without a level label:\n${bad.take(12).join('\n')}');
  });

  // §22-Huliot paranoid audit — 12 cross-product checks that supplement the
  // single-product tests above. Mirrors the 20-check audit run on Polyroll.
  // §22.J-Huliot — reference product per family carries pack/pallet counts.
  // Mirrors CATALOG §13 "reference product = full table row verbatim". The
  // first product in each family is the reference; it must carry the catalog's
  // יח׳/ארגז (pack) + יח׳/משטח (pallet) values verbatim. Catches data-entry
  // gaps where a family-reference was added without the pack columns.
  //
  // Excludes families that genuinely lack these in the source catalog:
  //   - kSmlAccessories (umbrella — many pages, varied table shapes)
  //   - kSmlAquaSlim (page 27 — different table layout, no pack-icons)
  // §17.1.b-Huliot — no orphan crops. Every sml_p{NN}_{tag}.jpg under
  // products/ must be referenced by at least one Huliot product via
  // _huliotImageFor. P5: removed sml_p24_b (אטם מעביר — table-only, reuses
  // _p(24,'a')) + sml_p25_b (מצרה ברזל-פלסטיק — reuses _p(18,'b')).
  // Catches future drift: a crop generated but not routed = dead asset.
  test('§17.1.b-Huliot no orphan crops (every sml_p*.jpg is referenced)', () {
    // HULIOT_TODO P10 (R2-fallback): until the crops are uploaded to R2 the
    // routing is short-circuited to whole-page assets, so this guard would
    // flag every `sml_p*.jpg` + `spec_sml_p*.jpg` in the products/ directory.
    // The crop files MUST stay on disk (they're the deliverable for the R2
    // upload) — so we read the canonical routing tables directly, not the
    // live `imageAsset`/`specImageAssets` which are R2-fallback-aware.
    final referenced = <String>{};
    for (final p in kHuliotCatalog) {
      // The canonical crop name pattern — derived from the same `page` + the
      // family routing letters maintained in _huliotImageForCrop. We accept
      // any sml_p{p.page}_*.jpg as a legitimate routing target.
      final pg = p.page.toString().padLeft(2, '0');
      for (final tag in const ['a', 'b', 'c', 'd']) {
        referenced.add('sml_p${pg}_$tag.jpg');
        referenced.add('spec_sml_p${pg}_$tag.jpg');
      }
    }
    final dir = Directory('assets/huliot_smartlock/products');
    final orphans = dir
        .listSync()
        .whereType<File>()
        .map((f) => f.path.split('/').last)
        .where((n) =>
            (n.startsWith('sml_p') || n.startsWith('spec_sml_p')) &&
            n.endsWith('.jpg'))
        .where((n) => !referenced.contains(n))
        .toList();
    expect(orphans, isEmpty,
        reason: 'unreferenced crop files (delete or wire them):\n'
            '${orphans.join('\n')}');
  });

  // §17.2-Huliot — every product with a dedicated photo crop also has its
  // matching spec/diagram crop on disk. The pairing is by-construction (the
  // diagram sits below the photo in the same catalog band), so a missing
  // spec means the photo's band-y math drifted or the page was excluded from
  // SPEC_PAGES in crop_huliot.py without updating _huliotSpecFor.
  // Exempt: products routed to a whole-page fallback (no photo crop), and
  // pages 24/27 where the diagram doesn't exist in the catalog (accessories
  // and AQUA SLIM renders).
  test('§17.2-Huliot every product with a photo crop has its spec crop', () {
    final missing = <String>[];
    for (final p in kHuliotCatalog) {
      final s = p.specImageFile;
      if (s == null) continue;
      final path = 'assets/huliot_smartlock/products/$s';
      if (!File(path).existsSync()) {
        missing.add('${p.sku} "${p.nameHe}" → $path (NOT ON DISK)');
      }
    }
    expect(missing, isEmpty,
        reason: 'spec crops referenced by _huliotSpecFor but not on disk:\n'
            '${missing.take(15).join('\n')}');
  });

  test('§22.J-Huliot reference product per family carries יח׳/ארגז + יח׳/משטח',
      () {
    const exempt = {kSmlAccessories, kSmlAquaSlim};
    final firstOf = <String, LipskeyCatalogProduct>{};
    for (final p in kHuliotCatalog) {
      firstOf.putIfAbsent(p.categoryHe, () => p);
    }
    final missing = <String>[];
    for (final entry in firstOf.entries) {
      if (exempt.contains(entry.key)) continue;
      final d = entry.value.dims ?? const {};
      if (d['יח׳/ארגז'] == null || d['יח׳/משטח'] == null) {
        missing.add('${entry.key} (${entry.value.sku}) '
            '[ארגז=${d['יח׳/ארגז']}, משטח=${d['יח׳/משטח']}]');
      }
    }
    expect(missing, isEmpty,
        reason:
            'reference product per family missing pack/pallet (CATALOG §13):\n'
            '${missing.join('\n')}');
  });

  test('§22-Huliot paranoid 12-check audit — cross-product consistency', () {
    final cat = kHuliotCatalog;
    final failures = <String>[];

    // #1 SKU uniqueness
    final skuCount = <String, int>{};
    for (final p in cat) {
      skuCount[p.sku] = (skuCount[p.sku] ?? 0) + 1;
    }
    final dupSkus = skuCount.entries.where((e) => e.value > 1).toList();
    if (dupSkus.isNotEmpty) {
      failures.add('#1 duplicate SKUs: ${dupSkus.map((e) => "${e.key}×${e.value}").join(", ")}');
    }

    // #2 nameHe uniqueness (key by full name — duplicates are R8 violations)
    final nameCount = <String, int>{};
    for (final p in cat) {
      nameCount[p.nameHe] = (nameCount[p.nameHe] ?? 0) + 1;
    }
    final dupNames = nameCount.entries.where((e) => e.value > 1).toList();
    if (dupNames.isNotEmpty) {
      failures.add('#2 duplicate nameHe: ${dupNames.map((e) => "\"${e.key}\"×${e.value}").join("; ")}');
    }

    // #3 every product has non-empty name
    final emptyN = cat.where((p) => p.nameHe.trim().isEmpty).toList();
    if (emptyN.isNotEmpty) {
      failures.add('#3 empty names: ${emptyN.length}');
    }

    // #4 SKU never appears in nameHe (antipattern — would echo SKU as title)
    final skuInName = cat.where((p) => p.nameHe.contains(p.sku)).toList();
    if (skuInName.isNotEmpty) {
      failures.add('#4 SKU appears in nameHe: ${skuInName.length}');
    }

    // #5 every product belongs to a known category
    final validCats = kHuliotCategories.toSet();
    final badCat = cat.where((p) => !validCats.contains(p.categoryHe)).toList();
    if (badCat.isNotEmpty) {
      failures.add('#5 invalid category: ${badCat.map((p) => "${p.sku}=${p.categoryHe}").take(3).join(", ")}');
    }

    // #6 page in valid range (catalog has product pages 11-43)
    final badPage = cat.where((p) => p.page < 11 || p.page > 43).toList();
    if (badPage.isNotEmpty) {
      failures.add('#6 page out of [11,43]: ${badPage.length}');
    }

    // #7 every product has at least 1 dim entry beyond יצרן+מק"ט
    final thinDims = cat.where((p) => (p.dims?.length ?? 0) < 3).toList();
    if (thinDims.isNotEmpty) {
      failures.add('#7 dims too thin (<3 entries): ${thinDims.length}');
    }

    // #8 every product is branded חוליות (was the regression with _brandDir)
    final wrongBrand = cat.where((p) => p.brand != 'חוליות').toList();
    if (wrongBrand.isNotEmpty) {
      failures.add('#8 wrong brand: ${wrongBrand.length}');
    }

    // #9 page coverage: at least 1 product per page in product-page range
    //    (11-43 is mostly product pages; allow gaps where the page is an
    //    informational diagram). Acceptable: TOC page or empty range.
    final productPages = cat.map((p) => p.page).toSet();
    final missingPages = <int>[];
    for (var pg = 11; pg <= 43; pg++) {
      if (!productPages.contains(pg)) missingPages.add(pg);
    }
    // Page 26 is an informational AQUA SLIM diagram (no SKUs on that page).
    final unexpectedMissing = missingPages.where((p) => p != 26).toList();
    if (unexpectedMissing.isNotEmpty) {
      failures.add('#9 product pages with zero SKUs (unexpected): $unexpectedMissing');
    }

    // #10 every dim value is a String (not int/double leaking through)
    final wrongType = <String>[];
    for (final p in cat) {
      for (final e in (p.dims ?? {}).entries) {
        if (e.value is! String) {
          wrongType.add('${p.sku} dims["${e.key}"]=${e.value} (${e.value.runtimeType})');
        }
      }
    }
    if (wrongType.isNotEmpty) {
      failures.add('#10 non-String dim values: ${wrongType.take(3).join(", ")}');
    }

    // #11 categoryEmoji is consistent (one emoji per catalog for v1 = 🚰)
    final emojis = cat.map((p) => p.categoryEmoji).toSet();
    if (emojis.length > 3) {
      failures.add('#11 too many distinct categoryEmoji (${emojis.length}): $emojis');
    }

    // #12 every product's nameHe carries the category root word (the singular
    //     stem of the categoryHe plural). Catches mis-categorisation.
    final namelessCat = <String>[];
    // Hebrew plural→singular roots (categoryHe is plural; nameHe is singular).
    const catRoot = <String, List<String>>{
      'מאספים': ['מאסף'],
      'מחסומים': ['מחסום'],
      'סיפונים SmartLock': ['סיפון', 'מחסום', 'ניקוז', 'מערכת', 'מבוא'],
      'מכסים, הגבהות ורשתות': ['מכסה', 'הגבהה', 'רשת', 'Top Floor'],
      'אביזרים משלימים': [],  // umbrella — too varied, skip
      'מאסף קווי AQUA SLIM': ['Aqua Slim', 'AQUA SLIM', 'פס', 'סט'],
      'אום SmartLock': ['אום'],
    };
    for (final p in cat) {
      final roots = catRoot[p.categoryHe] ??
          [p.categoryHe.split(RegExp(r'\s+')).first];
      if (roots.isEmpty) continue;
      final ok = roots.any((r) => p.nameHe.contains(r));
      if (!ok) {
        namelessCat.add('${p.sku} "${p.nameHe}" → cat="${p.categoryHe}"');
      }
    }
    if (namelessCat.isNotEmpty) {
      failures.add('#12 nameHe missing category root: ${namelessCat.take(3).join("; ")}');
    }

    expect(failures, isEmpty,
        reason: 'Huliot paranoid audit failed:\n${failures.join('\n')}');
  });

  // §22-Huliot every 2-3 digit token in nameHe must correspond to some dim
  // value (DN, D, D1/D2, DN1/DN2, L, angle, etc.). Catches typos / orphaned
  // numbers / wrong sizes. Skips numbers inside parentheses (which are
  // verbatim catalog notes like "(6)" or "(70)").
  test('§22-Huliot every numeric token in name is grounded in dims', () {
    final orphan = <String>[];
    for (final p in kHuliotCatalog) {
      // Strip parenthetical content (e.g. "סיפון 2" כפול לכיור אמריקאי (4)").
      final nameStripped = p.nameHe.replaceAll(RegExp(r'\([^)]*\)'), '');
      final nameNums =
          RegExp(r'\b(\d{2,4})\b').allMatches(nameStripped).map((m) => m.group(1)!).toSet();
      if (nameNums.isEmpty) continue;
      final dimNums = <String>{};
      for (final v in (p.dims ?? const {}).values) {
        final s = v.toString();
        for (final m in RegExp(r'\b(\d{2,4})\b').allMatches(s)) {
          dimNums.add(m.group(1)!);
        }
      }
      final orphaned = nameNums.difference(dimNums);
      if (orphaned.isNotEmpty) {
        orphan.add('${p.sku} "${p.nameHe}" → orphan nums: $orphaned');
      }
    }
    expect(orphan, isEmpty,
        reason: 'name has numbers not grounded in any dim — typo or missing '
            'dim:\n${orphan.take(12).join('\n')}');
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
        // p25 is sub-type-split (§22.D) — tested separately.
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
        // p26 is sub-type-split (§22.D) — tested separately.
        40: 'spec_tee_p40.jpg',
        // p41 is model-split (§22.C) — tested separately.
        51: 'spec_tee_p51.jpg',
        52: 'spec_tee_p52.jpg',
        82: 'spec_tee_p82.jpg',
      },
      kPprSaddles: {
        24: 'spec_saddle_p24.jpg',
        29: 'spec_saddle_p29.jpg',
        // p58 is model-split (§22.C) — tested separately.
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
        // round (non-hex). p27 sub-type-split (§22.D) — tested separately.
        29: 'spec_adapter_round_p29.jpg',
        // p53, p54, p55 all model-split by §22.C — tested separately below.
      },
      '${kPprAdapters}_hex': {
        // p28 sub-type-split (§22.D) — tested separately.
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

  // §22.D — p25 PPR threaded brass elbow 90° has 3 distinct sub-types:
  // משטח ריסון (with damper), חיצוני (external thread), פנימי (internal).
  test('§22.D p25 elbow_90 sub-type split — damper/external/internal', () {
    for (final p in kPolyrollCatalog.where((p) => p.page == 25)) {
      final s = p.specImageAssets.first.split('/').last;
      String want;
      if (p.nameHe.contains('משטח ריסון')) {
        want = 'spec_elbow_90_p25_damper.jpg';
      } else if (p.nameHe.contains('חיצוני')) {
        want = 'spec_elbow_90_p25_external.jpg';
      } else {
        want = 'spec_elbow_90_p25_internal.jpg';
      }
      expect(s, want, reason: '${p.sku} ${p.nameHe}');
    }
  });

  // §22.D — p26 PPR threaded brass tee: internal vs external thread split.
  test('§22.D p26 tee sub-type split — internal vs external thread', () {
    for (final p in kPolyrollCatalog.where((p) => p.page == 26)) {
      final s = p.specImageAssets.first.split('/').last;
      final want = p.nameHe.contains('חיצוני')
          ? 'spec_tee_p26_external.jpg'
          : 'spec_tee_p26_internal.jpg';
      expect(s, want, reason: '${p.sku} ${p.nameHe}');
    }
  });

  // §22.D — p27/p28 round/hex adapter: internal vs external thread split.
  test('§22.D p27 adapter round — internal vs external thread', () {
    for (final p in kPolyrollCatalog.where((p) => p.page == 27)) {
      final s = p.specImageAssets.first.split('/').last;
      final want = p.nameHe.contains('חיצוני')
          ? 'spec_adapter_round_p27_external.jpg'
          : 'spec_adapter_round_p27_internal.jpg';
      expect(s, want, reason: '${p.sku} ${p.nameHe}');
    }
  });
  test('§22.D p28 adapter hex — internal vs external thread', () {
    for (final p in kPolyrollCatalog.where((p) => p.page == 28)) {
      final s = p.specImageAssets.first.split('/').last;
      final want = p.nameHe.contains('חיצוני')
          ? 'spec_adapter_hex_p28_external.jpg'
          : 'spec_adapter_hex_p28_internal.jpg';
      expect(s, want, reason: '${p.sku} ${p.nameHe}');
    }
  });

  // §22.C — p58 PPR EF saddle: catalog "מודל" column assigns per-SKU.
  test('§22.C p58 saddle — Model A vs Model B per catalog table', () {
    const expectModel = {
      '6004800630': 'A', '6004800640': 'A', '6004801100': 'A',
      '6004800650': 'B', '6004801110': 'B', '6004801120': 'B',
    };
    final gaps = <String>[];
    for (final entry in expectModel.entries) {
      final p = kPolyrollCatalog.firstWhere((x) => x.sku == entry.key);
      final want = 'spec_saddle_p58_${entry.value.toLowerCase()}.jpg';
      if (!p.specImageAssets.first.endsWith(want)) {
        gaps.add('${entry.key} → ${p.specImageAssets.first} ≠ $want');
      }
      if (p.dims?['מודל'] != entry.value) {
        gaps.add('${entry.key}: model=${p.dims?['מודל']} ≠ ${entry.value}');
      }
    }
    expect(gaps, isEmpty, reason: gaps.join('\n'));
  });

  // §22.C — p41 PPR plain tee (large): 2 models split by size.
  test('§22.C p41 tee — Model A 160-250, Model B 315-400', () {
    const expectModel = {
      '6002300160': 'A', '6002300200': 'A', '6002300250': 'A',
      '6002300315': 'B', '6002300355': 'B', '6002300400': 'B',
    };
    final gaps = <String>[];
    for (final entry in expectModel.entries) {
      final p = kPolyrollCatalog.firstWhere((x) => x.sku == entry.key);
      final want = 'spec_tee_p41_${entry.value.toLowerCase()}.jpg';
      if (!p.specImageAssets.first.endsWith(want)) {
        gaps.add('${entry.key} → ${p.specImageAssets.first} ≠ $want');
      }
      if (p.dims?['מודל'] != entry.value) {
        gaps.add('${entry.key}: model=${p.dims?['מודל']} ≠ ${entry.value}');
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

  // §22.H — photo-only pages (EF p72-74, tools p90-92) have no dimension
  // drawing in the catalog, but they DO have a per-sub-type [photo + table]
  // block. Every product on these pages must resolve to a focused crop as its
  // FIRST spec asset — never the whole-page fallback as the primary.
  test('§22.H photo-only pages route to a focused crop, not the whole page', () {
    // Per-sub-type expected crop — keyed by a nameHe substring. The first
    // matching rule for the product's page wins (order matters where a page
    // has overlapping words). This asserts the SPECIFIC crop, so a sub-type
    // swap (e.g. p72 45°↔90°) is caught, not just "not the whole page".
    // page: ordered [nameHe-substring, expected-crop] rules; first match wins.
    // A product that matches NO rule is skipped — it has its own real spec
    // (e.g. the 3 אומגה on p74 use spec_omega_p74.jpg, not a §22.H crop).
    const expected = <int, List<List<String>>>{
      72: [['90', 'spec_ef_p72_90.jpg'], ['45', 'spec_ef_p72_45.jpg']],
      73: [['מצמד', 'spec_ef_p73_coupler.jpg'], ['מסעף', 'spec_ef_p73_tee.jpg']],
      74: [['מצמד', 'spec_ef_p74_coupler.jpg']],
      90: [['פלטת', 'spec_tool_p90_plate.jpg'],
           ['שולחני', 'spec_tool_p90_bench.jpg'],
           ['מכונת', 'spec_tool_p90_light.jpg'],
           ['מזוודת', 'spec_tool_p90_case.jpg']],
      91: [['מקדח', 'spec_tool_p91_bit.jpg'],
           ['תותב', 'spec_tool_p91_die.jpg'],
           ['מברגה', 'spec_tool_p91_driver.jpg']],
      92: [['חורים', 'spec_tool_p92_hole.jpg'],
           ['רוכב', 'spec_tool_p92_saddle.jpg']],
    };
    final gaps = <String>[];
    var asserted = 0;
    for (final p in kPolyrollCatalog.where((p) => expected.containsKey(p.page))) {
      final rules = expected[p.page]!;
      final match = rules.where((r) => p.nameHe.contains(r[0])).toList();
      if (match.isEmpty) continue; // product with its own real spec — not §22.H
      asserted++;
      final first = p.specImageAssets.first.split('/').last;
      final want = match.first[1];
      if (first != want) {
        gaps.add('${p.sku} p${p.page} (${p.nameHe}) → $first ≠ $want');
      }
      // The crop must exist on disk.
      if (!File(p.specImageAssets.first).existsSync()) {
        gaps.add('${p.sku} → missing ${p.specImageAssets.first}');
      }
      // The full page must still be available as a later pager slide.
      final hasPage =
          p.specImageAssets.any((a) => a.split('/').last.startsWith('page_'));
      if (!hasPage) gaps.add('${p.sku} → lost the full-page pager slide');
    }
    expect(gaps, isEmpty, reason: gaps.join('\n'));
    expect(asserted, greaterThanOrEqualTo(70),
        reason: 'expected ~75 photo-only products asserted, got $asserted');
  });
}

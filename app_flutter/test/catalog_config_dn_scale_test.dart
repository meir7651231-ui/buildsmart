// CATALOG-CONFIG · DN-scale golden — the קוטר axis folds inch + DN + plastic-OD
// onto ONE nominal-DN ladder. Inch uses the bore table (½"→DN15); every other
// number is an outer-diameter and snaps to the nearest REAL trade rung, which IS
// the DN — so 110→DN110 · 63→DN63 · 90→DN90 survive as their own step (the size
// names the pipe type & use · owner), while parse-noise (43 · 88 · 108) absorbs
// into the nearest real rung. Pins the mapping AND the real card wheel (values
// are canonical DN, ascending, with an inch hint baked into the label).
// Pure · exercised define-less (kCatalogConfig OFF).
import 'package:buildsmart/data/catalog_source.dart'
    show resolvedCatalogProducts;
import 'package:buildsmart/features/catalog_config/dn_scale.dart';
import 'package:buildsmart/features/catalog_config/product_chips.dart'
    show chipValuesOf, prioritizedSchema;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('#catalog-config dn_scale — canonicalDn goldens', () {
    test('inch → nominal-bore DN (owner: ½" IS DN15)', () {
      expect(canonicalDn('¼"'), 'DN8');
      expect(canonicalDn('3/8"'), 'DN10');
      expect(canonicalDn('½"'), 'DN15');
      expect(canonicalDn('¾"'), 'DN20');
      expect(canonicalDn('1"'), 'DN25');
      expect(canonicalDn('1¼"'), 'DN32');
      expect(canonicalDn('1½"'), 'DN40');
      expect(canonicalDn('2"'), 'DN50');
      expect(canonicalDn('2½"'), 'DN65');
      expect(canonicalDn('3"'), 'DN80');
      expect(canonicalDn('4"'), 'DN100');
      expect(canonicalDn('6"'), 'DN150');
      expect(canonicalDn('8"'), 'DN200');
    });

    test('plastic/PE OD keeps its OWN DN — the real trade sizes survive', () {
      // owner: "DN110 changes which piping it is and what it's used for".
      expect(canonicalDn('20'), 'DN20');
      expect(canonicalDn('63'), 'DN63');
      expect(canonicalDn('75'), 'DN75');
      expect(canonicalDn('90'), 'DN90');
      expect(canonicalDn('110'), 'DN110');
      expect(canonicalDn('160'), 'DN160');
      expect(canonicalDn('250 מ"מ'), 'DN250');
    });

    test('a legitimate DN (plastic OD or ISO bore) is kept — idempotent', () {
      expect(canonicalDn('DN40'), 'DN40');
      expect(canonicalDn('DN110'), 'DN110'); // plastic OD rung
      expect(canonicalDn('DN15'), 'DN15');
      // the ISO nominal-BORE rungs the inch table emits are kept too, so a
      // flange-rated fitting is never snapped down to a fabricated plastic size.
      expect(canonicalDn('DN80'), 'DN80');
      expect(canonicalDn('DN100'), 'DN100');
      expect(canonicalDn('DN150'), 'DN150');
      // idempotent on inch outputs (re-feeding DN100 must not re-snap to DN90).
      expect(canonicalDn(canonicalDn('4"')), 'DN100');
      expect(canonicalDn(canonicalDn('63')), 'DN63');
    });

    test('parse-noise absorbs into the nearest REAL rung', () {
      expect(canonicalDn('43'), 'DN40');
      expect(canonicalDn('88'), 'DN90');
      expect(canonicalDn('108'), 'DN110');
      expect(canonicalDn('122'), 'DN125');
      expect(canonicalDn('DN576'), 'DN400'); // huge outlier → biggest rung
    });

    test('an unparseable token passes through (never blanks a wheel)', () {
      expect(canonicalDn('לבן'), 'לבן');
      expect(canonicalDn(''), '');
    });
  });

  group('#catalog-config dn_scale — snap + sort helpers', () {
    test('snapOdToDn picks the nearest rung', () {
      expect(snapOdToDn(21.3), 20); // ½" thread OD
      expect(snapOdToDn(110), 110);
      expect(snapOdToDn(48), 50);
      expect(snapOdToDn(1000), 400);
    });

    test('dnNumber orders ascending by the DN integer (DN15 < DN110)', () {
      final labels = ['DN110', 'DN15', 'DN8', 'DN400', 'DN15 · ½"']
        ..sort((a, b) => dnNumber(a).compareTo(dnNumber(b)));
      expect(labels, ['DN8', 'DN15', 'DN15 · ½"', 'DN110', 'DN400']);
    });
  });

  group('#catalog-config dn_scale — REAL card wheel (prioritizedSchema)', () {
    test('the ברך wheel shows canonical DN, ascending, with an inch hint', () {
      final berekh =
          resolvedCatalogProducts.firstWhere((p) => p.sku == '213072');
      final diam = prioritizedSchema(berekh)
          .attributes
          .firstWhere((a) => a.id == 'diameter');

      // every wheel value is a canonical DN (no raw ½"/110/DN576 leaks through).
      for (final v in diam.values) {
        expect(v.canonical, matches(r'^DN\d+$'),
            reason: 'canonical must be a bare DN token: ${v.canonical}');
        expect(canonicalDn(v.canonical!), v.canonical);
      }
      // ascending by DN number.
      final nums = [for (final v in diam.values) dnNumber(v.canonical!)];
      expect(nums, orderedEquals([...nums]..sort()));
      // the inch hint is baked into the label (owner chose "DN15 · ½"").
      final dn15 = diam.values.firstWhere((v) => v.canonical == 'DN15');
      expect(dn15.labelHe, 'DN15 · ½"');
      // a plastic size shows the bare DN (no redundant hint).
      final dn110 = diam.values.firstWhere((v) => v.canonical == 'DN110');
      expect(dn110.labelHe, 'DN110');
    });

    test('matching token stays a bare canonical DN (variant swap still works)',
        () {
      final berekh =
          resolvedCatalogProducts.firstWhere((p) => p.sku == '213072');
      // 213072 = ברך 50/50 → its own diameter is DN50.
      expect(chipValuesOf(berekh)['diameter'], {'DN50'});
    });

    test('a flange-rated valve keeps its ISO bore DN (no fabricated size)', () {
      // 99041604 "ברז PPR כדורי בין אוגנים 110" carries dims['DN']=100 — the
      // flange nominal BORE (how a flange valve is actually specified), not an OD.
      // It must stay DN100 (a real, distinct rung), never snap to a fabricated
      // DN90 that collides with the plastic 90mm sizes on the wheel.
      final valve =
          resolvedCatalogProducts.firstWhere((p) => p.sku == '99041604');
      expect(chipValuesOf(valve)['diameter'], {'DN100'});
    });
  });
}

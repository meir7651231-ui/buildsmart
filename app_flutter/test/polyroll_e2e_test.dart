// End-to-end check — after `registerPolyrollSpecs()` runs, the PPR catalog
// gets rich output from every card helper that was empty before this bridge:
// installTools (welder), installEffort (מקצועי), installTips (PPR-specific),
// israeliStandards (ת"י 5452), compat (>0 mates within same DN family).
//
// This is the regression-gate for the Polyroll bridge: if any of these
// streams ever go empty again, this test goes red.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/polyroll_specs.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(registerPolyrollSpecs);

  group('PPR pipe DN20 (95016002) gets full card coverage', () {
    LipskeyCatalogProduct pipe() =>
        kPolyrollCatalog.firstWhere((p) => p.sku == '95016002');

    test('has a VerifiedSpec', () {
      expect(kVerifiedSpecs[pipe().sku], isNotNull);
    });

    test('installToolsFor mentions פוליפוזיה / socket fusion', () {
      final tools = installToolsFor(pipe());
      expect(tools, isNotEmpty);
      expect(tools.any((t) => t.contains('פוליפוזיה') || t.contains('socket fusion')),
          isTrue, reason: 'tools=$tools');
    });

    test('installEffortFor is מקצועי (heat-fusion requires training)', () {
      final eff = installEffortFor(pipe())!;
      expect(eff.difficulty, 'מקצועי');
      expect(eff.minutes, greaterThan(15));
    });

    test('installTipsFor includes a heat-fusion tip', () {
      final tips = installTipsFor(pipe());
      expect(tips, isNotEmpty);
      expect(
          tips.any(
              (t) => t.contains('לחמם') || t.contains('עומק') || t.contains('קירור')),
          isTrue);
    });

    test('israeliStandardsFor returns at least one supply standard', () {
      final std = israeliStandardsFor(pipe());
      expect(std, isNotEmpty);
      expect(std.any((s) => s.code == 'ת"י 5452'), isTrue,
          reason: 'PPR is a pressurised-supply fitting');
    });

    test('compatibleProductsFor returns at least one PPR mate', () {
      final mates = compatibleProductsFor(pipe());
      expect(mates, isNotEmpty,
          reason:
              'a DN20 PPR pipe should mate at least with a DN20 PPR fitting');
      // every mate must be PPR (same material family).
      for (final m in mates) {
        final s = kVerifiedSpecs[m.sku];
        expect(s?.material.startsWith('PPR'), isTrue,
            reason: 'non-PPR mate ${m.sku}');
      }
    });
  });

  group('PPR electrofusion variant gets the right tools', () {
    test('electrofusion category → ⚡ transformer instead of hand welder',
        () {
      final ef = kPolyrollCatalog
          .where((p) => p.categoryHe == kPprElectrofusion)
          .firstWhere((p) => polyrollSpecFor(p) != null);
      final tools = installToolsFor(ef);
      expect(tools.any((t) => t.contains('⚡') || t.contains('חשמלי')),
          isTrue, reason: 'tools=$tools');
    });
  });

  test(
      'complianceTriggersFor PPR adds its 4 material items WITHOUT swallowing '
      'standard supply compliance', () {
    final pipe = kPolyrollCatalog.firstWhere((p) => p.sku == '95016002');
    final trig = complianceTriggersFor(pipe);
    final labels = trig.map((t) => t.label).toList();
    // PPR-specific items present.
    expect(labels.any((l) => l.contains('EN ISO 15874')), isTrue);
    expect(labels.any((l) => l.contains('socket fusion')), isTrue);
    expect(labels.any((l) => l.contains('PN16')), isTrue);
    // Standard line-level checks are also present (this is the FIX — PPR
    // products used to early-return and miss these).
    expect(labels.any((l) => l.contains('ברז ניתוק')), isTrue,
        reason: 'every product needs an upstream shutoff');
  });

  test('aggregate coverage: ≥99% of PPR fusion-cat products yield rich tips',
      () {
    var checked = 0;
    var withTips = 0;
    for (final p in kPolyrollCatalog) {
      if (kVerifiedSpecs[p.sku] == null) continue;
      checked++;
      if (installTipsFor(p).isNotEmpty) withTips++;
    }
    expect(checked, greaterThan(700));
    expect(withTips / checked, greaterThanOrEqualTo(0.99),
        reason: '$withTips/$checked have tips');
  });
}

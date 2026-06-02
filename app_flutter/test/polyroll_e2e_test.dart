// End-to-end check — after `registerPolyrollSpecs()` runs, the PPR catalog
// gets rich output from every card helper that was empty before this bridge:
// installTools (welder), installEffort (מקצועי), installTips (PPR-specific),
// israeliStandards (ת"י 5452), compat (>0 mates within same DN family).
//
// This is the regression-gate for the Polyroll bridge: if any of these
// streams ever go empty again, this test goes red.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/huliot_smartlock_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/polyroll_specs.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/logic/install_kit.dart';
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

  test('connectionNeedsHe on PPR reads "PPR" / "ריתוך-שקע", not "HDPE"',
      () {
    final pipe = kPolyrollCatalog.firstWhere((p) => p.sku == '95016002');
    final needs = connectionNeedsHe(pipe);
    expect(needs, isNotEmpty);
    final joined = needs.join(' · ');
    expect(joined.contains('PPR'), isTrue,
        reason: 'PPR pipe needs should mention PPR · $joined');
    expect(joined.contains('HDPE'), isFalse,
        reason: 'PPR pipe needs must NOT label "HDPE" · $joined');
  });

  test('connectionExplainHe + chainEdgeLabelHe say "ריתוך-שקע" for PPR↔PPR',
      () {
    final pipe = kPolyrollCatalog.firstWhere((p) => p.sku == '95016002');
    final elbow = kPolyrollCatalog.firstWhere((p) => p.sku == '92117042');
    final carouselLabel = connectionExplainHe(pipe, elbow);
    final chainLabel = chainEdgeLabelHe(pipe, elbow);
    expect(carouselLabel.contains('ריתוך-שקע'), isTrue,
        reason: 'carousel label · $carouselLabel');
    expect(chainLabel.contains('ריתוך-שקע'), isTrue,
        reason: 'chain label · $chainLabel');
    expect(carouselLabel.contains('אום הידוק'), isFalse,
        reason: 'PPR must NOT read as compression-nut');
  });

  test(
      'engineeringSpecFor on PPR DN20 fiber uses real Di (~14.4mm), not DN',
      () {
    // sku 95270708 = צינור PPR פייזר 20×2.8 with di קוטר פנימי = 14.4mm.
    final fiber = kPolyrollCatalog.firstWhere((p) => p.sku == '95270708');
    final eng = engineeringSpecFor(fiber)!;
    // Should NOT be 20 (the DN/OD); should be the real internal diameter.
    expect(eng.minBoreMm, isNotNull);
    expect(eng.minBoreMm! < 20, isTrue,
        reason:
            'PPR thick wall → internal bore < DN. got minBoreMm=${eng.minBoreMm}');
    expect(eng.minBoreMm! > 10, isTrue,
        reason: 'sanity — bore for DN20 fiber should be > 10mm');
  });

  test('recommendedKitForProduct on PPR returns the welding kit', () {
    final pipe = kPolyrollCatalog.firstWhere((p) => p.sku == '95016002');
    final kit = recommendedKitForProduct(pipe);
    final labels = kit.map((k) => k.label).join(' · ');
    expect(labels.contains('ריתוך-שקע'), isTrue,
        reason: 'PPR kit must mention socket fusion welder · $labels');
    expect(labels.contains('compression') || labels.contains('חבישה'),
        isFalse,
        reason: 'PPR kit must NOT contain a compression wrench (wrong tool)');
  });

  test('recommendedKitFor (chain) on PPR↔PPR joint uses welder, not compression',
      () {
    final pipe = kPolyrollCatalog.firstWhere((p) => p.sku == '95016002');
    final elbow = kPolyrollCatalog.firstWhere((p) => p.sku == '92117042');
    final kit = recommendedKitFor([pipe, elbow]);
    final labels = kit.map((k) => k.label).join(' · ');
    expect(labels.contains('ריתוך-שקע'), isTrue,
        reason: 'PPR↔PPR chain kit must use welder · $labels');
    expect(labels.contains('חבישה'), isFalse,
        reason: 'PPR↔PPR chain must NOT use compression wrench');
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

  // ── P6: Huliot SmartLock brand-wiring into the shared product functions ──
  // Without these branches, Huliot fell through to defaults: no "נמצא ב"
  // group, no engineering-spec card, no standards row. These guard the wiring.
  group('P6 · Huliot brand-wiring', () {
    LipskeyCatalogProduct huliot(String sku) =>
        kHuliotCatalog.firstWhere((p) => p.sku == sku);

    test('finderGroupFor → דלוחין SmartLock (not null/אספקת מים)', () {
      for (final sku in ['64032300', '70940160', '61230060']) {
        final g = finderGroupFor(huliot(sku));
        expect(g, isNotNull, reason: '$sku must have a finder group');
        expect(g!.label, 'דלוחין SmartLock', reason: '$sku label');
        expect(g.emoji, '🟢');
      }
    });

    test('engineeringSpecFor → drainage snapshot (PP, no PN, 95°C)', () {
      final eng = engineeringSpecFor(huliot('64051300'))!; // צינור חלק 50
      expect(eng.material.contains('PP'), isTrue, reason: eng.material);
      expect(eng.pressureRating, isNull,
          reason: 'gravity drainage — no PN (R8: no PN column)');
      expect(eng.maxTempC, 95);
      expect(eng.waterSystem.contains('דלוחין'), isTrue);
      expect(eng.minBoreMm, 50, reason: 'DN50 → bore 50');
    });

    test('complianceTriggersFor → Huliot ת"י standards present', () {
      final labels =
          complianceTriggersFor(huliot('70145960')).map((t) => t.label).toList();
      expect(labels.any((l) => l.contains('958-1')), isTrue);
      expect(labels.any((l) => l.contains('5694')), isTrue);
      expect(labels.any((l) => l.contains('14020')), isTrue);
      expect(labels.any((l) => l.contains('EN-1451')), isTrue);
      // Must NOT leak the PPR supply standards (wrong system).
      expect(labels.any((l) => l.contains('EN ISO 15874')), isFalse,
          reason: 'drainage product must not carry PPR supply compliance');
    });

    test('every Huliot product gets a finder group (no orphans)', () {
      final orphans =
          kHuliotCatalog.where((p) => finderGroupFor(p) == null).toList();
      expect(orphans, isEmpty,
          reason: 'Huliot products without a group: '
              '${orphans.take(5).map((p) => p.sku).join(",")}');
    });
  });
}

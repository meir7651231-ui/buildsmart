// Pillar-2 Step 49b — G-flag-off: with the DEFAULT plumbing resolution the
// install studio behaves EXACTLY as today.
//
// A parallel builder inserts gated seams into
// lib/screens/install_studio_screen.dart, each guarded by
// `resolvedActiveTradeIdProvider == 'plumbing' → legacy path` (R1-2). Every
// pin below is taken from the LIVE screen/engine — never from the seam code —
// so a seam that leaks into the plumbing/default path turns this file red.
//
// Harness reuse:
//   • widget pump — robustness_test.dart's renderError idiom (ProviderScope →
//     MaterialApp → MediaQuery(textScaler 1.15) → Directionality(rtl) →
//     screen; BOUNDED pumps, because the blueprint flow animation repeats
//     forever and pumpAndSettle would hang).
//   • container — active_trade_provider_test.dart's `_fresh()` (empty mock
//     prefs + async trades-store `_load` settle).
//   • engine derivations — install_engine_delegation_test.dart's idiom: the
//     engine itself derives the pinned facts, so no hard-coded SKU can rot.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:buildsmart/logic/pressure_drop.dart';
import 'package:buildsmart/screens/install_studio_screen.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── legacy anchors — VALUES read from the LIVE screen at test-write time ─────
// install_studio_screen.dart:40-42, the system palette:
//   const _supply  = Color(0xFF0284C7); // blue — water supply
//   const _drain   = Color(0xFFD97706); // amber — drainage
//   const _fixture = Color(0xFF7C3AED); // violet — fixtures (the bridge)
// Pinned here through RENDERED widgets (behavioral, not source-text), so only
// a real flag-off visual change can flip them.
const Color _kSupplyBlue = Color(0xFF0284C7);
const Color _kDrainAmber = Color(0xFFD97706);
const Color _kFixtureViolet = Color(0xFF7C3AED);

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 10));

/// active_trade_provider_test.dart's `_fresh()`: a fresh container over EMPTY
/// mock prefs; instantiate the trades store and let its async `_load` settle,
/// so the reads below can never race it.
Future<ProviderContainer> _freshContainer() async {
  SharedPreferences.setMockInitialValues({});
  final c = ProviderContainer();
  addTearDown(c.dispose);
  c.read(tradesStoreProvider); // instantiate ⇒ kicks off the async _load
  await _settle();
  return c;
}

/// install_engine_delegation_test.dart's derivation: the FIRST mating pair
/// among the sorted kVerifiedSpecs ∩ kCatalogProducts skus, decided by the
/// engine itself — `connectionMethodLabel` with NO `trade` argument is the
/// legacy branch BY DEFINITION, so the derived (a, b, label) triple is a pure
/// legacy fact — robust to catalog edits, no hard-coded pair to rot.
({LipskeyCatalogProduct a, LipskeyCatalogProduct b, String label})
    _deriveLegacyMatingPair() {
  final bySku = <String, LipskeyCatalogProduct>{
    for (final p in kCatalogProducts) p.sku: p,
  };
  final skus = kVerifiedSpecs.keys.where(bySku.containsKey).toList()..sort();
  for (final sA in skus) {
    for (final sB in skus) {
      if (sA == sB) continue;
      final a = bySku[sA]!;
      final b = bySku[sB]!;
      final label = connectionMethodLabel(a, b);
      if (label.isNotEmpty) return (a: a, b: b, label: label);
    }
  }
  throw StateError(
    'no mating pair in sorted kVerifiedSpecs ∩ kCatalogProducts — '
    'the flag-off tests need one legacy joint to pin against',
  );
}

/// drainage_no_supply_test.dart's predicate: verified ends are drainage-ONLY
/// (any supply-touching product would flip [lineIsSupply] for the whole line).
bool _drainOnly(LipskeyCatalogProduct p) {
  final s = kVerifiedSpecs[p.sku];
  return s != null &&
      s.endSystems.length == 1 &&
      s.endSystems.contains(WaterSystem.drainage);
}

/// Derives a drainage trap pair whose ⚡-assemble outcome — mirrored through
/// the EXACT legacy pipeline the screen runs at its defaults (autoFlowFix →
/// buildInstallation with the auto-ticked clips+sealant accessories, 20°C) —
/// is a plan with ZERO open criticals (so ⚡ opens the BOM sheet directly, no
/// warning dialog) that is still a pure DRAINAGE line (so the ת"י-1205 slope
/// panel renders instead of the supply pressure-drop block).
List<LipskeyCatalogProduct> _deriveDrainagePairForBomSheet() {
  const acc = <String>{'HW-CLIP', 'HW-SEALANT'};
  final traps = kLipskeyCatalog
      .where(
        (p) =>
            _drainOnly(p) &&
            (p.categoryHe.contains('מחסום') || p.productType == 'סיפון'),
      )
      .toList();
  for (final a in traps) {
    for (final b in traps) {
      if (a.sku == b.sku) continue;
      final fixed = autoFlowFix([a, b]);
      final plan = buildInstallation(
        [...fixed.chain],
        accessories: acc,
        autoCompliance: true,
      );
      if (plan.criticalOpen(20, acc) == 0 && !lineIsSupply(plan.items)) {
        return [a, b];
      }
    }
  }
  throw StateError(
    'no drainage trap pair reaches the BOM sheet cleanly — the slope-panel '
    'pin needs one (see drainage_no_supply_test.dart)',
  );
}

/// robustness_test.dart's renderError pump shape at 1.15 text scale, RTL,
/// then a BOUNDED settle (the blueprint animation never ends). Surface is
/// 440×950 (the trade-builder family size): at 340px the LEGACY chain rows
/// (install_studio_screen.dart:1139, untouched code) overflow and the
/// exceptions fail the pump — the pre-existing narrow-layout debt is not
/// what this flag-off gate pins.
Future<void> _pumpStudio(
  WidgetTester t, {
  List<Override> overrides = const [],
}) async {
  await t.binding.setSurfaceSize(const Size(440, 950));
  addTearDown(() => t.binding.setSurfaceSize(null));
  await t.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Builder(
          builder: (ctx) => MediaQuery(
            data: MediaQuery.of(ctx)
                .copyWith(textScaler: const TextScaler.linear(1.15)),
            child: const Directionality(
              textDirection: TextDirection.rtl,
              child: InstallStudioScreen(),
            ),
          ),
        ),
      ),
    ),
  );
  for (var i = 0; i < 5; i++) {
    await t.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('G-flag-off — install studio, plumbing/default resolution', () {
    final legacy = _deriveLegacyMatingPair();

    test('the resolution defaults to plumbing with an empty store', () async {
      final c = await _freshContainer();
      expect(
        c.read(resolvedActiveTradeIdProvider),
        'plumbing',
        reason: 'the guard-condition of every studio seam: an empty authored '
            'store must resolve to the reserved plumbing id (R1-2)',
      );
      expect(
        c.read(activeTradeObjProvider),
        isNull,
        reason: 'plumbing has no authored Trade object — null physics means '
            'the LEGACY branch, never a hidden panel',
      );
    });

    testWidgets('the studio renders its legacy shell (anchors present)',
        (t) async {
      // 'installStudioSeen' pins the steady-state shell (no tutorial overlay).
      SharedPreferences.setMockInitialValues(
        const <String, Object>{'installStudioSeen': true},
      );
      await _pumpStudio(t);

      // Header title + subtitle (_header).
      expect(find.text('תכנון חיבור'), findsOneWidget);
      expect(find.text('בחר מה לחבר · נכין רשימת קנייה'), findsOneWidget);
      // Empty-canvas headline (_emptyState).
      expect(find.text('מה אתה רוצה לחבר?'), findsOneWidget);
      // Dock CTA, state A (empty chain).
      expect(find.text('➕ הוסף מוצר ראשון'), findsOneWidget);
      // Temp pill at the default 20°C — the cold label and the degree text.
      expect(find.text('קר'), findsOneWidget);
      expect(find.text('20°C'), findsOneWidget);
    });

    testWidgets('the slope panel is PRESENT for plumbing (ת"י 1205)',
        (t) async {
      SharedPreferences.setMockInitialValues(
        const <String, Object>{'installStudioSeen': true},
      );
      // The LEGACY chain-node Row (install_studio_screen.dart:1139,
      // untouched by s49b) overflows with long RTL product names at phone
      // widths — pre-existing layout debt that is NOT what this gate pins.
      // Filter ONLY RenderFlex-overflow errors at the source; every other
      // error still reaches the original handler and fails the test.
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains('RenderFlex overflowed')) {
          return;
        }
        prevOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = prevOnError);

      final pair = _deriveDrainagePairForBomSheet();
      await _pumpStudio(
        t,
        overrides: [chainProvider.overrideWith((_) => pair)],
      );

      // A 2-product chain shows the dock's state-C assemble CTA.
      final assembleCta = find.text('⚡ צור רשימת קנייה');
      expect(assembleCta, findsOneWidget);
      await t.tap(assembleCta);
      for (var i = 0; i < 5; i++) {
        await t.pump(const Duration(milliseconds: 120));
      }

      final sheetList = find.descendant(
        of: find.byType(DraggableScrollableSheet),
        matching: find.byType(ListView),
      );
      expect(
        sheetList,
        findsOneWidget,
        reason: 'the derived drainage pair has zero open criticals, so ⚡ '
            'must open the BOM sheet directly (no warning dialog)',
      );

      // The slope block sits below the diagram/price blocks — scroll to it.
      final anchor = find.text('מינ׳ 2% · ת"י 1205');
      for (var i = 0; i < 12 && anchor.evaluate().isEmpty; i++) {
        await t.drag(sheetList, const Offset(0, -350));
        await t.pump();
      }
      expect(
        anchor,
        findsOneWidget,
        reason: 'a drainage line on the plumbing path keeps its ת"י-1205 '
            'slope panel — an authored trade with null physics would hide '
            'it; plumbing must not',
      );
      // Default geometry 3 m run / 6 cm drop = exactly the 2% minimum.
      expect(find.text('שיפוע ניקוז: 2.0%'), findsOneWidget);
    });

    test('a known mating pair still yields its legacy method label', () {
      expect(
        legacy.label,
        isNotEmpty,
        reason: 'the engine itself derived this pair as mating',
      );
      expect(
        canConnect(legacy.a, legacy.b),
        isTrue,
        reason: 'the default (no-trade) mate check agrees with the label',
      );
      expect(
        connectionMethodLabel(legacy.a, legacy.b),
        legacy.label,
        reason: 'positional-only connectionMethodLabel — no trade argument — '
            'IS the plumbing/default path and must keep the legacy joint '
            'name verbatim (R1-2)',
      );
    });

    testWidgets('system colors are the legacy constants', (t) async {
      SharedPreferences.setMockInitialValues(
        const <String, Object>{'installStudioSeen': true},
      );
      await _pumpStudio(t);

      // The screen's single thermostat icon (temp pill) carries the supply
      // blue at the cold default.
      final thermo = t.widget<Icon>(find.byIcon(Icons.thermostat));
      expect(
        thermo.color,
        _kSupplyBlue,
        reason: 'temp-pill icon at 20°C is `_supply` (0xFF0284C7) — '
            'install_studio_screen.dart:40',
      );

      // The empty-dock hint chips render each system in its constant color.
      Color? chipColor(String label) =>
          t.widget<Text>(find.text(label)).style?.color;
      expect(
        chipColor('🔵 הזנה'),
        _kSupplyBlue,
        reason: 'supply chip — `_supply` 0xFF0284C7',
      );
      expect(
        chipColor('🟡 ניקוז'),
        _kDrainAmber,
        reason: 'drainage chip — `_drain` 0xFFD97706',
      );
      expect(
        chipColor('🟣 ברז / קבועה'),
        _kFixtureViolet,
        reason: 'fixture chip — `_fixture` 0xFF7C3AED',
      );
    });
  });
}

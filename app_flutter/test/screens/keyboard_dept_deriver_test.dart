// keyboard_dept_deriver — PURE MIRROR ENGINE tests for the מחלקות tab, MIRRORING
// test/screens/keyboard_store_deriver_test.dart /
// test/screens/keyboard_updates_deriver_test.dart (the proven, gate-green
// pattern) arm-for-arm.
//
// WHY THIS FILE IS THE WHOLE COVERAGE OF THE FLAG-ON LOGIC: the floating
// keyboard's live-mirror branch is gated by a compile-time `const kKbLiveMirror`
// (+ a runtime tier), and `flutter test` does NOT forward `--dart-define` to
// consts (feature_flags.dart) — so the flag-ON code path is unreachable from a
// unit test THROUGH the keyboard. The plan's deliberate design answer is that
// `deriveDeptContext` is a PURE FUNCTION taking its location as the only input
// and reading NO providers/context, so its ON logic is fully unit-testable with a
// hand-built location regardless of the flag. These tests exercise that pure
// function directly — they are the authoritative proof of the department mirror's
// chips, its dispatch surface, its tool base, determinism, and the
// pairwise-disjointness the dispatch fall-through relies on.
//
// Two layers (identical structure to the store/עדכונים files):
//   • PURE (no widget): the deriver is a value→value function; assert the EXACT
//     four department chips, the destByChip key-set (all REAL registry
//     destinations, by label), the empty runByChip, all-navigable, NEVER blank,
//     NO cap, the toolBase LABELS, determinism, and disjointness.
//   • DISPATCH (testWidgets + a capturing Consumer, hermetic ProviderContainer):
//     ACTUALLY INVOKE the returned KbDestination.run closures and assert they set
//     the right providers (homeDepartment + tab 1 + the catalog-drill reset) and
//     KEEP THE OVERLAY FLOATING (no Navigator.push from a chip) — the "run the
//     code" tier the reliability charter prefers over inspection.
//
// SharedPreferences.setMockInitialValues({}) is seeded for the widget layer
// (boardAuth/feature-flags read prefs lazily); the pure layer needs no binding.

import 'package:buildsmart/data/catalog_tree.dart' show CatalogNode;
import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show WaterSystem;
import 'package:buildsmart/logic/system_division.dart'
    show catalogSystemFilterProvider;
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogTreePathProvider;
import 'package:buildsmart/screens/departments_screen.dart'
    show deptFlatProductsProvider, homeDepartmentProvider;
import 'package:buildsmart/screens/keyboard_dept_deriver.dart';
import 'package:buildsmart/screens/keyboard_destinations.dart'
    show KbDestination, kbDestinations;
import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show KbToolNode, kbDeptNodes;
import 'package:buildsmart/screens/keyboard_updates_deriver.dart'
    show KbUpdatesContext;
import 'package:buildsmart/state/dept_location.dart';
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The four LIVE department labels the DeptRoot row must show, in OWNER order —
/// the SAME quartet the keyboard's hardcoded `labelsByTab[1]` shows today
/// (floating_card_keyboard.dart:356-361), so the deriver's root row is
/// byte-identical to the flag-OFF tab-1 row. Each owns a real registry
/// KbDestination (reusing `_openDepartment`).
const List<String> _kDeptChips = <String>[
  'אינסטלציה',
  'ברזים וסניטריים',
  'כלי עבודה ידני',
  'כלי עבודה חשמלי',
];

/// The tool-node LABELS the department surface installs (the comparable
/// projection — tool closures are never structurally equal, so equality keys on
/// the visible labels). Pinned to the REAL [kbDeptNodes] factory below so a label
/// edit there propagates automatically rather than silently diverging.
List<String> _toolLabels(KbUpdatesContext ctx) => <String>[
      for (final KbToolNode n in ctx.toolBase ?? const <KbToolNode>[]) n.label,
    ];

List<String> _deptNodeLabels() => <String>[for (final n in kbDeptNodes()) n.label];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ───────────────────────────────────────────────────────────────────────────
  // PURE: value→value, no widget tree. The strongest, most deterministic layer.
  // ───────────────────────────────────────────────────────────────────────────
  group('deriveDeptContext — DeptRoot arm (the 4 department chips)', () {
    const root = DeptRoot();

    test('chips are EXACTLY the 4 live departments, in owner order', () {
      final ctx = deriveDeptContext(root);
      expect(ctx.row.chips, _kDeptChips,
          reason: 'the root predictions are the four department chips, in '
              'owner order');
    });

    test('all four department chips are REAL registry KbDestinations '
        '(destByChip), runByChip is empty', () {
      final ctx = deriveDeptContext(root);
      expect(ctx.row.destByChip.keys.toSet(), _kDeptChips.toSet(),
          reason: 'each department chip dispatches via destByChip (ii)');
      expect(ctx.row.runByChip, isEmpty,
          reason: 'the departments are static nav targets → runByChip is empty '
              '(never a dynamic per-item closure)');

      // The destinations are sourced BY LABEL from the registry — identity-equal
      // to the same-label entries kbDestinations() returns, so they carry the
      // real `_openDepartment` runs (not a stub).
      final byLabel = {for (final d in kbDestinations()) d.label: d};
      for (final label in _kDeptChips) {
        expect(identical(ctx.row.destByChip[label], byLabel[label]), isTrue,
            reason: '"$label" must be the registry destination, by label');
      }
    });

    test('every department chip is navigable (gets the nav glyph)', () {
      final ctx = deriveDeptContext(root);
      expect(ctx.row.destinationChips, _kDeptChips.toSet(),
          reason: 'the whole department row is one-tap navigation → all '
              'navigable');
    });

    test('the row is NEVER blank — the four are STATIC, NO cap, no data param',
        () {
      // The departments surface carries no data param (the per-department PRODUCT
      // content is the CATALOG phase), so it ALWAYS renders all four. Unlike the
      // dynamic cart/orders/chats arms there is NO cap to apply — the four are a
      // fixed set like the 6 store service / 6 updates notif chips.
      final ctx = deriveDeptContext(root);
      expect(ctx.row.chips.length, _kDeptChips.length,
          reason: 'the four static department chips always render (NO cap)');
      expect(ctx.row.chips.length, 4,
          reason: 'exactly the four live departments — never truncated');
    });

    test('toolBase is the department tools (kbDeptNodes())', () {
      final ctx = deriveDeptContext(root);
      expect(_toolLabels(ctx), _deptNodeLabels(),
          reason: 'the root installs the kbDeptNodes() factory');
      // Pin to the REAL factory (not just a hardcoded copy): the deriver must
      // install exactly kbDeptNodes(), so a label edit there propagates here
      // automatically rather than silently diverging. (Mirrors the store/עדכונים
      // arms' factory-pin.)
      expect(_toolLabels(ctx), ['עץ חכם', 'מאתר', 'מסלול עבודה'],
          reason: 'the department tools are עץ חכם / מאתר / מסלול עבודה, in '
              'order (kbDeptNodes verbatim)');
    });
  });

  // ── DISPATCH DISJOINTNESS — the structural fall-through guarantee ───────────
  group('dispatch maps are pairwise-disjoint', () {
    void assertDisjoint(KbUpdatesContext ctx, String arm) {
      final dest = ctx.row.destByChip.keys.toSet();
      final run = ctx.row.runByChip.keys.toSet();
      expect(dest.intersection(run), isEmpty,
          reason: '$arm: destByChip ∩ runByChip must be empty so the dispatch '
              'fall-through is structural, not coincidental');
    }

    test('DeptRoot: destByChip ∩ runByChip == ∅', () {
      assertDisjoint(deriveDeptContext(const DeptRoot()), 'DeptRoot');
    });

    test('every department chip IS a registry destination label (the four are '
        'real nav targets, not free-text)', () {
      // The departments are STATIC destByChip nav chips (unlike the dynamic
      // cart/order/service runByChip chips, which must stay OUT of the registry).
      // So the dual assertion here is the INVERSE of the store/עדכונים dynamic
      // check: every department label MUST be present in the registry (it is a
      // real KbDestination reached by typing too), confirming the chip carries a
      // verified nav action rather than a keep-floating no-op.
      final destLabels = {for (final d in kbDestinations()) d.label};
      for (final label in _kDeptChips) {
        expect(destLabels.contains(label), isTrue,
            reason: 'department "$label" must BE a registry destination (a real '
                'nav target reused by label)');
      }
    });
  });

  // ── DETERMINISM (purity) ───────────────────────────────────────────────────
  group('deriver is deterministic (same location ⇒ equal context)', () {
    test('DeptRoot: two calls produce == contexts', () {
      const loc = DeptRoot();
      expect(deriveDeptContext(loc), deriveDeptContext(loc),
          reason: 'pure: identical input ⇒ identical (==) context (no '
              'per-frame churn)');
    });

    test('the context value-equality covers chips + dispatch keys + tool labels',
        () {
      // A second derive that differs in NOTHING must compare equal across all
      // three projections the KbUpdatesContext/KbPredRow equality keys on (chips,
      // the destByChip/runByChip key-sets, and the toolBase labels).
      final a = deriveDeptContext(const DeptRoot());
      final b = deriveDeptContext(const DeptRoot());
      expect(a, b);
      expect(a.hashCode, b.hashCode,
          reason: 'equal contexts ⇒ equal hashCode (the Provider de-dup key)');
    });
  });

  // ── FLAG-OFF BYTE-IDENTITY (deriver layer) ─────────────────────────────────
  // The widget-level flag-OFF regression (tab-1 row + typed path + tabs 0/2/3
  // unchanged) is ALREADY covered, green, by
  // test/screens/floating_card_keyboard_test.dart's 'tab 1 → the 4 departments'
  // case (and the tab-scoping checks around it), which pumps the REAL
  // FloatingCardKeyboard with kKbLiveMirror at its const default OFF and
  // featureFlagsProvider empty (kKbLiveMirrorFlag is not in _forcedOnFlags), so
  // the mirror branch + the build() watches fold out and the hardcoded
  // ['אינסטלציה','ברזים וסניטריים','כלי עבודה ידני','כלי עבודה חשמלי'] tab-1 row
  // is what renders. We do NOT duplicate that here. What we add is the
  // COMPLEMENT: proof that when the flag IS on, the deriver's DeptRoot row is
  // byte-identical to that preserved hardcoded row — so the flag flip changes
  // timing/wiring, never the entry row the user sees.
  group('flag-OFF byte-identity (deriver root == the hardcoded tab-1 row)', () {
    test('the deriver DeptRoot row equals labelsByTab[1] exactly', () {
      // This list is copied byte-for-byte from floating_card_keyboard.dart's
      // const labelsByTab[1] (verified, lines 356-361). The deriver must emit the
      // same labels in the same order so flag-ON's entry == flag-OFF's entry.
      const hardcodedTab1Row = <String>[
        'אינסטלציה',
        'ברזים וסניטריים',
        'כלי עבודה ידני',
        'כלי עבודה חשמלי',
      ];
      final ctx = deriveDeptContext(const DeptRoot());
      expect(ctx.row.chips, hardcodedTab1Row,
          reason: 'deriver root chips == the preserved tab-1 row');
      expect(ctx.row.destByChip.keys.toSet(), hardcodedTab1Row.toSet(),
          reason: 'and they carry the same by-label registry destinations');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // DISPATCH (run the code): invoke the returned KbDestination.run closures
  // against a real container + BuildContext and assert they set the right
  // providers AND keep the overlay floating (no Navigator.push from a chip). A
  // capturing Consumer hands us the (ref, context) the floating keyboard would
  // supply at tap time.
  // ───────────────────────────────────────────────────────────────────────────
  group('dispatch closures (invoked) set providers + keep floating', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    /// Pumps a tiny Consumer that captures the live (WidgetRef, BuildContext) and
    /// records every route pushed onto the Navigator, so a test can invoke a
    /// dispatch closure exactly as the keyboard would and assert no nav occurred.
    Future<({WidgetRef ref, BuildContext context, List<Route<dynamic>> pushed})>
        pumpRunner(WidgetTester tester, ProviderContainer container) async {
      late WidgetRef capturedRef;
      late BuildContext capturedContext;
      final pushed = <Route<dynamic>>[];
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorObservers: [_PushSpy(pushed)],
            home: Consumer(
              builder: (context, ref, _) {
                capturedRef = ref;
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return (ref: capturedRef, context: capturedContext, pushed: pushed);
    }

    testWidgets(
        'a department chip KbDestination.run opens that department '
        '(homeDepartment + tab 1 + catalog reset), no push', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final r = await pumpRunner(tester, container);

      // Seed a STALE drill so the reset is observable: a non-empty tree path, a
      // flat-products flag, a system filter, and the wrong tab. _openDepartment
      // must clear all of them (exactly as a department tile does). The seed
      // values use the REAL provider element types (List<CatalogNode>, the
      // WaterSystem enum) so the reset assertions exercise the actual contract.
      container.read(mainTabProvider.notifier).state = 3;
      container.read(catalogTreePathProvider.notifier).state = const [
        CatalogNode(id: 'stale', title: 'stale', emoji: '🪠'),
      ];
      container.read(deptFlatProductsProvider.notifier).state = true;
      container.read(catalogSystemFilterProvider.notifier).state =
          WaterSystem.supply;

      final ctx = deriveDeptContext(const DeptRoot());
      final before = r.pushed.length;

      // אינסטלציה → _openDepartment('אינסטלציה'): tab 1 + homeDepartment +
      // catalog drill reset.
      final KbDestination plumbing = ctx.row.destByChip['אינסטלציה']!;
      plumbing.run(r.ref, r.context);
      await tester.pump();

      expect(container.read(homeDepartmentProvider), 'אינסטלציה',
          reason: 'the chip selects that department');
      expect(container.read(mainTabProvider), 1,
          reason: 'and brings the מחלקות tab (index 1) forward');
      expect(container.read(catalogTreePathProvider), isEmpty,
          reason: 'the stale catalog drill path is RESET (lands on the dept '
              'top view, not a stale path)');
      expect(container.read(deptFlatProductsProvider), isFalse,
          reason: 'the flat-products flag is reset');
      expect(container.read(catalogSystemFilterProvider), isNull,
          reason: 'the system filter is reset');
      expect(r.pushed.length, before,
          reason: 'a department chip swaps the screen under the overlay — no '
              'route push (keep-floating)');
    });

    testWidgets(
        'each of the four department chips selects its OWN department, no push',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final r = await pumpRunner(tester, container);

      final ctx = deriveDeptContext(const DeptRoot());
      final before = r.pushed.length;

      // Walk all four chips — each must land homeDepartmentProvider on its own
      // label (proving the by-label registry resolution wired the right run to
      // the right chip, never a cross-wired or shared closure).
      for (final label in _kDeptChips) {
        // Clear so each selection is a genuine, observable change.
        container.read(homeDepartmentProvider.notifier).state = null;
        ctx.row.destByChip[label]!.run(r.ref, r.context);
        await tester.pump();
        expect(container.read(homeDepartmentProvider), label,
            reason: 'department chip "$label" opens department "$label"');
        expect(container.read(mainTabProvider), 1,
            reason: 'and brings the מחלקות tab forward');
      }

      expect(r.pushed.length, before,
          reason: 'no department chip pushes a route — all keep-floating');
    });
  });
}

/// Records every route pushed onto the Navigator, so a test can prove a dispatch
/// closure performed NO navigation (the keep-floating guarantee: a chip sets a
/// provider; only the SCREEN — not the keyboard — ever pushes a route).
class _PushSpy extends NavigatorObserver {
  _PushSpy(this.pushed);
  final List<Route<dynamic>> pushed;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
    super.didPush(route, previousRoute);
  }
}

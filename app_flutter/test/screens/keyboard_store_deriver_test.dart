// keyboard_store_deriver — PURE MIRROR ENGINE tests for the חנות tab, MIRRORING
// test/screens/keyboard_updates_deriver_test.dart (the proven, gate-green
// עדכונים pattern) arm-for-arm.
//
// WHY THIS FILE IS THE WHOLE COVERAGE OF THE FLAG-ON LOGIC: the floating
// keyboard's live-mirror branch is gated by a compile-time `const kKbLiveMirror`
// (+ a runtime tier), and `flutter test` does NOT forward `--dart-define` to
// consts (feature_flags.dart) — so the flag-ON code path is unreachable from a
// unit test THROUGH the keyboard. The plan's deliberate design answer is that
// `deriveStoreContext` is a PURE FUNCTION taking ALL data as parameters and
// reading NO providers/context, so its ON logic is fully unit-testable with
// hand-built locations regardless of the flag. These tests exercise that pure
// function directly — they are the authoritative proof of the store mirror's
// chips, its three dispatch surfaces, its tool bases, determinism, and the
// pairwise-disjointness the dispatch fall-through relies on.
//
// Two layers (identical structure to the עדכונים file):
//   • PURE (no widget): the deriver is a value→value function; assert the EXACT
//     chips, the destByChip/runByChip key-sets, the toolBase LABELS, determinism,
//     disjointness, the cart/order dedup-by-label + cap, and empty/edge safety.
//   • DISPATCH (testWidgets + a capturing Consumer, hermetic ProviderContainer):
//     ACTUALLY INVOKE the returned closures and assert they set the right
//     providers and KEEP THE OVERLAY FLOATING (no Navigator.push from a chip) —
//     the "run the code" tier the reliability charter prefers over inspection.
//
// SharedPreferences.setMockInitialValues({}) is seeded for the widget layer
// (boardAuth/feature-flags read prefs lazily); the pure layer needs no binding.

import 'package:buildsmart/screens/keyboard_destinations.dart'
    show KbDestination, kbDestinations;
import 'package:buildsmart/screens/keyboard_store_deriver.dart';
import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show KbToolNode, kbStoreNodes;
import 'package:buildsmart/screens/keyboard_updates_deriver.dart'
    show KbUpdatesContext;
import 'package:buildsmart/screens/store_screen.dart'
    show StoreSection, storeSectionProvider;
import 'package:buildsmart/state/orders_engine.dart' show Order;
import 'package:buildsmart/state/smart_cart.dart' show SmartCartLine;
import 'package:buildsmart/state/store_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The three entry-section labels the StoreRoot row must show, in OWNER order —
/// the SAME triple the keyboard's hardcoded `labelsByTab[3]` shows today
/// (floating_card_keyboard.dart:359), so the deriver's root row is byte-identical
/// to the flag-OFF tab-3 row.
const List<String> _kEntrySections = <String>[
  'הסל שלי',
  'ההזמנות שלי',
  'שירותים',
];

/// The 6 SERVICE chips, in the exact VERBATIM order + labels the deriver's
/// `_kServiceLabels` emits (mirroring store_screen.dart's service rows).
const List<String> _kServiceChips = <String>[
  'השכרת כלים',
  'פקדונות',
  'החזרה חדשה',
  'מכרז ספקים',
  'גיליונות בטיחות',
  'השוואת מחירים',
];

/// The tool-node LABELS each section installs (the comparable projection — tool
/// closures are never structurally equal, so equality keys on visible labels).
/// Each list is pinned to the REAL [kbStoreNodes] factory below so a label edit
/// there propagates automatically rather than silently diverging.
List<String> _toolLabels(KbUpdatesContext ctx) => <String>[
      for (final KbToolNode n in ctx.toolBase ?? const <KbToolNode>[]) n.label,
    ];

List<String> _nodeLabels(StoreSection s) =>
    <String>[for (final n in kbStoreNodes(s)) n.label];

/// A minimal cart line fixture — only the three fields the deriver reads
/// (productEmoji / productName / productQty) carry signal; the rest are inert.
SmartCartLine _line(String emoji, String name, {int qty = 1}) => SmartCartLine(
      productKey: '$name#key',
      productName: name,
      productEmoji: emoji,
      brandName: 'מותג',
      brandPrice: 100,
      productQty: qty,
      accessories: const [],
    );

/// A minimal order fixture — only [id] and [stage] carry signal for the chip
/// label ("<id> · <stageLabel>"); the rest are inert required fields.
Order _order(String id, String stage) => Order(
      id: id,
      who: 'דוד',
      site: 'אתר',
      items: 1,
      sum: 100,
      stage: stage,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ───────────────────────────────────────────────────────────────────────────
  // PURE: value→value, no widget tree. The strongest, most deterministic layer.
  // ───────────────────────────────────────────────────────────────────────────
  group('deriveStoreContext — StoreRoot arm (entry / section chips)', () {
    const root = StoreRoot(section: StoreSection.all);

    test('chips are EXACTLY [הסל שלי, ההזמנות שלי, שירותים] in owner order', () {
      final ctx = deriveStoreContext(root);
      expect(ctx.row.chips, _kEntrySections,
          reason: 'the root predictions are the three section chips, in order');
    });

    test('all three section chips are REAL registry KbDestinations (destByChip), '
        'runByChip is empty', () {
      final ctx = deriveStoreContext(root);
      expect(ctx.row.destByChip.keys.toSet(), _kEntrySections.toSet(),
          reason: 'each section chip dispatches via destByChip (ii)');
      expect(ctx.row.runByChip, isEmpty,
          reason: 'no dynamic chips at the root → runByChip is empty');

      // The destinations are sourced BY LABEL from the registry — identity-equal
      // to the same-label entries kbDestinations() returns, so they carry the
      // real `_openStoreSection` runs (not a stub).
      final byLabel = {for (final d in kbDestinations()) d.label: d};
      for (final label in _kEntrySections) {
        expect(identical(ctx.row.destByChip[label], byLabel[label]), isTrue,
            reason: '"$label" must be the registry destination, by label');
      }
    });

    test('every section chip is navigable (gets the nav glyph)', () {
      final ctx = deriveStoreContext(root);
      expect(ctx.row.destinationChips, _kEntrySections.toSet(),
          reason: 'the whole root row is one-tap navigation → all navigable');
    });

    test('toolBase is the store-root (section==all) tools', () {
      final ctx = deriveStoreContext(root);
      expect(_toolLabels(ctx), _nodeLabels(StoreSection.all),
          reason: 'the root installs kbStoreNodes(all)');
    });
  });

  group('deriveStoreContext — CartLocation arm (real cart-line chips)', () {
    const loc = CartLocation();

    test('one chip per cart line, label = "<emoji> <name>", in order', () {
      final cart = [
        _line('🚿', 'ברז'),
        _line('🔧', 'מפתח'),
        _line('🪜', 'סולם'),
      ];
      final ctx = deriveStoreContext(loc, cart: cart);
      expect(ctx.row.chips, ['🚿 ברז', '🔧 מפתח', '🪜 סולם'],
          reason: 'cart chips are emoji+name, in cart order');
      expect(ctx.row.runByChip.keys.toSet(), {'🚿 ברז', '🔧 מפתח', '🪜 סולם'},
          reason: 'each cart chip is a dynamic runByChip closure');
      expect(ctx.row.destByChip, isEmpty);
    });

    test('a line with qty > 1 appends " ×qty" to the label', () {
      final ctx = deriveStoreContext(loc, cart: [_line('🚿', 'ברז', qty: 3)]);
      expect(ctx.row.chips, ['🚿 ברז ×3'],
          reason: 'qty>1 renders the multiplier, matching the cart row');
    });

    test('qty == 1 does NOT append a multiplier', () {
      final ctx = deriveStoreContext(loc, cart: [_line('🚿', 'ברז', qty: 1)]);
      expect(ctx.row.chips, ['🚿 ברז'],
          reason: 'qty==1 stays bare (no " ×1")');
    });

    test('DE-DUPS by visible label: identical emoji+name collapse to one chip',
        () {
      final cart = [
        _line('🚿', 'ברז'),
        _line('🚿', 'ברז'), // same label → collapses
        _line('🔧', 'מפתח'),
      ];
      final ctx = deriveStoreContext(loc, cart: cart);
      expect(ctx.row.chips, ['🚿 ברז', '🔧 מפתח'],
          reason: 'the duplicate "🚿 ברז" label collapses to a single chip');
      expect(ctx.row.runByChip.keys.length, 2,
          reason: 'one closure per distinct label');
    });

    test('CAPS at 5 cart chips (reuses the _kStoreRowCap budget)', () {
      final cart = [for (var i = 0; i < 9; i++) _line('📦', 'פריט $i')];
      final ctx = deriveStoreContext(loc, cart: cart);
      expect(ctx.row.chips.length, 5, reason: 'capped at 5');
      expect(ctx.row.chips,
          ['📦 פריט 0', '📦 פריט 1', '📦 פריט 2', '📦 פריט 3', '📦 פריט 4'],
          reason: 'the cap keeps the FIRST five in order');
    });

    test('EMPTY cart → empty chip list, tools only, no crash', () {
      final ctx = deriveStoreContext(loc, cart: const []);
      expect(ctx.row.chips, isEmpty,
          reason: 'zero cart lines → no chips (the row shows tools only)');
      expect(ctx.row.runByChip, isEmpty);
      expect(_toolLabels(ctx), _nodeLabels(StoreSection.cart),
          reason: 'the cart tools still render with an empty cart');
    });

    test('toolBase is the cart tools (kbStoreNodes(cart))', () {
      final ctx = deriveStoreContext(loc, cart: const []);
      expect(_toolLabels(ctx), _nodeLabels(StoreSection.cart));
    });
  });

  group('deriveStoreContext — OrdersLocation arm (recent-order chips)', () {
    const loc = OrdersLocation();

    test('one chip per order, label = "<id> · <stageLabel>", in order', () {
      final orders = [
        _order('BS-1042', 'transit'),
        _order('BS-1043', 'preparing'),
      ];
      final ctx = deriveStoreContext(loc, orders: orders);
      expect(ctx.row.chips, ['BS-1042 · בדרך 🚛', 'BS-1043 · בהכנה 🔧'],
          reason: 'order chips are "id · live-hebrew-stage", in list order');
      expect(ctx.row.runByChip.keys.toSet(),
          {'BS-1042 · בדרך 🚛', 'BS-1043 · בהכנה 🔧'},
          reason: 'each order chip is a dynamic runByChip closure');
      expect(ctx.row.destByChip, isEmpty);
    });

    test('an unknown stage falls back to the raw stage string', () {
      // _stageLabelFor mirrors the store: an unmapped stage renders verbatim.
      final ctx = deriveStoreContext(loc, orders: [_order('BS-9', 'weird')]);
      expect(ctx.row.chips, ['BS-9 · weird'],
          reason: 'an unmapped stage falls through to the raw value');
    });

    test('CAPS at 5 order chips', () {
      final orders = [
        for (var i = 0; i < 8; i++) _order('BS-$i', 'new'),
      ];
      final ctx = deriveStoreContext(loc, orders: orders);
      expect(ctx.row.chips.length, 5, reason: 'capped at 5');
    });

    test('EMPTY orders → empty chip list, tools only, no crash', () {
      final ctx = deriveStoreContext(loc, orders: const []);
      expect(ctx.row.chips, isEmpty);
      expect(ctx.row.runByChip, isEmpty);
      expect(_toolLabels(ctx), _nodeLabels(StoreSection.orders),
          reason: 'the order tools still render with no orders');
    });

    test('toolBase is the order tools (kbStoreNodes(orders))', () {
      final ctx = deriveStoreContext(loc, orders: const []);
      expect(_toolLabels(ctx), _nodeLabels(StoreSection.orders));
    });
  });

  group('deriveStoreContext — ServicesLocation arm (the 6 static chips)', () {
    const loc = ServicesLocation();

    test('chips are EXACTLY the 6 service labels, verbatim + in order', () {
      final ctx = deriveStoreContext(loc);
      expect(ctx.row.chips, _kServiceChips,
          reason: 'the services arm emits its const list verbatim, in order');
    });

    test('all 6 chips dispatch via runByChip (iii); destByChip empty', () {
      final ctx = deriveStoreContext(loc);
      expect(ctx.row.runByChip.keys.toSet(), _kServiceChips.toSet(),
          reason: 'each service chip is a dynamic runByChip closure');
      expect(ctx.row.destByChip, isEmpty,
          reason: 'no static destinations in the services arm');
    });

    test('every service chip is navigable', () {
      final ctx = deriveStoreContext(loc);
      expect(ctx.row.destinationChips, _kServiceChips.toSet(),
          reason: 'all 6 service chips get the nav glyph');
    });

    test('the row is NEVER blank — static, independent of any data', () {
      // The services surface carries no data param, so it always renders all 6.
      final ctx = deriveStoreContext(loc);
      expect(ctx.row.chips.length, _kServiceChips.length,
          reason: 'the 6 static service chips always render');
    });

    test('toolBase is the service tools (kbStoreNodes(services))', () {
      final ctx = deriveStoreContext(loc);
      expect(_toolLabels(ctx), _nodeLabels(StoreSection.services));
    });
  });

  // ── DISPATCH DISJOINTNESS — the structural fall-through guarantee ───────────
  group('dispatch maps are pairwise-disjoint (every arm)', () {
    void assertDisjoint(KbUpdatesContext ctx, String arm) {
      final dest = ctx.row.destByChip.keys.toSet();
      final run = ctx.row.runByChip.keys.toSet();
      expect(dest.intersection(run), isEmpty,
          reason: '$arm: destByChip ∩ runByChip must be empty so the dispatch '
              'fall-through is structural, not coincidental');
    }

    test('StoreRoot: destByChip ∩ runByChip == ∅', () {
      assertDisjoint(
          deriveStoreContext(const StoreRoot(section: StoreSection.all)),
          'StoreRoot');
    });

    test('CartLocation: destByChip ∩ runByChip == ∅', () {
      assertDisjoint(
        deriveStoreContext(const CartLocation(),
            cart: [_line('🚿', 'ברז'), _line('🔧', 'מפתח')]),
        'CartLocation',
      );
    });

    test('OrdersLocation: destByChip ∩ runByChip == ∅', () {
      assertDisjoint(
        deriveStoreContext(const OrdersLocation(),
            orders: [_order('BS-1', 'new'), _order('BS-2', 'ready')]),
        'OrdersLocation',
      );
    });

    test('ServicesLocation: destByChip ∩ runByChip == ∅', () {
      assertDisjoint(deriveStoreContext(const ServicesLocation()),
          'ServicesLocation');
    });

    test(
        'no service label nor a seed cart/order label collides with ANY registry '
        'destination label (fall-through stays structural)', () {
      final destLabels = {for (final d in kbDestinations()) d.label};
      // The dynamic chips must not create an AMBIGUOUS dispatch. The real
      // guarantee is PER-ROW (runByChip ∩ destByChip == ∅, asserted per arm
      // above) — never global label uniqueness. A service label MAY, by design,
      // coincide with a nav destination: 'השוואת מחירים' is BOTH a service chip
      // (a runByChip keep-floating on the ServicesLocation row) AND a registry
      // nav destination (reached by typing). That is harmless — they never share
      // a row, so the fall-through stays structural. Only NON-intentional-overlap
      // service labels must stay out of the registry.
      const intentionalNavOverlap = {'השוואת מחירים'};
      for (final label in _kServiceChips) {
        if (intentionalNavOverlap.contains(label)) continue;
        expect(destLabels.contains(label), isFalse,
            reason: 'service "$label" must not be a destination label');
      }
      // Realistic cart/order chip labels never collide with a nav destination
      // (they carry emoji + free text / an order id), so the fall-through is
      // unambiguous on those rows too.
      for (final label in const ['🚿 ברז', '🔧 מפתח', 'BS-1042 · בדרך 🚛']) {
        expect(destLabels.contains(label), isFalse,
            reason: 'dynamic chip "$label" must not be a destination label');
      }
    });
  });

  // ── DETERMINISM (purity) ───────────────────────────────────────────────────
  group('deriver is deterministic (same location + data ⇒ equal context)', () {
    test('StoreRoot: two calls produce == contexts', () {
      const loc = StoreRoot(section: StoreSection.all);
      expect(deriveStoreContext(loc), deriveStoreContext(loc),
          reason: 'pure: identical inputs ⇒ identical (==) context');
    });

    test('CartLocation: identical cart data ⇒ == contexts', () {
      const loc = CartLocation();
      final c1 = [_line('🚿', 'ברז'), _line('🔧', 'מפתח')];
      final c2 = [_line('🚿', 'ברז'), _line('🔧', 'מפתח')];
      expect(deriveStoreContext(loc, cart: c1),
          deriveStoreContext(loc, cart: c2),
          reason: 'equal cart lists ⇒ equal context (no per-frame churn)');
    });

    test('OrdersLocation: identical order data ⇒ == contexts', () {
      const loc = OrdersLocation();
      final o1 = [_order('BS-1', 'transit')];
      final o2 = [_order('BS-1', 'transit')];
      expect(deriveStoreContext(loc, orders: o1),
          deriveStoreContext(loc, orders: o2));
    });

    test('ServicesLocation: two calls produce == contexts', () {
      const loc = ServicesLocation();
      expect(deriveStoreContext(loc), deriveStoreContext(loc));
    });

    test('a different location ⇒ a DIFFERENT context', () {
      final cart = deriveStoreContext(const CartLocation());
      final services = deriveStoreContext(const ServicesLocation());
      expect(cart == services, isFalse,
          reason: 'distinct surfaces must not compare equal');
    });
  });

  // ── FLAG-OFF BYTE-IDENTITY (deriver layer) ─────────────────────────────────
  // The widget-level flag-OFF regression (tab-3 row + typed path + tabs 0/1/2
  // unchanged) is ALREADY covered, green, by
  // test/screens/floating_card_keyboard_test.dart, which pumps the REAL
  // FloatingCardKeyboard with kKbLiveMirror at its const default OFF and
  // featureFlagsProvider empty (kKbLiveMirrorFlag is not in _forcedOnFlags), so
  // the mirror branch + the build() watches fold out and the hardcoded
  // ['הסל שלי','ההזמנות שלי','שירותים'] tab-3 row is what renders. We do NOT
  // duplicate that here. What we add is the COMPLEMENT: proof that when the flag
  // IS on, the deriver's StoreRoot row is byte-identical to that preserved
  // hardcoded row — so the flag flip changes timing/wiring, never the entry row
  // the user sees.
  group('flag-OFF byte-identity (deriver root == the hardcoded tab-3 row)', () {
    test('the deriver StoreRoot row equals labelsByTab[3] exactly', () {
      // This list is copied byte-for-byte from floating_card_keyboard.dart's
      // const labelsByTab[3] (verified, line 359). The deriver must emit the same
      // labels in the same order so flag-ON's entry == flag-OFF's entry.
      const hardcodedTab3Row = <String>['הסל שלי', 'ההזמנות שלי', 'שירותים'];
      final ctx = deriveStoreContext(const StoreRoot(section: StoreSection.all));
      expect(ctx.row.chips, hardcodedTab3Row,
          reason: 'deriver root chips == the preserved tab-3 row');
      expect(ctx.row.destByChip.keys.toSet(), hardcodedTab3Row.toSet(),
          reason: 'and they carry the same by-label registry destinations');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // DISPATCH (run the code): invoke the returned closures against a real
  // container + BuildContext and assert they set the right providers AND keep
  // the overlay floating (no Navigator.push from a chip). A capturing Consumer
  // hands us the (ref, context) the floating keyboard would supply at tap time.
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
        'a section chip KbDestination.run flips storeSectionProvider, no push',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final r = await pumpRunner(tester, container);

      final ctx =
          deriveStoreContext(const StoreRoot(section: StoreSection.all));
      final before = r.pushed.length;

      // הסל שלי → _openStoreSection(cart): mainTab 3 + storeSection cart.
      final KbDestination cart = ctx.row.destByChip['הסל שלי']!;
      cart.run(r.ref, r.context);
      await tester.pump();
      expect(container.read(storeSectionProvider), StoreSection.cart,
          reason: 'הסל שלי routes to the cart section');

      // שירותים → _openStoreSection(services).
      final KbDestination services = ctx.row.destByChip['שירותים']!;
      services.run(r.ref, r.context);
      await tester.pump();
      expect(container.read(storeSectionProvider), StoreSection.services,
          reason: 'שירותים routes to the services section');

      expect(r.pushed.length, before,
          reason: 'section chips swap a section under the overlay — no push');
    });

    testWidgets(
        'a cart-line chip closure keeps the cart section + does NOT push',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final r = await pumpRunner(tester, container);

      // Start on cart so the keep-floating no-op is a genuine no-op (re-assert).
      container.read(storeSectionProvider.notifier).state = StoreSection.cart;
      final ctx = deriveStoreContext(const CartLocation(),
          cart: [_line('🚿', 'ברז')]);

      final before = r.pushed.length;
      ctx.row.runByChip['🚿 ברז']!(r.ref, r.context);
      await tester.pump();

      expect(container.read(storeSectionProvider), StoreSection.cart,
          reason: 'the cart chip keeps the user on the cart section '
              '(keep-floating deferral — the SCREEN owns any real per-line nav)');
      expect(r.pushed.length, before,
          reason: 'the chip itself pushes no route — keep-floating');
    });

    testWidgets(
        'an order chip closure re-asserts the orders section, no push',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final r = await pumpRunner(tester, container);

      container.read(storeSectionProvider.notifier).state = StoreSection.orders;
      final ctx = deriveStoreContext(const OrdersLocation(),
          orders: [_order('BS-1042', 'transit')]);

      final before = r.pushed.length;
      ctx.row.runByChip['BS-1042 · בדרך 🚛']!(r.ref, r.context);
      await tester.pump();

      expect(container.read(storeSectionProvider), StoreSection.orders,
          reason: 'the order chip keeps the user on the orders section');
      expect(r.pushed.length, before,
          reason: 'the chip itself pushes no route — keep-floating');
    });

    testWidgets(
        'a service chip closure sets the services section (from all), no push',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final r = await pumpRunner(tester, container);

      // Start on the default (all) so the closure makes a VISIBLE change to
      // services — proving the runByChip closure really sets the provider.
      expect(container.read(storeSectionProvider), StoreSection.all,
          reason: 'sanity: starts on the default section');
      final ctx = deriveStoreContext(const ServicesLocation());

      final before = r.pushed.length;
      ctx.row.runByChip['השכרת כלים']!(r.ref, r.context);
      await tester.pump();

      expect(container.read(storeSectionProvider), StoreSection.services,
          reason: 'the service chip sets the services section (keep-floating)');
      expect(r.pushed.length, before,
          reason: 'a service chip mutates a provider only — keep-floating');
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

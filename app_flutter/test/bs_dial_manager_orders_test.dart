// M2 — widget coverage of the 👔 manager 📦 הזמנות leaves. Drives the real
// BS-dial widget into the manager persona's הזמנות section and asserts each of
// the six `mo-*` leaves opens an INLINE order-list panel (R2 — no navigation)
// listing the REAL orders in that one order-flow stage, that the two empty
// stages (pickup · delivered in the seed) show the legacy empty text, and that
// NONE of them show the "בבנייה" stub. Every order datum is the verbatim seed
// from manager_dashboard.dart (itself a port of index.html SYS_ORDERS_SEED).

import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/screens/bs_dial_widget.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/widgets/dial.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester t, [int frames = 8]) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  Future<ProviderContainer> pump(WidgetTester t) async {
    SharedPreferences.setMockInitialValues({});
    await t.binding.setSurfaceSize(const Size(440, 1100));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('he'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            // Align to top so the rising dial column stays on-screen for taps.
            child: Scaffold(
              body: Align(
                alignment: Alignment.topRight,
                child: SingleChildScrollView(child: BsDialWidget()),
              ),
            ),
          ),
        ),
      ),
    );
    await settle(t);
    return ProviderScope.containerOf(t.element(find.byType(BsDialWidget)));
  }

  // Drive the dial: pick the manager persona, then drill into הזמנות.
  Future<void> openOrders(WidgetTester t, ProviderContainer c) async {
    c.read(activePersonaProvider.notifier).state = 'manager';
    await settle(t);
    // Tap the הזמנות section ROW (scope to a DialRow — the persona has a
    // 🚚 הזמנות section AND a 🚚 הזמנות פתוחות dashboard leaf elsewhere; here
    // only the section row is on screen at L2).
    await t.tap(
      find.descendant(of: find.byType(DialRow), matching: find.text('הזמנות')),
    );
    await settle(t);
  }

  // Tap a leaf ROW by its title (scoped to a DialRow so the panel header, which
  // can repeat the same stage label, does not make the finder ambiguous).
  Future<void> tapLeaf(WidgetTester t, String title) async {
    await t.tap(
      find.descendant(of: find.byType(DialRow), matching: find.text(title)),
    );
    await settle(t);
  }

  group('manager 📦 הזמנות — inline order-list leaves (M2)', () {
    testWidgets('all six mo-* leaves are present (verbatim stage titles)', (
      t,
    ) async {
      final c = await pump(t);
      await openOrders(t, c);
      for (final title in const [
        'התקבלה',
        'בהכנה',
        'מוכן לאיסוף',
        'נאסף',
        'בדרך לאתר',
        'נמסר ✓',
      ]) {
        expect(find.text(title), findsWidgets, reason: 'leaf $title missing');
      }
    });

    testWidgets(
      'each populated stage leaf opens an inline panel listing its REAL '
      'orders (id / who · site / items · sum) — and NO "בבנייה"',
      (t) async {
        final c = await pump(t);
        await openOrders(t, c);

        // The four stages that carry a seed order: title → the order in it.
        final populated = <String, ManagerOrder>{
          'התקבלה': kManagerOrderSeed.firstWhere((o) => o.stage == 'new'),
          'בהכנה': kManagerOrderSeed.firstWhere((o) => o.stage == 'preparing'),
          'מוכן לאיסוף': kManagerOrderSeed.firstWhere(
            (o) => o.stage == 'ready',
          ),
          'בדרך לאתר': kManagerOrderSeed.firstWhere(
            (o) => o.stage == 'transit',
          ),
        };

        for (final entry in populated.entries) {
          final o = entry.value;
          await tapLeaf(t, entry.key);
          // The inline panel set bsOrderLeafProvider (no navigation occurred).
          expect(
            c.read(bsOrderLeafProvider),
            isNotNull,
            reason: 'tapping ${entry.key} should open an order panel',
          );
          // The real order's fields are on screen, verbatim.
          expect(
            find.text('📦 ${o.id}'),
            findsOneWidget,
            reason: 'panel for ${entry.key} should show order ${o.id}',
          );
          expect(
            find.text('${o.who} · ${o.site}'),
            findsOneWidget,
            reason: 'panel for ${entry.key} should show ${o.who} · ${o.site}',
          );
          expect(
            find.text('${o.items} פריטים · ₪${o.sum}'),
            findsOneWidget,
            reason: 'panel for ${entry.key} should show items/sum',
          );
          // No "בבנייה" stub for any order leaf.
          expect(find.textContaining('בבנייה'), findsNothing);
          // Close before the next leaf (re-tap toggles it shut).
          await tapLeaf(t, entry.key);
          expect(c.read(bsOrderLeafProvider), isNull);
        }
      },
    );

    testWidgets(
      'the two EMPTY stages (נאסף · נמסר ✓) show the legacy empty text — '
      'and NO "בבנייה"',
      (t) async {
        final c = await pump(t);
        await openOrders(t, c);

        for (final title in const ['נאסף', 'נמסר ✓']) {
          final stage = title == 'נאסף' ? 'pickup' : 'delivered';
          // Sanity: the seed really has zero orders in this stage.
          expect(
            kManagerOrderSeed.where((o) => o.stage == stage),
            isEmpty,
            reason: '$title must be an empty stage in the seed',
          );
          await tapLeaf(t, title);
          expect(c.read(bsOrderLeafProvider), isNotNull);
          // The verbatim legacy empty line (index.html `md-empty`).
          expect(
            find.text('לא נמצאו הזמנות תואמות.'),
            findsOneWidget,
            reason: '$title (empty stage) should show the empty text',
          );
          // It is genuinely empty — no order id rendered.
          expect(find.textContaining('📦 BS-'), findsNothing);
          expect(find.textContaining('בבנייה'), findsNothing);
          await tapLeaf(t, title);
          expect(c.read(bsOrderLeafProvider), isNull);
        }
      },
    );

    testWidgets('opening an order leaf clears any open metric panel (mutually '
        'exclusive)', (t) async {
      final c = await pump(t);
      // Open a dashboard metric panel first (M1), then switch to הזמנות and
      // open an order leaf — the metric panel must close.
      c.read(activePersonaProvider.notifier).state = 'manager';
      await settle(t);
      await t.tap(
        find.descendant(
          of: find.byType(DialRow),
          matching: find.text('לוח בקרה'),
        ),
      );
      await settle(t);
      await tapLeaf(t, 'הזמנות פתוחות');
      expect(c.read(bsMetricLeafProvider), 'md-open-orders');
      // Pop back to the persona root, drill into הזמנות, open an order leaf.
      c.read(bsDrillPathProvider.notifier).state = const [];
      c.read(bsMetricLeafProvider.notifier).state = null;
      await settle(t);
      await openOrders(t, c);
      await tapLeaf(t, 'התקבלה');
      expect(c.read(bsOrderLeafProvider), 'mo-new');
      expect(c.read(bsMetricLeafProvider), isNull);
    });

    test('kManagerOrderLeafIds covers exactly the six order-status leaves', () {
      expect(kManagerOrderLeafIds, {
        'mo-new',
        'mo-preparing',
        'mo-ready',
        'mo-pickup',
        'mo-transit',
        'mo-delivered',
      });
      // Each leaf maps to a real order-flow stage (no invented stage).
      for (final stage in kManagerOrderLeafStage.values) {
        expect(kManagerOrderFlow, contains(stage));
      }
    });
  });
}

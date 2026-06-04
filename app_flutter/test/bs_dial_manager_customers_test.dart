// M3 — widget coverage of the 👔 manager 👥 לקוחות leaves. Drives the real
// BS-dial widget into the manager persona's לקוחות section and asserts each of
// the two `mc-*` leaves opens an INLINE customer-list panel (R2 — no
// navigation) listing the REAL customers in that one status filter, that NONE
// of them show the "בבנייה" stub, and that the customer panel is mutually
// exclusive with the metric (M1) and order (M2) panels. Every customer datum is
// derived from `mgrCustomerList` / `contractorCredit` in manager_dashboard.dart
// (itself grouping index.html's SYS_ORDERS_SEED by buyer).
//
// Data reality (Dart `contractorCredit`): the 4 seed buyers each have a tiny
// utilisation %, so all four are status `live` (פעיל) and NONE reach `low`
// (אשראי גבוה, pct>=90). Hence `mc-live` lists all four with their real
// spend/credit and `mc-low` is empty → the legacy empty text. This mirrors M2,
// where pickup/delivered are empty stages.

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
    await t.binding.setSurfaceSize(const Size(440, 1300));
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

  // Drive the dial: pick the manager persona, then drill into לקוחות.
  Future<void> openCustomers(WidgetTester t, ProviderContainer c) async {
    c.read(activePersonaProvider.notifier).state = 'manager';
    await settle(t);
    await t.tap(
      find.descendant(of: find.byType(DialRow), matching: find.text('לקוחות')),
    );
    await settle(t);
  }

  // Tap a leaf ROW by its title (scoped to a DialRow so the panel header, which
  // can repeat the same status label, does not make the finder ambiguous).
  Future<void> tapLeaf(WidgetTester t, String title) async {
    await t.tap(
      find.descendant(of: find.byType(DialRow), matching: find.text(title)),
    );
    await settle(t);
  }

  // Comma thousands-separators — mirrors the legacy `Number.toLocaleString()`
  // the panel renders for spend/credit (@index.html:16602).
  String grouped(int n) {
    final s = n.abs().toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return n < 0 ? '-$b' : b.toString();
  }

  group('manager 👥 לקוחות — inline customer-list leaves (M3)', () {
    testWidgets('both mc-* leaves are present (verbatim status titles)', (
      t,
    ) async {
      final c = await pump(t);
      await openCustomers(t, c);
      for (final title in const ['פעיל', 'אשראי גבוה']) {
        expect(find.text(title), findsWidgets, reason: 'leaf $title missing');
      }
    });

    testWidgets(
      'the פעיל leaf (mc-live) opens an inline panel listing the REAL '
      'customers (name · orders/sites · credit line) — and NO "בבנייה"',
      (t) async {
        final c = await pump(t);
        await openCustomers(t, c);

        // With the Dart credit ceilings every seed buyer is status `live`, so
        // mc-live lists ALL of them; sanity-check that against mgrCustomerList.
        final live = mgrCustomerList()
            .where((m) {
              final pct = m.creditLimit == 0
                  ? 0
                  : ((m.totalSpend / m.creditLimit) * 100).round();
              return pct > 0 && pct < 90;
            })
            .toList();
        expect(live, isNotEmpty, reason: 'mc-live should have customers');
        expect(
          live.length,
          mgrCustomerList().length,
          reason: 'all seed buyers are status live with the Dart credit',
        );

        await tapLeaf(t, 'פעיל');
        // The inline panel set bsCustomerLeafProvider (no navigation occurred).
        expect(c.read(bsCustomerLeafProvider), 'mc-live');
        // The panel is the customer panel — others are clear.
        expect(c.read(bsMetricLeafProvider), isNull);
        expect(c.read(bsOrderLeafProvider), isNull);

        for (final m in live) {
          final pct = ((m.totalSpend / m.creditLimit) * 100).round();
          // The real customer's name is on screen.
          expect(
            find.text(m.name),
            findsWidgets,
            reason: 'panel should show customer ${m.name}',
          );
          // The verbatim credit line (₪spent / ₪credit (pct%)).
          expect(
            find.text(
              'ניצול אשראי: ₪${grouped(m.totalSpend)} / ₪${grouped(m.creditLimit)} ($pct%)',
            ),
            findsOneWidget,
            reason: 'panel should show ${m.name} credit line',
          );
        }
        // The "orders · sites" sub-line (each seed buyer has 1 order · 1 site).
        expect(find.text('1 הזמנות · 1 אתרים'), findsWidgets);
        // No "בבנייה" stub anywhere.
        expect(find.textContaining('בבנייה'), findsNothing);

        // Re-tap closes (toggle).
        await tapLeaf(t, 'פעיל');
        expect(c.read(bsCustomerLeafProvider), isNull);
      },
    );

    testWidgets(
      'the אשראי גבוה leaf (mc-low) is empty in the seed → shows the legacy '
      'empty text — and NO "בבנייה"',
      (t) async {
        final c = await pump(t);
        await openCustomers(t, c);

        // Sanity: no seed buyer reaches the `low` band (pct>=90) with the Dart
        // credit ceilings.
        final low = mgrCustomerList().where((m) {
          final pct = m.creditLimit == 0
              ? 0
              : ((m.totalSpend / m.creditLimit) * 100).round();
          return pct >= 90;
        });
        expect(low, isEmpty, reason: 'mc-low must be empty in the seed');

        await tapLeaf(t, 'אשראי גבוה');
        expect(c.read(bsCustomerLeafProvider), 'mc-low');
        // The verbatim legacy empty line for customers (@index.html:16586).
        expect(
          find.text('לא נמצאו קבלנים תואמים.'),
          findsOneWidget,
          reason: 'mc-low (empty status) should show the empty text',
        );
        // It is genuinely empty — no credit line rendered.
        expect(find.textContaining('ניצול אשראי:'), findsNothing);
        expect(find.textContaining('בבנייה'), findsNothing);

        await tapLeaf(t, 'אשראי גבוה');
        expect(c.read(bsCustomerLeafProvider), isNull);
      },
    );

    testWidgets(
      'opening a customer leaf clears any open metric/order panel (mutually '
      'exclusive)',
      (t) async {
        final c = await pump(t);

        // 1) Open a dashboard metric panel (M1), then a customer leaf — the
        //    metric panel must close.
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
        // Pop back to persona root, drill into לקוחות, open a customer leaf.
        c.read(bsDrillPathProvider.notifier).state = const [];
        c.read(bsMetricLeafProvider.notifier).state = null;
        await settle(t);
        await openCustomers(t, c);
        await tapLeaf(t, 'פעיל');
        expect(c.read(bsCustomerLeafProvider), 'mc-live');
        expect(c.read(bsMetricLeafProvider), isNull);
        expect(c.read(bsOrderLeafProvider), isNull);

        // 2) Open an order panel (M2) while the customer panel is open — the
        //    customer panel must close (the reverse exclusion).
        c.read(bsDrillPathProvider.notifier).state = const [];
        c.read(bsCustomerLeafProvider.notifier).state = null;
        await settle(t);
        c.read(activePersonaProvider.notifier).state = 'manager';
        await settle(t);
        await t.tap(
          find.descendant(
            of: find.byType(DialRow),
            matching: find.text('הזמנות'),
          ),
        );
        await settle(t);
        await tapLeaf(t, 'התקבלה');
        expect(c.read(bsOrderLeafProvider), 'mo-new');
        expect(c.read(bsCustomerLeafProvider), isNull);
      },
    );

    test('kManagerCustomerLeafIds covers exactly the two customer leaves', () {
      expect(kManagerCustomerLeafIds, {'mc-live', 'mc-low'});
      // Each leaf maps to a real legacy status (no invented status).
      for (final status in kManagerCustomerLeafStatus.values) {
        expect(const ['live', 'low', 'off'], contains(status));
      }
    });
  });
}

// M1 — widget coverage of the 👔 manager 📊 dashboard leaves. Drives the
// real BS-dial widget into the manager persona's לוח בקרה and asserts each of
// the five `md-*` leaves opens an INLINE metric panel (R2 — no navigation)
// showing the real derived number, and that NONE of them show the "בבנייה"
// stub. Numbers are the verbatim values from manager_dashboard.dart.

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
    await t.binding.setSurfaceSize(const Size(440, 950));
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

  // Drive the dial: pick the manager persona, then drill into לוח בקרה.
  Future<void> openDashboard(WidgetTester t, ProviderContainer c) async {
    c.read(activePersonaProvider.notifier).state = 'manager';
    await settle(t);
    await t.tap(find.text('לוח בקרה'));
    await settle(t);
  }

  group('manager 📊 dashboard — inline metric leaves (M1)', () {
    testWidgets('all five md-* leaves are present (verbatim titles)',
        (t) async {
      final c = await pump(t);
      await openDashboard(t, c);
      for (final title in const [
        'הזמנות פתוחות',
        'מוצרים בקטלוג',
        'אביזרים נלווים',
        'זמינים כעת',
        'חנויות פעילות',
      ]) {
        expect(find.text(title), findsOneWidget, reason: 'leaf $title missing');
      }
    });

    testWidgets('tapping a leaf opens an inline panel with the real number — '
        'and shows NO "בבנייה" stub', (t) async {
      final c = await pump(t);
      await openDashboard(t, c);

      // Each leaf → its verbatim derived value (from managerAnalytics).
      const a = managerAnalytics;
      final cases = <String, String>{
        'הזמנות פתוחות': '${a.openOrders}', // 4
        'מוצרים בקטלוג': '${a.catalogCount}', // 54
        'אביזרים נלווים': '${a.accessoryCount}', // 148
        'זמינים כעת': '${a.availableCount}', // 202
        'חנויות פעילות': a.storesLabel, // 3/3
      };

      for (final entry in cases.entries) {
        // Tap the leaf ROW specifically (the panel header repeats a title once
        // a panel is open, so scope the finder to the DialRow).
        await t.tap(
          find.descendant(
            of: find.byType(DialRow),
            matching: find.text(entry.key),
          ),
        );
        await settle(t);
        // The inline panel sets bsMetricLeafProvider (no navigation occurred).
        expect(c.read(bsMetricLeafProvider), isNotNull);
        // The real number is now on screen.
        expect(
          find.text(entry.value),
          findsWidgets,
          reason: 'panel for ${entry.key} should show ${entry.value}',
        );
        // No "בבנייה" stub for any dashboard leaf.
        expect(find.textContaining('בבנייה'), findsNothing);
      }
    });

    testWidgets('tapping the open leaf again closes the panel (toggle)',
        (t) async {
      final c = await pump(t);
      await openDashboard(t, c);
      // The dial ROW (text inside a DialRow) — distinct from the panel header,
      // which repeats the same title once the panel is open.
      final row = find.descendant(
        of: find.byType(DialRow),
        matching: find.text('הזמנות פתוחות'),
      );
      await t.tap(row);
      await settle(t);
      expect(c.read(bsMetricLeafProvider), 'md-open-orders');
      // Re-tap the same leaf row → closes.
      await t.tap(row);
      await settle(t);
      expect(c.read(bsMetricLeafProvider), isNull);
    });

    test('kManagerMetricLeafIds covers exactly the five dashboard leaves', () {
      expect(kManagerMetricLeafIds, {
        'md-open-orders',
        'md-catalog',
        'md-accessories',
        'md-available',
        'md-stores',
      });
    });
  });
}

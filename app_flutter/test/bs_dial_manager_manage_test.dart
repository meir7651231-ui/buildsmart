// M4 — widget coverage of the 👔 manager 🛠️ ניהול leaves (the FINAL manager
// wave). Drives the real BS-dial widget into the manager persona's ניהול
// section and asserts each of the five `mm-*` leaves reaches its REAL target,
// with NO "בבנייה" stub anywhere:
//   • mm-cats     → an INLINE data panel (R2 — no navigation) listing the REAL
//     catalog categories + each one's product count, from
//     kManagerCatalogCategories (the legacy SECTION 3 tally @index.html:16716).
//   • mm-settings → an INLINE data panel with the three REAL contractor-app
//     config rows (express surcharge / credit ceiling / VAT), verbatim from the
//     legacy constants (SECTION 4 @index.html:16733-16740).
//   • mm-trees / mm-brands → a labelled toast with the leaf's REAL legacy action
//     label (the verbatim `mmSection` sub-title), NOT "בבנייה" — the legacy body
//     is a `prompt()`-driven server edit with no backend here.
//   • mm-regression → STILL routes to RegressionPanelScreen (no regression).
// The two inline panels are mutually exclusive with the metric (M1) / order
// (M2) / customer (M3) panels.

import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/screens/bs_dial_widget.dart';
import 'package:buildsmart/screens/regression_panel_screen.dart';
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
    await t.binding.setSurfaceSize(const Size(440, 1600));
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

  // Drive the dial: pick the manager persona, then drill into ניהול.
  Future<void> openManage(WidgetTester t, ProviderContainer c) async {
    c.read(activePersonaProvider.notifier).state = 'manager';
    await settle(t);
    await t.tap(
      find.descendant(of: find.byType(DialRow), matching: find.text('ניהול')),
    );
    await settle(t);
  }

  // Tap a leaf ROW by its title (scoped to a DialRow so a panel header that can
  // repeat the same label does not make the finder ambiguous).
  Future<void> tapLeaf(WidgetTester t, String title) async {
    await t.tap(
      find.descendant(of: find.byType(DialRow), matching: find.text(title)),
    );
    await settle(t);
  }

  // Comma thousands-separators — mirrors the legacy `Number.toLocaleString()`
  // the settings panel renders for the credit ceiling (@index.html:16736).
  String grouped(int n) {
    final s = n.abs().toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return n < 0 ? '-$b' : b.toString();
  }

  group('manager 🛠️ ניהול — final wave (M4)', () {
    testWidgets('all five mm-* leaves are present (verbatim titles)', (
      t,
    ) async {
      final c = await pump(t);
      await openManage(t, c);
      for (final title in const [
        'עץ המוצרים',
        'מותגים ומחירים',
        'קטגוריות',
        'הגדרות אפליקציה',
        'בדיקות רגרסיה',
      ]) {
        expect(find.text(title), findsWidgets, reason: 'leaf $title missing');
      }
    });

    testWidgets(
      'the קטגוריות leaf (mm-cats) opens an inline panel listing the REAL '
      'categories + product counts — and NO "בבנייה"',
      (t) async {
        final c = await pump(t);
        await openManage(t, c);

        await tapLeaf(t, 'קטגוריות');
        // The inline panel set bsManageLeafProvider (no navigation occurred).
        expect(c.read(bsManageLeafProvider), 'mm-cats');
        // It is the manage panel — the other panels are clear.
        expect(c.read(bsMetricLeafProvider), isNull);
        expect(c.read(bsOrderLeafProvider), isNull);
        expect(c.read(bsCustomerLeafProvider), isNull);

        // The header counts the real categories.
        expect(
          find.text('קטגוריות פעילות (${kManagerCatalogCategories.length})'),
          findsOneWidget,
        );
        // Every real category + its real product count is on screen.
        kManagerCatalogCategories.forEach((cat, count) {
          expect(find.text(cat), findsWidgets, reason: 'category $cat missing');
          expect(
            find.text('$count מוצרים'),
            findsWidgets,
            reason: 'count for $cat missing',
          );
        });
        // The verbatim legacy hint line.
        expect(
          find.text('שינוי שם קטגוריה מעדכן את כל המוצרים שבה.'),
          findsOneWidget,
        );
        // No "בבנייה" stub anywhere.
        expect(find.textContaining('בבנייה'), findsNothing);

        // Re-tap closes (toggle).
        await tapLeaf(t, 'קטגוריות');
        expect(c.read(bsManageLeafProvider), isNull);
      },
    );

    testWidgets(
      'the הגדרות אפליקציה leaf (mm-settings) opens an inline panel with the '
      'REAL config rows (express / credit / VAT) — and NO "בבנייה"',
      (t) async {
        final c = await pump(t);
        await openManage(t, c);

        await tapLeaf(t, 'הגדרות אפליקציה');
        expect(c.read(bsManageLeafProvider), 'mm-settings');
        expect(c.read(bsMetricLeafProvider), isNull);
        expect(c.read(bsOrderLeafProvider), isNull);
        expect(c.read(bsCustomerLeafProvider), isNull);

        // The three verbatim config rows (labels + values from the legacy
        // constants EXPRESS_FEE=120 / creditLimit=50000 / VAT_RATE=0.18).
        expect(find.text('תוספת משלוח אקספרס'), findsOneWidget);
        expect(find.text('₪120'), findsOneWidget);
        expect(find.text('מסגרת אשראי לקבלן'), findsOneWidget);
        expect(find.text('₪${grouped(50000)}'), findsOneWidget); // ₪50,000
        expect(find.text('שיעור מע״מ'), findsOneWidget);
        expect(find.text('18%'), findsOneWidget);
        // The verbatim legacy hint.
        expect(
          find.text(
            'המע״מ קבוע לפי חוק (18%). תוספת האקספרס והאשראי נראים מיד בעגלת הקבלן.',
          ),
          findsOneWidget,
        );
        expect(find.textContaining('בבנייה'), findsNothing);

        await tapLeaf(t, 'הגדרות אפליקציה');
        expect(c.read(bsManageLeafProvider), isNull);
      },
    );

    testWidgets(
      'the עץ המוצרים / מותגים ומחירים leaves (mm-trees / mm-brands) fire the '
      'REAL legacy action toast (server edit) — NOT "בבנייה", no panel opens',
      (t) async {
        final c = await pump(t);
        await openManage(t, c);

        // mm-trees — legacy `mmSection` sub-title (@index.html:16653).
        await tapLeaf(t, 'עץ המוצרים');
        // No data panel opened — it is an action leaf.
        expect(c.read(bsManageLeafProvider), isNull);
        expect(c.read(bsMetricLeafProvider), isNull);
        expect(c.read(bsOrderLeafProvider), isNull);
        expect(c.read(bsCustomerLeafProvider), isNull);
        // The verbatim action label is shown in a toast — NOT "בבנייה".
        expect(
          find.text('🌳 עריכת האביזרים המשלימים של כל מוצר'),
          findsOneWidget,
        );
        expect(find.textContaining('בבנייה'), findsNothing);

        // Let the snackbar clear, then mm-brands (@index.html:16687).
        await settle(t, 30);
        await tapLeaf(t, 'מותגים ומחירים');
        expect(c.read(bsManageLeafProvider), isNull);
        expect(
          find.text('🏷️ עריכת המותגים והמחירים של כל מוצר'),
          findsOneWidget,
        );
        expect(find.textContaining('בבנייה'), findsNothing);
      },
    );

    testWidgets(
      'the בדיקות רגרסיה leaf (mm-regression) STILL routes to its screen '
      '(no regression) — and NO "בבנייה"',
      (t) async {
        final c = await pump(t);
        await openManage(t, c);

        expect(find.byType(RegressionPanelScreen), findsNothing);
        await tapLeaf(t, 'בדיקות רגרסיה');
        // It routed to the real regression screen (not a panel / not a toast).
        expect(find.byType(RegressionPanelScreen), findsOneWidget);
        // The route closes the dial (openDialProvider → none) and opens no
        // manage/metric/order/customer panel.
        expect(c.read(openDialProvider), OpenDial.none);
        expect(c.read(bsManageLeafProvider), isNull);
        expect(find.textContaining('בבנייה'), findsNothing);
      },
    );

    testWidgets(
      'opening a manage data leaf clears any open metric/order/customer panel '
      '(mutually exclusive — both directions)',
      (t) async {
        final c = await pump(t);

        // 1) Open a dashboard metric panel (M1), then a manage leaf — the
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
        // Pop to persona root, drill into ניהול, open a manage data leaf.
        c.read(bsDrillPathProvider.notifier).state = const [];
        c.read(bsMetricLeafProvider.notifier).state = null;
        await settle(t);
        await openManage(t, c);
        await tapLeaf(t, 'קטגוריות');
        expect(c.read(bsManageLeafProvider), 'mm-cats');
        expect(c.read(bsMetricLeafProvider), isNull);
        expect(c.read(bsOrderLeafProvider), isNull);
        expect(c.read(bsCustomerLeafProvider), isNull);

        // 2) Open a customer panel (M3) while the manage panel is open — the
        //    manage panel must close (the reverse exclusion).
        c.read(bsDrillPathProvider.notifier).state = const [];
        c.read(bsManageLeafProvider.notifier).state = null;
        await settle(t);
        c.read(activePersonaProvider.notifier).state = 'manager';
        await settle(t);
        await t.tap(
          find.descendant(
            of: find.byType(DialRow),
            matching: find.text('לקוחות'),
          ),
        );
        await settle(t);
        await tapLeaf(t, 'פעיל');
        expect(c.read(bsCustomerLeafProvider), 'mc-live');
        expect(c.read(bsManageLeafProvider), isNull);
      },
    );

    test('the mm-* leaf sets partition the ניהול section with no overlap', () {
      // The two data-view leaves, the two action leaves, and mm-regression are
      // disjoint and together cover every ניהול leaf — so NO leaf can fall
      // through to the "בבנייה" stub.
      expect(kManagerManageDataLeafIds, {'mm-cats', 'mm-settings'});
      expect(kManagerManageActionLeafIds.keys.toSet(), {'mm-trees', 'mm-brands'});
      // No id is both a data leaf and an action leaf.
      expect(
        kManagerManageDataLeafIds
            .intersection(kManagerManageActionLeafIds.keys.toSet()),
        isEmpty,
      );
      // mm-regression is in neither set (it routes).
      expect(kManagerManageDataLeafIds.contains('mm-regression'), isFalse);
      expect(
        kManagerManageActionLeafIds.containsKey('mm-regression'),
        isFalse,
      );
    });
  });
}

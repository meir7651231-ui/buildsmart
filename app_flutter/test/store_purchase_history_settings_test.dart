// B5 wiring — the 'היסטוריית רכישות' store-settings toggle (store_settings →
// פרטיות ורכישות) used to persist-but-do-nothing ('בבנייה — עדיין לא משפיע').
// It now drives a REAL, observable client effect: when OFF, the הזמנות tab hides
// the purchase-history list behind a privacy notice (the buyer's own choice);
// when ON (default) the order rows render. No backend — pure local display gate.
//
// Mounts StoreScreen directly on an RTL surface (the same harness shape as
// store_notif_widget_test.dart) and drives storeSectionProvider to .orders.

import 'package:buildsmart/screens/store_screen.dart'
    show StoreScreen, StoreSection, storeSectionProvider;
import 'package:buildsmart/state/store_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Mounts StoreScreen on the orders tab and returns its container so the test
  /// can flip the setting.
  Future<ProviderContainer> pumpOrders(WidgetTester t) async {
    SharedPreferences.setMockInitialValues({});
    await t.binding.setSurfaceSize(const Size(440, 950));
    addTearDown(() => t.binding.setSurfaceSize(null));
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(storeSectionProvider.notifier).state = StoreSection.orders;
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('he'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: StoreScreen()),
          ),
        ),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    return container;
  }

  group('purchaseHistory gates the order-history list', () {
    testWidgets('ON (default) → order rows show, no privacy notice', (t) async {
      final c = await pumpOrders(t);
      expect(c.read(storeSettingsProvider).purchaseHistory, isTrue);
      // The privacy-hidden state is absent; real order rows are present.
      expect(find.text('היסטוריית הרכישות מוסתרת'), findsNothing);
      expect(find.byType(InkWell), findsWidgets); // order rows
    });

    testWidgets('OFF → list hidden behind the privacy notice', (t) async {
      final c = await pumpOrders(t);
      c
          .read(storeSettingsProvider.notifier)
          .update((s) => s.copyWith(purchaseHistory: false));
      for (var i = 0; i < 4; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('היסטוריית הרכישות מוסתרת'), findsOneWidget);
      expect(find.text('הצג היסטוריה'), findsOneWidget);
    });

    testWidgets('tapping "הצג היסטוריה" re-enables the setting and the list',
        (t) async {
      final c = await pumpOrders(t);
      c
          .read(storeSettingsProvider.notifier)
          .update((s) => s.copyWith(purchaseHistory: false));
      for (var i = 0; i < 4; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
      await t.tap(find.text('הצג היסטוריה'));
      for (var i = 0; i < 4; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
      expect(c.read(storeSettingsProvider).purchaseHistory, isTrue);
      expect(find.text('היסטוריית הרכישות מוסתרת'), findsNothing);
    });
  });
}

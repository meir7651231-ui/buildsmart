// B5 wiring — three store-settings toggles that used to persist-but-do-nothing
// ('בבנייה — עדיין לא משפיע') now drive a REAL, observable client effect at the
// checkout/cart surface. Each test flips the setting and asserts the UI changes
// (the honesty rule: a wired setting must produce an observable difference).
//
//   • shareCartWithTeam     → the cart 'שתף' button shows only when ON.
//   • supplierCreditEnabled → the 'אשראי ספק' payment chip shows only when ON.
//   • defaultAddress        → pre-fills the 'לאן לשלוח?' ship-to field.
//
// Drives the real app to the cart section exactly as HomeShell's cart FAB does
// (tab 3 + StoreSection.cart), mirroring test/cart_share_test.dart. The cart is
// one short ListView (maxExtent ≈ 685px); the payment selector + actions row
// both sit at its bottom, so jumping the scrollable to maxScrollExtent reveals
// them deterministically (lazy-list step scrolling is flaky for this).

import 'package:buildsmart/main.dart';
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/screens/store_screen.dart'
    show StoreSection, openShipToSheet, shipToProvider, storeSectionProvider;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/share_seam.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/store_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

SmartCartLine _line(String name, String emoji, int price, int qty) =>
    SmartCartLine(
      productKey: name,
      productName: name,
      productEmoji: emoji,
      brandName: 'מותג',
      brandPrice: price,
      productQty: qty,
      accessories: const [],
    );

/// The cart's vertical scrollable (its ListView has a unique padding).
Finder _cartScrollable() => find
    .descendant(
      of: find.byWidgetPredicate(
        (w) =>
            w is ListView &&
            w.padding ==
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      matching: find.byType(Scrollable),
    )
    .first;

/// Reveals the bottom of the cart (payment selector + actions row) reliably.
Future<void> _scrollCartToBottom(WidgetTester t) async {
  final st = t.state<ScrollableState>(_cartScrollable());
  st.position.jumpTo(st.position.maxScrollExtent);
  await t.pumpAndSettle();
}

/// Pumps the app (with optional overrides), lands on the cart section with one
/// line, and returns the HomeShell container so the test can flip settings.
Future<ProviderContainer> _toCart(
  WidgetTester t, {
  List<Override> overrides = const [],
}) async {
  await t.pumpWidget(
    ProviderScope(overrides: overrides, child: const BuildSmartApp()),
  );
  await t.pumpAndSettle();
  final container =
      ProviderScope.containerOf(t.element(find.byType(HomeShell)));
  container.read(smartCartProvider.notifier).add(_line('מלט', '🧱', 30, 2));
  container.read(storeSectionProvider.notifier).state = StoreSection.cart;
  container.read(mainTabProvider.notifier).state = 3;
  await t.pumpAndSettle();
  return container;
}

void main() {
  group('shareCartWithTeam gates the cart שתף button', () {
    testWidgets('OFF (default) → no שתף button', (t) async {
      SharedPreferences.setMockInitialValues({});
      final container = await _toCart(t);
      expect(container.read(storeSettingsProvider).shareCartWithTeam, isFalse);
      await _scrollCartToBottom(t);
      // The actions row is on screen (נקה is its last button) but שתף is gated.
      expect(find.text('נקה'), findsOneWidget);
      expect(find.text('שתף'), findsNothing);
    });

    testWidgets('ON → שתף button appears', (t) async {
      SharedPreferences.setMockInitialValues({});
      final container = await _toCart(t);
      container
          .read(storeSettingsProvider.notifier)
          .update((s) => s.copyWith(shareCartWithTeam: true));
      await t.pumpAndSettle();
      await _scrollCartToBottom(t);
      expect(find.text('שתף'), findsOneWidget);
    });

    testWidgets('ON → שתף actually shares the cart summary via the seam',
        (t) async {
      SharedPreferences.setMockInitialValues({});
      final shared = <String>[];
      final container = await _toCart(
        t,
        overrides: [
          shareTextProvider.overrideWithValue((text) async {
            shared.add(text);
          }),
        ],
      );
      container
          .read(storeSettingsProvider.notifier)
          .update((s) => s.copyWith(shareCartWithTeam: true));
      await t.pumpAndSettle();
      await _scrollCartToBottom(t);
      await t.tap(find.text('שתף'));
      await t.pumpAndSettle();
      expect(shared, hasLength(1));
      expect(shared.single, contains('מלט'));
      expect(shared.single, contains('סה״כ: ₪60'));
    });
  });

  group('supplierCreditEnabled gates the אשראי ספק payment chip', () {
    testWidgets('OFF (default) → no אשראי ספק chip (כרטיס still shown)',
        (t) async {
      SharedPreferences.setMockInitialValues({});
      final container = await _toCart(t);
      expect(
        container.read(storeSettingsProvider).supplierCreditEnabled,
        isFalse,
      );
      await _scrollCartToBottom(t);
      expect(find.textContaining('אמצעי תשלום'), findsOneWidget);
      expect(find.text('כרטיס'), findsOneWidget); // always offered
      expect(find.text('אשראי ספק'), findsNothing); // gated off
    });

    testWidgets('ON → אשראי ספק chip appears', (t) async {
      SharedPreferences.setMockInitialValues({});
      final container = await _toCart(t);
      container
          .read(storeSettingsProvider.notifier)
          .update((s) => s.copyWith(supplierCreditEnabled: true));
      await t.pumpAndSettle();
      await _scrollCartToBottom(t);
      expect(find.text('אשראי ספק'), findsOneWidget);
      expect(find.text('כרטיס'), findsOneWidget);
    });
  });

  group('defaultAddress pre-fills the ship-to field', () {
    testWidgets('empty default → ship-to field starts empty', (t) async {
      SharedPreferences.setMockInitialValues({});
      await _openShipTo(t, defaultAddress: '');
      final field = t.widget<TextField>(find.byType(TextField).first);
      expect(field.controller?.text ?? '', isEmpty);
    });

    testWidgets('saved default → ship-to field is pre-filled with it',
        (t) async {
      SharedPreferences.setMockInitialValues({});
      await _openShipTo(t, defaultAddress: 'הרצל 10, תל אביב');
      final field = t.widget<TextField>(find.byType(TextField).first);
      expect(field.controller?.text, 'הרצל 10, תל אביב');
    });

    testWidgets('in-progress shipTo wins over the default', (t) async {
      SharedPreferences.setMockInitialValues({});
      await _openShipTo(
        t,
        defaultAddress: 'הרצל 10, תל אביב',
        shipTo: 'אבן גבירול 5',
      );
      final field = t.widget<TextField>(find.byType(TextField).first);
      expect(field.controller?.text, 'אבן גבירול 5');
    });
  });
}

/// Opens the ship-to sheet with the given store-settings default address and
/// optional in-progress shipTo. Uses a tiny self-contained host (its own
/// container + Navigator) so the modal sheet opens deterministically.
Future<void> _openShipTo(
  WidgetTester t, {
  required String defaultAddress,
  String shipTo = '',
}) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  if (defaultAddress.isNotEmpty) {
    container
        .read(storeSettingsProvider.notifier)
        .update((s) => s.copyWith(defaultAddress: defaultAddress));
  }
  if (shipTo.isNotEmpty) {
    container.read(shipToProvider.notifier).state = shipTo;
  }
  await t.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Consumer(
          builder: (c, ref, _) => Scaffold(
            body: Builder(
              builder: (bctx) => Center(
                child: ElevatedButton(
                  onPressed: () => openShipToSheet(bctx, ref),
                  child: const Text('פתח'),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await t.pumpAndSettle();
  await t.tap(find.text('פתח'));
  await t.pumpAndSettle();
  expect(find.text('לאן לשלוח?'), findsOneWidget);
}

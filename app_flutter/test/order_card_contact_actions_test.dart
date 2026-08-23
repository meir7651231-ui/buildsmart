// Order-card surface — the 📞/💬 ContactActions on a real order card.
//
// The product decision: an order card's contact buttons reach the PERSON WHO
// PLACED the order (the contractor), via the additive `Order.customerPhone`
// (stamped at checkout from the placer's profile), projected onto `SysOrder`
// and rendered by `ContactActions(phone: order.customerPhone)`.
//
// We pump the COURIER DELIVERY DETAIL SHEET (a self-contained ConsumerWidget
// order card that reads `sysOrdersProvider` by id) over a test engine seeded
// with a single order, and assert:
//   • a STAMPED order → the 📞/💬 buttons render and target the right Uris;
//   • an UN-STAMPED order (empty customerPhone — every seed/legacy order) →
//     NO buttons at all (ContactActions' empty-guard) = the zero-regression.
//
// url_launcher can't launch in a unit test, so the [urlLauncherProvider] seam
// is overridden with a capturing fake (same pattern as contact_actions_test).

import 'package:buildsmart/screens/courier_delivery_detail_sheet.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/url_launcher_seam.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturingLauncher {
  final List<Uri> launched = [];
  Future<bool> call(Uri uri) async {
    launched.add(uri);
    return true;
  }
}

/// Pump the courier order card for a single [order] over a Firebase-free engine
/// seeded with exactly that order (persist:false → no SharedPreferences).
Future<_CapturingLauncher> _pumpCard(WidgetTester tester, Order order) async {
  final fake = _CapturingLauncher();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        urlLauncherProvider.overrideWithValue(fake.call),
        // Seed the shared engine with just this one order; sysOrdersProvider
        // projects it (carrying customerPhone) for the card to read by id.
        ordersEngineProvider.overrideWith(
          (ref) => OrdersEngineNotifier(persist: false, seed: [order]),
        ),
      ],
      child: MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: CourierDeliveryDetailSheet(orderId: order.id),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return fake;
}

Order _order({required String phone, String stage = 'pickup'}) => Order(
      id: 'BS-1042',
      who: 'יוסי כהן',
      site: 'מגדל הרצליה',
      items: 7,
      sum: 1240,
      stage: stage,
      customerPhone: phone,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('order card · ContactActions(phone: order.customerPhone)', () {
    testWidgets('a STAMPED order renders 📞/💬 reaching the contractor',
        (tester) async {
      final fake = await _pumpCard(tester, _order(phone: '050-123 4567'));

      // The card is showing the right order (customer name renders).
      expect(find.textContaining('יוסי כהן'), findsWidgets);
      // Both contact buttons render for a valid phone.
      expect(find.byIcon(Icons.call), findsOneWidget);
      expect(find.byIcon(Icons.chat), findsOneWidget);

      await tester.tap(find.byIcon(Icons.call));
      await tester.pumpAndSettle();
      expect(
        Uri.decodeFull(fake.launched.single.toString()),
        'tel:050-123 4567',
      );

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();
      expect(fake.launched.last.toString(), 'https://wa.me/972501234567');
    });

    testWidgets('an UN-STAMPED order shows NO buttons (zero-regression)',
        (tester) async {
      final fake = await _pumpCard(tester, _order(phone: ''));

      // Same card, same order — but with no phone there are no buttons.
      expect(find.textContaining('יוסי כהן'), findsWidgets);
      expect(find.byIcon(Icons.call), findsNothing);
      expect(find.byIcon(Icons.chat), findsNothing);
      expect(fake.launched, isEmpty);
    });
  });
}

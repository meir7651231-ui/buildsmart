// #52 — the ORDER/shipment notification toggles, relocated from settings into
// the orders world (store_screen · 📦 הזמנות). The sheet binds the SAME
// notifSettingsProvider, so a flip here writes the one source of truth — there
// is no second copy of the state.
import 'package:buildsmart/screens/order_notif_sheet.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('orders-world sheet shows + writes typeOrders/typeShipments (#52)',
      (tester) async {
    late WidgetRef ref;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Consumer(
            builder: (c, r, _) {
              ref = r;
              return const Scaffold(body: OrderNotifSheet());
            },
          ),
        ),
      ),
    );
    await tester.pump();

    // both order/shipment toggles render in the orders world
    expect(find.text('עדכוני הזמנות'), findsOneWidget);
    expect(find.text('עדכוני משלוחים'), findsOneWidget);

    // flipping writes the SAME notifSettingsProvider (one source of truth)
    expect(ref.read(notifSettingsProvider).typeOrders, isTrue);
    await tester.tap(find.text('עדכוני הזמנות'));
    await tester.pump();
    expect(ref.read(notifSettingsProvider).typeOrders, isFalse,
        reason: 'the orders-world toggle writes notifSettingsProvider.typeOrders');

    expect(ref.read(notifSettingsProvider).typeShipments, isTrue);
    await tester.tap(find.text('עדכוני משלוחים'));
    await tester.pump();
    expect(ref.read(notifSettingsProvider).typeShipments, isFalse);
  });
}

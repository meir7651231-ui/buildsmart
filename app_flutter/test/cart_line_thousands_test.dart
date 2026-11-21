// Regression: cart line totals / accessory sums / the shared cart text printed
// raw ("₪5400") while the cart summary groups ("₪5,400"). Every ₪ amount in the
// cart now routes through logic/money_format.dart.
import 'package:buildsmart/main.dart';
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/screens/store_screen.dart'
    show StoreSection, storeSectionProvider;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/share_seam.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/store_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('cart line + accessory totals are thousands-grouped', (t) async {
    SharedPreferences.setMockInitialValues({});
    final shared = <String>[];
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          shareTextProvider.overrideWithValue((s) async => shared.add(s)),
        ],
        child: const BuildSmartApp(),
      ),
    );
    await t.pumpAndSettle();
    final c = ProviderScope.containerOf(t.element(find.byType(HomeShell)));

    // 2 × ₪2,100 + accessory 1 × ₪1,200 = ₪5,400.
    c.read(smartCartProvider.notifier).add(
          const SmartCartLine(
            productKey: 'boiler',
            productName: 'דוד',
            productEmoji: '🔥',
            brandName: 'מותג',
            brandPrice: 2100,
            productQty: 2,
            accessories: [
              SmartCartAcc(name: 'ערכת חיבור', emoji: '🔧', price: 1200, qty: 1),
            ],
          ),
        );
    c
        .read(storeSettingsProvider.notifier)
        .update((s) => s.copyWith(shareCartWithTeam: true));
    c.read(storeSectionProvider.notifier).state = StoreSection.cart;
    c.read(mainTabProvider.notifier).state = 3;
    await t.pumpAndSettle();

    expect(find.text('דוד × 2'), findsOneWidget);
    expect(find.text('₪5,400'), findsWidgets);
    expect(find.text('₪5400'), findsNothing);
    expect(find.text('₪1,200'), findsOneWidget);
    expect(find.text('₪1200'), findsNothing);

    final cartScroll = find
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
    await t.scrollUntilVisible(find.text('שתף'), 150, scrollable: cartScroll);
    await t.pumpAndSettle();
    await t.drag(cartScroll, const Offset(0, -120));
    await t.pumpAndSettle();
    await t.tap(find.text('שתף'));
    await t.pumpAndSettle();

    expect(shared, hasLength(1));
    expect(shared.single, contains('= ₪5,400'));
    expect(shared.single, contains('סה״כ: ₪5,400'));
  });
}

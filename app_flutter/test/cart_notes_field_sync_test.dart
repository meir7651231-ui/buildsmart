// Nightly 2026-11-20 — the cart's "📝 הערות לשליח" field follows the provider.
// The store stays mounted in the shell's IndexedStack, so when
// cartNotesProvider is reset from outside (account change — see
// ship_to_identity_reset_test — order placed, cart cleared) the field used to
// keep showing the old note, and the next tap/keystroke wrote it straight back
// onto the next user's order.
import 'package:buildsmart/main.dart';
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/screens/store_screen.dart'
    show StoreSection, storeSectionProvider, cartNotesProvider;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('external reset of the note clears the visible field', (t) async {
    SharedPreferences.setMockInitialValues({});
    await t.pumpWidget(const ProviderScope(child: BuildSmartApp()));
    await t.pumpAndSettle();
    final c = ProviderScope.containerOf(t.element(find.byType(HomeShell)));

    c
        .read(smartCartProvider.notifier)
        .add(
          const SmartCartLine(
            productKey: 'מלט',
            productName: 'מלט',
            productEmoji: '🧱',
            brandName: 'מותג',
            brandPrice: 30,
            productQty: 1,
            accessories: [],
          ),
        );
    c.read(cartNotesProvider.notifier).state = 'הערה של משתמש א';
    c.read(storeSectionProvider.notifier).state = StoreSection.cart;
    c.read(mainTabProvider.notifier).state = 3;
    await t.pumpAndSettle();

    final cartScroll =
        find
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
    await t.scrollUntilVisible(
      find.text('📝 הערות לשליח'),
      150,
      scrollable: cartScroll,
    );
    await t.pumpAndSettle();

    String fieldText() => t
        .widgetList<EditableText>(find.byType(EditableText))
        .map((e) => e.controller.text)
        .firstWhere((s) => s.contains('משתמש א'), orElse: () => '');
    expect(fieldText(), 'הערה של משתמש א');

    // Simulates the identity reset (sign-out → another account).
    c.read(cartNotesProvider.notifier).state = '';
    await t.pumpAndSettle();
    expect(fieldText(), '', reason: 'the field must not keep the old note');
    expect(c.read(cartNotesProvider), '');
  });
}

// LAUNCH FIX #1 — the cart 'שתף' button (store_screen.dart _CartActionsRow).
//
// It used to ONLY toast the cart summary. It now hands that summary to the
// real native/Web share sheet — through the injectable `shareTextProvider`
// seam (lib/state/share_seam.dart), so this test CAPTURES the exact shared
// text without a live share sheet. Mirrors test/contact_actions_test.dart.
//
// The cart-actions row is private, so we drive the real app to the cart
// section (the same providers HomeShell's cart FAB sets) and tap 'שתף'.

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

/// Records every text handed to the share seam.
class _CapturingSharer {
  final List<String> shared = [];
  Future<void> call(String text) async => shared.add(text);
}

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

void main() {
  testWidgets('tapping שתף hands the cart summary to the share seam',
      (t) async {
    SharedPreferences.setMockInitialValues({});
    final fake = _CapturingSharer();

    await t.pumpWidget(
      ProviderScope(
        overrides: [shareTextProvider.overrideWithValue(fake.call)],
        child: const BuildSmartApp(),
      ),
    );
    await t.pumpAndSettle();

    final container =
        ProviderScope.containerOf(t.element(find.byType(HomeShell)));

    // Seed a real cart line, then land on the store's cart section (exactly
    // what HomeShell's cart FAB does: tab 3 + StoreSection.cart).
    // The 'שתף' button is gated behind the 'שיתוף סל עם צוות' store setting
    // (off by default) — enable it so the share row renders (B5 wiring).
    container.read(smartCartProvider.notifier).add(_line('מלט', '🧱', 30, 2));
    container
        .read(storeSettingsProvider.notifier)
        .update((s) => s.copyWith(shareCartWithTeam: true));
    container.read(storeSectionProvider.notifier).state = StoreSection.cart;
    container.read(mainTabProvider.notifier).state = 3;
    await t.pumpAndSettle();

    // The cart line renders (these prove we're on the cart list, not elsewhere).
    expect(find.text('מלט × 2'), findsOneWidget);
    expect(find.text('₪60'), findsWidgets);

    // The cart-actions row lives at the bottom of the cart ListView — scroll
    // THAT list (its padding is unique: symmetric h12/v8) so we don't grab the
    // notes-field's internal editor scrollable.
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
    // Drag a little further so the actions row clears the bottom edge and the
    // button is fully hittable (scrollUntilVisible stops at first visibility).
    await t.drag(cartScroll, const Offset(0, -120));
    await t.pumpAndSettle();

    await t.tap(find.text('שתף'));
    await t.pumpAndSettle();

    // Exactly one share fired, carrying the real cart line + total.
    expect(fake.shared, hasLength(1));
    final text = fake.shared.single;
    expect(text, contains('מלט'));
    expect(text, contains('🧱'));
    expect(text, contains('× 2'));
    expect(text, contains('₪60')); // 30 × 2 line total
    expect(text, contains('סה״כ: ₪60'));
  });

  testWidgets('empty cart shares NOTHING (only toasts הסל ריק)', (t) async {
    SharedPreferences.setMockInitialValues({});
    final fake = _CapturingSharer();

    await t.pumpWidget(
      ProviderScope(
        overrides: [shareTextProvider.overrideWithValue(fake.call)],
        child: const BuildSmartApp(),
      ),
    );
    await t.pumpAndSettle();

    final container =
        ProviderScope.containerOf(t.element(find.byType(HomeShell)));
    container.read(storeSectionProvider.notifier).state = StoreSection.cart;
    container.read(mainTabProvider.notifier).state = 3;
    await t.pumpAndSettle();

    // Empty cart → the actions row is not shown (cart shows the empty state),
    // so there is nothing to tap and nothing is shared.
    expect(find.text('שתף'), findsNothing);
    expect(fake.shared, isEmpty);
  });
}

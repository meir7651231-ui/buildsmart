// Nightly 2026-11-16 — the courier-notes field ('📝 הערות לשליח') must follow
// `cartNotesProvider` when the cart is reset (checkout success / 'נקה').
//
// Bug: _CartView seeded its TextEditingController from the provider ONCE in
// initState. Checkout and 'נקה' reset the provider to '' — but the controller
// kept the old text, because _CartView stays mounted (it just shows the empty
// state). On the next cart the field still SHOWED the previous order's note
// while the provider (what placeOrder reads) was '' → the note the user sees
// was silently not sent; typing one more character sent old+new text.

import 'package:buildsmart/main.dart';
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/screens/store_screen.dart'
    show StoreSection, cartNotesProvider, storeSectionProvider;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

SmartCartLine _line(String name, int qty) => SmartCartLine(
      productKey: name,
      productName: name,
      productEmoji: '🧱',
      brandName: 'מותג',
      brandPrice: 30,
      productQty: qty,
      accessories: const [],
    );

/// The notes editor — the only EditableText in the cart whose hint is the
/// courier-notes hint.
const _hint = 'קומה / כניסה / שם האתר / הוראות לנהג...';

Finder _notesEditor() => find.descendant(
      of: find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == _hint,
      ),
      matching: find.byType(EditableText),
    );

/// The cart ListView's own scrollable (padding h12/v8 is unique to it), so we
/// don't grab the notes editor's internal scrollable.
Finder _cartScroll() => find
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

Future<void> _revealNotes(WidgetTester t) async {
  await t.scrollUntilVisible(_notesEditor(), 150, scrollable: _cartScroll());
  await t.pumpAndSettle();
}

String _notesText(WidgetTester t) =>
    t.widget<EditableText>(_notesEditor()).controller.text;

Future<ProviderContainer> _openCart(WidgetTester t) async {
  SharedPreferences.setMockInitialValues({});
  await t.pumpWidget(const ProviderScope(child: BuildSmartApp()));
  await t.pumpAndSettle();
  final c = ProviderScope.containerOf(t.element(find.byType(HomeShell)));
  c.read(smartCartProvider.notifier).add(_line('מלט', 2));
  c.read(storeSectionProvider.notifier).state = StoreSection.cart;
  c.read(mainTabProvider.notifier).state = 3;
  await t.pumpAndSettle();
  await _revealNotes(t);
  return c;
}

void main() {
  testWidgets('typing in the notes field writes cartNotesProvider', (t) async {
    final c = await _openCart(t);
    expect(_notesEditor(), findsOneWidget);
    await t.enterText(_notesEditor(), 'קומה 3');
    await t.pump();
    expect(c.read(cartNotesProvider), 'קומה 3');
  });

  testWidgets('cart reset (provider → "") clears the visible note too',
      (t) async {
    final c = await _openCart(t);
    await t.enterText(_notesEditor(), 'קומה 3');
    await t.pump();

    // Exactly what checkout success / 'נקה' do.
    c.read(smartCartProvider.notifier).clear();
    c.read(cartNotesProvider.notifier).state = '';
    await t.pumpAndSettle();

    // Next order: a new line → the cart list (and notes field) is back.
    c.read(smartCartProvider.notifier).add(_line('חול', 1));
    await t.pumpAndSettle();
    await _revealNotes(t);

    expect(_notesText(t), '',
        reason: "the previous order's note must not linger in the field");
    expect(c.read(cartNotesProvider), '');

    // Typing now sends ONLY the new text (not old+new).
    await t.enterText(_notesEditor(), 'כניסה ב');
    await t.pump();
    expect(c.read(cartNotesProvider), 'כניסה ב');
  });

  testWidgets('reset while the cart list stays visible also clears the field',
      (t) async {
    final c = await _openCart(t);
    await t.enterText(_notesEditor(), 'קומה 3');
    await t.pump();

    c.read(cartNotesProvider.notifier).state = '';
    await t.pumpAndSettle();
    expect(_notesText(t), '');
  });

  testWidgets('the field is named for screen readers + uses theme ink',
      (t) async {
    final handle = t.ensureSemantics();
    await _openCart(t);
    await t.enterText(_notesEditor(), 'קומה 3');
    await t.pump();

    // Named even once text is typed (the hint is gone then).
    expect(find.bySemanticsLabel(RegExp('הערות לשליח')), findsWidgets);

    final editor = t.widget<EditableText>(_notesEditor());
    final scheme = Theme.of(t.element(_notesEditor())).colorScheme;
    expect(editor.style.color, scheme.onSurface,
        reason: 'typed text must follow the theme (dark-mode readable)');
    handle.dispose();
  });
}


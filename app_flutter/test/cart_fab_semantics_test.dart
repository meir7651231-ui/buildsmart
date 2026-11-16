// Nightly 2026-11-16 — the floating cart button (CartFab) must have a real
// screen-reader name. Before: an unlabelled cart icon + the badge digits, so
// TalkBack/VoiceOver announced only "3, button".

import 'package:buildsmart/screens/home_shell.dart';
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

Future<ProviderContainer> _pumpFab(WidgetTester t) async {
  SharedPreferences.setMockInitialValues({});
  final c = ProviderContainer();
  addTearDown(c.dispose);
  await t.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(floatingActionButton: CartFab()),
        ),
      ),
    ),
  );
  return c;
}

void main() {
  group('cartFabSemanticsLabel', () {
    test('names the action and the item count (Hebrew singular for 1)', () {
      expect(cartFabSemanticsLabel(0), 'פתיחת הסל');
      expect(cartFabSemanticsLabel(1), 'פתיחת הסל · פריט אחד');
      expect(cartFabSemanticsLabel(3), 'פתיחת הסל · 3 פריטים');
    });
  });

  testWidgets('the FAB is a named button — not just the badge digits',
      (t) async {
    final handle = t.ensureSemantics();
    final c = await _pumpFab(t);
    c.read(smartCartProvider.notifier)
      ..add(_line('מלט', 2))
      ..add(_line('חול', 1));
    await t.pumpAndSettle();

    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    // The badge still SHOWS the count visually.
    expect(find.text('3'), findsOneWidget);

    expect(
      t.getSemantics(fab),
      matchesSemantics(
        label: 'פתיחת הסל · 3 פריטים',
        isButton: true,
        hasTapAction: true,
        hasFocusAction: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
      ),
    );
    handle.dispose();
  });
}

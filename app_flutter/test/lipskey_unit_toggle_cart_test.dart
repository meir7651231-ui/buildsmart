// Nightly 2026-11-20 — the list card's unit chips (בודד / ארגז / משטח) must
// keep the stepper and the cart in agreement when the product is already in
// the cart. Before: 30 units in the cart → tap "ארגז" (pack of 20) → stepper
// showed "1" while the cart still held 30, and the next "−" silently wrote 20
// (10 units lost). Now the switch rounds the cart UP to whole packs (never
// loses quantity) and the stepper equals the cart.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _p = kLipskeyCatalog.firstWhere((p) => p.sku == '217861'); // pack 20
const _key = 'lip:217861';

SmartCartLine _line(int qty) => SmartCartLine(
  productKey: _key,
  productName: _p.nameHe,
  productEmoji: _p.typeEmoji,
  brandName: _p.brand,
  brandPrice: 0,
  productQty: qty,
  accessories: const [],
);

Widget _app(ProviderContainer c) => UncontrolledProviderScope(
  container: c,
  child: MaterialApp(
    home: Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: LipskeyProductCard(product: _p, products: [_p]),
        ),
      ),
    ),
  ),
);

/// The stepper's centre count (the only Text that is a bare integer inside
/// the stepper row).
String _stepperCount(WidgetTester t) {
  final minus = find.byTooltip('הפחת כמות');
  final row = find.ancestor(of: minus, matching: find.byType(Row)).first;
  final nums =
      t
          .widgetList<Text>(
            find.descendant(of: row, matching: find.byType(Text)),
          )
          .map((w) => w.data ?? '')
          .where((s) => RegExp(r'^\d+$').hasMatch(s))
          .toList();
  return nums.single;
}

void main() {
  late ProviderContainer c;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    c = ProviderContainer();
  });
  tearDown(() => c.dispose());

  testWidgets('pack chip with 30 in cart → cart rounds UP to 2 packs (40), '
      'stepper shows 2', (t) async {
    await t.binding.setSurfaceSize(const Size(500, 900));
    c.read(smartCartProvider.notifier).setQtyForKey(_line(30));
    await t.pumpWidget(_app(c));
    await t.pumpAndSettle();
    expect(_stepperCount(t), '30');

    await t.tap(find.text('ארגז'));
    await t.pumpAndSettle();
    expect(c.read(smartCartProvider.notifier).qtyForKey(_key), 40);
    expect(_stepperCount(t), '2');

    // "−" now removes exactly one pack — no hidden units vanish.
    await t.tap(find.byTooltip('הפחת כמות'));
    await t.pumpAndSettle();
    expect(c.read(smartCartProvider.notifier).qtyForKey(_key), 20);
    expect(_stepperCount(t), '1');

    // Back to single units: 20 singles, cart unchanged.
    await t.tap(find.text('בודד'));
    await t.pumpAndSettle();
    expect(c.read(smartCartProvider.notifier).qtyForKey(_key), 20);
    expect(_stepperCount(t), '20');
    await t.binding.setSurfaceSize(null);
  });

  testWidgets('exact multiple (40 → 2 packs) leaves the cart untouched', (
    t,
  ) async {
    await t.binding.setSurfaceSize(const Size(500, 900));
    c.read(smartCartProvider.notifier).setQtyForKey(_line(40));
    await t.pumpWidget(_app(c));
    await t.pumpAndSettle();
    await t.tap(find.text('ארגז'));
    await t.pumpAndSettle();
    expect(c.read(smartCartProvider.notifier).qtyForKey(_key), 40);
    expect(_stepperCount(t), '2');
    await t.binding.setSurfaceSize(null);
  });

  testWidgets('unit chips expose button + selected state to screen readers', (
    t,
  ) async {
    final handle = t.ensureSemantics();
    await t.binding.setSurfaceSize(const Size(500, 900));
    c.read(smartCartProvider.notifier).setQtyForKey(_line(20));
    await t.pumpWidget(_app(c));
    await t.pumpAndSettle();
    await t.tap(find.text('ארגז'));
    await t.pumpAndSettle();
    expect(
      t.getSemantics(find.text('ארגז')),
      matchesSemantics(
        label: 'ארגז',
        isButton: true,
        isSelected: true,
        isEnabled: true,
        hasEnabledState: true,
        hasTapAction: true,
      ),
    );
    await t.binding.setSurfaceSize(null);
    handle.dispose();
  });
}

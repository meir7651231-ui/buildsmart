import 'package:buildsmart/main.dart';
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// End-to-end purchase journey for ONE real catalog product (SKU 217861 —
/// "מחסום (סיפון) אמריקאי 1.25\" לכיור רחצה"). Drives every button from the
/// catalog search, through the product sheet, the cart FAB, the store cart
/// (stepper + summary), and checkout to confirmation — asserting both the UI
/// and the underlying providers at each stage. If any button in the chain is
/// broken, this test goes red.
void main() {
  const sku = '217861';
  const productName = 'מחסום (סיפון) אמריקאי 1.25" לכיור רחצה';

  Widget app() => const ProviderScope(child: BuildSmartApp());

  ProviderContainer containerOf(WidgetTester t) =>
      ProviderScope.containerOf(t.element(find.byType(HomeShell)));

  testWidgets('product 217861 — full journey: search → sheet → cart → checkout',
      (t) async {
    await t.pumpWidget(app());
    await t.pumpAndSettle();

    // ── Stage 1 · catalog boots ──────────────────────────────────────────
    expect(find.text('BuildSmart'), findsOneWidget);

    // ── Stage 2 · open the search panel and query the SKU ────────────────
    final searchField = find.byType(TextField).first;
    await t.tap(searchField);
    await t.pumpAndSettle();
    await t.enterText(searchField, sku);
    await t.pumpAndSettle();

    // The live product result for that SKU is shown.
    expect(find.text(productName), findsAtLeastNWidgets(1),
        reason: 'search did not surface product $sku');

    // ── Stage 3 · open the product sheet ─────────────────────────────────
    await t.ensureVisible(find.text(productName).first);
    await t.tap(find.text(productName).first);
    await t.pumpAndSettle();

    // The modal product sheet opened.
    expect(find.byType(DraggableScrollableSheet), findsOneWidget);

    // ── Stage 4 · add to cart ────────────────────────────────────────────
    // The sheet body is a lazy ListView; scroll the CTA into view first.
    final sheetScrollable = find
        .descendant(
          of: find.byType(DraggableScrollableSheet),
          matching: find.byType(Scrollable),
        )
        .first;
    await t.scrollUntilVisible(find.text('הוסף לסל'), 250,
        scrollable: sheetScrollable);
    await t.pumpAndSettle();
    expect(find.text('הוסף לסל'), findsOneWidget);
    await t.tap(find.text('הוסף לסל'));
    await t.pumpAndSettle();

    // Provider truth: exactly one smart-cart line for this SKU, qty 1.
    final lines = containerOf(t).read(smartCartProvider);
    expect(lines.length, 1);
    expect(lines.single.productKey, 'lip:$sku');
    expect(lines.single.productName, productName);
    expect(lines.single.productQty, 1);

    // ── Stage 5 · jump to the store via the cart FAB ─────────────────────
    expect(find.byType(FloatingActionButton), findsOneWidget);
    await t.tap(find.byType(FloatingActionButton));
    await t.pumpAndSettle();

    // ── Stage 6 · open the cart section ──────────────────────────────────
    await t.tap(find.text('🛒 הסל'));
    await t.pumpAndSettle();

    // The smart line we added is shown in the cart (rendered as "name × qty").
    expect(find.textContaining(productName), findsAtLeastNWidgets(1));
    // The cart's vertical list (not the horizontal chip rows).
    final cartScrollable = find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .first;

    // ── Stage 7 · the + stepper raises a fixed-item quantity ─────────────
    final qtyBefore = containerOf(t)
        .read(cartQtysProvider)
        .values
        .fold<int>(0, (s, q) => s + q);
    await t.scrollUntilVisible(find.byIcon(Icons.add).first, 120,
        scrollable: cartScrollable);
    await t.pumpAndSettle();
    // Tap the mounted "+" stepper nearest the viewport centre — avoids
    // edge-of-viewport mis-taps (where an overlapping widget wins the hit test).
    final midY = t.getRect(cartScrollable).center.dy;
    final adds = find.byIcon(Icons.add);
    var bestIdx = 0;
    var bestDist = double.infinity;
    for (var i = 0; i < adds.evaluate().length; i++) {
      final d = (t.getCenter(adds.at(i)).dy - midY).abs();
      if (d < bestDist) {
        bestDist = d;
        bestIdx = i;
      }
    }
    await t.tap(adds.at(bestIdx));
    await t.pumpAndSettle();
    final qtyAfter = containerOf(t)
        .read(cartQtysProvider)
        .values
        .fold<int>(0, (s, q) => s + q);
    expect(qtyAfter, qtyBefore + 1, reason: 'stepper + did not raise quantity');

    // ── Stage 8 · checkout ───────────────────────────────────────────────
    await t.scrollUntilVisible(find.textContaining('הזמן עכשיו'), 250,
        scrollable: cartScrollable);
    // The full summary (incl. the total line) is now in view.
    expect(find.text('סה"כ לתשלום'), findsOneWidget);
    await t.tap(find.textContaining('הזמן עכשיו'));
    await t.pumpAndSettle();

    // No minimum-order block, no large-order dialog → checkout sheet opens.
    expect(find.text('אישור הזמנה'), findsOneWidget);

    // ── Stage 9 · confirm the order ──────────────────────────────────────
    await t.tap(find.text('אישור הזמנה'));
    await t.pump(); // start the pop + snackbar
    await t.pump(const Duration(milliseconds: 350)); // snackbar entrance

    // The confirmation toast fired ("הזמנה #N אושרה! 🎉").
    expect(find.textContaining('אושרה'), findsAtLeastNWidgets(1));
  });
}

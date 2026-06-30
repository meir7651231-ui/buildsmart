// P10.99: convergence → line → cart, end to end. Two products are picked, the line is
// completed into a BOM, and 'add all to cart' pushes every line item into the smart cart
// and clears the picks. Closes Phase 10.

import 'package:buildsmart/features/card_keyboard/card_picks.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show divePoolBySku;
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/state/smart_cart.dart' show smartCartProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final pool = divePoolBySku.values.toList();
  final base = pool.firstWhere(
    (q) => pool.where((x) => x.categoryHe == q.categoryHe).length >= 3,
  );
  final cat = pool.where((q) => q.categoryHe == base.categoryHe).toList();

  testWidgets('2 picks → complete line → BOM → add all fills the cart, clears the line',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('he'),
          home: Builder(builder: (ctx) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showLipskeyProductSheet(ctx, cat[0], cat, forceLive: true);
            });
            return const Scaffold(body: SizedBox.shrink());
          }),
        ),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 80));
    }

    final container =
        ProviderScope.containerOf(tester.element(find.byType(LipskeyProductSheet)));
    container.read(cardPicksProvider.notifier)
      ..addPick(CardPick(sku: cat[0].sku, label: cat[0].nameHe))
      ..addPick(CardPick(sku: cat[1].sku, label: cat[1].nameHe));
    await tester.pump();

    // Complete the line → BOM opens.
    tester
        .widget<ActionChip>(find.byKey(const Key('completeLineChip')))
        .onPressed!
        .call();
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.byKey(const Key('lineBomSheet')), findsOneWidget);

    // Add all to cart.
    expect(container.read(smartCartProvider), isEmpty);
    tester
        .widget<FilledButton>(find.byKey(const Key('addLineToCartButton')))
        .onPressed!
        .call();
    await tester.pump();

    expect(container.read(smartCartProvider), isNotEmpty,
        reason: 'every line item reached the cart');
    expect(container.read(cardPicksProvider), isEmpty,
        reason: 'the line cleared after completing');
  });
}

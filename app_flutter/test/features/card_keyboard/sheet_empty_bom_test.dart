// Swarm-review: a fully-unresolvable line (picks whose skus are not in the dive pool) must
// NOT let 'add all to cart' add 0 items and silently wipe the picks with a fake success
// toast. The BOM shows an empty-state and the add button is disabled (onPressed == null).

import 'package:buildsmart/features/card_keyboard/card_picks.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show divePoolBySku;
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final pool = divePoolBySku.values.toList();
  final base = pool.firstWhere(
    (q) => pool.where((x) => x.categoryHe == q.categoryHe).length >= 3,
  );
  final cat = pool.where((q) => q.categoryHe == base.categoryHe).toList();

  testWidgets('empty BOM (unresolvable picks) disables add-to-cart — no silent 0-add',
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

    final container = ProviderScope.containerOf(
        tester.element(find.byType(LipskeyProductSheet)));
    // two picks whose skus resolve to NOTHING in the dive pool → an empty plan
    container.read(cardPicksProvider.notifier)
      ..addPick(const CardPick(sku: '__NOPE_1__', label: 'x'))
      ..addPick(const CardPick(sku: '__NOPE_2__', label: 'y'));
    await tester.pump();

    tester
        .widget<ActionChip>(find.byKey(const Key('completeLineChip')))
        .onPressed!
        .call();
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.byKey(const Key('lineBomSheet')), findsOneWidget);

    final btn = tester
        .widget<FilledButton>(find.byKey(const Key('addLineToCartButton')));
    expect(btn.onPressed, isNull,
        reason: 'a fully-unresolvable plan must not be addable to the cart');
  });
}

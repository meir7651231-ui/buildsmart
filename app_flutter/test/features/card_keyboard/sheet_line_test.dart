// P10.98: the line controls on the product sheet — 'add to line' records a pick;
// 'complete line (N)' appears at >=2 picks and opens the BOM sheet (items + gaps + add all
// to cart). Flag-gated: flag-OFF the controls are absent (byte-identical).

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
  final p0 = cat[0];

  final lineControls = find.byKey(const Key('lineControls'));
  final addToLineChip = find.byKey(const Key('addToLineChip'));
  final completeLineChip = find.byKey(const Key('completeLineChip'));
  final bomSheet = find.byKey(const Key('lineBomSheet'));

  Future<void> pump(WidgetTester tester, {required bool forceLive}) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('he'),
          home: Builder(builder: (ctx) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showLipskeyProductSheet(ctx, p0, cat, forceLive: forceLive);
            });
            return const Scaffold(body: SizedBox.shrink());
          }),
        ),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 80));
    }
  }

  testWidgets('flag-OFF: no line controls (byte-identity)', (tester) async {
    await pump(tester, forceLive: false);
    expect(lineControls, findsNothing);
  });

  testWidgets(
      'forceLive: complete-line appears at 2 picks and opens the BOM with add-to-cart',
      (tester) async {
    await pump(tester, forceLive: true);
    expect(addToLineChip, findsOneWidget);
    expect(completeLineChip, findsNothing); // 0 picks

    final container =
        ProviderScope.containerOf(tester.element(find.byType(LipskeyProductSheet)));
    container.read(cardPicksProvider.notifier)
      ..addPick(CardPick(sku: cat[0].sku, label: cat[0].nameHe))
      ..addPick(CardPick(sku: cat[1].sku, label: cat[1].nameHe));
    await tester.pump();
    expect(completeLineChip, findsOneWidget);

    tester.widget<ActionChip>(completeLineChip).onPressed!.call();
    await tester.pump(const Duration(milliseconds: 120));
    expect(bomSheet, findsOneWidget);
    expect(find.byKey(const Key('addLineToCartButton')), findsOneWidget);
  });
}

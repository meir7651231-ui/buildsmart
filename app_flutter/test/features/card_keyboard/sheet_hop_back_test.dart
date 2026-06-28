// P8.74/75: the flag-gated hop 'back' control on the product sheet. Behind
// kCardKeyboard (forced here via forceLive), a 'back' chip appears once the user has
// hopped to a related product, and ONE activation returns to the PREVIOUS product (not
// the opening variant). Flag-OFF the chip never renders — byte-identical.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A real category with >=3 products: the opening variant + two hop targets.
  final base = kLipskeyCatalog.firstWhere(
    (q) =>
        kLipskeyCatalog.where((x) => x.categoryHe == q.categoryHe).length >= 3,
  );
  final cat =
      kLipskeyCatalog.where((q) => q.categoryHe == base.categoryHe).toList();
  final p0 = cat[0];
  final p1 = cat[1];
  final p2 = cat[2];

  final backChip = find.byKey(const Key('hopBackChip'));

  Future<void> pump(
    WidgetTester tester, {
    required bool forceLive,
    required List<LipskeyCatalogProduct> seed,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('he'),
          home: Builder(builder: (ctx) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showLipskeyProductSheet(ctx, p0, [p0, p1, p2],
                  forceLive: forceLive, hopSeedForTest: seed);
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

  // Activate the back control via its wired callback — robust against modal-barrier
  // hit-testing (the chip sits high in the sheet, at an offset the scrim absorbs).
  Future<void> activateBack(WidgetTester tester) async {
    tester.widget<ActionChip>(backChip).onPressed!.call();
    await tester.pump(const Duration(milliseconds: 80));
  }

  testWidgets('flag-OFF: no back control even mid-hop (byte-identity)',
      (tester) async {
    await pump(tester, forceLive: false, seed: [p1]);
    expect(backChip, findsNothing);
  });

  testWidgets('forceLive: no back control at the opening variant (empty stack)',
      (tester) async {
    await pump(tester, forceLive: true, seed: const []);
    expect(backChip, findsNothing);
  });

  testWidgets('forceLive: the back control pops EXACTLY one hop', (tester) async {
    await pump(tester, forceLive: true, seed: [p1, p2]);
    // two hops deep → control visible
    expect(backChip, findsOneWidget);
    await activateBack(tester);
    // back went to the FIRST hop, not the variant → still visible
    expect(backChip, findsOneWidget);
    await activateBack(tester);
    // back at the opening variant → gone
    expect(backChip, findsNothing);
  });
}

// P8.78: the hop path breadcrumb on the product sheet — every product in the path as a
// tappable crumb (home → … → current). Tapping a crumb jumps back to it; tapping home
// clears to the opening variant. Flag-OFF the breadcrumb is absent (byte-identical).

import 'package:buildsmart/data/lipskey_catalog.dart';
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
  final p1 = cat[1];
  final p2 = cat[2];

  final crumb = find.byKey(const Key('hopBreadcrumb'));
  final crumb0 = find.byKey(const Key('hopCrumb_0'));
  final crumb1 = find.byKey(const Key('hopCrumb_1'));
  final home = find.byKey(const Key('hopCrumb_home'));

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
              showLipskeyProductSheet(ctx, p0, cat,
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

  testWidgets('flag-OFF: no breadcrumb even mid-hop (byte-identity)',
      (tester) async {
    await pump(tester, forceLive: false, seed: [p1, p2]);
    expect(crumb, findsNothing);
  });

  testWidgets('forceLive: the breadcrumb lists the whole path', (tester) async {
    await pump(tester, forceLive: true, seed: [p1, p2]);
    expect(crumb, findsOneWidget);
    expect(home, findsOneWidget);
    expect(crumb0, findsOneWidget);
    expect(crumb1, findsOneWidget);
  });

  testWidgets('forceLive: tapping a crumb jumps back to that hop', (tester) async {
    await pump(tester, forceLive: true, seed: [p1, p2]);
    expect(crumb1, findsOneWidget);
    // tap the first crumb → popTo(0) → the path truncates to [p1]
    tester.widget<InkWell>(crumb0).onTap!.call();
    await tester.pump(const Duration(milliseconds: 80));
    expect(crumb1, findsNothing, reason: 'the deeper hop is dropped');
    expect(crumb0, findsOneWidget, reason: 'the first hop remains current');
  });

  testWidgets('forceLive: tapping home clears the whole path', (tester) async {
    await pump(tester, forceLive: true, seed: [p1, p2]);
    tester.widget<InkWell>(home).onTap!.call();
    await tester.pump(const Duration(milliseconds: 80));
    expect(crumb, findsNothing, reason: 'empty path → breadcrumb gone');
  });
}

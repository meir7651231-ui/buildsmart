// P9.89: the '🔌 מה מתחבר לזה' rail on the product sheet — the current product's
// hop-graph neighbours reached by a compat or kit edge (the same canonical graph as the
// related rail, filtered to physical-connection edges), as tappable in-place hops.
// Flag-gated: flag-OFF the rail is absent (byte-identical).

import 'package:buildsmart/features/card_keyboard/hop_graph.dart'
    show EdgeKind, HopGraph;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show divePoolBySku;
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final g = HopGraph.build();
  // A product that HAS at least one compat/kit neighbour, so the rail renders.
  final connectSku = divePoolBySku.keys.firstWhere(
    (s) => g.rankedNeighborsOf(s).any((n) {
      final k = g.kindsBetween(s, n);
      return k.contains(EdgeKind.compat) || k.contains(EdgeKind.kit);
    }),
  );
  final p0 = divePoolBySku[connectSku]!;
  final cat =
      divePoolBySku.values.where((q) => q.categoryHe == p0.categoryHe).toList();

  final connectRail = find.byKey(const Key('hopConnectRail'));
  final connectChips = find.byWidgetPredicate((w) {
    final k = w.key;
    return w is ActionChip &&
        k is ValueKey<String> &&
        k.value.startsWith('hopConnectChip_');
  });
  final backChip = find.byKey(const Key('hopBackChip'));

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

  testWidgets('flag-OFF: the connect rail is absent (byte-identity)',
      (tester) async {
    await pump(tester, forceLive: false);
    expect(connectRail, findsNothing);
  });

  testWidgets('forceLive: the connect rail renders compat/kit chips; tapping hops',
      (tester) async {
    await pump(tester, forceLive: true);
    expect(connectRail, findsOneWidget);
    expect(connectChips, findsWidgets);
    expect(backChip, findsNothing);
    tester.widget<ActionChip>(connectChips.first).onPressed!.call();
    await tester.pump(const Duration(milliseconds: 80));
    expect(backChip, findsOneWidget, reason: 'tapping a connect chip hops in place');
  });
}

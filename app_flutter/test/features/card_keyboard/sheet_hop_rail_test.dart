// P8.77: the flag-gated 'related' rail on the product sheet — the hop-graph neighbours
// of the current product as tappable chips, each an in-place hop. Flag-OFF the rail is
// absent (byte-identical); flag-ON it is never empty (the hub guarantees >=1 neighbour)
// and tapping a chip hops the sheet in place.

import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show divePoolBySku;
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Products from the hop-graph node-set (divePoolBySku) so rankedNeighborsOf is live.
  final pool = divePoolBySku.values.toList();
  final base = pool.firstWhere(
    (q) => pool.where((x) => x.categoryHe == q.categoryHe).length >= 3,
  );
  final cat = pool.where((q) => q.categoryHe == base.categoryHe).toList();
  final p0 = cat[0];

  final rail = find.byKey(const Key('hopRail'));
  final railChips = find.byWidgetPredicate((w) {
    final k = w.key;
    return w is ActionChip &&
        k is ValueKey<String> &&
        k.value.startsWith('hopRailChip_');
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

  testWidgets('flag-OFF: the related rail is absent (byte-identity)',
      (tester) async {
    await pump(tester, forceLive: false);
    expect(rail, findsNothing);
    expect(railChips, findsNothing);
  });

  testWidgets('forceLive: the rail renders tappable neighbour chips',
      (tester) async {
    await pump(tester, forceLive: true);
    expect(rail, findsOneWidget);
    expect(railChips, findsWidgets, reason: 'the hub guarantees >=1 neighbour');
  });

  testWidgets('forceLive: tapping a rail chip hops in place', (tester) async {
    await pump(tester, forceLive: true);
    // opening variant: no back control yet
    expect(backChip, findsNothing);
    // tap the first neighbour chip → in-place hop
    tester.widget<ActionChip>(railChips.first).onPressed!.call();
    await tester.pump(const Duration(milliseconds: 80));
    // a hop happened → the back control appears
    expect(backChip, findsOneWidget);
  });

  testWidgets('forceLive: the two rails are DISJOINT (de-dup, no double-listing)',
      (tester) async {
    await pump(tester, forceLive: true);
    Set<String> skusOf(String prefix) => tester
        .widgetList<ActionChip>(find.byWidgetPredicate((w) {
          final k = w.key;
          return w is ActionChip &&
              k is ValueKey<String> &&
              k.value.startsWith(prefix);
        }))
        .map((c) => (c.key! as ValueKey<String>).value.substring(prefix.length))
        .toSet();
    final related = skusOf('hopRailChip_');
    final connect = skusOf('hopConnectChip_');
    expect(related, isNotEmpty,
        reason: 'the hub guarantees the related rail is non-empty');
    expect(related.intersection(connect), isEmpty,
        reason: 'a product must not appear in BOTH rails — '
            'compat/kit neighbours live only in the connect rail');
  });
}

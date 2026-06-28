// P8.81: consolidated flag-OFF audit for the WHOLE hop zone. Behind kCardKeyboard (off
// in production) and without forceLive, NONE of the hop UI renders — related rail, rail
// chips, back control, breadcrumb, home crumb — even when a hop path already exists. This
// is the byte-identity guarantee for the product sheet: the monster work adds nothing to
// the live render until the flag flips.

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

  testWidgets(
      'flag-OFF: the ENTIRE hop zone is absent, even mid-hop (byte-identity)',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('he'),
          home: Builder(builder: (ctx) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // A 2-deep hop path is seeded, but the flag is OFF and forceLive is
              // false — so the hop zone must still render nothing.
              showLipskeyProductSheet(ctx, cat[0], cat,
                  hopSeedForTest: [cat[1], cat[2]]);
            });
            return const Scaffold(body: SizedBox.shrink());
          }),
        ),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 80));
    }

    expect(find.byKey(const Key('hopRail')), findsNothing);
    expect(find.byKey(const Key('hopBackChip')), findsNothing);
    expect(find.byKey(const Key('hopBreadcrumb')), findsNothing);
    expect(find.byKey(const Key('hopCrumb_home')), findsNothing);
    expect(
      find.byWidgetPredicate((w) {
        final k = w.key;
        return k is ValueKey<String> && k.value.startsWith('hopRailChip_');
      }),
      findsNothing,
      reason: 'no rail chips flag-OFF',
    );
  });
}

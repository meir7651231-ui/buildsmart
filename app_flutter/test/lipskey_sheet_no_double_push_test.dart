// Regression (POLISH "caliber", HIGH nav): two taps landing in the SAME frame
// used to push two stacked product sheets (showLipskeyProductSheet had no
// re-entrancy guard). The frame-scoped guard must swallow the second open.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('two same-frame opens stack only ONE product sheet', (tester) async {
    final p = kLipskeyCatalog.first;
    final cat =
        kLipskeyCatalog.where((q) => q.categoryHe == p.categoryHe).toList();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('he'),
          home: Builder(builder: (ctx) {
            // Both calls fire in the SAME frame (before the first route pushes) —
            // exactly the double-tap the guard must collapse to one.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showLipskeyProductSheet(ctx, p, cat);
              showLipskeyProductSheet(ctx, p, cat);
            });
            return const Scaffold(body: SizedBox.shrink());
          }),
        ),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 80));
    }

    expect(find.byType(LipskeyProductSheet), findsOneWidget,
        reason: 'the re-entrancy guard must swallow the same-frame second open');
  });
}

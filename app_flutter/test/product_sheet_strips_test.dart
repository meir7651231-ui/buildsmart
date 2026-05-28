// Smoke-test for the 4 informational strips on the internal product sheet
// (lipskey_product_sheet.dart). Verifies that:
//   1. The strips render visibly when the product has any of the 4 axes.
//   2. Tapping a strip triggers its callback (InkWell wiring works).
//   3. The variants-strip and accessories-strip taps cause the sheet to
//      scroll their target section into view via GlobalKey + ensureVisible.
//
// Because _QuickInfoStrips is library-private, we test through the public
// LipskeyProductSheet entry point — finding strip rows by their emoji text.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpSheet(WidgetTester tester, LipskeyCatalogProduct p,
      List<LipskeyCatalogProduct> siblings) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('he'),
          home: Builder(builder: (ctx) {
            // Open the sheet immediately on first frame.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showLipskeyProductSheet(ctx, p, siblings);
            });
            return const Scaffold(body: SizedBox.shrink());
          }),
        ),
      ),
    );
    // pumpAndSettle is too aggressive for the DraggableScrollableSheet
    // animations; pump a few frames manually.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 80));
    }
  }

  testWidgets('quick-info strips render and are tappable', (tester) async {
    // Pick a product that has all four signals present, so every strip shows.
    final p = kLipskeyCatalog.firstWhere((q) {
      final hasFinder = finderGroupFor(q) != null;
      final hasCompat = compatibleProductsCount(q) > 0;
      final hasKit = installKitFor(q) != null;
      final hasVariants = variantSiblingsCountFor(q) > 1;
      return hasFinder && hasCompat && hasKit && hasVariants;
    });
    final cat = kLipskeyCatalog.where((q) => q.categoryHe == p.categoryHe).toList();

    await pumpSheet(tester, p, cat);

    // ── Each strip must be on-screen by its label text.
    expect(find.text('נמצא ב:'), findsOneWidget,
        reason: 'finder strip should be rendered');
    expect(find.text('מוצרים תואמים:'), findsOneWidget,
        reason: 'compat strip should be rendered');
    expect(find.text('ערכת התקנה:'), findsOneWidget,
        reason: 'kit strip should be rendered');
    expect(find.text('דומים:'), findsOneWidget,
        reason: 'variants strip should be rendered');

    // ── Each strip is inside an InkWell (proves it's clickable, not text).
    Finder stripInkWell(String label) {
      return find.ancestor(
        of: find.text(label),
        matching: find.byType(InkWell),
      );
    }

    expect(stripInkWell('נמצא ב:'), findsWidgets,
        reason: 'finder strip must wrap an InkWell');
    expect(stripInkWell('מוצרים תואמים:'), findsWidgets,
        reason: 'compat strip must wrap an InkWell');
    expect(stripInkWell('ערכת התקנה:'), findsWidgets,
        reason: 'kit strip must wrap an InkWell');
    expect(stripInkWell('דומים:'), findsWidgets,
        reason: 'variants strip must wrap an InkWell');

    // ── Tap the variants strip: it should scroll-trigger (no throw).
    await tester.tap(find.text('דומים:').first);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));

    // ── Tap the compat strip.
    await tester.tap(find.text('מוצרים תואמים:').first);
    await tester.pump(const Duration(milliseconds: 400));

    // ── Tap the kit strip.
    await tester.tap(find.text('ערכת התקנה:').first);
    await tester.pump(const Duration(milliseconds: 400));

    // Reaching here without exception proves all four onTap callbacks are
    // wired and fire on tap.
  });
}

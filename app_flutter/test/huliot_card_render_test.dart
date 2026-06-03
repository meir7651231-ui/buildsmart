// Regression guard for the empty-card bug: a Huliot product sheet rendered BLANK
// because the search call-site built the sibling list from kLipskeyCatalog
// (empty for Huliot/PPR categories), and the sheet's variant pager threw
// "Invalid argument(s): 0" on the empty list. Two-layer fix:
//   1. the search-result onTap builds the list from the unified kCatalogProducts;
//   2. showLipskeyProductSheet falls back to [product] when handed an empty list.
import 'package:buildsmart/data/huliot_smartlock_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/polyroll_specs.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<int> _openAndCountTexts(
  WidgetTester tester,
  dynamic product,
  List products,
) async {
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: ElevatedButton(
            onPressed: () =>
                showLipskeyProductSheet(ctx, product, products.cast()),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  expect(tester.takeException(), isNull,
      reason: 'the product sheet must never throw on open');
  return tester
      .widgetList<Text>(find.byType(Text))
      .where((t) => (t.data ?? '').trim().isNotEmpty)
      .length;
}

void main() {
  setUpAll(registerPolyrollSpecs);

  testWidgets('Huliot sheet renders with the unified-catalog sibling list',
      (t) async {
    final p = kHuliotCatalog.firstWhere((x) => x.sku == '64032300');
    final cat =
        kCatalogProducts.where((x) => x.categoryHe == p.categoryHe).toList();
    expect(cat, isNotEmpty);
    final texts = await _openAndCountTexts(t, p, cat);
    expect(texts, greaterThan(10),
        reason: 'card should render its content, not blank');
  });

  testWidgets('sheet survives an EMPTY sibling list (guard → [product])',
      (t) async {
    final p = kHuliotCatalog.firstWhere((x) => x.sku == '64032300');
    final texts = await _openAndCountTexts(t, p, const []);
    expect(texts, greaterThan(10),
        reason: 'empty-list guard must still render the card');
  });
}

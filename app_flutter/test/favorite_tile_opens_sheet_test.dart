// LAUNCH FIX #2 — the home מועדפים tile (smart_home_screen.dart _Favorites).
//
// A favorited product tile had full button affordance but `onTap: () {}` (dead).
// It now opens the product sheet exactly like the catalog's own favorites row
// (_FavProductRow → showLipskeyProductSheet). This test seeds a favorite,
// taps the tile, and asserts the LipskeyProductSheet opens.

import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/screens/lipskey_product_sheet.dart'
    show LipskeyProductSheet;
import 'package:buildsmart/screens/smart_home_screen.dart' show SmartHomeBody;
import 'package:buildsmart/state/product_favorites.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadFonts() async {
  final f = FontLoader('Heebo')
    ..addFont(rootBundle.load('assets/fonts/Heebo-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Heebo-Bold.ttf'));
  await f.load();
}

void main() {
  testWidgets('tapping a favorite tile opens the product sheet', (t) async {
    await _loadFonts();
    SharedPreferences.setMockInitialValues({});
    // Tall surface so the whole lazy home ListView (incl. the bottom מועדפים
    // section + its ★ tile) builds — no fragile scroll finder needed.
    t.view.physicalSize = const Size(1200, 5000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);

    // A real catalog product to favorite — seeded from the SAME source the
    // favorites grid reads (catalogRepositoryProvider -> kCatalogProducts), so
    // the toggled SKU is guaranteed present and its ★ tile renders.
    final product = kCatalogProducts.first;

    late ProviderContainer container;
    await t.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'Heebo', useMaterial3: true),
          home: Builder(
            builder: (ctx) {
              container = ProviderScope.containerOf(ctx);
              return const Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(body: SmartHomeBody()),
              );
            },
          ),
        ),
      ),
    );
    // Seed the favorite → the מועדפים grid now renders this product's tile.
    container.read(productFavoritesProvider.notifier).toggle(product.sku);
    await t.pumpAndSettle();

    // No sheet yet.
    expect(find.byType(LipskeyProductSheet), findsNothing);

    // The favorites section renders at the bottom of the tall list; its ★ tile
    // is built and findable without scrolling.
    expect(find.byKey(const Key('catalog-list')), findsOneWidget);
    expect(find.byIcon(Icons.star), findsWidgets);

    // Tap the favorite tile (the star-icon mini tile carrying this product).
    final tile = find.ancestor(
      of: find.byIcon(Icons.star),
      matching: find.byType(InkWell),
    );
    await t.tap(tile.first);
    await t.pumpAndSettle();

    // The product sheet opened — same destination as its non-favorite siblings.
    expect(find.byType(LipskeyProductSheet), findsOneWidget);
  });
}

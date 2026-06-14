// LAUNCH FIX #2 — the home מועדפים tile (smart_home_screen.dart _Favorites).
//
// A favorited product tile had full button affordance but `onTap: () {}` (dead).
// It now opens the product sheet exactly like the catalog's own favorites row
// (_FavProductRow → showLipskeyProductSheet). This test seeds a favorite,
// taps the tile, and asserts the LipskeyProductSheet opens.

import 'package:buildsmart/data/lipskey_catalog.dart' show kLipskeyCatalog;
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

    // A real catalog product to favorite.
    final product = kLipskeyCatalog.first;

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

    // The favorites section sits at the very bottom of the home body's lazy
    // ListView (Key('catalog-list')) — scroll THAT list until the star-icon
    // favorite tile builds and is in view.
    final listScroll = find.descendant(
      of: find.byKey(const Key('catalog-list')),
      matching: find.byType(Scrollable),
    );
    await t.scrollUntilVisible(
      find.byIcon(Icons.star),
      250,
      scrollable: listScroll.first,
    );
    await t.pumpAndSettle();

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

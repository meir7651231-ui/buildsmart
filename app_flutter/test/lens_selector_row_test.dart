import 'package:buildsmart/data/catalog_lens.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/lens_selector_row.dart';
import 'package:buildsmart/state/catalog_lens_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget coverage for the LIST-LEVEL lens selector (step 3 UI). Verifies it
/// shows only the meaningful lenses, hides itself when <2 apply, and drives
/// `catalogLensProvider` on tap.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pump(
    WidgetTester t,
    List<LipskeyCatalogProduct> products,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await t.binding.setSurfaceSize(const Size(440, 200));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('he'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: LensSelectorRow(products: products)),
          ),
        ),
      ),
    );
    await t.pump();
    return container;
  }

  testWidgets('copper set shows 📂 + 🎚, NOT 🌳', (t) async {
    final copper =
        kLipskeyCatalog.where((p) => p.categoryHe == 'אביזרי נחושת').toList();
    await pump(t, copper);
    expect(find.text(CatalogLens.category.chipLabel), findsOneWidget);
    expect(find.text(CatalogLens.variant.chipLabel), findsOneWidget);
    expect(find.text(CatalogLens.smartTree.chipLabel), findsNothing,
        reason: 'copper maps <25% to smart-tree → lens hidden');
  });

  testWidgets('empty set → renders nothing (only category applies)', (t) async {
    await pump(t, const []);
    // <2 lenses → SizedBox.shrink; none of the chip labels appear.
    expect(find.text(CatalogLens.category.chipLabel), findsNothing);
    expect(find.text('סדר לפי:'), findsNothing);
  });

  testWidgets('tapping 🎚 sets catalogLensProvider to variant', (t) async {
    final copper =
        kLipskeyCatalog.where((p) => p.categoryHe == 'אביזרי נחושת').toList();
    final container = await pump(t, copper);
    expect(container.read(catalogLensProvider), CatalogLens.category,
        reason: 'default is category');
    await t.tap(find.text(CatalogLens.variant.chipLabel));
    await t.pump();
    expect(container.read(catalogLensProvider), CatalogLens.variant);
  });
}

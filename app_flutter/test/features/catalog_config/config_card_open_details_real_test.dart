// CATALOG-CONFIG · dive-bs2b — the REAL card → sheet path (NOT a mock onOpenDetails).
// Pumps the LIVE [CatalogConfigScreen] over the real [resolvedCatalogProducts], opens
// a real pilot config card, and drives the actual [_onOpenDetails] → the internal
// [LipskeyProductSheet]. This is the owner's bug ("עלה לי רק החיצוני לא הפנימי"): the
// external card came up but the internal sheet never did, because the vast majority of
// catalog tiles carry a CATEGORY familyId (not an engine family), so
// variantForSelection returns null and the old _onOpenDetails silently no-oped. The
// fix makes _onOpenDetails robust (fall back to the family's / the tapped type's own
// product) and adds a visible "📄 פרטים" button; BOTH the image tap and the button
// must open the sheet. SSOT: knowledge/CATALOG-CONFIG-PLAN.md (§E.3).

import 'package:buildsmart/data/catalog_source.dart' show resolvedCatalogProducts;
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/features/catalog_config/browse_model.dart';
import 'package:buildsmart/features/catalog_config/catalog_config_screen.dart';
import 'package:buildsmart/features/catalog_config/product_chips.dart';
import 'package:buildsmart/features/catalog_config/product_config_schema.dart';
import 'package:buildsmart/features/catalog_config/variant_image.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart'
    show LipskeyProductSheet;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadFonts() async {
  final f = FontLoader('Heebo')
    ..addFont(rootBundle.load('assets/fonts/Heebo-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Heebo-Bold.ttf'));
  await f.load();
}

// Replicate config_card's default seed exactly, so we can pick a real tile whose
// picks resolve to NO catalog variant (the owner's 94%-of-tiles case) — the tile
// that used to no-op silently.
AttributeValue _defaultValue(AttributeDef a) {
  for (final v in a.values) {
    if (v.sortIndex == 0) return v;
  }
  return a.values.first;
}

String _token(AttributeValue v) => v.canonical ?? v.labelHe;

Map<String, String> _seed(ProductConfigSchema s) => {
      for (final a in s.attributes)
        if (a.values.isNotEmpty) a.id: _token(_defaultValue(a)),
    };

/// The sku of the first tile (top of the list, always built) whose default picks
/// resolve to NO catalog variant — the silently-no-oping case we must fix.
String _firstNullVariantSku() {
  final browse = browseAll(resolvedCatalogProducts);
  for (final family in browse.families) {
    for (final tile in family.tiles) {
      final matches =
          resolvedCatalogProducts.where((p) => p.sku == tile.sku).toList();
      if (matches.isEmpty) continue;
      final schema = prioritizedSchema(matches.first);
      final variant = variantForSelection(
        schema,
        _seed(schema),
        resolvedCatalogProducts,
      );
      if (variant == null) return tile.sku;
    }
  }
  fail('expected at least one tile whose variant resolves to null');
}

Widget _host(String sku) => ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Heebo', useMaterial3: true),
        home: CatalogConfigScreen(initialExpandedSku: sku),
      ),
    );

void main() {
  late String nullSku;

  setUpAll(() {
    nullSku = _firstNullVariantSku();
  });

  testWidgets(
      'REAL _onOpenDetails: tapping the centre image of a null-variant tile opens '
      'the internal sheet (owner bug: only the external came up)', (t) async {
    await _loadFonts();
    t.view.physicalSize = const Size(1200, 3000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);

    await t.pumpWidget(_host(nullSku));
    await t.pumpAndSettle();

    // the inline card of the (null-variant) pilot tile is open.
    expect(find.byKey(const Key('configImageCenter')), findsOneWidget);
    expect(find.byType(LipskeyProductSheet), findsNothing);

    // TAP the centre image → the REAL _onOpenDetails path → the internal sheet.
    // (warnIfMissed:false — the keyed target is the inner Center; the tap dispatches
    // to its opaque ancestor GestureDetector, which carries the onTap handler.)
    await t.tap(
      find.byKey(const Key('configImageCenter')),
      warnIfMissed: false,
    );
    await t.pumpAndSettle();

    expect(
      find.byType(LipskeyProductSheet),
      findsOneWidget,
      reason: 'the internal product sheet must open even when the selection '
          'resolves to no exact catalog variant (base-fallback family)',
    );
  });

  testWidgets(
      'REAL _onOpenDetails: the visible "📄 פרטים" button opens the internal sheet',
      (t) async {
    await _loadFonts();
    t.view.physicalSize = const Size(1200, 3000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);

    await t.pumpWidget(_host(nullSku));
    await t.pumpAndSettle();

    // the dedicated details affordance is present on the open card…
    final details = find.byKey(const Key('configOpenDetails'));
    expect(details, findsOneWidget);
    expect(find.byType(LipskeyProductSheet), findsNothing);

    // …and tapping it opens the internal sheet through the same robust path.
    await t.tap(details);
    await t.pumpAndSettle();
    expect(find.byType(LipskeyProductSheet), findsOneWidget);
  });
}

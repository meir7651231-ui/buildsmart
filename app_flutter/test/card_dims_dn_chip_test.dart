// Guard for the dims-derived DN chip on the product card.
//
// Many Lipskey fittings (elbows, seals, covers) carry their bore ONLY in the
// dims map (e.g. {DN: 40}), never in the Hebrew name. The finder surfaces that
// as a גודל chip, so the card must show it too — otherwise the user filters by
// DN40 and lands on a card with no visible size, and the collapsed DN variants
// (cycled via the family badge) look identical. _NameWords renders a gray
// informational DN chip from tokensFromDims when the name has no size token.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/screens/_size_norm.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _card(LipskeyCatalogProduct p) => ProviderScope(
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(child: LipskeyProductCard(product: p, products: [p])),
      ),
    ),
  ),
);

void main() {
  testWidgets('elbow shows its bore (DN) on the card — Lipski 116624', (
    tester,
  ) async {
    // ברך 87° 40, dims {DN: 40} — after gate 117 v6.01 the bore is in the
    // name itself as the size chip '40'; after gate 117 follow-up Lipski
    // renders via _HierarchyChips so the breadcrumb shows ברך · 87° · 40.
    // The test verifies the bore is still visible on the card; the literal
    // 'DN40' label was the _NameWords-era marker and is no longer required.
    final p = kLipskeyCatalog.firstWhere((q) => q.sku == '116624');
    expect(
      (p.dims?['DN'] ?? p.dims?['dn'])?.toString(),
      isNotNull,
      reason: 'precondition: dims carry a DN',
    );

    await tester.pumpWidget(_card(p));
    await tester.pump();

    expect(
      find.text('40'),
      findsAtLeastNWidgets(1),
      reason: 'the bore (40) must be visible on the card',
    );
  });

  testWidgets('חוליות cover with DN only in dims shows a DN chip (hierarchy)', (
    tester,
  ) async {
    // A חוליות cover/riser/grate uses the _HierarchyChips path; its bore lives
    // only in dims, and the breadcrumb carries no size — so the dims DN must
    // surface there too, else the card shows no size while the finder filters
    // it by DN.
    final p = kCatalogProducts.firstWhere(
      (q) =>
          q.brand == 'חוליות' &&
          (q.dims?['DN'] ?? q.dims?['dn']) != null &&
          !q.nameHe.split(RegExp(r'\s+')).any(isSizeToken),
      orElse: () => kCatalogProducts.first,
    );
    // the rendered label comes from tokensFromDims (e.g. 98.2 → "DN98")
    final dn =
        tokensFromDims(
          p.dims!,
        ).firstWhere((t) => t.family == SizeFamily.dnDiameter).label;
    await tester.pumpWidget(_card(p));
    await tester.pump();
    expect(
      find.text(dn),
      findsOneWidget,
      reason: 'hierarchy card "${p.nameHe}" must show $dn',
    );
  });

  testWidgets(
    'PPR valve whose name states the OD does NOT get a dims-DN chip',
    (tester) async {
      // PPR exposes its OD in the name (the breadcrumb), so the gate suppresses
      // the dims-DN — no second, possibly-inconsistent DN pill.
      final p = kCatalogProducts.firstWhere(
        (q) => q.nameHe.contains('ברז PPR כדורי פוליפרופילן 50'),
        orElse: () => kCatalogProducts.first,
      );
      await tester.pumpWidget(_card(p));
      await tester.pump();
      // the unreliable dims DN for this product is DN63 — must NOT appear
      expect(find.text('DN63'), findsNothing);
    },
  );

  testWidgets(
    'product whose name already has a size does NOT get a dup DN chip',
    (tester) async {
      // A product whose size lives in the name keeps a single (pickable) size
      // chip — the gray dims-DN chip is suppressed to avoid a duplicate.
      final p = kLipskeyCatalog.firstWhere(
        (q) =>
            q.nameHe.contains('DN') && (q.dims?['DN'] ?? q.dims?['dn']) != null,
        orElse: () => kLipskeyCatalog.first,
      );
      await tester.pumpWidget(_card(p));
      await tester.pump();
      final dn = RegExp(r'DN\d+').firstMatch(p.nameHe)?.group(0);
      if (dn != null) {
        // exactly one DN label (the name chip), not two (name + gray dims chip)
        expect(find.text(dn), findsOneWidget);
      }
    },
  );
}

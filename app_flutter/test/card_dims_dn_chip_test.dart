// Guard for the dims-derived DN chip on the product card.
//
// Many Lipskey fittings (elbows, seals, covers) carry their bore ONLY in the
// dims map (e.g. {DN: 40}), never in the Hebrew name. The finder surfaces that
// as a גודל chip, so the card must show it too — otherwise the user filters by
// DN40 and lands on a card with no visible size, and the collapsed DN variants
// (cycled via the family badge) look identical. _NameWords renders a gray
// informational DN chip from tokensFromDims when the name has no size token.
import 'package:buildsmart/data/lipskey_catalog.dart';
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
  testWidgets('elbow with DN only in dims shows a DN chip on the card', (
    tester,
  ) async {
    // ברך 90° - תבריג כפול, dims {DN: 40} — DN is NOT in the name.
    final p = kLipskeyCatalog.firstWhere((q) => q.sku == '116624');
    expect(
      p.nameHe.contains('DN'),
      isFalse,
      reason: 'precondition: the name itself carries no DN',
    );
    expect(
      (p.dims?['DN'] ?? p.dims?['dn'])?.toString(),
      isNotNull,
      reason: 'precondition: dims carry a DN',
    );

    await tester.pumpWidget(_card(p));
    await tester.pump();

    expect(
      find.text('DN40'),
      findsOneWidget,
      reason: 'the dims DN must be visible on the card',
    );
  });

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

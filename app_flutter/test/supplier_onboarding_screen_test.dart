// C4.1 — the supplier self-onboarding screen wiring.
//
// Proves the form drives the C4.2-4.4 pipeline: it SUGGESTS facets from the name (C4.3),
// BLOCKS an invalid draft (C4.2), and hands a VALID [SupplierDraft] to the submit seam —
// which the go-live writer turns into a catalog product + inventory row (C4.4). The seam
// is overridden with a capturing fake, so nothing touches Firebase.

import 'package:buildsmart/data/repositories/supplier_onboarding.dart';
import 'package:buildsmart/screens/manager_screens_sheet.dart'
    show showManagerScreensSheet;
import 'package:buildsmart/screens/supplier_onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host({SupplierSubmit? onSubmit}) => ProviderScope(
  overrides: [
    if (onSubmit != null) supplierSubmitProvider.overrideWithValue(onSubmit),
  ],
  child: const MaterialApp(home: SupplierOnboardingScreen(storeId: 's1')),
);

/// A tall viewport so the whole form / sheet is on-screen (the default 800×600 clips
/// the bottom of a long form ⇒ taps miss + a modal sheet overflows).
void _tall(WidgetTester t) {
  t.view.physicalSize = const Size(1200, 2600);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
}

// Field order in the form (index into find.byType(TextField)).
const _kSku = 0;
const _kNameHe = 1;
const _kCategoryHe = 3;
const _kPrice = 7;
const _kStock = 8;

void main() {
  testWidgets('C4.1 — the form renders its fields', (tester) async {
    await tester.pumpWidget(_host());
    expect(find.text('מק"ט'), findsOneWidget);
    expect(find.text('מחיר (₪)'), findsOneWidget);
    expect(find.text('מלאי'), findsOneWidget);
    expect(find.text('שלח מוצר'), findsOneWidget);
  });

  testWidgets('C4.1 — facet chips appear from the typed name (C4.3)', (
    tester,
  ) async {
    const name = 'מחבר ישר 1" זכר להברגה';
    // Precondition: this name really does yield ≥1 auto-facet (else pick another).
    final f = suggestFacets(
      const SupplierDraft(
        storeId: 's1',
        sku: 'x',
        nameHe: name,
        categoryHe: 'מחברים',
      ),
    );
    final expected = <String>[
      if (f.type != null) f.type!,
      if (f.gender != null) f.gender!,
      if (f.method != null) f.method!,
      ...f.sizes,
    ];
    expect(expected, isNotEmpty, reason: 'test name must yield facets');

    await tester.pumpWidget(_host());
    await tester.enterText(find.byType(TextField).at(_kNameHe), name);
    await tester.pump();
    expect(find.text('מאפיינים מזוהים אוטומטית'), findsOneWidget);
  });

  testWidgets('C4.1 — an invalid draft is blocked (submit never called)', (
    tester,
  ) async {
    _tall(tester);
    var called = false;
    await tester.pumpWidget(_host(onSubmit: (_) async => called = true));
    await tester.tap(find.text('שלח מוצר')); // all fields empty ⇒ invalid
    await tester.pump();

    expect(called, isFalse);
    expect(find.textContaining('חובה'), findsWidgets); // required-field errors
  });

  testWidgets(
    'C4.1 — a valid draft flows to the pipeline (product + inventory)',
    (tester) async {
      _tall(tester);
      SupplierDraft? captured;
      await tester.pumpWidget(_host(onSubmit: (d) async => captured = d));

      await tester.enterText(find.byType(TextField).at(_kSku), '999');
      await tester.enterText(find.byType(TextField).at(_kNameHe), 'ברז כיור');
      await tester.enterText(find.byType(TextField).at(_kCategoryHe), 'ברזים');
      await tester.enterText(find.byType(TextField).at(_kPrice), '55');
      await tester.enterText(find.byType(TextField).at(_kStock), '10');
      await tester.tap(find.text('שלח מוצר'));
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.sku, '999');
      expect(captured!.nameHe, 'ברז כיור');
      expect(
        captured!.storeId,
        's1',
        reason: 'every draft is stamped with the store',
      );

      // C4.4 — the pipeline turns it into an inventory row; price/stock live HERE
      // (R1-6), never in the catalog product doc.
      final inv = draftToInventory(captured!);
      expect(inv, isNotNull);
      expect(inv!.price, 55);
      expect(inv.stock, 10);
      expect(inv.storeId, 's1');

      expect(find.byKey(const Key('supplierDone')), findsOneWidget);
    },
  );

  testWidgets('C4.1 — the supplier entry tile is ABSENT by default (flag off)', (
    tester,
  ) async {
    _tall(tester);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder:
                (ctx) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => showManagerScreensSheet(ctx),
                      child: const Text('open'),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // The sheet opened, but the kTradeImportFlag-gated tile is not in the tree —
    // the manager surface is byte-identical with the flag off.
    expect(find.text('מעבר בין מסכים'), findsOneWidget);
    expect(find.text('העלאת מוצר (ספק)'), findsNothing);
  });
}

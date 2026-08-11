// P1 · the full internal product card — renders the 13 data sections from the
// real engine for the SmartLock elbow hero. Guards: card + name + buy render, and
// the engine-driven engineering-spec section is present (proves live wiring, not
// a static mock). SmartLock has no VerifiedSpec ⇒ compat/price sections are
// legitimately absent — the card must still render (conditional sections).
import 'package:buildsmart/data/lipskey_catalog.dart' show kLipskeyCatalog;
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/features/internal_card/full_internal_card.dart';
import 'package:buildsmart/state/smart_cart.dart' show smartCartProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FullInternalCard renders the SmartLock elbow hero + live sections',
      (tester) async {
    final hero = catalogProductForSku(FullInternalCard.heroSku);
    expect(hero, isNotNull,
        reason: 'hero SKU ${FullInternalCard.heroSku} must resolve in the catalog');

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FullInternalCard(product: hero!),
            ),
          ),
        ),
      ),
    );

    // The card shell + name + image + buy CTA always render (image-first).
    expect(find.byKey(const Key('fullInternalCard')), findsOneWidget);
    expect(find.byKey(const Key('internalCardName')), findsOneWidget);
    expect(find.byKey(const Key('internalCardImage')), findsOneWidget);
    expect(find.byKey(const Key('internalCardBuy')), findsOneWidget);

    // D15 — the spec is HIDDEN behind 📋 (not spilled): closed by default.
    expect(find.byKey(const Key('internalCardSpecPanel')), findsNothing);
    expect(find.text('מפרט הנדסי'), findsNothing);

    // Tapping 📋 swaps the image for the tabbed spec panel; the default tab
    // (מפרט) shows engineeringSpecFor's מפרט-הנדסי — presence proves live wiring.
    await tester.tap(find.byKey(const Key('internalCardSpecToggle')));
    await tester.pump();
    expect(find.byKey(const Key('internalCardSpecPanel')), findsOneWidget);
    expect(find.text('מפרט הנדסי'), findsOneWidget);

    // Switching to the טמפ׳ tab reveals the טמפרטורה section (live tab switch).
    await tester.tap(find.text('טמפ׳'));
    await tester.pump();
    expect(find.text('טמפרטורה'), findsOneWidget);
  });

  testWidgets('tapping the header image opens the gallery (D3)', (tester) async {
    final hero = catalogProductForSku(FullInternalCard.heroSku)!;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: FullInternalCard(product: hero)),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('internalCardImage')), findsOneWidget);
    await tester.tap(find.byKey(const Key('internalCardImage')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    // The SmartLock hero carries product + spec images ⇒ the pager opens.
    expect(find.byKey(const Key('internalCardGallery')), findsOneWidget);
  });

  testWidgets('swiping the name cycles the variant family (D5)', (tester) async {
    final hero = catalogProductForSku(FullInternalCard.heroSku)!;
    final fam = variantSiblingsOf(hero);
    expect(fam.length, greaterThan(1),
        reason: 'the elbow-90 hero must have size variants to cycle');
    final i = fam.indexWhere((s) => s.sku == hero.sku);
    final goNext = i < fam.length - 1;
    final expected = goNext ? fam[i + 1] : fam[i - 1];

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: FullInternalCard(product: hero)),
          ),
        ),
      ),
    );
    expect(find.text(hero.nameHe), findsOneWidget);

    // Swipe the name toward the end that has room (left ⇒ next, right ⇒ prev).
    await tester.fling(
      find.byKey(const Key('internalCardName')),
      Offset(goNext ? -250 : 250, 0),
      1000,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    // The card now shows the neighbouring variant.
    expect(find.text(expected.nameHe), findsOneWidget);
  });

  testWidgets('tapping a size dot jumps straight to that variant (D5)',
      (tester) async {
    final hero = catalogProductForSku(FullInternalCard.heroSku)!;
    final fam = variantSiblingsOf(hero);
    expect(fam.length, greaterThan(1));
    final cur = fam.indexWhere((s) => s.sku == hero.sku);
    final target = cur == 0 ? 1 : 0; // a different variant's dot

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: FullInternalCard(product: hero)),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(Key('variantDot_$target')));
    await tester.pump();
    expect(find.text(fam[target].nameHe), findsOneWidget);
  });

  testWidgets('add-to-cart adds a line for the current variant (D6)',
      (tester) async {
    final hero = catalogProductForSku(FullInternalCard.heroSku)!;
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: FullInternalCard(product: hero)),
          ),
        ),
      ),
    );

    expect(container.read(smartCartProvider), isEmpty);
    // The card is tall — bring the buy button into the viewport before tapping.
    await tester.ensureVisible(find.byKey(const Key('internalCardBuy')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('internalCardBuy')));
    await tester.pump();

    final cart = container.read(smartCartProvider);
    expect(cart, hasLength(1));
    expect(cart.first.productName, hero.nameHe);

    // Flush the toast auto-dismiss timer so teardown sees no pending timer.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('line buttons are hidden until a product is added (D6/D14)',
      (tester) async {
    final hero = catalogProductForSku(FullInternalCard.heroSku)!;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: FullInternalCard(product: hero)),
          ),
        ),
      ),
    );

    // Base card: no line strip, no smart buttons.
    expect(find.byKey(const Key('internalCardLineStrip')), findsNothing);
    expect(find.byKey(const Key('lineBtnCheck')), findsNothing);

    // Add a product → the line strip (circles + buttons) appears.
    await tester.ensureVisible(find.byKey(const Key('internalCardBuy')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('internalCardBuy')));
    await tester.pump();

    expect(find.byKey(const Key('internalCardLineStrip')), findsOneWidget);
    expect(find.byKey(const Key('lineBtnCheck')), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('בדיקה opens the connection-check sheet after adding (D14)',
      (tester) async {
    final hero = catalogProductForSku(FullInternalCard.heroSku)!;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: FullInternalCard(product: hero)),
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.byKey(const Key('internalCardBuy')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('internalCardBuy')));
    await tester.pump(const Duration(seconds: 5)); // add + flush toast

    await tester.ensureVisible(find.byKey(const Key('lineBtnCheck')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('lineBtnCheck')));
    await tester.pumpAndSettle();

    expect(find.textContaining('בדיקת חיבורים'), findsOneWidget);
  });

  testWidgets('השלם runs the solver and shows a path after adding (D14)',
      (tester) async {
    // A product that actually has compatible mates (SmartLock has none).
    final withCompat =
        kLipskeyCatalog.firstWhere((p) => compatibleProductsFor(p).isNotEmpty);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FullInternalCard(product: withCompat),
            ),
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.byKey(const Key('internalCardBuy')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('internalCardBuy')));
    await tester.pump(const Duration(seconds: 5));

    await tester.ensureVisible(find.byKey(const Key('lineBtnSolve')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('lineBtnSolve')));
    await tester.pumpAndSettle();

    expect(find.textContaining('השלמת חיבור'), findsOneWidget);
  });

  testWidgets('קו opens the sudoku line-builder grid (D11/D13)',
      (tester) async {
    final hero = catalogProductForSku(FullInternalCard.heroSku)!;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: FullInternalCard(product: hero)),
          ),
        ),
      ),
    );

    // Add a product so the line strip (with קו) appears.
    await tester.ensureVisible(find.byKey(const Key('internalCardBuy')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('internalCardBuy')));
    await tester.pump(const Duration(seconds: 5)); // add + flush toast

    await tester.ensureVisible(find.byKey(const Key('lineBtnLine')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('lineBtnLine')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sudokuGrid')), findsOneWidget);
  });

  testWidgets('swiping the image reveals the connects-rail (D4)',
      (tester) async {
    final withCompat =
        kLipskeyCatalog.firstWhere((p) => compatibleProductsFor(p).isNotEmpty);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FullInternalCard(product: withCompat),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('internalCardRail')), findsNothing);
    // Swipe left → the LEFT end's connect-rail (per-side, D4).
    await tester.fling(
      find.byKey(const Key('internalCardImage')),
      const Offset(-220, 0),
      900,
    );
    await tester.pump();

    expect(find.byKey(const Key('internalCardRail')), findsOneWidget);
    expect(find.textContaining('מתחבר לצד שמאל'), findsOneWidget);
  });

  test('compatibleProductsForEnd is truly per-end — the two ends differ (D4)',
      () {
    // A product whose two physical ends accept different fittings.
    final asym = kLipskeyCatalog.firstWhere((p) {
      if (verifiedEndsCountFor(p) < 2) return false;
      final a = compatibleProductsForEnd(p, 0).map((e) => e.sku).toSet();
      final b = compatibleProductsForEnd(p, 1).map((e) => e.sku).toSet();
      return a.isNotEmpty && b.isNotEmpty && a.length != b.length;
    });
    final e0 = compatibleProductsForEnd(asym, 0).map((e) => e.sku).toSet();
    final e1 = compatibleProductsForEnd(asym, 1).map((e) => e.sku).toSet();
    expect(e0, isNotEmpty);
    expect(e1, isNotEmpty);
    // The heart of per-side: end 0 and end 1 must NOT be the same set.
    expect(e0, isNot(equals(e1)),
        reason: 'each end must accept its own set of mates');
  });
}

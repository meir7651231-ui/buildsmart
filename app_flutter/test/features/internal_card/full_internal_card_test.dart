// P1 · the full internal product card — renders the 13 data sections from the
// real engine for the SmartLock elbow hero. Guards: card + name + buy render, and
// the engine-driven engineering-spec section is present (proves live wiring, not
// a static mock). SmartLock has no VerifiedSpec ⇒ compat/price sections are
// legitimately absent — the card must still render (conditional sections).
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/features/internal_card/full_internal_card.dart';
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

    // The card shell + header + buy CTA always render.
    expect(find.byKey(const Key('fullInternalCard')), findsOneWidget);
    expect(find.byKey(const Key('internalCardName')), findsOneWidget);
    expect(find.byKey(const Key('internalCardBuy')), findsOneWidget);

    // engineeringSpecFor drives the מפרט-הנדסי + טמפרטורה sections for the
    // חוליות (SmartLock) hero — their presence proves the card is wired to the
    // live engine, not a static render.
    expect(find.text('מפרט הנדסי'), findsOneWidget);
    expect(find.text('טמפרטורה'), findsOneWidget);
  });
}

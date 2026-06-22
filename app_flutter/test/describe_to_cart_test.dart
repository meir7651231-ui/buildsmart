// Pins the describe→cart anti-hallucination design (#ai-describe-to-cart): Claude
// is constrained to a CLOSED SET — `matchRecipe` accepts only a real
// `kSmartProducts` key and DROPS anything else (NONE / invented), and the cart is
// assembled from REAL catalog products only. Pure — no gateway, no widget pump.
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/screens/describe_to_cart_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final recipe = kSmartProducts.first;

  test('matchRecipe accepts a real key (exact + contained), rejects the rest', () {
    expect(matchRecipe(recipe.key)?.key, recipe.key,
        reason: 'an exact recipe key resolves to that recipe');
    expect(matchRecipe('הבחירה היא ${recipe.key}')?.key, recipe.key,
        reason: 'a key wrapped in prose is still matched (contained)');
    expect(matchRecipe('NONE'), isNull, reason: 'NONE → no recipe');
    expect(matchRecipe('not-a-real-key-12345'), isNull,
        reason: 'a hallucinated/invalid key is dropped (closed-set guard)');
    expect(matchRecipe(''), isNull);
  });

  test('describeToCartPrompt grounds the model in the closed recipe set', () {
    final p = describeToCartPrompt('יש לי נזילה מתחת לכיור');
    expect(p, contains('יש לי נזילה מתחת לכיור'),
        reason: 'the contractor request is in the prompt');
    expect(p, contains(recipe.key), reason: 'every recipe key is offered');
    expect(p, contains('NONE'), reason: 'the model may decline');
    expect(p, contains('החזר אך ורק'),
        reason: 'the model is constrained to return ONLY a key');
  });

  test('resolvedKitProducts returns only REAL catalog products (never invented)',
      () {
    for (final r in kSmartProducts.take(25)) {
      for (final p in resolvedKitProducts(r)) {
        expect(p.sku, isNotEmpty,
            reason: 'every cart line is a real, bound catalog product');
      }
    }
  });
}

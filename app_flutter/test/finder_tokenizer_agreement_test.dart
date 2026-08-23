// Guard: the two size tokenizers must agree on what is a size word.
//
// `parseSizeTokens` (finder) and `isSizeToken` (card word-classifier) used to
// disagree on a leading bare fraction: `parseSizeTokens('½"')` yields a token
// but `isSizeToken('½"')` returned false (its regex required a leading digit).
// On the Lipskey `_NameWords` path that would render `½"` as a plain link word
// instead of a size chip, and `productListDedupeKey` wouldn't strip it (size
// variants wouldn't collapse). No catalog product triggers it today (the lone
// `½"` item is a חוליות hierarchy card), but the asymmetry is a latent bug —
// this locks the two tokenizers in agreement.
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/screens/_size_norm.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart'
    show isSizeToken;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isSizeToken accepts leading bare fractions (½" ¾" ¼")', () {
    // single-word tokens only (mm/cm like `40 מ"מ` are two words, handled by
    // the card's two-word lookahead, not isSizeToken)
    for (final s in ['½"', '¾"', '¼"', '⅜"', '½', '1¼"', 'DN40', '16×20']) {
      expect(isSizeToken(s), isTrue, reason: '"$s" should be a size token');
    }
  });

  test('isSizeToken still rejects plain words and warranty-style numbers', () {
    for (final s in ['אמריקאי', 'עגול', 'שנים', 'מ"מ', 'PPR', 'abc']) {
      expect(isSizeToken(s), isFalse, reason: '"$s" must not be a size token');
    }
  });

  test('every single-word size token in the catalog is accepted by both', () {
    // For each product, any single name word that parseSizeTokens turns into
    // exactly one token must also pass isSizeToken — so the card never demotes
    // a finder size chip to a plain word.
    final bad = <String>[];
    for (final p in kCatalogProducts) {
      for (final w in p.nameHe.split(RegExp(r'\s+'))) {
        final toks = parseSizeTokens(w);
        if (toks.length == 1 && !isSizeToken(w)) {
          bad.add('word "$w" in "${p.nameHe}"');
        }
      }
    }
    expect(bad, isEmpty, reason: bad.take(10).join('\n'));
  });
}

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/screens/_size_norm.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cross-pipeline consistency: a product's CARD chip text (built from the
/// name split into words, classified via `isSizeToken`, displayed via
/// `displaySizeLabel`) must match the FILTER chip text the finder surfaces
/// (built via `parseSizeTokens`).
///
/// P9 (`1.25"` vs `1¼"`), P12 (`Ø1/2"` vs `½"`), P16 (`40×60` vs `60×40`)
/// were all "card and filter disagree on the same physical size". This test
/// asserts they can't disagree silently again.
void main() {
  /// Mirror of how the product card derives a size word — split by
  /// whitespace, look ahead for a `digit … unit-suffix` pair (`200 ס"מ`,
  /// `300 מ׳`, `40 מ"מ`) AND fall back to `isSizeToken` + `displaySizeLabel`
  /// for single-word tokens. Mirrors `_NameWords.build` in
  /// `lipskey_products_screen.dart`.
  Set<String> cardSizeChipsFor(String nameHe) {
    final words = nameHe.split(RegExp(r'\s+'));
    final out = <String>{};
    var i = 0;
    while (i < words.length) {
      // Two-word size lookahead (P17 fix): if joining w with the next word
      // yields exactly one finder size token ending in the next word, take
      // the joined label.
      if (i + 1 < words.length) {
        final two = '${words[i]} ${words[i + 1]}';
        final twoTokens = parseSizeTokens(two);
        if (twoTokens.length == 1 &&
            twoTokens.first.label.endsWith(words[i + 1])) {
          out.add(twoTokens.first.label);
          i += 2;
          continue;
        }
      }
      final w = words[i];
      if (isSizeToken(w)) {
        // Cross-inch (`1/2"×3/8"`) is one word that yields TWO finder tokens
        // — emit all of them on the card side too.
        final tokens = parseSizeTokens(w);
        if (tokens.length > 1) {
          out.addAll(tokens.map((t) => t.label));
        } else {
          out.add(displaySizeLabel(w));
        }
      }
      i++;
    }
    return out;
  }

  /// What the finder filter would surface from a single product's name.
  Set<String> finderSizeChipsFor(String nameHe) =>
      parseSizeTokens(nameHe).map((t) => t.label).toSet();

  group('card ↔ filter chip text — no display drift', () {
    test(
      'finder chip set ⊆ card chip set — every finder chip is on a card',
      () {
        // The harmful direction is finder→card: if the filter shows a chip
        // that does not match any card text, the user clicks an orphan. The
        // reverse (card has extras the finder doesn't surface) is by design
        // — card is more permissive (bare numbers, angles) and the finder
        // is stricter.
        final orphans = <String>[];
        for (final p in kCatalogProducts) {
          final card = cardSizeChipsFor(p.nameHe);
          final finder = finderSizeChipsFor(p.nameHe);
          final missing = finder.difference(card);
          if (missing.isNotEmpty) {
            orphans.add('sku=${p.sku}  name="${p.nameHe}"  '
                'finder=$finder  card=$card  missing=$missing');
          }
        }
        expect(orphans, isEmpty,
            reason: 'finder chips with no matching card chip '
                '(would be orphan filter clicks):\n'
                '${orphans.take(8).join("\n")}');
      },
    );

    test('every chip label from the finder is renderable LTR-safe', () {
      // P16: a chip with digits must render the digit run as-typed. The
      // finder `_chip` widget forces TextDirection.ltr when label contains
      // a digit; here we assert the label itself stays in its source order
      // (no surprise reversal at construction time).
      for (final p in kCatalogProducts.take(500)) {
        for (final t in parseSizeTokens(p.nameHe)) {
          if (t.label.contains('×')) {
            final parts = t.label.split('×');
            expect(parts.length, 2,
                reason: 'cross-dim label "${t.label}" should have exactly one ×');
            expect(
                double.tryParse(parts.first.replaceAll(RegExp(r'[^\d.]'), '')),
                isNotNull,
                reason: 'first half of cross-dim "${t.label}" should be numeric');
          }
        }
      }
    });
  });

  group('regression sentinels — closed Pn must stay closed', () {
    test('P9: card chip `1.25"` collapses to `1¼"`', () {
      expect(displaySizeLabel('1.25"'), '1¼"');
    });
    test('P12: card chip `Ø1/2"` collapses to `½"`', () {
      expect(displaySizeLabel('Ø1/2"'), '½"');
    });
    test('P13: card chip `⅜"` folds to `3/8"` (canvaskit font miss)', () {
      expect(displaySizeLabel('⅜"'), '3/8"');
    });
    test('P15: card chip `020 מ"מ` normalizes to `20 מ"מ`', () {
      expect(parseSizeTokens('זרוע 020 מ"מ').first.label, '20 מ"מ');
    });
  });
}

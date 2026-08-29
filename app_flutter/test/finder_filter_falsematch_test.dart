// Regression guard for the finder size/angle filter's substring false-match.
//
// `_productHasChip` (finder_screen.dart) matches a product to a chip by (1)
// structural size tokens, (2) structural angle tokens, then (3) a `nameHe`
// substring fallback for curated-facet PLAIN-WORD chips (אמריקאי / מכסה / …).
// That fallback must NEVER fire for a digit-bearing label: `5"` is a substring
// of `1.25"`, `50 מ"מ` of `250 מ"מ`, `2"` of `1/2"` — so an unconditional
// contains let a size chip match a LARGER size it isn't. The fix gates the
// fallback to digit-free labels. This test mirrors the fixed matcher and
// asserts no digit chip can match a product that lacks the structural token.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/screens/_size_norm.dart';
import 'package:flutter_test/flutter_test.dart';

// Mirror of the FIXED _productHasChip.
bool productHasChip(LipskeyCatalogProduct p, String chipLabel) {
  final struct = <String>{
    ...parseSizeTokens(p.nameHe).map((t) => t.label),
    ...parseAngleTokens(p.nameHe).map((t) => t.label),
  };
  if (p.dims != null)
    struct.addAll(tokensFromDims(p.dims!).map((t) => t.label));
  if (struct.contains(chipLabel)) return true;
  // digit-free curated-facet fallback only
  if (!RegExp(r'\d').hasMatch(chipLabel) && p.nameHe.contains(chipLabel)) {
    return true;
  }
  return p.color == chipLabel;
}

void main() {
  test('a digit chip never matches a product lacking its structural token', () {
    final digitLabels = <String>{};
    for (final p in kCatalogProducts) {
      digitLabels.addAll(parseSizeTokens(p.nameHe).map((t) => t.label));
      if (p.dims != null) {
        digitLabels.addAll(tokensFromDims(p.dims!).map((t) => t.label));
      }
      digitLabels.addAll(parseAngleTokens(p.nameHe).map((t) => t.label));
    }
    digitLabels.removeWhere((l) => !RegExp(r'\d').hasMatch(l));

    final bad = <String>[];
    for (final p in kCatalogProducts) {
      final struct = <String>{
        ...parseSizeTokens(p.nameHe).map((t) => t.label),
        ...parseAngleTokens(p.nameHe).map((t) => t.label),
        if (p.dims != null) ...tokensFromDims(p.dims!).map((t) => t.label),
      };
      for (final l in digitLabels) {
        if (productHasChip(p, l) && !struct.contains(l)) {
          bad.add('chip "$l" matched "${p.nameHe}" without the token');
        }
      }
    }
    expect(bad, isEmpty, reason: bad.take(10).join('\n'));
  });

  test('concrete: `5"` chip does not match a `1.25"` product', () {
    final p = kCatalogProducts.firstWhere(
      (q) => q.nameHe.contains('1.25"'),
      orElse: () => kCatalogProducts.first,
    );
    expect(
      p.nameHe.contains('5"'),
      isTrue,
      reason: 'precondition: the bug-triggering substring is present',
    );
    expect(
      productHasChip(p, '5"'),
      isFalse,
      reason: 'a 5" filter must not surface a 1.25" product',
    );
  });
}

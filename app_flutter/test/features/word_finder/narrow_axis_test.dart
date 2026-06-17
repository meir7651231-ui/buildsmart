// Pure unit test for the lifted finder axis logic (STEP 0). No widgets — just
// the behaviour-preserving narrowAxis(): on a pool whose products carry
// DIFFERENT size tokens AND more than one colour, the SIZE axis ('גודל') must
// win over the COLOUR axis ('צבע') — size precedes colour in the axis order.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/word_finder/narrow_axis.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('narrowAxis', () {
    // Three products: half-inch / three-quarter-inch / one-inch taps, each a
    // different colour. The names carry parseable inch tokens (1/2" → ½",
    // 3/4" → ¾", 1") so the size axis splits the pool (>1 size); the colours
    // (≥2) would split too, but size is checked first.
    const half = LipskeyCatalogProduct(
      sku: 'A', nameHe: 'ברז כיור 1/2"', nameEn: 'tap half',
      color: 'לבן',
      categoryHe: 'ברזי כיור', categoryEn: 'sink taps',
      categoryEmoji: '🚰', page: 1,
    );
    const threeQuarter = LipskeyCatalogProduct(
      sku: 'B', nameHe: 'ברז כיור 3/4"', nameEn: 'tap three-quarter',
      color: 'כרום',
      categoryHe: 'ברזי כיור', categoryEn: 'sink taps',
      categoryEmoji: '🚰', page: 1,
    );
    const oneInch = LipskeyCatalogProduct(
      sku: 'C', nameHe: 'ברז כיור 1"', nameEn: 'tap one-inch',
      color: 'שחור',
      categoryHe: 'ברזי כיור', categoryEn: 'sink taps',
      categoryEmoji: '🚰', page: 1,
    );

    test('returns the size axis (גודל), not colour (צבע), on a multi-size pool',
        () {
      final pool = [half, threeQuarter, oneInch];
      final axis = narrowAxis(pool, null);
      expect(axis.label, 'גודל');
      // Sanity: the pool DOES carry >1 distinct colours, so the only reason
      // we didn't land on 'צבע' is that size legitimately precedes colour.
      expect(colorOptions(pool).length, greaterThan(1));
      // The size chips are the parsed, pretty-folded inch tokens.
      expect(axis.chips, containsAll(<String>['½"', '¾"', '1"']));
    });
  });
}

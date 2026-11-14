// Diameter chips (catalog variants · size facet). `sizeDiameterAtoms` builds the
// chip atoms; the vulgar-fraction glyphs used to collapse distinct sizes:
//   ¼" and ¾" → one "/4" chip;  1½" → "1/2" (same chip as half-inch ½"/1/2").
// Each glyph now maps to its full ASCII fraction, so the catalog's two
// spellings of the SAME size merge while different sizes stay apart.
import 'package:buildsmart/data/variant_families.dart';
import 'package:buildsmart/screens/_size_norm.dart' show prettyInch;
import 'package:buildsmart/screens/catalog_screen.dart' show diameterSortKey;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sizeDiameterAtoms · fraction glyphs', () {
    test('¼" and ¾" are different chips', () {
      expect(sizeDiameterAtoms('¼"'), ['1/4"']);
      expect(sizeDiameterAtoms('¾"'), ['3/4"']);
    });

    test('glyph and ASCII spellings of the same size merge', () {
      expect(sizeDiameterAtoms('½"'), sizeDiameterAtoms('1/2"'));
      expect(sizeDiameterAtoms('¾"'), sizeDiameterAtoms('3/4"'));
      expect(sizeDiameterAtoms('1½"'), sizeDiameterAtoms('11/2"'));
      expect(sizeDiameterAtoms('1¼"'), sizeDiameterAtoms('11/4"'));
      expect(sizeDiameterAtoms('2½"'), sizeDiameterAtoms('21/2"'));
    });

    test('1½" is not the half-inch chip; 1¼" is not the quarter-inch chip', () {
      expect(sizeDiameterAtoms('1½"'), isNot(sizeDiameterAtoms('½"')));
      expect(sizeDiameterAtoms('1¼"'), isNot(sizeDiameterAtoms('1/4"')));
    });

    test('× splits normalise each side', () {
      expect(sizeDiameterAtoms('16×½"').toSet(), {'16', '1/2"'});
    });

    test('chip labels read like the product cards (pretty fold)', () {
      final atoms =
          [
            '¼"',
            '¾"',
            '1½"',
            '11/2"',
            '½"',
            '1/2"',
          ].expand(sizeDiameterAtoms).map(prettyInch).toSet();
      expect(atoms, {'¼"', '¾"', '1½"', '½"'});
    });

    test('chips sort by real bore, not by the first digit run', () {
      final atoms = [
        '11/2"', '1/2"', '3/4"', '1/4"', '1"', '21/2"', '11/4"', //
        '8"', '10"', '5"', '3/8"', '23/8"', '50', 'DN40',
      ]..sort((a, b) => diameterSortKey(a).compareTo(diameterSortKey(b)));
      expect(atoms, [
        '1/4"', '3/8"', '1/2"', '3/4"', '1"', '11/4"', '11/2"', 'DN40', //
        '50', '23/8"', '21/2"', '5"', '8"', '10"',
      ]);
    });
  });
}

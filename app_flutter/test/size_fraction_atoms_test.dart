// Diameter chips (catalog variants · size facet). `sizeDiameterAtoms` builds the
// chip atoms; the vulgar-fraction glyphs used to collapse distinct sizes:
//   ¼" and ¾" → one "/4" chip;  1½" → "1/2" (same chip as half-inch ½"/1/2").
// Each glyph now maps to its full ASCII fraction, so the catalog's two
// spellings of the SAME size merge while different sizes stay apart.
import 'package:buildsmart/data/variant_families.dart';
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
  });
}

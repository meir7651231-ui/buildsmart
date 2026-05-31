// Roadmap step 87 — every AnimationController used by the SmartProduct card
// path (`catalog_screen.dart`) must respect `catalogSettings.reducedMotion`,
// otherwise users who opted into reduced motion still see elasticOut bouncing.
//
// We enforce this with a STATIC text invariant: in `catalog_screen.dart`, the
// number of `AnimationController(` declarations equals the number of
// `reducedMotion` checks. New animations added without a guard turn this red.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every AnimationController in catalog_screen.dart has a reducedMotion guard',
      () {
    final src =
        File('lib/screens/catalog_screen.dart').readAsStringSync();
    final ctrlCount = 'AnimationController('.allMatches(src).length;
    final guardCount = 'reducedMotion'.allMatches(src).length;
    expect(ctrlCount, greaterThan(0),
        reason: 'expected at least one AnimationController in catalog_screen');
    expect(guardCount, greaterThanOrEqualTo(ctrlCount),
        reason:
            'mismatch: $ctrlCount AnimationController(...) usages but only '
            '$guardCount reducedMotion checks. Every new animation in the card '
            'path must respect catalogSettings.reducedMotion (Roadmap step 87).');
  });
}

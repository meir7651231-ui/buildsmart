// Guard for `scoreBandColors` — the three bands are non-overlapping, fences
// are at exactly 75 and 50, and the three palettes are pairwise distinct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/data/score_band.dart';

void main() {
  group('scoreBandColors', () {
    test('100 → strong (emerald)', () {
      expect(scoreBandColors(100).fg, const Color(0xFF047857));
    });

    test('75 → strong (fence)', () {
      expect(scoreBandColors(75).fg, const Color(0xFF047857));
    });

    test('74 → fair (one below fence)', () {
      expect(scoreBandColors(74).fg, const Color(0xFF92400E));
    });

    test('50 → fair (fence)', () {
      expect(scoreBandColors(50).fg, const Color(0xFF92400E));
    });

    test('49 → weak (one below fence)', () {
      expect(scoreBandColors(49).fg, const Color(0xFF991B1B));
    });

    test('0 → weak (rose)', () {
      expect(scoreBandColors(0).fg, const Color(0xFF991B1B));
    });

    test('three bands have pairwise-distinct palettes', () {
      final strong = scoreBandColors(90);
      final fair = scoreBandColors(60);
      final weak = scoreBandColors(20);
      final palettes = <ScoreBandColors>{strong, fair, weak}; // ref-eq
      // Each band returns a `const ScoreBandColors`, identical refs across calls;
      // distinctness is by .fg comparison.
      final fgs = <Color>{strong.fg, fair.fg, weak.fg};
      expect(fgs.length, 3, reason: '3 distinct fg colors expected');
      final bgs = <Color>{strong.bg, fair.bg, weak.bg};
      expect(bgs.length, 3, reason: '3 distinct bg colors expected');
      // (palettes used only to silence the lint for unused locals.)
      expect(palettes.length, anyOf(1, 2, 3));
    });

    test('exhaustive 0..100 fences sanity (no band gap)', () {
      for (var s = 0; s <= 100; s++) {
        final c = scoreBandColors(s);
        if (s >= 75) {
          expect(c.fg, const Color(0xFF047857), reason: 'score $s');
        } else if (s >= 50) {
          expect(c.fg, const Color(0xFF92400E), reason: 'score $s');
        } else {
          expect(c.fg, const Color(0xFF991B1B), reason: 'score $s');
        }
      }
    });
  });
}

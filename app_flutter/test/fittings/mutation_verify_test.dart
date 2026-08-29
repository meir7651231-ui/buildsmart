// mutation-L3 (פאזה 0, שלב 11) — מוכיח שה-golden + מוכיח-הליבה **מבחינים**: כל
// מוטציה אמיתית במנוע הייתה מפילה אותם. אם בדיקה כאן נכשלת ⇒ ה-golden ווקוּאי
// (בולע רגרסיות) ⇒ תקן את ה-golden, לא את זה.
import 'dart:math' as math;

import 'package:buildsmart/features/fittings/engine/fitting_dims.dart';
import 'package:flutter_test/flutter_test.dart';

/// r1 מ*וטנטי* — הגישה הנאיבית `(x*10).round()/10` (half-away, עם שגיאת-הכפל).
/// זה בדיוק הבאג ש-`r1` תיקן; המוטנט חייב להיבדל בערך-תיקו אמיתי.
double _r1Mutant(double x) => (x * 10).round() / 10;

void main() {
  group('mutation-L3 — the golden/core-proof would catch a real regression', () {
    test('OD-sensitive: same family, different OD → different dims', () {
      for (final fam in kFittingFamilies) {
        final a = generate(fam, 32);
        final b = generate(fam, 50);
        expect(a, isNot(equals(b)),
            reason: '$fam is OD-blind — an OD mutation would slip the golden',);
      }
    });

    test('family-sensitive: same OD, different family → different dims', () {
      final coupler = generate('מצמד', 50);
      for (final fam in kFittingFamilies.where((f) => f != 'מצמד')) {
        expect(generate(fam, 50), isNot(equals(coupler)),
            reason: '$fam ≡ coupler at OD50 — a family swap would slip',);
      }
    });

    test('formula-constant mutation is caught (coupler A = 2F+2, not +3)', () {
      // The true engine: A = 2·F + 2. A mutant "+3" MUST differ.
      const od = 32;
      final f = kDepth[od]!;
      final trueA = generate('מצמד', od)['A'];
      final mutantA = r1(2 * f + 3);
      expect(trueA, isNot(equals(mutantA)),
          reason: 'coupler A not pinned — a constant drift would slip',);
      expect(trueA, r1(2 * f + 2)); // sanity: the true formula
    });

    test('elbow angle mutation is caught (45° ≠ 90° z/l)', () {
      expect(generate('ברך 45°', 32)['z'],
          isNot(equals(generate('ברך 90°', 32)['z'])),
          reason: 'elbow z is angle-blind — a θ mutation would slip',);
    });

    test('r1 rounding is load-bearing — the naive x*10 mutant diverges', () {
      // 26.7/2 = 13.349999… : true round → 13.3, the x*10 mutant → 13.4.
      // The tee E golden (=2·(z+F)) is exactly what caught this in the port.
      expect(r1(26.7 / 2), 13.3, reason: 'r1 must round the TRUE value down');
      expect(_r1Mutant(26.7 / 2), 13.4,
          reason: 'the mutant rounds the false tie up — proving r1 is not free',);
      expect(r1(26.7 / 2), isNot(equals(_r1Mutant(26.7 / 2))));
      // and it flows through tee E: true 55.6 vs mutant-path 55.8.
      final f = kDepth[20]!;
      expect(r1(2 * (r1(generate('מסעף (טי)', 20)['B']! / 2) + f)), 55.6);
    });

    test('miteredElbow ratios are pinned (∝d, not a fixed constant)', () {
      // A = 3·d — doubling d MUST double A (a ∝-mutation to a constant slips otherwise).
      expect(miteredElbow(400)['A'], 2 * miteredElbow(200)['A']!);
      expect(miteredElbow(160)['G'], r1(1.377 * 160));
    });
  });

  // guard: the mutant helper is genuinely a mutant (not accidentally equal to r1)
  test('mutation harness itself is non-vacuous', () {
    var diffs = 0;
    for (var od = 20; od <= 125; od++) {
      if (_r1Mutant(od * 0.97) != r1(od * 0.97)) diffs++;
    }
    expect(diffs, greaterThan(0),
        reason: 'the r1 mutant never differs — harness is vacuous',);
    // sanity that math import is used (angle helper parity)
    expect(math.tan(0), 0);
  });
}

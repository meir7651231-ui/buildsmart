import 'package:buildsmart/features/word_finder/color_truth.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/narrow_axis.dart'
    show colorOptions;
import 'package:flutter_test/flutter_test.dart';

const _finishes = {
  'נחושת', 'ניקל', 'ניקל מוברש', 'נירוסטה',
  'כרום', 'זהב', 'זהב מבריק', 'זהב מוברש',
};

void main() {
  test('every kTrueColors member is a true colour', () {
    for (final c in kTrueColors) {
      expect(isTrueColor(c), isTrue, reason: c);
    }
  });

  test('every metal finish is NOT a true colour', () {
    for (final f in _finishes) {
      expect(isTrueColor(f), isFalse, reason: f);
    }
  });

  test('cardColorOptions == live colours minus the finish leaks', () {
    final live = colorOptions(kDivePool).toSet();
    final card = cardColorOptions(kDivePool).toSet();
    // The robust check: deriving the expectation from the live data catches any
    // kTrueColors typo (a real colour wrongly dropped, or a finish wrongly kept).
    expect(card, live.difference(_finishes),
        reason: 'the card colour axis must be exactly the real colours');
    expect(card, isNot(contains('נחושת')), reason: 'copper is not a colour');
    expect(card, contains('לבן'));
    expect(card.length, lessThan(live.length));
  });
}

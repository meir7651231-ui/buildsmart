import 'dart:io';

import 'package:buildsmart/features/card_keyboard/decisions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('P3 opening-surface decisions resolve to their owner values', () {
    expect(kOpeningSurfaceIsSingleMouth, isTrue);
    expect(kMaxScreen1Decisions, 1);
    expect(kCensusInputsAreCapabilityGated, isTrue);
  });

  test('each opening decision carries an OWNER-REVIEW marker the owner can veto',
      () {
    final src =
        File('lib/features/card_keyboard/decisions.dart').readAsStringSync();
    expect(RegExp('OWNER-REVIEW').allMatches(src).length,
        greaterThanOrEqualTo(3),
        reason: 'the three opening decisions each need a vetoable marker');
  });
}

// P9.82: softTilt is the soft re-ranking multiplier. It must be INERT (1.0) with no
// anchor — so an anchorless pool leaves the hard-signal order byte-identical — and lift
// monotonically with more anchors, never above the cap.

import 'package:buildsmart/features/card_keyboard/soft_signals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no anchor → inert (exactly 1.0)', () {
    expect(softTilt(), 1.0);
  });

  test('any single anchor lifts above 1.0', () {
    expect(softTilt(connection: true), greaterThan(1.0));
    expect(softTilt(recipe: true), greaterThan(1.0));
    expect(softTilt(history: true), greaterThan(1.0));
  });

  test('anchors ordered by strength: connection > recipe > history', () {
    expect(softTilt(connection: true), greaterThan(softTilt(recipe: true)));
    expect(softTilt(recipe: true), greaterThan(softTilt(history: true)));
  });

  test('more anchors → monotonically higher, never above the cap', () {
    final one = softTilt(connection: true);
    final two = softTilt(connection: true, recipe: true);
    final all = softTilt(connection: true, recipe: true, history: true);
    expect(two, greaterThan(one));
    expect(all, greaterThanOrEqualTo(two));
    expect(all, lessThanOrEqualTo(kMaxSoftTilt));
  });

  test('the cap is never exceeded', () {
    expect(
      softTilt(connection: true, recipe: true, history: true),
      lessThanOrEqualTo(kMaxSoftTilt),
    );
  });
}

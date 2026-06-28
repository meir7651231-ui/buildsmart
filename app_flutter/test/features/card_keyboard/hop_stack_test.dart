// P8.75: HopStack is the sheet's product back-stack — a single 'back' must return to
// the PREVIOUS product, not collapse the whole path. Pure, so tested in isolation.

import 'package:buildsmart/features/card_keyboard/hop_stack.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty stack: no current, cannot go back, back is a no-op', () {
    final s = HopStack<String>();
    expect(s.current, isNull);
    expect(s.canGoBack, isFalse);
    expect(s.depth, 0);
    s.back();
    expect(s.current, isNull);
  });

  test('two hops then ONE back returns to the first hop (not the opening variant)',
      () {
    final s = HopStack<String>()
      ..push('A')
      ..push('B');
    expect(s.current, 'B');
    expect(s.depth, 2);
    s.back();
    expect(s.current, 'A', reason: 'one back pops only the last hop');
    expect(s.canGoBack, isTrue);
    s.back();
    expect(s.current, isNull, reason: 'second back reaches the opening variant');
    expect(s.canGoBack, isFalse);
  });

  test('clear empties the whole path at once', () {
    final s = HopStack<String>()
      ..push('A')
      ..push('B')
      ..push('C');
    expect(s.depth, 3);
    s.clear();
    expect(s.current, isNull);
    expect(s.path, isEmpty);
  });

  test('path is oldest-first and unmodifiable', () {
    final s = HopStack<int>()
      ..push(1)
      ..push(2);
    expect(s.path, [1, 2]);
    expect(() => s.path.add(3), throwsUnsupportedError);
  });
}

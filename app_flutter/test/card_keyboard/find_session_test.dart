// Pure unit tests for [FindSession] — the keyboard find-mode's engine driver.
// VM-only (no Flutter binding): the session is pure, so these run fast and pin
// the ≤6 contract + the seed/narrow/undo behaviour the keyboard relies on.

import 'package:buildsmart/features/card_keyboard/card_engine.dart'
    show CardAskWords, CardResolve, CardShowProducts, MergedKeys;
import 'package:buildsmart/features/card_keyboard/decisions.dart'
    show kMaxDiveTurns;
import 'package:buildsmart/features/card_keyboard/find_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FindSession', () {
    test('opens on CardAskWords with an empty stack', () {
      final s = FindSession();
      expect(s.stack, isEmpty);
      expect(s.verdict, isA<CardAskWords>());
      expect(s.selection, isEmpty);
    });

    test('pushWord seeds the dive and leaves the opening', () {
      final s = FindSession();
      expect(s.pushWord('ברז'), isTrue);
      expect(s.stack, hasLength(1));
      expect(s.verdict, isNot(isA<CardAskWords>()));
      expect(s.selection, isNotEmpty);
    });

    test('pushWord on an unknown word is a no-op (no dead-end)', () {
      final s = FindSession();
      expect(s.pushWord('xyzzyqwerty'), isFalse);
      expect(s.stack, isEmpty);
      expect(s.verdict, isA<CardAskWords>());
    });

    test('driving merged chips converges within the ≤6 gate', () {
      final s = FindSession();
      expect(s.pushWord('ברז'), isTrue);
      var guard = 0;
      while (s.verdict is MergedKeys && guard < 12) {
        final chips = (s.verdict as MergedKeys).chips;
        expect(chips, isNotEmpty);
        s.pushChip(chips.first);
        guard++;
      }
      // The forced gate guarantees we leave MergedKeys for a product verdict.
      expect(s.verdict is MergedKeys, isFalse);
      expect(s.verdict is CardShowProducts || s.verdict is CardResolve, isTrue);
      expect(s.stack.length, lessThanOrEqualTo(kMaxDiveTurns));
      expect(s.selection.length, equals(s.stack.length));
    });

    test('pop undoes the last step; reset clears the dive', () {
      final s = FindSession()..pushWord('ברז');
      final afterSeed = s.stack.length;
      if (s.verdict is MergedKeys) {
        s.pushChip((s.verdict as MergedKeys).chips.first);
        expect(s.stack.length, afterSeed + 1);
        s.pop();
        expect(s.stack.length, afterSeed);
      }
      s.reset();
      expect(s.stack, isEmpty);
      expect(s.verdict, isA<CardAskWords>());
    });

    test('a tapped chip never widens the pool', () {
      final s = FindSession()..pushWord('ברז');
      if (s.verdict is MergedKeys) {
        final chip = (s.verdict as MergedKeys).chips.first;
        final before = s.pool.length;
        s.pushChip(chip);
        expect(s.pool.length, lessThanOrEqualTo(before));
      }
    });
  });
}

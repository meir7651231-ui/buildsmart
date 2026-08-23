import 'package:buildsmart/features/card_keyboard/card_engine.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show NewbieStep;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show buildWordLexicon;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lex = buildWordLexicon(kDivePool);
  final pool = kDivePool.take(50).toList();
  const noStack = <NewbieStep>[];

  setUp(clearMergedKeysMemo);

  test('enabled: same verdict type as the direct merge (correctness)', () {
    final direct = mergedKeys(pool, noStack, lex, null);
    final memo = mergedKeysMemoized(pool, noStack, lex, null, enabled: true);
    expect(memo.runtimeType, direct.runtimeType);
  });

  test('enabled: a repeated card-set is served from the memo (one compute)', () {
    final first = mergedKeysMemoized(pool, noStack, lex, null, enabled: true);
    final second = mergedKeysMemoized(pool, noStack, lex, null, enabled: true);
    expect(identical(first, second), isTrue,
        reason: 'the second call hits the memo, not a recomputation');
  });

  test('disabled (production default) never memoises', () {
    expect(kCensusMemoEnabled, isFalse, reason: 'production must not memoise');
    final a = mergedKeysMemoized(pool, noStack, lex, null);
    final b = mergedKeysMemoized(pool, noStack, lex, null);
    expect(identical(a, b), isFalse, reason: 'disabled → a fresh compute each call');
  });

  test('a different card-set keys a different memo entry', () {
    final a = mergedKeysMemoized(
        kDivePool.take(50).toList(), noStack, lex, null,
        enabled: true);
    final b = mergedKeysMemoized(
        kDivePool.take(300).toList(), noStack, lex, null,
        enabled: true);
    expect(identical(a, b), isFalse, reason: 'distinct card-sets, distinct keys');
  });
}

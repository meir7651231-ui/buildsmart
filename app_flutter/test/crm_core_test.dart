// GIANT Phase-2 wave-2a — the CRM shared core: Hebrew search-normalize (the
// unified single source) + the Damerau-Levenshtein fuzzy primitive that was
// MISSING in the app (today's search is contains-only). Pure; the live consumers
// (customer dedup, fuzzy customer search) land in later gated slices.

import 'package:buildsmart/logic/fuzzy_match.dart';
import 'package:buildsmart/logic/text_normalize.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normSearch / normName', () {
    test('lowercases, strips niqqud, folds final letters, drops punctuation', () {
      // final mem ם folds to מ, so 'שלום' normalizes to 'שלומ'.
      expect(normSearch('  שָׁלוֹם  '), 'שלומ',
          reason: 'niqqud stripped + trim + final-letter fold');
      expect(normSearch('כהן'), normSearch('כהנ'), reason: 'ן↔נ final-letter fold');
      // the dash is removed (to nothing, not a space) and final nun folds:
      // 'בן-דוד' → 'בנדוד'.
      expect(normSearch('בן-דוד'), 'בנדוד');
      expect(normSearch('ABC'), 'abc');
    });

    test('normName folds ALL whitespace for a tight dedup key', () {
      expect(normName('בן דוד'), normName('בןדוד'));
      expect(normName(' שמעון '), normName('שמעון'));
    });
  });

  group('damerauLevenshtein', () {
    test('identity, empty, and the three edits each cost 1', () {
      expect(damerauLevenshtein('abc', 'abc'), 0);
      expect(damerauLevenshtein('', 'abc'), 3);
      expect(damerauLevenshtein('abc', ''), 3);
      expect(damerauLevenshtein('abc', 'abx'), 1, reason: 'substitution');
      expect(damerauLevenshtein('abc', 'ab'), 1, reason: 'deletion');
      expect(damerauLevenshtein('ab', 'abc'), 1, reason: 'insertion');
    });

    test('adjacent transposition costs 1 (Damerau, not plain Levenshtein)', () {
      expect(damerauLevenshtein('חנ', 'נח'), 1);
      expect(damerauLevenshtein('שמעון', 'שמע ון'), 1, reason: 'one insert');
    });

    test('symmetric', () {
      expect(damerauLevenshtein('כהן', 'קהן'), damerauLevenshtein('קהן', 'כהן'));
    });
  });

  group('fuzzyTolerance / fuzzyMatch / fuzzyScore', () {
    test('tolerance is floor(len/3)+1', () {
      expect(fuzzyTolerance(3), 2); // 3~/3 + 1
      expect(fuzzyTolerance(6), 3);
      expect(fuzzyTolerance(0), 1);
    });

    test('a substring is always a match (score 0)', () {
      expect(fuzzyMatch('כהן', 'משפחת כהן'), isTrue);
      expect(fuzzyScore('כהן', 'משפחת כהן'), 0);
    });

    test('a one-typo name inside tolerance matches; far apart does not', () {
      expect(fuzzyMatch('שמעון', 'שימעון'), isTrue, reason: 'one insert ≤ 2');
      expect(fuzzyMatch('כהן', 'לוי'), isFalse);
      expect(fuzzyScore('כהן', 'לוי'), -1);
    });

    test('normalization flows through — final-letter + niqqud fold before dist',
        () {
      expect(fuzzyMatch('כהן', 'כהנ'), isTrue, reason: 'ן↔נ ⇒ distance 0');
      expect(fuzzyScore('כֹּהֵן', 'כהן'), 0);
    });

    test('empty query or candidate never matches', () {
      expect(fuzzyMatch('', 'כהן'), isFalse);
      expect(fuzzyMatch('כהן', ''), isFalse);
      expect(fuzzyScore('', ''), -1);
    });
  });
}

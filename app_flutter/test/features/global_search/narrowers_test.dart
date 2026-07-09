// PROPERTY tests for the OPTION-B prediction-row narrowers (pure, flag-free).
// These pin the quality invariants the owner asked for ("רמה גבוהה מאוד"):
// every suggested word is result-guaranteed (never a dead-end), actually narrows
// the set, is deterministic, de-duplicated and capped.

import 'package:buildsmart/features/global_search/narrowers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('crossDomainNextTokens', () {
    const titles = <String>[
      'ברז מעבר כדורי',
      'ברז כיור פרח',
      'חיבור ברז ניל',
    ];

    test('every returned token appears in ≥1 matching title (never a dead-end)',
        () {
      final out = crossDomainNextTokens('ברז', titles);
      expect(out, isNotEmpty);
      for (final tok in out) {
        expect(
          titles.any((t) => narrowerTokens(t).contains(tok)),
          isTrue,
          reason: '"$tok" must come from a currently-matching title, so appending '
              'it always leaves ≥1 result',
        );
      }
    });

    test('never suggests a token already in the query', () {
      final out = crossDomainNextTokens(
          'ברז מעבר', const <String>['ברז מעבר כדורי', 'ברז מעבר ניל']);
      expect(out.contains('ברז'), isFalse);
      expect(out.contains('מעבר'), isFalse);
    });

    test('a token common to EVERY matching title does not narrow → dropped', () {
      // "ברז" is in all three → useless as a narrower (keeps the whole set).
      final out = crossDomainNextTokens(
          'כדורי', const <String>['ברז כדורי אא', 'ברז כדורי בב', 'ברז כדורי גג']);
      expect(out.contains('ברז'), isFalse,
          reason: 'ברז is universal across the matches → it must not be offered');
    });

    test('ranked by frequency — the most common next word leads', () {
      final ranked = crossDomainNextTokens(
        'ברז',
        const <String>['ברז מעבר', 'ברז מעבר', 'ברז מעבר', 'ברז כיור'],
        max: 4,
      );
      expect(ranked.first, 'מעבר',
          reason: 'מעבר appears in 3 titles, כיור in 1 → מעבר is the top suggestion');
    });

    test('deterministic — same inputs give an identical list', () {
      const t = <String>['ברז מעבר כדורי', 'משה אברהם', 'איטום רצפת מקלחת'];
      expect(crossDomainNextTokens('רצפת', t), crossDomainNextTokens('רצפת', t));
    });

    test('caps at max, de-dupes, and drops single-char noise', () {
      final out = crossDomainNextTokens(
          '', const <String>['aa bb cc dd ee', 'bb cc dd', 'x y'], max: 3);
      expect(out.length, lessThanOrEqualTo(3));
      expect(out.toSet().length, out.length, reason: 'no duplicates');
      expect(out.contains('x'), isFalse, reason: 'single-char tokens are noise');
    });

    test('empty matching set → no suggestions (nothing to narrow)', () {
      expect(crossDomainNextTokens('ברז', const <String>[]), isEmpty);
    });

    test('cross-domain: a customer/task query still yields narrowers', () {
      // "משה" matches a customer + a chat — the row must still help ("אברהם"…).
      final out = crossDomainNextTokens(
          'משה', const <String>['משה אברהם', 'לקוח משה כהן', 'משה לוי הקבלן']);
      expect(out, isNotEmpty,
          reason: 'a non-product query must still get typing help (cross-domain)');
      expect(out.contains('משה'), isFalse);
    });
  });

  group('mergeNarrowers', () {
    test('primary leads, secondary fills, de-duped + capped', () {
      expect(mergeNarrowers(['a', 'b'], ['b', 'c', 'd'], max: 3), ['a', 'b', 'c']);
    });

    test('trims and drops blanks', () {
      expect(mergeNarrowers([' a ', '', '  '], ['a', 'b'], max: 4), ['a', 'b']);
    });

    test('deterministic', () {
      expect(mergeNarrowers(['a', 'b'], ['c'], max: 4),
          mergeNarrowers(['a', 'b'], ['c'], max: 4));
    });
  });
}

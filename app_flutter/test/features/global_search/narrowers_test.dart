// PROPERTY tests for the OPTION-B prediction-row narrowers (pure, flag-free).
// Pins the "רמה גבוהה מאוד" invariants — including the two defects the adversarial
// swarm caught: the ADJACENCY dead-end (a frequency-only picker suggested a word
// that empties the panel) and the tokenizer JUNK CHIPS (מס. · ו-2 · *עם · bare
// emoji). Every suggestion must be result-guaranteed, clean, deterministic.

import 'package:buildsmart/features/global_search/narrowers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('narrowerTokens (junk-chip hygiene — swarm finding #2)', () {
    test('trims edge punctuation: מס. · *עם · dangling inch-mark', () {
      expect(narrowerTokens('מחסום (מס. 3)'), isNot(contains('מס.')));
      expect(narrowerTokens('מחסום (מס. 3)'), contains('מס'));
      expect(narrowerTokens('*עם אפשרות'), <String>['עם', 'אפשרות']);
      expect(narrowerTokens('ברז 1/2"'), contains('1/2')); // trailing " stripped
    });

    test('keeps Hebrew abbreviations + numeric sizes WHOLE (internal kept)', () {
      expect(narrowerTokens('צינור ש״ת'), contains('ש״ת'));
      expect(narrowerTokens('לקוח ח.פ.'), contains('ח.פ')); // only trailing . trimmed
      expect(narrowerTokens('מצמד 50/50'), contains('50/50'));
    });

    test('splits on hyphen/dashes (ו-2 · -130/40) but never on / or .', () {
      expect(narrowerTokens('אומים ו-2 אטמים'), isNot(contains('ו-2')));
      expect(narrowerTokens('רצפה -130/40 תקני'), isNot(contains('-130/40')));
      expect(narrowerTokens('רצפה -130/40 תקני'), contains('130/40'));
    });

    test('parens + middle-dot split cleanly', () {
      expect(narrowerTokens('אסלה (עומדת)'), <String>['אסלה', 'עומדת']);
      expect(narrowerTokens('מחבר DN32 · אטמים'), containsAll(<String>['dn32', 'אטמים']));
    });
  });

  group('crossDomainNextTokens (adjacency — never dead-ends — swarm finding #1)', () {
    test('REGRESSION: "אברהם" over first-last names yields NO reversed dead-end', () {
      // The swarm bug: names read "משה אברהם" (never reversed), so a frequency
      // picker suggested "משה" for query "אברהם" → append → "אברהם משה" → the
      // panel's contiguous search returns ∅. Fixed: אברהם is TERMINAL → no
      // successor → empty row (safe), not a dead-end chip.
      final out = crossDomainNextTokens(
          'אברהם', const <String>['משה אברהם', 'לקוח — משה אברהם']);
      expect(out, isEmpty,
          reason: 'nothing follows אברהם in these titles → no safe suggestion');
    });

    test('every suggestion is the CONTIGUOUS successor: "query tok" is a substring '
        'of a matching title, so appending it keeps ≥1 result', () {
      const titles = <String>[
        'ברז מעבר כדורי',
        'ברז כיור פרח',
        'חיבור ברז ניל',
      ];
      final out = crossDomainNextTokens('ברז', titles);
      expect(out, isNotEmpty);
      for (final tok in out) {
        expect(titles.any((t) => t.toLowerCase().contains('ברז $tok')), isTrue,
            reason: '"ברז $tok" must be a contiguous run in a matching title');
      }
    });

    test('cross-domain: a non-product query still gets valid successors', () {
      final out = crossDomainNextTokens(
          'משה', const <String>['משה אברהם', 'לקוח משה כהן']);
      expect(out, containsAll(<String>['אברהם', 'כהן']));
      expect(out.contains('משה'), isFalse);
    });

    test('ranked by frequency — the most common successor leads', () {
      final out = crossDomainNextTokens(
        'ברז',
        const <String>['ברז מעבר', 'ברז מעבר', 'ברז מעבר', 'ברז כיור'],
      );
      expect(out.first, 'מעבר');
    });

    test('drops a bare astral emoji successor (grapheme length, not UTF-16 units)',
        () {
      // "🛡" is 2 UTF-16 code units but ONE grapheme → must be dropped.
      expect(crossDomainNextTokens('en', const <String>['en 🛡']).contains('🛡'),
          isFalse);
    });

    test('deterministic · capped · empty query → nothing', () {
      const t = <String>['ברז מעבר כדורי', 'ברז מעבר ניל', 'ברז כיור'];
      expect(crossDomainNextTokens('ברז', t), crossDomainNextTokens('ברז', t));
      expect(crossDomainNextTokens('ברז', t, max: 2).length, lessThanOrEqualTo(2));
      expect(crossDomainNextTokens('', t), isEmpty);
    });
  });

  group('mergeNarrowers', () {
    test('primary leads, secondary fills, de-duped + capped', () {
      expect(mergeNarrowers(['a', 'b'], ['b', 'c', 'd'], max: 3), ['a', 'b', 'c']);
    });
    test('trims, drops blanks, guards non-positive max', () {
      expect(mergeNarrowers([' a ', '', '  '], ['a', 'b'], max: 4), ['a', 'b']);
      expect(mergeNarrowers(['a'], ['b'], max: 0), isEmpty);
    });
    test('deterministic', () {
      expect(mergeNarrowers(['a', 'b'], ['c'], max: 4),
          mergeNarrowers(['a', 'b'], ['c'], max: 4));
    });
  });
}

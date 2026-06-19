// Smart-input ranking (Phase-1) — pure ordering/capping rules for the
// suggestion list. Covers: frequency>=3 promotion, recent-cap guarantee, the
// overall cap, startsWith>contains match ordering, text de-dup, and the
// first-item-is-primary contract.
import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:buildsmart/widgets/smart_input/ranking.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _texts(List<Suggestion> s) => [for (final x in s) x.text];

void main() {
  test('frequency >= 3 promotes a candidate to first', () {
    final out = rankSuggestions(
      const [Suggestion('apple'), Suggestion('banana'), Suggestion('cherry')],
      frequencies: const {'cherry': 3},
    );
    expect(out.first.text, 'cherry',
        reason: 'a popular (freq>=3) candidate floats to the front');
    expect(out.first.isPrimary, isTrue);
  });

  test('among popular, higher frequency wins the front', () {
    final out = rankSuggestions(
      const [Suggestion('a'), Suggestion('b'), Suggestion('c')],
      frequencies: const {'a': 3, 'b': 9, 'c': 5},
    );
    expect(_texts(out).take(3), ['b', 'c', 'a'],
        reason: 'ties among popular broken by higher frequency first');
  });

  test('frequency below the threshold does NOT promote', () {
    final out = rankSuggestions(
      const [Suggestion('apple'), Suggestion('banana')],
      frequencies: const {'banana': 2}, // < 3
    );
    expect(out.first.text, 'apple',
        reason: 'freq 2 is not popular — source order is preserved');
  });

  test('up to recentCap recent picks are guaranteed included past the cap', () {
    // 6 ranked fillers + 2 recent that would otherwise be pushed out by cap=3.
    final candidates = const [
      Suggestion('f1'),
      Suggestion('f2'),
      Suggestion('f3'),
      Suggestion('f4'),
      Suggestion('r-old'),
      Suggestion('r-new'),
    ];
    final out = rankSuggestions(
      candidates,
      recent: const ['r-new', 'r-old'], // recent-first
      recentCap: 2,
      cap: 3,
    );
    expect(out.length, 3, reason: 'cap is respected');
    expect(_texts(out), containsAll(<String>['r-new', 'r-old']),
        reason: 'both recent picks (<= recentCap) survive the cap');
    // recent-first ordering: r-new appears before r-old.
    expect(out.indexWhere((s) => s.text == 'r-new'),
        lessThan(out.indexWhere((s) => s.text == 'r-old')));
  });

  test('recentCap limits how many recents are force-included', () {
    final candidates = const [
      Suggestion('x1'),
      Suggestion('r1'),
      Suggestion('r2'),
      Suggestion('r3'),
    ];
    final out = rankSuggestions(
      candidates,
      recent: const ['r1', 'r2', 'r3'],
      recentCap: 1,
      cap: 2,
    );
    expect(out.length, 2);
    // Only the single most-recent (r1) is guaranteed; the remaining slot is the
    // ranked filler 'x1' (first in source order), so r2/r3 are not forced in.
    expect(out.first.text, 'r1');
    expect(_texts(out), ['r1', 'x1']);
  });

  test('cap is respected (never more than cap items)', () {
    final candidates = [for (var i = 0; i < 20; i++) Suggestion('p$i')];
    final out = rankSuggestions(candidates, cap: 4);
    expect(out.length, 4);
  });

  test('startsWith(query) beats contains(query) beats no-match', () {
    final out = rankSuggestions(
      const [
        Suggestion('no match here'),
        Suggestion('xx-abc-yy'), // contains
        Suggestion('abc-def'), // startsWith
      ],
      query: 'abc',
    );
    expect(_texts(out), ['abc-def', 'xx-abc-yy', 'no match here'],
        reason: 'startsWith > contains > none');
  });

  test('query match is case-insensitive', () {
    final out = rankSuggestions(
      const [Suggestion('Zebra'), Suggestion('ABCdef')],
      query: 'abc',
    );
    expect(out.first.text, 'ABCdef');
  });

  test('result is de-duplicated by text', () {
    final out = rankSuggestions(
      const [
        Suggestion('dup'),
        Suggestion('dup', label: 'second'),
        Suggestion('unique'),
      ],
    );
    expect(_texts(out), ['dup', 'unique']);
    expect(_texts(out).where((t) => t == 'dup').length, 1);
  });

  test('first item is primary, the rest are not', () {
    final out = rankSuggestions(
      const [Suggestion('a'), Suggestion('b'), Suggestion('c')],
    );
    expect(out.first.isPrimary, isTrue);
    expect(out.skip(1).every((s) => !s.isPrimary), isTrue,
        reason: 'only the first item carries isPrimary');
  });

  test('label is preserved when an item is rebuilt as primary', () {
    final out = rankSuggestions(const [Suggestion('a', label: 'Alpha')]);
    expect(out.first.label, 'Alpha');
    expect(out.first.isPrimary, isTrue);
  });

  test('empty candidates → empty list', () {
    expect(rankSuggestions(const []), isEmpty);
  });
}

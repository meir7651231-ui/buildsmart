// GLOBAL SEARCH (phase 0) — the pure aggregation core: [scoreMatch] relevance
// + [GlobalSearchIndex.search] merge/rank/cap. Driven by trivial fake sources
// (no providers, no Firebase, no UI) — the merge is fully deterministic.

import 'package:buildsmart/features/global_search/global_search.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void _noop(WidgetRef ref, BuildContext context) {}

/// A fake domain source: scores each of [titles] against the query (live, via
/// [scoreMatch]), drops non-matches, sorts by score, and honours the cap —
/// exactly the contract a real per-domain adapter follows.
SearchSource _sourceOf(SearchResultKind kind, List<String> titles) =>
    (query, max) {
      final hits = <SearchResult>[];
      for (final t in titles) {
        final s = scoreMatch(query, t);
        if (s > 0) {
          hits.add(SearchResult(kind: kind, title: t, score: s, run: _noop));
        }
      }
      hits.sort((a, b) => b.score.compareTo(a.score));
      return hits.length <= max ? hits : hits.sublist(0, max);
    };

void main() {
  group('scoreMatch', () {
    test('exact > prefix > word-start > contains > none', () {
      expect(scoreMatch('בר', 'בר'), 4); // exact
      expect(scoreMatch('בר', 'ברז'), 3); // prefix
      expect(scoreMatch('כדור', 'ברז כדורי'), 2); // a later word starts with it
      expect(scoreMatch('דור', 'ברז כדורי'), 1); // substring inside a word
      expect(scoreMatch('xyz', 'ברז'), 0); // no match
      expect(scoreMatch('', 'ברז'), 0); // empty query never matches
    });

    test('case-insensitive (query pre-lowered, text lowered here)', () {
      expect(scoreMatch('home', 'Home Screen'), 3);
    });
  });

  group('GlobalSearchIndex.search', () {
    test('empty / whitespace query returns nothing', () {
      final idx =
          GlobalSearchIndex([_sourceOf(SearchResultKind.product, ['ברז'])]);
      expect(idx.search(''), isEmpty);
      expect(idx.search('   '), isEmpty);
    });

    test('merges hits across sources, ranked by score', () {
      final idx = GlobalSearchIndex([
        _sourceOf(SearchResultKind.product, ['ברז כדורי']), // prefix (3)
        _sourceOf(SearchResultKind.screen, ['ברז']), // exact (4)
        _sourceOf(SearchResultKind.chat, ['שיחה על ברז']), // word-start (2)
      ]);
      expect(
        idx.search('ברז').map((r) => r.kind).toList(),
        [
          SearchResultKind.screen,
          SearchResultKind.product,
          SearchResultKind.chat,
        ],
        reason: 'exact(4) > prefix(3) > word-start(2)',
      );
    });

    test('ties broken by kind order then title (deterministic)', () {
      // Three EXACT matches (score 4) across kinds → declaration order decides.
      final idx = GlobalSearchIndex([
        _sourceOf(SearchResultKind.chat, ['x']),
        _sourceOf(SearchResultKind.product, ['x']),
        _sourceOf(SearchResultKind.order, ['x']),
      ]);
      expect(
        idx.search('x').map((r) => r.kind).toList(),
        [
          SearchResultKind.product,
          SearchResultKind.order,
          SearchResultKind.chat,
        ],
      );
    });

    test('per-source cap: no single domain floods the row', () {
      final flood = _sourceOf(
        SearchResultKind.product,
        ['בר1', 'בר2', 'בר3', 'בר4', 'בר5', 'בר6'],
      );
      expect(
        GlobalSearchIndex([flood]).search('בר', perSource: 2).length,
        2,
      );
    });

    test('total cap on the merged list', () {
      final a = _sourceOf(SearchResultKind.product, ['בר1', 'בר2', 'בר3']);
      final b = _sourceOf(SearchResultKind.screen, ['בר4', 'בר5', 'בר6']);
      expect(
        GlobalSearchIndex([a, b]).search('בר', perSource: 3, total: 4).length,
        4,
      );
    });
  });

  group('GlobalSearchIndex.searchBalanced', () {
    // A prolific PRODUCT source (5 hits) beside a single screen + single chat.
    // Every title starts with 'בר' → all score 3 (prefix), so the flat search
    // ranks purely by kind and products win every tie.
    GlobalSearchIndex flooded() => GlobalSearchIndex([
          _sourceOf(
            SearchResultKind.product,
            ['בר1', 'בר2', 'בר3', 'בר4', 'בר5'],
          ),
          _sourceOf(SearchResultKind.screen, ['ברגים']),
          _sourceOf(SearchResultKind.chat, ['ברוך']),
        ]);

    test('flat search FLOODS: the prolific domain fills every visible slot', () {
      // Baseline that motivates searchBalanced — with a 3-slot row the products
      // crowd the screen + chat out entirely.
      final kinds = flooded().search('בר', total: 3).map((r) => r.kind);
      expect(kinds.toSet(), {SearchResultKind.product},
          reason: 'flat score sort → 3 products, no screen/chat');
    });

    test('searchBalanced REPRESENTS every domain before any repeats', () {
      // Round 0 takes the #1 of each source, so all three domains appear in the
      // first three slots even though products dominate the score board.
      final kinds = flooded()
          .searchBalanced('בר', total: 5)
          .map((r) => r.kind)
          .toList();
      expect(
        kinds.take(3).toSet(),
        {
          SearchResultKind.product,
          SearchResultKind.screen,
          SearchResultKind.chat,
        },
        reason: 'every domain with a hit is represented in the first round',
      );
      // Within round 0 the equal scores tie-break by kind order, so the very
      // first is the product; the extra slots (4,5) go to the next products.
      expect(kinds.first, SearchResultKind.product);
      expect(kinds.length, 5, reason: 'honours the total cap');
    });

    test('searchBalanced: empty / whitespace query returns nothing', () {
      expect(flooded().searchBalanced(''), isEmpty);
      expect(flooded().searchBalanced('   '), isEmpty);
    });

    test('searchBalanced orders each round by score (not just kind)', () {
      // A screen scoring higher (exact) than the product (prefix) leads its
      // round despite products winning EQUAL-score ties.
      final idx = GlobalSearchIndex([
        _sourceOf(SearchResultKind.product, ['ברז']), // prefix vs 'בר' → 3
        _sourceOf(SearchResultKind.screen, ['בר']), // exact 'בר' → 4
      ]);
      expect(
        idx.searchBalanced('בר').map((r) => r.kind).toList(),
        [SearchResultKind.screen, SearchResultKind.product],
        reason: 'exact(4) screen outranks prefix(3) product within the round',
      );
    });
  });
}

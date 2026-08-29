// Pillar 5 · Step 63 (R1-7) — the Layer-B (server) SearchRepository body.
//
// NO Firebase here: the token index ([CatalogTokenIndex]) is driven by a
// HAND-ROLLED fake ([_FakeTokenIndex]) that filters an in-memory fixture by an
// indexer-equivalent `nameTokens` — the same Firebase-free strategy
// `authored_products_firebase_test.dart` / `paged_query_test.dart` use (no
// fake_cloud_firestore, no new packages).
//
// Pins the Step-63 contract the spec lists in §63.5 (adapted to current code):
//   • NARROW-TOKEN choice — [catalogNarrowToken] picks the longest query word's
//     leading 3-gram (the answer-equivalence-safe rarity proxy), null when it
//     can't be safely narrowed;
//   • the LAYER-B PATH — [search] narrows over the port, then re-ranks the
//     candidate page with the SAME `fuzzySearchProducts(query, products: …)`;
//   • ANSWER-EQUIVALENT (R1-7, NOT byte-identical) — Layer-B's top-N over the
//     token-narrowed candidates equals Layer-A's over the whole fixture;
//   • DEGRADE-TO-LAYER-A (never blank) — no index / un-narrowable query / empty
//     candidate page / a throwing port all fall back to the verbatim local scan.
import 'package:buildsmart/data/fuzzy_search.dart' show fuzzySearchProducts;
import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/repositories/search_firebase.dart';
import 'package:buildsmart/data/repositories/search_repository.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter_test/flutter_test.dart';

/// SKU sequence — the order-sensitive fingerprint of a ranked result page.
List<String> _skus(List<LipskeyCatalogProduct> ps) => [for (final p in ps) p.sku];

/// The INDEXER-EQUIVALENT tokenizer: `nameHe` → words + 3-grams, lowercased —
/// exactly what the step-63 `onCatalogProductWrite` indexer
/// (`functions/src/catalog.ts`) writes to `nameTokens` (nameHe ONLY, R1-7). The
/// fake index matches `arrayContains` against this, so the golden below proves
/// that [catalogNarrowToken]'s 3-gram choice yields a SUPERSET of the Layer-A
/// match set ⇒ the re-rank is answer-equivalent.
List<String> _nameTokens(String nameHe) {
  final out = <String>{};
  for (final w in nameHe
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)) {
    out.add(w); // whole-word token
    for (var i = 0; i + 3 <= w.length; i++) {
      out.add(w.substring(i, i + 3)); // 3-gram tokens
    }
  }
  return out.toList();
}

LipskeyCatalogProduct _p(String sku, String nameHe) => LipskeyCatalogProduct(
      sku: sku,
      nameHe: nameHe,
      nameEn: '',
      categoryHe: '',
      categoryEn: '',
      categoryEmoji: '',
      page: 0,
    );

/// A small mixed Hebrew/Latin fixture. Note "מגוף ברזל" contains "ברז" only as a
/// SUBSTRING of "ברזל" — the case a whole-word filter would miss but a 3-gram
/// recovers.
final List<LipskeyCatalogProduct> _fixture = [
  _p('A', 'ברז כדורי'), //            has ברז
  _p('B', 'ברז מטבח AQUATEC'), //     has ברז, aquatec
  _p('C', 'ברז נחושת לכיור'), //       has ברז + נחושת (phrase-adjacent)
  _p('D', 'צינור נחושת'), //           has נחושת, NOT ברז
  _p('E', 'מחבר AQUATEC ישר'), //      has aquatec, NOT ברז
  _p('F', 'ברז AQUATEC נחושת'), //     has ברז + נחושת (non-adjacent) + aquatec
  _p('G', 'שסתום פליז'), //            matches none
  _p('H', 'מגוף ברזל'), //             "ברז" as a SUBSTRING of "ברזל"
];

/// A hand-rolled fake [CatalogTokenIndex] over an in-memory fixture. Faithfully
/// mimics the real `where('nameTokens', arrayContains: token).orderBy('nameHe')
/// .limit(n)` query: filter by the indexer-equivalent [_nameTokens], sort by
/// `nameHe`, cap at [limit]. Records every queried token, and can be forced to
/// throw / return empty to drive the degrade paths.
class _FakeTokenIndex implements CatalogTokenIndex {
  _FakeTokenIndex(this.catalog);

  final List<LipskeyCatalogProduct> catalog;

  /// Every token [candidatesForToken] was asked for, in order — so a test can
  /// assert the port WAS (or was NOT) hit.
  final List<String> queried = [];

  bool throwOnQuery = false;
  List<LipskeyCatalogProduct>? forcedResult;

  @override
  Future<List<LipskeyCatalogProduct>> candidatesForToken(
    String token, {
    required int limit,
  }) async {
    queried.add(token);
    if (throwOnQuery) throw StateError('server unavailable');
    if (forcedResult != null) return forcedResult!;
    final hits = [
      for (final p in catalog)
        if (_nameTokens(p.nameHe).contains(token)) p,
    ]..sort((a, b) => a.nameHe.compareTo(b.nameHe));
    return hits.take(limit).toList();
  }
}

void main() {
  test('both layers still satisfy the SearchRepository seam (drop-in)', () {
    expect(const FirebaseSearchRepository(), isA<SearchRepository>());
    expect(
      FirebaseSearchRepository(index: _FakeTokenIndex(_fixture)),
      isA<SearchRepository>(),
    );
  });

  group('catalogNarrowToken — the answer-equivalence-safe 3-gram (rarity proxy)',
      () {
    test('picks the LONGEST word\'s leading 3-gram', () {
      expect(catalogNarrowToken('ברז נחושת'), 'נחו'); // longest word נחושת
      expect(catalogNarrowToken('aquatec'), 'aqu');
      expect(catalogNarrowToken('  ברז   מטבח  '), 'מטב'); // longest word, ws-tolerant
    });

    test('returns null when it cannot be safely narrowed → caller degrades', () {
      expect(catalogNarrowToken(''), isNull);
      expect(catalogNarrowToken('   '), isNull);
      expect(catalogNarrowToken('1"'), isNull); // no word ≥ 3 chars
      expect(catalogNarrowToken('ab cd'), isNull);
    });

    test('a 3-char word narrows on itself', () {
      expect(catalogNarrowToken('abc'), 'abc');
      expect(catalogNarrowToken('ברז'), 'ברז');
    });
  });

  group('Layer-B PATH — narrow over the port, re-rank the candidate page', () {
    test('search = fuzzySearchProducts(query, products: narrowed-candidates)',
        () async {
      final index = _FakeTokenIndex(_fixture);
      final repo = FirebaseSearchRepository(index: index);

      final got = await repo.search('ברז נחושת', limit: 40);

      // It NARROWED via the port on the query's 3-gram, not a full scan.
      expect(index.queried, ['נחו']);

      // …and the result is exactly the fuzzy re-rank of the narrowed candidates.
      final candidates = await _FakeTokenIndex(_fixture)
          .candidatesForToken('נחו', limit: 40); // the {C, D, F} candidate page
      final expected = fuzzySearchProducts('ברז נחושת', products: candidates);
      expect(_skus(got), _skus(expected));

      // Concretely: only C + F contain BOTH words; D (נחושת, no ברז) was a
      // candidate but the re-rank dropped it, and A/B/E/H were never fetched.
      expect(_skus(got), ['C', 'F']);
    });

    test('the caller\'s limit caps the re-ranked page', () async {
      final repo = FirebaseSearchRepository(index: _FakeTokenIndex(_fixture));
      final one = await repo.search('ברז נחושת', limit: 1);
      expect(one, hasLength(1));
      expect(one.single.sku, 'C'); // the phrase-adjacent best match ranks first
    });
  });

  group('Layer-B ANSWER-EQUIVALENT to Layer-A (R1-7, not byte-identical)', () {
    test('tie-free query → identical top-N sequence', () async {
      final repo = FirebaseSearchRepository(index: _FakeTokenIndex(_fixture));

      final layerB = await repo.search('ברז נחושת', limit: 40);
      final layerA = fuzzySearchProducts('ברז נחושת', products: _fixture);

      expect(
        _skus(layerB),
        _skus(layerA),
        reason: 'the token-narrow must not change the answer — the rarest-3gram '
            'candidate set is a superset of the Layer-A match set',
      );
      expect(_skus(layerB), ['C', 'F']);
    });

    test('tied-score query → same answer SET (order is answer-equivalent only)',
        () async {
      final repo = FirebaseSearchRepository(index: _FakeTokenIndex(_fixture));

      final layerB = await repo.search('aquatec', limit: 40);
      final layerA = fuzzySearchProducts('aquatec', products: _fixture);

      // All three AQUATEC rows score equally (single-word phrase) → the stable
      // tiebreak differs (candidate order vs full-catalog order), so R1-7 pins the
      // SET, not the byte-order.
      expect(_skus(layerB).toSet(), _skus(layerA).toSet());
      expect(_skus(layerB).toSet(), {'B', 'E', 'F'});
    });
  });

  group('DEGRADE-TO-LAYER-A — never blank (the "OFF → Layer-A" contract)', () {
    test('no index wired (shipped default) → verbatim Layer-A, SYNCHRONOUS', () {
      const repo = FirebaseSearchRepository(); // null index

      // Byte-identical OFF path: the returned future IS a SynchronousFuture.
      expect(
        repo.search('ברז', limit: 40),
        isA<SynchronousFuture<List<LipskeyCatalogProduct>>>(),
      );
      // …and its answer is the verbatim bundled-catalog fuzzy scan.
      var ran = false;
      repo.search('ברז', limit: 40).then((r) {
        ran = true;
        expect(_skus(r), _skus(fuzzySearchProducts('ברז', limit: 40)));
        expect(r, isNotEmpty);
      });
      expect(ran, isTrue, reason: 'the OFF path must resolve in the same frame');
    });

    test('an un-narrowable query degrades WITHOUT ever hitting the port',
        () async {
      final index = _FakeTokenIndex(_fixture);
      final repo = FirebaseSearchRepository(index: index);

      final got = await repo.search('1"', limit: 40); // no word ≥ 3 chars
      expect(index.queried, isEmpty, reason: 'no safe token → no server call');
      expect(_skus(got), _skus(fuzzySearchProducts('1"', limit: 40)));
    });

    test('a throwing port degrades to Layer-A (never blank)', () async {
      final index = _FakeTokenIndex(_fixture)..throwOnQuery = true;
      final repo = FirebaseSearchRepository(index: index);

      final got = await repo.search('ברז', limit: 40);
      expect(index.queried, ['ברז'], reason: 'it tried the server first');
      expect(_skus(got), _skus(fuzzySearchProducts('ברז', limit: 40)));
      expect(got, isNotEmpty, reason: 'a server hiccup must never blank the page');
    });

    test('an empty candidate page degrades to Layer-A (never blank)', () async {
      final index = _FakeTokenIndex(_fixture)..forcedResult = const [];
      final repo = FirebaseSearchRepository(index: index);

      final got = await repo.search('ברז נחושת', limit: 40);
      expect(index.queried, ['נחו'], reason: 'it narrowed, then found nothing');
      expect(_skus(got), _skus(fuzzySearchProducts('ברז נחושת', limit: 40)));
    });

    test('empty / whitespace query → empty result (fuzzySearchProducts contract)',
        () async {
      final repo = FirebaseSearchRepository(index: _FakeTokenIndex(_fixture));
      expect(await repo.search(''), isEmpty);
      expect(await repo.search('   ', limit: 40), isEmpty);
    });
  });
}

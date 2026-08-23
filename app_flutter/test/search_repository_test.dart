// Pillar 5 · Step 62 — the SearchRepository seam.
//
// Pins the Layer-A (local) contract the step promises:
//   1. GOLDEN — [LocalSearchRepository.search]'s top-N is IDENTICAL to a direct
//      `fuzzySearchProducts` call (it wraps it VERBATIM), so the seam adds no
//      behavioural drift (same `nameHe` scan, same ranking, same page).
//   2. SYNCHRONOUS — the local search resolves in the SAME frame
//      ([SynchronousFuture]): the `.then` callback runs before the next line, so
//      today's in-frame search takes ZERO added latency (the §3 trap avoided).
//   3. EMPTY — an empty / whitespace query yields an empty list (the
//      `fuzzySearchProducts` contract, preserved).
//   4. DORMANT — `searchRepositoryProvider` defaults to the const local impl (the
//      server flags are OFF in tests), so the build is byte-identical to today.
//   5. ZERO NETWORK — the Layer-A files import NO `cloud_firestore` directly (a
//      raw-source scan): OFF search never touches the network.
//   6. SKELETON — the step-62 [FirebaseSearchRepository] degrades to the SAME
//      Layer-A answer (the step-63 "OFF → Layer-A" contract; step 63 swaps its
//      body for the token-narrow + re-rank).
import 'dart:io';

import 'package:buildsmart/data/fuzzy_search.dart' show fuzzySearchProducts;
import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/paged_query.dart' show Cursor;
import 'package:buildsmart/data/repositories/search_firebase.dart';
import 'package:buildsmart/data/repositories/search_local.dart';
import 'package:buildsmart/data/repositories/search_repository.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// SKU sequence — the order-sensitive fingerprint of a ranked result page.
List<String> _skus(List<LipskeyCatalogProduct> ps) =>
    [for (final p in ps) p.sku];

/// True when [rawSource] has a live `import '…cloud_firestore…';` directive
/// (anchored to an import so a doc-comment mention of the package name — as these
/// seam headers carry — can't count). Mirrors `catalog_static_guard_test`.
bool _importsFirestore(String rawSource) => RegExp(
      '''import\\s+['"][^'"]*cloud_firestore[^'"]*['"]''',
    ).hasMatch(rawSource);

void main() {
  const local = LocalSearchRepository();

  test('both layers satisfy the SearchRepository seam (drop-in)', () {
    expect(const LocalSearchRepository(), isA<SearchRepository>());
    expect(const FirebaseSearchRepository(), isA<SearchRepository>());
  });

  group('Layer-A golden — local wraps fuzzySearchProducts verbatim', () {
    // A spread of queries: single Hebrew word, multi-word, Latin brand, size.
    for (final q in const ['ברז', 'ברז AQUATEC', 'aquatec', '1"']) {
      for (final n in const [20, 40]) {
        test('search("$q", limit: $n) == fuzzySearchProducts("$q", limit: $n)',
            () async {
          final got = await local.search(q, limit: n);
          final direct = fuzzySearchProducts(q, limit: n);
          expect(
            _skus(got),
            _skus(direct),
            reason: 'the local seam must be a VERBATIM wrapper — same order, '
                'same items, same cap',
          );
          expect(got.length, lessThanOrEqualTo(n));
        });
      }
    }

    test('a passed cursor is ignored — the local layer is single-page',
        () async {
      final withCursor =
          await local.search('ברז', limit: 40, after: const Cursor('x', 'y'));
      final without = fuzzySearchProducts('ברז', limit: 40);
      expect(_skus(withCursor), _skus(without));
    });
  });

  test('local resolves SYNCHRONOUSLY — the .then runs in the same frame', () {
    // Directly: the returned future IS a SynchronousFuture (the §4 contract).
    expect(
      local.search('ברז', limit: 40),
      isA<SynchronousFuture<List<LipskeyCatalogProduct>>>(),
    );
    var ran = false;
    List<LipskeyCatalogProduct>? out;
    // A SynchronousFuture invokes `then` inline: `ran` must be true before the
    // expect below (no frame delay on the offline path — the whole point of §4).
    local.search('ברז', limit: 40).then((r) {
      ran = true;
      out = r;
    });
    expect(
      ran,
      isTrue,
      reason: 'LocalSearchRepository must return a SynchronousFuture so the '
          'OFF search path adds zero latency',
    );
    expect(out, isNotNull);
    expect(out, isNotEmpty);
  });

  test('empty / whitespace query → empty result (fuzzySearchProducts contract)',
      () async {
    expect(await local.search(''), isEmpty);
    expect(await local.search('   ', limit: 40), isEmpty);
  });

  test(
      'searchRepositoryProvider defaults to the const LOCAL impl '
      '(dormant / byte-identical OFF)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final repo = container.read(searchRepositoryProvider);
    expect(
      repo,
      isA<LocalSearchRepository>(),
      reason: 'with the server-search flags OFF (the test default) the seam '
          'must return the verbatim local layer',
    );
  });

  test('OFF ⇒ zero network — the Layer-A seam files import no cloud_firestore',
      () {
    // Tests run from the app_flutter package root (same convention as the guard
    // tests), so these resolve directly.
    for (final path in const [
      'lib/data/repositories/search_repository.dart',
      'lib/data/repositories/search_local.dart',
      'lib/data/repositories/search_firebase.dart',
    ]) {
      final f = File(path);
      expect(f.existsSync(), isTrue, reason: '$path must exist');
      expect(
        _importsFirestore(f.readAsStringSync()),
        isFalse,
        reason: '$path must stay Firebase-free — the seam speaks the neutral '
            'Cursor, and the live handle stays behind the one real adapter',
      );
    }
    // Sanity: the detector actually FIRES on a file that really imports it, so a
    // silently-broken regex can't make the check above pass vacuously.
    final adapter =
        File('lib/data/repositories/authored_products_firebase.dart');
    if (adapter.existsSync()) {
      expect(
        _importsFirestore(adapter.readAsStringSync()),
        isTrue,
        reason: 'the import detector must match the real Firestore adapter',
      );
    }
  });

  test(
      'step-62 Firebase SKELETON degrades to the SAME Layer-A answer '
      '(the step-63 "OFF → Layer-A" contract)', () async {
    const firebase = FirebaseSearchRepository();
    for (final q in const ['ברז', 'aquatec']) {
      final skeleton = await firebase.search(q, limit: 40);
      final layerA = await local.search(q, limit: 40);
      expect(
        _skus(skeleton),
        _skus(layerA),
        reason: 'until step 63 wires the server token-narrow, the skeleton '
            'must yield honest Layer-A results, never blank',
      );
    }
  });
}

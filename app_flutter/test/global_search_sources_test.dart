// GLOBAL SEARCH (phase 1) — the wired domain sources over the app's REAL indexes.
// screens/products are pure (const data) → tested directly; the assembled index
// (which also exercises the chats source's captured ref) runs under a ProviderScope.

import 'package:buildsmart/features/global_search/global_search.dart';
import 'package:buildsmart/features/global_search/global_search_sources.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('screenSource matches the nav index; every hit is a wired screen', () {
    final hits = screenSource('בית', 8); // 'בית' = the home destination
    expect(hits, isNotEmpty, reason: 'the home screen is in the 48-nav index');
    for (final h in hits) {
      expect(h.kind, SearchResultKind.screen);
      expect(h.score, greaterThan(0));
    }
  });

  test('productSource scans the catalog by name; capped, all products', () {
    final hits = productSource('ברז', 5); // ברז = faucet/valve, very common
    expect(hits, isNotEmpty, reason: 'the catalog has ברז products');
    expect(hits.length, lessThanOrEqualTo(5), reason: 'honours the cap');
    for (final h in hits) {
      expect(h.kind, SearchResultKind.product);
      expect(h.title.contains('ברז') || h.score > 0, isTrue);
    }
  });

  test('an unmatched query returns nothing from either pure source', () {
    expect(screenSource('zzqx', 8), isEmpty);
    expect(productSource('zzqx', 8), isEmpty);
  });

  testWidgets('buildGlobalSearchIndex assembles the sources; search returns a '
      'merged, ranked list including products', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    late GlobalSearchIndex idx;
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            idx = buildGlobalSearchIndex(ref);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    final out = idx.search('ברז');
    expect(out, isNotEmpty);
    expect(
      out.any((r) => r.kind == SearchResultKind.product),
      isTrue,
      reason: 'the products source contributes ברז hits into the merged list',
    );
    // ranked: scores are non-increasing.
    for (var i = 1; i < out.length; i++) {
      expect(out[i - 1].score, greaterThanOrEqualTo(out[i].score));
    }
  });
}

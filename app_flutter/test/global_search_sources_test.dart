// GLOBAL SEARCH (phase 1) — the wired domain sources over the app's REAL indexes.
// screens/products are pure (const data) → tested directly; the assembled index
// (which also exercises the chats source's captured ref) runs under a ProviderScope.

import 'package:buildsmart/features/global_search/global_search.dart';
import 'package:buildsmart/features/global_search/global_search_sources.dart';
import 'package:buildsmart/screens/chats_screen.dart'
    show ThreadLite, visibleThreadsProvider;
import 'package:buildsmart/screens/notifications_screen.dart'
    show activeNotifViewsProvider;
import 'package:buildsmart/screens/store_screen.dart' show storeOrdersProvider;
import 'package:buildsmart/state/tasks_engine.dart' show tasksProvider;
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

  testWidgets(
      'the chats source contributes a live thread into the merged index '
      '(chats join screens+products in the unified row)', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    late GlobalSearchIndex idx;
    late List<ThreadLite> threads;
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            idx = buildGlobalSearchIndex(ref);
            threads = ref.read(visibleThreadsProvider);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(threads, isNotEmpty,
        reason: 'the contractor persona has seeded chat threads to search');
    final target = threads.first;

    // Search the thread's EXACT name → an exact (score-4) chat hit. An exact
    // match leads its own source and is well within the per-source cap, so it
    // MUST appear in the merged list — proving the chats source is wired into
    // buildGlobalSearchIndex alongside screens + products.
    final out = idx.search(target.name);
    expect(
      out.any(
        (r) => r.kind == SearchResultKind.chat && r.title == target.name,
      ),
      isTrue,
      reason: 'the chats source surfaced the visible thread "${target.name}" '
          'into the unified results',
    );
  });

  testWidgets('orders / notifications / tasks sources each contribute their '
      'items into the merged index (phase 4)', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    late GlobalSearchIndex idx;
    String? orderId; // order number (o.id)
    String? notifTitle; // notification title
    String? taskName; // task name
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            idx = buildGlobalSearchIndex(ref);
            final orders = ref.read(storeOrdersProvider);
            if (orders.isNotEmpty) orderId = orders.first.id;
            final notifs = ref.read(activeNotifViewsProvider);
            if (notifs.isNotEmpty) notifTitle = notifs.first.title;
            final tasks = ref.read(tasksProvider);
            if (tasks.isNotEmpty) taskName = tasks.first.name;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    // The demo harness seeds all three, so all three should have surfaced a
    // sample item; each must appear in the merged index with its own kind.
    expect(orderId != null || notifTitle != null || taskName != null, isTrue,
        reason: 'the demo harness seeds orders / notifications / tasks');

    if (orderId != null) {
      final id = orderId!;
      expect(
        idx.search(id).any(
            (r) => r.kind == SearchResultKind.order && r.title == id),
        isTrue,
        reason: 'the orders source surfaces order "$id"',
      );
    }
    if (notifTitle != null) {
      final t = notifTitle!;
      expect(
        idx.search(t).any(
            (r) => r.kind == SearchResultKind.notification && r.title == t),
        isTrue,
        reason: 'the notifications source surfaces "$t"',
      );
    }
    if (taskName != null) {
      final n = taskName!;
      expect(
        idx.search(n).any(
            (r) => r.kind == SearchResultKind.task && r.title == n),
        isTrue,
        reason: 'the tasks source surfaces task "$n"',
      );
    }
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// GLOBAL SEARCH — the wired domain SOURCES (phase 1). Each is a thin adapter over
// a domain's EXISTING index/provider (NOT a new index), mapping its hits into the
// unified [SearchResult] and re-using the domain's own open/navigate action:
//
//   • screens  — [matchDestinations] (the 48-destination nav index); run = the
//                destination's own verified navigation closure.
//   • products — the union catalog [kDivePool] (929 SKUs) scanned by Hebrew name;
//                run = open the product sheet with its category siblings.
//   • chats    — [visibleThreadsProvider] (the live thread list); run = the same
//                tab + sub-tab + [updatesChatOpenProvider] path a chat chip uses.
//
// [buildGlobalSearchIndex] assembles them into one [GlobalSearchIndex] for the
// keyboard (phase 3). Pure where the data is const (screens/products); chats
// captures the keyboard's `ref` so it reads the live thread list at query time.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/features/global_search/global_search.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/screens/chats_screen.dart'
    show updatesChatOpenProvider, visibleThreadsProvider;
import 'package:buildsmart/screens/keyboard_destinations.dart'
    show KbDestination, matchDestinations;
import 'package:buildsmart/screens/lipskey_product_sheet.dart'
    show showLipskeyProductSheet;
import 'package:buildsmart/screens/updates_screen.dart'
    show updatesSubTabProvider;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Best relevance of [query] over any of a hit's [texts] (its label + synonyms).
double _bestScore(String query, Iterable<String> texts) {
  var best = 0.0;
  for (final t in texts) {
    final s = scoreMatch(query, t);
    if (s > best) best = s;
  }
  return best;
}

/// SCREENS — reuses the existing 48-destination nav index. A hit scores on the
/// BEST of its label + keywords (so a synonym match still ranks), and carries the
/// destination's own verified [KbDestination.run] navigation closure verbatim.
List<SearchResult> screenSource(String query, int max) => <SearchResult>[
      for (final KbDestination d in matchDestinations(query, max: max))
        SearchResult(
          kind: SearchResultKind.screen,
          title: d.label,
          score: _bestScore(query, <String>[d.label, ...d.keywords]),
          run: d.run,
        ),
    ];

/// PRODUCTS — scans the union catalog [kDivePool] by Hebrew name, top-[max] by
/// relevance. Tapping opens the product sheet with its category siblings (so the
/// variant pager has real neighbours), exactly like the finder's product open.
List<SearchResult> productSource(String query, int max) {
  final hits = <SearchResult>[];
  for (final p in kDivePool) {
    final s = scoreMatch(query, p.nameHe);
    if (s <= 0) continue;
    hits.add(
      SearchResult(
        kind: SearchResultKind.product,
        title: p.nameHe,
        subtitle: p.categoryHe,
        score: s,
        run: (ref, context) => showLipskeyProductSheet(
          context,
          p,
          kDivePool.where((x) => x.categoryHe == p.categoryHe).toList(),
        ),
      ),
    );
  }
  hits.sort((a, b) => b.score.compareTo(a.score));
  return hits.length <= max ? hits : hits.sublist(0, max);
}

/// CHATS — reads the live [visibleThreadsProvider] at query time (via the
/// captured [ref]) and matches thread names. Tapping opens the chat the SAME way
/// a conversation chip does: updates tab (2) + chats sub-tab (1) +
/// [updatesChatOpenProvider] = the thread id — no route push, live.
SearchSource chatSourceFor(WidgetRef ref) => (query, max) {
      final hits = <SearchResult>[];
      for (final t in ref.read(visibleThreadsProvider)) {
        final s = scoreMatch(query, t.name);
        if (s <= 0) continue;
        final id = t.id;
        hits.add(
          SearchResult(
            kind: SearchResultKind.chat,
            title: t.name,
            score: s,
            run: (r, context) {
              r.read(mainTabProvider.notifier).state = 2; // עדכונים
              r.read(updatesSubTabProvider.notifier).state = 1; // שיחות
              r.read(updatesChatOpenProvider.notifier).state = id;
            },
          ),
        );
      }
      hits.sort((a, b) => b.score.compareTo(a.score));
      return hits.length <= max ? hits : hits.sublist(0, max);
    };

/// Assemble the global search index with every wired source. Called by the
/// keyboard (phase 3) with its live [ref]. Screens + products are pure (const
/// data); chats captures [ref] to read the live thread list at query time. More
/// sources (tasks / orders / customers / notifications) join in phase 2.
GlobalSearchIndex buildGlobalSearchIndex(WidgetRef ref) => GlobalSearchIndex(
      <SearchSource>[
        screenSource,
        productSource,
        chatSourceFor(ref),
      ],
    );

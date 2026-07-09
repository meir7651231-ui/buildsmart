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
import 'package:buildsmart/screens/manager_dashboard_screen.dart'
    show showCustomerDetailSheet;
import 'package:buildsmart/screens/notifications_screen.dart'
    show activeNotifViewsProvider, notifSectionProvider;
import 'package:buildsmart/screens/store_screen.dart'
    show
        StoreSection,
        storeOrderOpenProvider,
        storeOrdersProvider,
        storeSectionProvider;
import 'package:buildsmart/screens/tasks_screen.dart' show showTaskDetailSheet;
import 'package:buildsmart/screens/updates_screen.dart'
    show updatesSubTabProvider;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/orders_engine.dart'
    show managerCustomersProvider;
import 'package:buildsmart/state/tasks_engine.dart' show tasksProvider;
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
///
/// Only STRONG matches (score >= 2 — exact / prefix / any-word-start) are kept.
/// A mere substring match (score 1) is too weak for a NAVIGATION target: e.g. the
/// one-letter query "ס" substring-hits the "מסך" keyword of the בית destination,
/// so "בית" would surface for "ס" and then, on tap, navigate to a tab you are
/// often already on — reading as a dead result. Products/chats/etc. keep score-1
/// substring hits (you're narrowing a data set there); screens must be a real
/// prefix/word match to be worth a jump.
List<SearchResult> screenSource(String query, int max) {
  final hits = <SearchResult>[];
  for (final KbDestination d in matchDestinations(query, max: max)) {
    final s = _bestScore(query, <String>[d.label, ...d.keywords]);
    if (s < 2) continue; // exact/prefix/word-start only — no weak substring jumps
    hits.add(
      SearchResult(
        kind: SearchResultKind.screen,
        title: d.label,
        score: s,
        run: d.run,
      ),
    );
  }
  return hits;
}

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

/// ORDERS — reads the live [storeOrdersProvider] at query time and matches order
/// NUMBERS (`o.id`, e.g. "BS-1042"). Tapping navigates to the store's orders
/// section (main tab 3 + [storeSectionProvider] = orders) AND opens that order's
/// detail sheet via [storeOrderOpenProvider] (the store screen listens) —
/// navigate + open, no route push.
SearchSource orderSourceFor(WidgetRef ref) => (query, max) {
      final hits = <SearchResult>[];
      for (final o in ref.read(storeOrdersProvider)) {
        final s = scoreMatch(query, o.id);
        if (s <= 0) continue;
        final id = o.id;
        hits.add(
          SearchResult(
            kind: SearchResultKind.order,
            title: o.id,
            subtitle: o.stageLabel,
            score: s,
            run: (r, context) {
              r.read(mainTabProvider.notifier).state = 3; // חנות
              r.read(storeSectionProvider.notifier).state = StoreSection.orders;
              r.read(storeOrderOpenProvider.notifier).state = id;
            },
          ),
        );
      }
      hits.sort((a, b) => b.score.compareTo(a.score));
      return hits.length <= max ? hits : hits.sublist(0, max);
    };

/// NOTIFICATIONS — reads the live [activeNotifViewsProvider] at query time and
/// matches notification titles. Notifications have no per-item detail view, so a
/// tap navigates to the notification's SECTION (main tab 2 + [updatesSubTabProvider]
/// = 0 התראות + [notifSectionProvider] = the hit's own type) — the natural "open"
/// this domain supports, reusing the exact seam the keyboard's notif chips use.
SearchSource notifSourceFor(WidgetRef ref) => (query, max) {
      final hits = <SearchResult>[];
      for (final n in ref.read(activeNotifViewsProvider)) {
        final s = scoreMatch(query, n.title);
        if (s <= 0) continue;
        final section = n.type;
        hits.add(
          SearchResult(
            kind: SearchResultKind.notification,
            title: n.title,
            score: s,
            run: (r, context) {
              r.read(mainTabProvider.notifier).state = 2; // עדכונים
              r.read(updatesSubTabProvider.notifier).state = 0; // התראות
              r.read(notifSectionProvider.notifier).state = section;
            },
          ),
        );
      }
      hits.sort((a, b) => b.score.compareTo(a.score));
      return hits.length <= max ? hits : hits.sublist(0, max);
    };

/// TASKS — reads the live [tasksProvider] at query time and matches task NAMES.
/// Tapping opens that task's detail sheet directly over the keyboard's context
/// (the SAME approver sheet the board rows show) via [showTaskDetailSheet] —
/// tasks have no home tab, so opening the sheet IS the navigation.
SearchSource taskSourceFor(WidgetRef ref) => (query, max) {
      final hits = <SearchResult>[];
      for (final t in ref.read(tasksProvider)) {
        final s = scoreMatch(query, t.name);
        if (s <= 0) continue;
        hits.add(
          SearchResult(
            kind: SearchResultKind.task,
            title: t.name,
            score: s,
            run: (r, context) => showTaskDetailSheet(context, t),
          ),
        );
      }
      hits.sort((a, b) => b.score.compareTo(a.score));
      return hits.length <= max ? hits : hits.sublist(0, max);
    };

/// CUSTOMERS — reads the live [managerCustomersProvider] at query time and
/// matches customer NAMES. Tapping opens that customer's detail sheet directly
/// (the SAME manager sheet the dashboard's customers tab shows) via
/// [showCustomerDetailSheet]. These live in the manager dashboard, so the result
/// is only meaningful in a manager-context keyboard — dormant behind the flag.
SearchSource customerSourceFor(WidgetRef ref) => (query, max) {
      final hits = <SearchResult>[];
      for (final c in ref.read(managerCustomersProvider)) {
        final s = scoreMatch(query, c.name);
        if (s <= 0) continue;
        final name = c.name;
        hits.add(
          SearchResult(
            kind: SearchResultKind.customer,
            title: c.name,
            score: s,
            run: (r, context) => showCustomerDetailSheet(r, context, name),
          ),
        );
      }
      hits.sort((a, b) => b.score.compareTo(a.score));
      return hits.length <= max ? hits : hits.sublist(0, max);
    };

/// Assemble the global search index with every wired source. Called by the
/// keyboard with its live [ref]. Screens + products are pure (const data); the
/// rest capture [ref] to read their live lists at query time. All seven domains:
/// screens · products · chats · orders · notifications · tasks · customers.
GlobalSearchIndex buildGlobalSearchIndex(WidgetRef ref) => GlobalSearchIndex(
      <SearchSource>[
        screenSource,
        productSource,
        chatSourceFor(ref),
        orderSourceFor(ref),
        notifSourceFor(ref),
        taskSourceFor(ref),
        customerSourceFor(ref),
      ],
    );

/// Like [buildGlobalSearchIndex] but WITHOUT [productSource] — the ~900-SKU name
/// scan. Used by the OPTION-B prediction row's cross-domain narrowers, which only
/// need the ENTITY + screen titles (products there are already served by the
/// finder engine via `cardKeyboardPredictions`); dropping productSource removes a
/// full redundant per-keystroke pool scan + its throwaway allocations (adversarial
/// swarm perf finding). Screens + the five entity domains only.
GlobalSearchIndex buildEntitySearchIndex(WidgetRef ref) => GlobalSearchIndex(
      <SearchSource>[
        screenSource,
        chatSourceFor(ref),
        orderSourceFor(ref),
        notifSourceFor(ref),
        taskSourceFor(ref),
        customerSourceFor(ref),
      ],
    );

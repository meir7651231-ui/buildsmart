// ─────────────────────────────────────────────────────────────────────────────
// GLOBAL SEARCH — the unified "search everything" layer (owner: "keep it in the
// same place [the keyboard prediction row] but let EVERYTHING be there").
//
// This is a THIN AGGREGATION layer, NOT a new index: one query fans out to every
// registered [SearchSource] (each a pure adapter over a domain's EXISTING index/
// provider — products via the word-lexicon, screens via kbDestinations, chats via
// the visible-threads, tasks/orders/customers via their engines …), the hits are
// score-ranked and per-source capped (so no one domain floods), and the merged
// top-N is returned for the keyboard's prediction row.
//
// PURE + TESTABLE: [scoreMatch] + [GlobalSearchIndex.search] have no side effects
// and no Firebase — a source is just `(query, max) -> results`, so the merge/rank
// is driven in tests by trivial fake sources. Each real source captures its `ref`
// when the index is built (see the per-domain adapters in phase 1+), keeping this
// core UI- and provider-free.
//
// FLAG-GATED: [kGlobalSearch] defaults OFF → the keyboard's row is byte-identical
// until the feature is switched on (--dart-define=GLOBAL_SEARCH=true), the same
// zero-regression invariant every other launch flag uses.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Master switch for the unified global search. Default OFF → the keyboard
/// prediction row is byte-identical to today; flip on at build time with
/// `--dart-define=GLOBAL_SEARCH=true`.
const bool kGlobalSearch = bool.fromEnvironment('GLOBAL_SEARCH');

/// What a [SearchResult] points at — drives its icon + grouping, and (as the
/// declaration order) the deterministic tie-break when two hits score equally.
/// Ordered by general utility in a construction-procurement app.
enum SearchResultKind {
  product,
  screen,
  order,
  task,
  customer,
  chat,
  notification,
  setting,
}

/// One unified search hit from ANY domain source. [run] performs the result's
/// action at tap time (open the product / navigate to the screen / open the
/// chat …) — it is invoked with the live keyboard [WidgetRef] + [BuildContext].
@immutable
class SearchResult {
  const SearchResult({
    required this.kind,
    required this.title,
    required this.run,
    this.subtitle = '',
    this.score = 0,
  });

  /// The domain this hit belongs to (icon + grouping + tie-break order).
  final SearchResultKind kind;

  /// The primary label shown on the chip/row (e.g. the product name, screen
  /// name, chat contact, task title).
  final String title;

  /// An optional secondary line (e.g. the task's status, the order's site).
  final String subtitle;

  /// Relevance score from [scoreMatch] (exact 4 › prefix 3 › word-start 2 ›
  /// contains 1). Higher ranks first across the merged list.
  final double score;

  /// The tap action — navigate / open. Invoked with the keyboard's ref+context.
  final void Function(WidgetRef ref, BuildContext context) run;
}

/// A pure domain search adapter: given the already-lowercased, trimmed [query]
/// and a per-source cap [max], return up to [max] scored [SearchResult]s from ONE
/// domain. A real source is a closure that captured its `ref` at index-build
/// time; a test source is a trivial in-memory closure. No side effects.
typedef SearchSource = List<SearchResult> Function(String query, int max);

/// The whitespace splitter for [scoreMatch]'s word-start check — hoisted to a
/// single top-level instance so a broad query does not reconstruct a RegExp for
/// every one of the ~900 catalogue names it scans per keystroke (swarm perf
/// finding). Same pattern the catalog uses for its hot `_kWhitespace`.
final RegExp _wsSplit = RegExp(r'\s+');

/// Relevance of [query] against [text]: exact 4 › prefix 3 › any-word-start 2 ›
/// substring 1 › no-match 0. Case-insensitive — callers pass a lowered [query];
/// [text] is lowered here. An empty query never matches (returns 0).
double scoreMatch(String query, String text) {
  if (query.isEmpty) return 0;
  final t = text.toLowerCase();
  if (t == query) return 4; // exact
  if (t.startsWith(query)) return 3; // prefix
  for (final w in t.split(_wsSplit)) {
    if (w.isNotEmpty && w.startsWith(query)) return 2; // any word starts with it
  }
  if (t.contains(query)) return 1; // substring anywhere
  return 0;
}

/// The unified aggregator. Holds the registered [sources] (built once, each with
/// its domain `ref` captured); [search] fans a query out to all of them, caps
/// each so no single domain floods the row, and returns the merged, score-ranked
/// hits. Const + pure — the merge/rank is fully deterministic and testable.
@immutable
class GlobalSearchIndex {
  const GlobalSearchIndex(this.sources);

  /// One adapter per domain (products / screens / chats / tasks / …).
  final List<SearchSource> sources;

  /// Search every source for [query]. [perSource] caps each domain's
  /// contribution (products can't drown out chats); [total] caps the merged
  /// list. Ranking is score-desc, ties broken by [SearchResultKind] declaration
  /// order then title — stable + deterministic (safe for golden/snapshot tests).
  /// An empty/whitespace query returns nothing (the row stays as-is).
  List<SearchResult> search(
    String query, {
    int perSource = 4,
    int total = 24,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const <SearchResult>[];

    final merged = <SearchResult>[];
    for (final source in sources) {
      final hits = source(q, perSource);
      // Defensive: honour the per-source cap even if a source over-returns.
      merged.addAll(hits.length <= perSource ? hits : hits.sublist(0, perSource));
    }

    merged.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final byKind = a.kind.index.compareTo(b.kind.index);
      if (byKind != 0) return byKind;
      return a.title.compareTo(b.title);
    });

    return merged.length <= total ? merged : merged.sublist(0, total);
  }

  /// ROUND-ROBIN variant of [search] — the "everything is there" ordering the
  /// keyboard row uses. Instead of a flat score sort (where one prolific domain,
  /// e.g. products, can fill every visible slot and crowd screens/chats out), it
  /// takes each source's #1 hit, then each source's #2, and so on: EVERY domain
  /// with a match is represented before any domain gets a second slot. Within a
  /// round the higher score still leads (then [SearchResultKind] order, then
  /// title), so relevance orders the visible mix without any domain vanishing.
  /// Same per-source + [total] caps and the same empty-query contract as [search].
  List<SearchResult> searchBalanced(
    String query, {
    int perSource = 4,
    int total = 24,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const <SearchResult>[];

    // Per-source ranked buckets (each already scored + sorted + capped by the
    // source; defensively re-capped here so an over-returning source can't skew
    // the round-robin).
    final buckets = <List<SearchResult>>[
      for (final source in sources)
        () {
          final hits = source(q, perSource);
          return hits.length <= perSource ? hits : hits.sublist(0, perSource);
        }(),
    ];

    final out = <SearchResult>[];
    for (var round = 0; out.length < total; round++) {
      // This round's candidates: the round-th hit from every bucket that has one.
      final roundHits = <SearchResult>[
        for (final b in buckets)
          if (round < b.length) b[round],
      ];
      if (roundHits.isEmpty) break; // every bucket exhausted.
      roundHits.sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        if (byScore != 0) return byScore;
        final byKind = a.kind.index.compareTo(b.kind.index);
        if (byKind != 0) return byKind;
        return a.title.compareTo(b.title);
      });
      for (final h in roundHits) {
        if (out.length >= total) break;
        out.add(h);
      }
    }
    return out;
  }
}

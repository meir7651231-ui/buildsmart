// ─────────────────────────────────────────────────────────────────────────────
// PagedQuery<T> — CURSOR pagination over the neutral remote seam (Studio step 53).
//
// Studio's catalog is the one collection that grows past a single listen (10Ks of
// SKUs), so browse must PAGE. This helper adds cursor pagination on TOP of the
// same Firebase-free seam the cache base already speaks (`RemoteDoc` = id + map,
// `firestore_cached_repo.dart:50`) — WITHOUT leaking a Firestore type.
//
// THE SHAPE (mirrors `RemoteCollectionSource` `firestore_cached_repo.dart:61`):
//   • [PagedSource] is a NEW neutral read-port — one `page({after, limit})` that
//     returns [RemoteDoc]s, plus an [isSinglePage] flag that mirrors the base
//     seam's [RemoteCollectionSource.isScoped] getter. The REAL adapter (built in
//     a later step) turns a [Cursor] into a Firestore `startAfter`; the fake test
//     source SLICES an in-memory list. Neither this file nor its test imports
//     `cloud_firestore` — the seam stays Firebase-free, exactly like the base.
//   • [Cursor] is a NEUTRAL immutable position (last-doc-id + sort value) — NOT a
//     `DocumentSnapshot`. Carrying a snapshot would break the Firebase-free seam;
//     carrying (id, sortValue) is all the real adapter needs to resume a query.
//
// HARD RULES (violating any breaks the contract):
//   1. NEVER `offset` — cursor (`startAfter`) only. Offset pays to read+skip the
//      pages before it; cursor jumps straight to the boundary (§6 cost guardrail).
//   2. A requested limit is CLAMPED to <= [maxLimit] (40) — a defensive cap so no
//      caller can ask the backend for 10K rows in one page by mistake.
//   3. The OFF / local single-page source ([LocalPagedSource]) returns the WHOLE
//      list in ONE page (`hasMore = false`) SYNCHRONOUSLY (`SynchronousFuture`) —
//      so with Studio-live OFF the browse path is byte-identical to today (no
//      network, no frame delay), the same "born non-empty" spirit as the base.
//
// DORMANT: no provider/widget wires this yet — nothing changes behaviour this
// step. It is the read-port that `catalog_firebase.dart` (step 60) will build on.
// ─────────────────────────────────────────────────────────────────────────────

// Only [RemoteDoc]/[RemoteCollectionSource] enter scope from here — the imported
// library has no `export`, so its own `cloud_firestore` import does NOT leak in:
// this file stays Firebase-free, exactly like the base seam.
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:flutter/foundation.dart';

/// A NEUTRAL, immutable pagination cursor — the position a page resumes AFTER.
///
/// Holds only [lastDocId] (the id of the last document of the previous page) and
/// [sortValue] (that document's value for the query's order-by field) — all the
/// real Firestore adapter needs to resume a `startAfter` query, and NOTHING
/// Firebase-specific, so the seam stays Firebase-free (a `DocumentSnapshot` would
/// leak the backend). The fake test source needs only [lastDocId] to slice next.
@immutable
class Cursor {
  const Cursor(this.lastDocId, this.sortValue);

  /// Document id of the LAST item of the page this cursor follows.
  final String lastDocId;

  /// That last document's value for the query's sort field (doc-id by default).
  /// `Object?` — Firestore sort keys are heterogeneous (String / num / Timestamp).
  final Object? sortValue;

  @override
  bool operator ==(Object other) =>
      other is Cursor &&
      other.lastDocId == lastDocId &&
      other.sortValue == sortValue;

  @override
  int get hashCode => Object.hash(lastDocId, sortValue);

  @override
  String toString() => 'Cursor($lastDocId, $sortValue)';
}

/// One page of results — IMMUTABLE so a UI can hold it as state. [cursor] is the
/// position to pass to the NEXT [PagedQuery.page] call (null when [hasMore] is
/// false — there is nothing after the last page); [hasMore] drives whether the
/// list shows a sentinel "load more" footer (twin of `capped`,
/// `catalog_screen.dart:2267`).
@immutable
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.cursor,
    required this.hasMore,
  });

  /// The decoded models for this page (already mapped from [RemoteDoc]).
  final List<T> items;

  /// Where the next page resumes — pass to `page(after: result.cursor)`. Null iff
  /// [hasMore] is false.
  final Cursor? cursor;

  /// Whether a further page MAY exist (drives the sentinel footer).
  final bool hasMore;
}

/// The neutral PAGED read-port — the paging analog of [RemoteCollectionSource].
/// The cache base's seam pushes a whole collection via `snapshots()`; this port
/// instead PULLS one bounded page at a time, so a 10K collection never listens as
/// a whole. Speaks only neutral [RemoteDoc]s + a [Cursor] — Firebase-free, so a
/// hand-rolled fake drives the tests and only the real adapter imports Firestore.
abstract class PagedSource {
  /// Fetch up to [limit] documents that come AFTER [after] (null = from the
  /// start), in the source's own order. The real adapter translates [after] into
  /// a Firestore `startAfter` + `limit(n)` query — NEVER `offset`. The fake test
  /// source slices an in-memory list. Returns fewer than [limit] on the last page.
  Future<List<RemoteDoc>> page({required int limit, Cursor? after});

  /// Whether this source PAGES remotely. `false` marks the OFF / local
  /// single-page source ([LocalPagedSource]) that returns the whole list in one
  /// page — the mirror of [RemoteCollectionSource.isScoped]: a property of the
  /// source that [PagedQuery] reads to decide the shape of the result.
  bool get isSinglePage;
}

/// The OFF / local single-page source: wraps an in-memory list (today's bundled
/// catalog) and returns it ALL, in ONE page, SYNCHRONOUSLY. This is the path when
/// Studio-live is off — [PagedQuery.page] resolves in the same frame with the
/// full list and `hasMore = false`, so the browse screen behaves byte-identically
/// to today (no network, no pagination) — the paging analog of the base's
/// born-seeded cache.
class LocalPagedSource implements PagedSource {
  LocalPagedSource(this._docs);

  final List<RemoteDoc> _docs;

  /// Single page — always: the whole list is returned at once (never paged).
  @override
  bool get isSinglePage => true;

  /// The whole list, in one synchronous page. [after]/[limit] are ignored — a
  /// single-page source has exactly one page, so there is never a "next" to skip
  /// to and nothing to cap. [SynchronousFuture] keeps the OFF path frame-perfect.
  @override
  Future<List<RemoteDoc>> page({required int limit, Cursor? after}) =>
      SynchronousFuture<List<RemoteDoc>>(List<RemoteDoc>.unmodifiable(_docs));
}

/// Cursor-paginates a [PagedSource], decoding each [RemoteDoc] into a model [T].
///
/// One instance describes one paged query (a source + how to decode a doc + how
/// to read its sort value + the page size). Call [page] repeatedly, threading the
/// previous [PagedResult.cursor] into the next call, until [PagedResult.hasMore]
/// is false. Stateless between calls — the cursor carries all continuation state.
class PagedQuery<T> {
  PagedQuery({
    required PagedSource source,
    required T Function(RemoteDoc doc) fromDoc,
    Object? Function(RemoteDoc doc)? sortValueOf,
    int limit = maxLimit,
  })  : _source = source,
        _fromDoc = fromDoc,
        _sortValueOf = sortValueOf ?? _defaultSortValue,
        _limit = _clamp(limit);

  /// Hard defensive cap on the page size — no page ever asks the backend for more
  /// than this many docs, however large a [limit] a caller passes (§6 guardrail).
  static const int maxLimit = 40;

  final PagedSource _source;
  final T Function(RemoteDoc doc) _fromDoc;
  final Object? Function(RemoteDoc doc) _sortValueOf;
  final int _limit;

  /// The EFFECTIVE page size actually requested from the source — the caller's
  /// [limit] after clamping to `1..[maxLimit]`.
  int get limit => _limit;

  static int _clamp(int requested) =>
      requested < 1 ? 1 : (requested > maxLimit ? maxLimit : requested);

  /// Default sort key: the doc id (the order a Firestore query has with no
  /// explicit order-by). A caller ordering by another field (e.g. `nameHe`)
  /// passes its own extractor so the [Cursor] carries the right resume value.
  static Object? _defaultSortValue(RemoteDoc doc) => doc.id;

  /// Fetch the next page, resuming AFTER [after] (null = the first page). Returns
  /// a [PagedResult] with the decoded [PagedResult.items], a [Cursor] to continue
  /// from (null when there is no next page), and [PagedResult.hasMore]. When the
  /// source is the OFF / local single-page one this resolves SYNCHRONOUSLY with
  /// the full list (`hasMore = false`), because a [SynchronousFuture] threaded
  /// through a value-returning `then` stays synchronous.
  Future<PagedResult<T>> page({Cursor? after}) =>
      _source.page(limit: _limit, after: after).then(_toResult);

  PagedResult<T> _toResult(List<RemoteDoc> docs) {
    final items = <T>[];
    for (final doc in docs) {
      items.add(_fromDoc(doc));
    }
    // A single-page source never has a next page. Otherwise a FULL page (we got
    // as many as we asked for) MAY have more behind it — the standard cursor
    // heuristic; the follow-up call simply returns empty if it was the exact end.
    final hasMore = !_source.isSinglePage && docs.length >= _limit;
    final last = docs.isEmpty ? null : docs.last;
    final cursor = (hasMore && last != null)
        ? Cursor(last.id, _sortValueOf(last))
        : null;
    return PagedResult<T>(
      items: List<T>.unmodifiable(items),
      cursor: cursor,
      hasMore: hasMore,
    );
  }
}

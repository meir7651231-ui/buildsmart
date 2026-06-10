// ─────────────────────────────────────────────────────────────────────────────
// FirestoreCachedRepo<T> — the offline-first CACHE base every `_firebase`
// repository (S3 ×6) inherits. It is the bridge that lets the SYNCHRONOUS
// repository interfaces (`List<Order> all()`) keep working over an ASYNC,
// real-time Firestore backend WITHOUT touching a single provider or widget.
//
// THE BRIDGE (the whole point — see SPEC-server-connect §0 "sync interface מול
// async backend"):
//   • a Firestore `snapshots()` listener pushes every change into an in-memory
//     `List<T>` cache (real-time flows IN here);
//   • sync reads (`cached()`) serve straight from that cache (instant — no await);
//   • writes update the cache OPTIMISTICALLY and fire-and-forget the matching
//     Firestore `set`/`delete` in the background.
// → the interface stays sync, the UI never changes, real-time still flows. This
//   is the drop-in the whole server-connect track rests on.
//
// HARD RULES this base enforces (violating any of them breaks the contract):
//   1. NEVER turn a read into a Future — `cached()` is synchronous.
//   2. A write / stream / decode failure must NEVER throw into the UI — every
//      remote touch goes through `guardWrite` / a guarded `attach`, which CATCH
//      and LOG (the optimistic cache is the source of truth the user sees).
//   3. A corrupt document is SKIPPED (logged), never dropped-the-whole-list — a
//      single bad doc can't blank the app.
//   4. The cache is BORN seeded (the app is non-empty before the first snapshot).
//
// THE SEAM (`RemoteCollectionSource`): the base talks to Firestore only through
// this abstract port, which speaks in NEUTRAL decoded docs ([RemoteDoc] = id +
// map) — NOT in `QuerySnapshot`/`DocumentReference`. That keeps this file (and
// its tests) Firebase-free: the real adapter ([FirestoreCollectionSource])
// resolves `FirebaseFirestore.instance` LAZILY (never at construction) and maps
// the real `QuerySnapshot` down to [RemoteDoc]s; a hand-rolled fake source
// drives the unit tests with zero new packages.
//
// Comment density/voice intentionally mirrors `orders_local.dart` — this is the
// foundation 6 parallel S3 authors read first, so the "why" is spelled out.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// One decoded remote document — the NEUTRAL shape the cache base speaks in
/// (instead of a Firestore `QueryDocumentSnapshot`). `id` is the document id;
/// `data` is its field map. Keeping the seam in this shape is what lets the base
/// class + its tests stay Firebase-free (a fake source emits these directly).
@immutable
class RemoteDoc {
  const RemoteDoc(this.id, this.data);

  final String id;
  final Map<String, dynamic> data;
}

/// The injectable Firestore seam. The cache base touches the backend ONLY
/// through this port, so a hand-rolled fake can drive every unit test and the
/// real impl ([FirestoreCollectionSource]) stays the only thing that imports a
/// live `FirebaseFirestore`. All three methods speak neutral [RemoteDoc]/maps.
abstract class RemoteCollectionSource {
  /// The live document stream — one event per collection change. The base maps
  /// each [RemoteDoc] through the repo's `fromDoc` and replaces the cache.
  Stream<List<RemoteDoc>> snapshots();

  /// Write (create-or-merge) the document [id] with field-map [data]. Background
  /// fire-and-forget from the base; failures are caught+logged by `guardWrite`.
  Future<void> set(String id, Map<String, dynamic> data);

  /// Delete the document [id]. Same guarded, background semantics as [set].
  Future<void> delete(String id);
}

/// The REAL Firestore adapter. Resolves `FirebaseFirestore.instance` LAZILY —
/// never in the constructor — so merely constructing a repository (e.g. when a
/// provider is read) does NOT require Firebase to be initialised; the instance
/// is only touched on the first `snapshots()`/`set()`/`delete()`. It maps the
/// live `QuerySnapshot` down to neutral [RemoteDoc]s for the base.
class FirestoreCollectionSource implements RemoteCollectionSource {
  FirestoreCollectionSource(this.collectionPath, {FirebaseFirestore? firestore})
      : _injected = firestore;

  /// The collection name (e.g. `orders`).
  final String collectionPath;

  /// Optional pre-resolved instance (tests / DI). When null the instance is
  /// resolved lazily from the singleton on first use.
  final FirebaseFirestore? _injected;

  /// Lazily-resolved Firestore handle — `FirebaseFirestore.instance` is read
  /// ONLY here, on demand, never at construction (so a Firebase-free app/test
  /// can construct the repo without initialising Firebase).
  FirebaseFirestore get _db => _injected ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(collectionPath);

  @override
  Stream<List<RemoteDoc>> snapshots() => _col.snapshots().map(
        (snap) => snap.docs
            .map((d) => RemoteDoc(d.id, d.data()))
            .toList(growable: false),
      );

  @override
  Future<void> set(String id, Map<String, dynamic> data) =>
      _col.doc(id).set(data, SetOptions(merge: true));

  @override
  Future<void> delete(String id) => _col.doc(id).delete();
}

/// The offline-first cache base. Generic over the domain model [T] (Order,
/// Customer, …). Extends [ChangeNotifier] so a thin Riverpod provider can listen
/// if it wants, but the primary read path is the sync [cached] getter.
///
/// A subclass supplies the model⇄doc mapping ([fromDoc]/[toDoc]/[idOf]), the
/// [seed] (so the cache is born non-empty), and — if it cares — an ordering
/// ([sortBy], since Firestore returns documents in doc-id order) and an
/// [onFirstSnapshotEmpty] hook (default no-op).
abstract class FirestoreCachedRepo<T> extends ChangeNotifier {
  FirestoreCachedRepo(this._source) {
    // Born seeded — the app is non-empty BEFORE the first snapshot arrives.
    _cache = _sorted(List<T>.of(seed));
  }

  final RemoteCollectionSource _source;

  late List<T> _cache;
  bool _firstSnapshotSeen = false;

  // ── subclass contract ──────────────────────────────────────────────────────

  /// Decode one remote document into a model. THROWING here is fine — the base
  /// catches it per-doc and SKIPS the bad document (it never blanks the list).
  T fromDoc(RemoteDoc doc);

  /// Encode a model into a Firestore field-map (the inverse of [fromDoc]).
  Map<String, dynamic> toDoc(T value);

  /// The document id for a model (e.g. `order.id`). Used as the Firestore
  /// doc-id on writes and to de-dup on optimistic [upsert].
  String idOf(T value);

  /// The genesis list the cache is BORN with (so the app is non-empty before
  /// the first snapshot). For orders this is `kOrdersEngineSeed`.
  List<T> get seed;

  /// Restore the engine's ordering. Firestore returns documents in doc-id order,
  /// which is NOT the order the UI expects (orders are newest-first). Default is
  /// identity; subclasses override to re-sort the cache after every snapshot.
  List<T> sortBy(List<T> items) => items;

  /// Hook invoked once, the first time the FIRST snapshot arrives EMPTY (a fresh
  /// backend). Default no-op; the orders repo overrides it to seed the remote
  /// from the local seed via [pushCacheToRemote]. A LATER empty snapshot (the
  /// collection was emptied at runtime) is NOT first-empty and is honoured as a
  /// real "now empty" state — see [attach].
  void onFirstSnapshotEmpty() {}

  // ── reads (SYNCHRONOUS — the bridge) ───────────────────────────────────────

  /// The in-memory cache — served synchronously, instantly, with no await. This
  /// is what every sync interface method (`all()`, `byId()`, …) reads through.
  List<T> cached() => List<T>.unmodifiable(_cache);

  // ── live wiring ────────────────────────────────────────────────────────────

  /// Subscribe to the live document stream. Each event is mapped through
  /// [fromDoc] (corrupt docs skipped+logged), [sortBy]-ordered, and replaces the
  /// cache, then [notifyListeners]. The subscription is guarded so a stream
  /// error can never throw into the app; [dispose] cancels it.
  void attach() {
    _sub ??= _source.snapshots().listen(
      _onSnapshot,
      onError: (Object e, StackTrace st) {
        // A stream error must never surface in the UI — keep the last good cache.
        debugPrint('FirestoreCachedRepo<$T>: snapshot stream error: $e');
      },
    );
  }

  void _onSnapshot(List<RemoteDoc> docs) {
    // First empty snapshot on a FRESH backend → let the subclass seed remote;
    // keep showing the seeded cache (don't blank the app to empty).
    if (docs.isEmpty && !_firstSnapshotSeen) {
      _firstSnapshotSeen = true;
      onFirstSnapshotEmpty();
      return;
    }
    _firstSnapshotSeen = true;

    final mapped = <T>[];
    for (final d in docs) {
      try {
        mapped.add(fromDoc(d));
      } on Object catch (e) {
        // Skip ONE corrupt document (logged) — never drop the whole list.
        debugPrint('FirestoreCachedRepo<$T>: skipped corrupt doc ${d.id}: $e');
      }
    }
    _cache = _sorted(mapped);
    notifyListeners();
  }

  // ── writes (optimistic cache + guarded background remote) ───────────────────

  /// Optimistically upsert [value] into the cache (replace-by-id or prepend) and
  /// fire the matching Firestore `set` in the background (guarded). The UI sees
  /// the change synchronously; the remote catches up (and a later snapshot
  /// reconciles). A write failure is caught+logged, never thrown.
  void upsert(T value, {bool prepend = true}) {
    final id = idOf(value);
    final idx = _cache.indexWhere((e) => idOf(e) == id);
    final next = List<T>.of(_cache);
    if (idx >= 0) {
      next[idx] = value;
    } else if (prepend) {
      next.insert(0, value);
    } else {
      next.add(value);
    }
    _cache = _sorted(next);
    notifyListeners();
    guardWrite(() => _source.set(id, toDoc(value)));
  }

  /// Optimistically replace the WHOLE cache with [values] and push each to the
  /// remote in the background (guarded). Used by `resetToSeed` (replace with the
  /// seed). Deletions of docs no longer present are out of scope for S2 (the
  /// pilot replaces, it does not prune) — a later snapshot reconciles reads.
  void replaceAll(List<T> values) {
    _cache = _sorted(List<T>.of(values));
    notifyListeners();
    for (final v in values) {
      guardWrite(() => _source.set(idOf(v), toDoc(v)));
    }
  }

  /// Optimistically remove the doc with [id] from the cache and delete it
  /// remotely in the background (guarded). Provided for S3 repos that need it;
  /// the orders pilot does not delete.
  void removeById(String id) {
    _cache = _sorted(_cache.where((e) => idOf(e) != id).toList());
    notifyListeners();
    guardWrite(() => _source.delete(id));
  }

  /// Push the ENTIRE current cache to the remote (no cache mutation) — used by
  /// [onFirstSnapshotEmpty] to seed a fresh backend from the local seed. Each
  /// write is guarded; a failure is logged, never thrown.
  void pushCacheToRemote() {
    for (final v in _cache) {
      guardWrite(() => _source.set(idOf(v), toDoc(v)));
    }
  }

  /// Run a background remote write, swallowing+logging ANY failure. This is the
  /// single choke-point that guarantees rule #2: a write failure (offline, rules
  /// rejection, decode error) NEVER throws into the UI. Returns the (already
  /// guarded) future so callers/tests may await settling if they wish.
  @protected
  Future<void> guardWrite(Future<void> Function() write) async {
    try {
      await write();
    } on Object catch (e) {
      debugPrint('FirestoreCachedRepo<$T>: write failed (ignored): $e');
    }
  }

  List<T> _sorted(List<T> items) => sortBy(items);

  // ── lifecycle ───────────────────────────────────────────────────────────────

  StreamSubscription<List<RemoteDoc>>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FirebaseMaterialRequestsRepository — the SERVER-SWAP-Z Firestore impl of the
// worker→contractor material-request queue, built on the offline-first cache
// base ([FirestoreCachedRepo]). It is a DROP-IN behind
// [MaterialRequestsNotifier.bindRemote]: the providers + UI are unchanged — only
// which store the notifier mirrors changes.
//
// Mirrors the orders pilot (`orders_firebase.dart`):
//   • reads (`all`) are SYNCHRONOUS, served from the in-memory cache the base
//     maintains from a Firestore `snapshots()` listener on `material_requests`;
//   • writes (`submit`/`setStatus`) update the cache OPTIMISTICALLY and fire the
//     matching Firestore write in the background — a failure is logged, never
//     thrown.
//
// WRITE SEMANTICS ARE VERBATIM PORTS of `MaterialRequestsNotifier`
// (`state/material_requests_engine.dart`) so every worker/contractor number
// stays byte-for-byte identical to the local path:
//   • `submit` → drop empty item lines, mint `mat-${micros}-${_seq}`, status
//     `requested`, appended;
//   • `setStatus` → guard on a known status + a non-terminal request, else no-op.
//
// SEED CONTRACT: the queue is BORN EMPTY (no demo seed) — a material request only
// exists once a worker files one. A first EMPTY snapshot (fresh backend) is the
// honest empty queue; `pushCacheToRemote` writes nothing (empty cache).
//
// FIELD MAPPING: `MaterialRequest.toJson` verbatim (doc-id = request id 'mat-…').
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/material_requests_engine.dart';

/// The Firestore-backed material-requests repo. Constructed over the
/// `material_requests` collection; the real Firestore instance is resolved
/// LAZILY by [FirestoreCollectionSource] (never here), so construction does not
/// require Firebase to be initialised. Pass `source` in tests to drive the cache
/// with a fake.
class FirebaseMaterialRequestsRepository
    extends FirestoreCachedRepo<MaterialRequest> {
  // Stage-2 scale — plain limit(500) growth-bound; no orderBy, no doc excluded.
  FirebaseMaterialRequestsRepository({RemoteCollectionSource? source})
      : super(source ??
            FirestoreCollectionSource(
              'material_requests',
              bound: (q) => q.limit(500),
            ));

  // ── base contract: seed · mapping · ordering · fresh-backend hook ───────────

  /// Born EMPTY — a material request only exists once a worker files one (no
  /// demo seed), identical genesis to the local engine (`super(const [])`).
  @override
  List<MaterialRequest> get seed => const [];

  /// doc-id = the request id (`mat-…`).
  @override
  String idOf(MaterialRequest r) => r.id;

  /// `MaterialRequest` → Firestore doc — the model's own `toJson` verbatim.
  @override
  Map<String, dynamic> toDoc(MaterialRequest r) => r.toJson();

  /// Firestore doc → `MaterialRequest` via the model's defensive `tryFromJson`
  /// (the doc-id is merged in as `id` so a doc written without the field still
  /// decodes). THROWS on a structurally-bad doc — the base catches that per-doc
  /// and skips it (never blanks the list).
  @override
  MaterialRequest fromDoc(RemoteDoc doc) {
    final r = MaterialRequest.tryFromJson(<String, dynamic>{
      ...doc.data,
      'id': doc.id,
    });
    if (r == null) {
      throw const FormatException('malformed material_requests doc');
    }
    return r;
  }

  /// Restore the engine's insertion order (it appends). Firestore returns docs
  /// in doc-id order; re-sort by `createdTs` ascending so `all()` matches the
  /// append order the local engine holds. The contractor/worker inbox providers
  /// re-sort newest-first themselves.
  @override
  List<MaterialRequest> sortBy(List<MaterialRequest> items) =>
      List<MaterialRequest>.of(items)
        ..sort((a, b) => a.createdTs.compareTo(b.createdTs));

  /// Fresh backend (first snapshot empty) → push the (empty) cache; nothing to
  /// seed, but keeps the one uniform hook every repo uses.
  @override
  void onFirstSnapshotEmpty() => pushCacheToRemote();

  // ── reads (SYNCHRONOUS — served from the cache) ─────────────────────────────

  /// The full live queue — what [MaterialRequestsNotifier._refreshFromRemote]
  /// mirrors into the engine state.
  List<MaterialRequest> all() => cached();

  // ── writes (optimistic cache + background Firestore) ────────────────────────

  /// Monotonic id suffix — verbatim port of `MaterialRequestsNotifier._seq`
  /// (web `DateTime` precision is ~1ms, so two rapid submits could collide on a
  /// timestamp-only id).
  int _seq = 0;

  /// WORKER write — verbatim port of `MaterialRequestsNotifier.submit`: drop
  /// empty/whitespace item lines, mint `mat-${micros}-${_seq}`, status
  /// `requested`, optimistically appended + written to Firestore in the
  /// background. Returns the new request's id.
  String submit({
    required String employerId,
    required String workerUid,
    required String username,
    required String workerName,
    required List<String> items,
    String note = '',
  }) {
    _seq++;
    final cleaned = <String>[
      for (final raw in items)
        if (raw.trim().isNotEmpty) raw.trim(),
    ];
    final id = 'mat-${DateTime.now().microsecondsSinceEpoch}-$_seq';
    final r = MaterialRequest(
      id: id,
      employerId: employerId,
      workerUid: workerUid,
      username: username,
      workerName: workerName,
      items: cleaned,
      note: note.trim(),
      createdTs: DateTime.now().microsecondsSinceEpoch,
      // status defaults to kMatReqRequested (the model's default).
    );
    upsert(r, prepend: false); // engine appends; derived providers re-sort
    return id;
  }

  /// CONTRACTOR write — verbatim port of `MaterialRequestsNotifier.setStatus`:
  /// guard on a known [kMatReqStatuses] value + a non-terminal request, then
  /// optimistically advance the status + background-write. No-op otherwise.
  void setStatus(String id, String status) {
    if (!kMatReqStatuses.contains(status)) return;
    final idx = cached().indexWhere((r) => r.id == id);
    if (idx < 0) return;
    final r = cached()[idx];
    if (r.status == kMatReqSupplied || r.status == kMatReqDeclined) return;
    upsert(r.copyWith(status: status), prepend: false);
  }
}

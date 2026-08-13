// ─────────────────────────────────────────────────────────────────────────────
// worker_notifs_repository (Wave T3 · 2d) — the SERVER worker bell feed reader.
// The §6 worker 🔔 bell migrates from the client's username-keyed local store to
// `workerNotifs/{workerUid}`, which the `onTaskStatusChanged` Cloud Function
// WRITES (task approve/reject/assign) — so a REAL registered worker (whose board
// username is NOT one of the demo `kWorkerUsernames`) actually receives their
// task bells, keyed by their uid instead of a demo username.
//
// SELF-ONLY: the rule is `workerNotifs/{uid}` read/write by the owner; the client
// only READS its own feed and marks-read / clears it. Cross-party generation is
// the trigger's job (Admin SDK), never a client write to another user's feed.
//
// GATED + DORMANT: [workerNotifsServerProvider] streams the feed ONLY under
// `kTasksServer && useFirebaseBackend` for a real signed-in WORKER; otherwise it
// emits the empty list and the local username-keyed store (worker_notifs.dart)
// stays the source — byte-identical OFF.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/worker_notifs.dart' show WorkerNotif;
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The worker's own bell feed at `workerNotifs/{uid}` — a single doc
/// `{ items: [...], updatedAt }`. Reads decode `items` (newest-first, the trigger
/// prepends); mark-read / clear read-modify-write the whole `items` list.
class WorkerNotifsRepository {
  WorkerNotifsRepository(this._source, {required this.uid});

  final RemoteCollectionSource _source;
  final String uid;

  /// Decode the one doc's `items` into [WorkerNotif]s (empty when absent/odd).
  List<WorkerNotif> _decode(List<RemoteDoc> docs) {
    for (final d in docs) {
      if (d.id != uid) continue;
      final raw = d.data['items'];
      if (raw is! List) return const [];
      return [
        for (final j in raw)
          if (j is Map) WorkerNotif.fromJson(j.cast<String, dynamic>()),
      ];
    }
    return const [];
  }

  /// Live stream of the worker's feed (newest-first).
  Stream<List<WorkerNotif>> watch() => _source.snapshots().map(_decode);

  Future<void> _writeAll(List<WorkerNotif> items) => _source.set(uid, {
        'items': [for (final n in items) n.toJson()],
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

  /// Mark ONE entry read (read-modify-write over the current [items]).
  Future<void> markRead(List<WorkerNotif> items, String id) => _writeAll([
        for (final n in items) n.id == id ? n.copyWith(read: true) : n,
      ]);

  /// Mark the WHOLE feed read.
  Future<void> markAllRead(List<WorkerNotif> items) =>
      _writeAll([for (final n in items) n.copyWith(read: true)]);

  /// Clear the feed (IRREVERSIBLE — the caller confirms first).
  Future<void> clear() => _writeAll(const []);
}

/// The worker-notifs repo — gated on a real (non-demo) signed-in WORKER, ON.
final workerNotifsRepositoryProvider =
    Provider<WorkerNotifsRepository?>((ref) {
  if (kTasksServer && useFirebaseBackend) {
    final s = ref.watch(boardAuthProvider);
    if (s != null &&
        s.role == BoardRole.worker &&
        !s.demo &&
        s.uid.isNotEmpty) {
      final uid = s.uid;
      return WorkerNotifsRepository(
        FirestoreCollectionSource(
          'workerNotifs',
          scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
        ),
        uid: uid,
      );
    }
  }
  return null;
});

/// The live SERVER feed for the logged worker (newest-first) — empty when the
/// repo is null (OFF / non-worker / demo), so the local store stays the source.
final workerNotifsServerProvider =
    StreamProvider<List<WorkerNotif>>((ref) {
  final repo = ref.watch(workerNotifsRepositoryProvider);
  if (repo == null) return Stream<List<WorkerNotif>>.value(const []);
  return repo.watch();
});

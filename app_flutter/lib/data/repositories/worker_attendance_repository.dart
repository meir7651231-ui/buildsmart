// ─────────────────────────────────────────────────────────────────────────────
// worker_attendance_repository — the FIRST worker-HR local→server migration: a
// worker's own attendance ledger at `workerAttendance/{workerUid}`.
//
// WHY THIS SHAPE (not the carts single-owner shape): worker HR is TWO-SIDED —
// the WORKER writes their own days, and their EMPLOYER (contractor) reads them.
// So the doc is keyed by the WORKER's uid and carries an `employerId` field (the
// contractor uid, from the setEmployer claim via the board session), and the
// firestore rule lets the worker WRITE/READ their own doc while the employer (and
// a manager) may READ it — the employer's roster query (`where employerId == me`)
// arrives in the next slice. This slice is the WORKER-SELF side only.
//
// `workerAttendance/{uid}` holds `{ days: [ AttendanceDay.toJson … ], employerId,
// updatedAt }`. A worker only ever clocks THEMSELF, so the notifier's whole state
// is this worker's rows — the same full-list-rewrite the local `_persist` does.
// Resolves Firestore LAZILY through the neutral [RemoteCollectionSource] seam
// (scoped to the uid), so a hand-rolled fake drives the unit tests — Firebase-free.
//
// GATED + DORMANT (byte-identity): [workerAttendanceRepositoryProvider] returns
// this repo ONLY under `kUserDataServer && useFirebaseBackend` for a real
// (non-demo) signed-in WORKER uid; otherwise null. With [kUserDataServer]
// const-false (every normal build) the branch is dead code → tree-shaken, the
// notifier keeps its verbatim SharedPreferences (`bs.worker-attendance.v1`) path
// → the OFF build is BYTE-IDENTICAL. The courier reuse (a separate ledger key)
// stays local — it passes no repo.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/worker_attendance.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The worker's own attendance store at `workerAttendance/{workerUid}` — ONE
/// document per worker holding `{ days, employerId, updatedAt }`. Talks to
/// Firestore only through the neutral [RemoteCollectionSource] seam (scoped to the
/// worker uid), so a hand-rolled fake drives the unit tests.
class WorkerAttendanceRepository {
  WorkerAttendanceRepository(
    this._source, {
    required this.currentUid,
    required this.employerId,
  });

  /// The scoped Firestore seam (`workerAttendance`, `documentId == currentUid`).
  final RemoteCollectionSource _source;

  /// The signed-in worker uid the doc is keyed on.
  final String currentUid;

  /// The worker's employer (contractor) uid — stamped on the doc so the employer
  /// roster query can find it, and the read rule can prove employment. '' when
  /// unassigned (the doc is then self-only until an admin runs setEmployer).
  final String employerId;

  /// Read `workerAttendance/{uid}` and decode its `days`; the empty list when the
  /// doc is absent / unreadable (NEVER throws — the caller starts empty, like the
  /// local path's `raw == null`). Per-entry tolerant (a bad row is skipped),
  /// mirroring the local `AttendanceDay.tryFromJson`.
  Future<List<AttendanceDay>> loadMine() async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == currentUid) return _daysOf(d.data);
      }
      return const <AttendanceDay>[];
    } on Object catch (_) {
      return const <AttendanceDay>[];
    }
  }

  /// Merge-write the worker's WHOLE ledger to `workerAttendance/{uid}` as
  /// `{ days, employerId, updatedAt }` — the server twin of the local
  /// `setString`. `employerId` rides every write so the employer roster query
  /// (next slice) can scope to it; `updatedAt` is a client ms-epoch stamp.
  Future<void> saveMine(List<AttendanceDay> days) {
    return _source.set(currentUid, <String, dynamic>{
      'days': days.map((d) => d.toJson()).toList(),
      'employerId': employerId,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Decode the `days` array of a `workerAttendance/{uid}` doc (mirrors the local
  /// path's per-entry tolerant `tryFromJson` — a missing/wrong-typed array →
  /// empty; a malformed row is skipped, never throws).
  static List<AttendanceDay> _daysOf(Map<String, dynamic> data) {
    final raw = data['days'];
    if (raw is! List) return const <AttendanceDay>[];
    final out = <AttendanceDay>[];
    for (final e in raw) {
      final d = AttendanceDay.tryFromJson(e);
      if (d != null) out.add(d);
    }
    return out;
  }
}

/// The worker-attendance repository provider — the server-migration seam the
/// worker's [workerAttendanceProvider] routes its persist/load through. Returns
/// the Firestore-backed, uid-scoped repo ONLY under
/// `kUserDataServer && useFirebaseBackend` for a real (non-demo) signed-in WORKER;
/// otherwise null (the SharedPreferences path). With [kUserDataServer] const-false
/// the branch is dead code (tree-shaken) → null → byte-identical.
final workerAttendanceRepositoryProvider =
    Provider<WorkerAttendanceRepository?>((ref) {
  if (kUserDataServer && useFirebaseBackend) {
    final session = ref.watch(boardAuthProvider);
    // A REAL (non-demo) signed-in worker with a Firebase uid only — a demo/seed
    // session (no uid) keeps its device-local ledger, exactly like today.
    if (session != null &&
        session.role == BoardRole.worker &&
        !session.demo &&
        session.uid.isNotEmpty) {
      final uid = session.uid;
      final source = FirestoreCollectionSource(
        'workerAttendance',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return WorkerAttendanceRepository(
        source,
        currentUid: uid,
        employerId: session.employerId,
      );
    }
  }
  return null;
});

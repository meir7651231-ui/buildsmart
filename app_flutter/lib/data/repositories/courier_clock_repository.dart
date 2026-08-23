// ─────────────────────────────────────────────────────────────────────────────
// courier_clock_repository — courier delivery-clock local→server migration: the
// courier's own pickup/delivered wall-clock stamps at `courierClock/{courierUid}`.
//
// SINGLE-DOC + SELF-ONLY: the clock is the COURIER's own measurement side-map
// `{ orderId: { pickedUpAt, deliveredAt, attempts } }`, read back only by that
// courier's reports tab. The server doc wraps the whole map under `entries`:
// `courierClock/{uid} = { entries: { …the map… }, updatedAt }`. No other party
// reads it (the store gets the monthly report via CHAT), so the rule is self-only.
//
// GATED + DORMANT (byte-identity): [courierClockRepositoryProvider] returns this
// repo ONLY under `kUserDataServer && useFirebaseBackend` for a real (non-demo)
// signed-in COURIER uid; otherwise null (the SharedPreferences `bs.courier-clock.v1`
// path, byte-identical). Best-effort like the local writer: a server failure never
// breaks a delivery advance — the reports honestly show the stamp as unmeasured.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The courier's own delivery-clock at `courierClock/{courierUid}` — ONE document
/// wrapping the `{ orderId: { pickedUpAt, deliveredAt, attempts } }` map under
/// `entries`. Read-modify-write: the writer loads the map, stamps one entry, saves.
class CourierClockRepository {
  CourierClockRepository(this._source, {required this.uid});

  final RemoteCollectionSource _source;
  final String uid;

  /// Read `courierClock/{uid}` and return its `entries` map (the raw orderId→stamp
  /// map); empty when the doc is absent / unreadable (never throws) — the async
  /// twin of the SharedPreferences `getString` + `jsonDecode`.
  Future<Map<String, dynamic>> load() async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == uid) {
          final raw = d.data['entries'];
          return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
        }
      }
      return <String, dynamic>{};
    } on Object catch (_) {
      return <String, dynamic>{};
    }
  }

  /// Merge-write the WHOLE clock map to `courierClock/{uid}` as
  /// `{ entries, updatedAt }` — the server twin of the SharedPreferences
  /// `setString`. `updatedAt` is a client ms-epoch stamp.
  Future<void> save(Map<String, dynamic> entries) {
    return _source.set(uid, <String, dynamic>{
      'entries': entries,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

/// The courier-clock repository provider — gated on a real (non-demo) signed-in
/// courier; null on the OFF path (byte-identical). Mirrors the courier_profile
/// gate (single-doc; self-only).
final courierClockRepositoryProvider =
    Provider<CourierClockRepository?>((ref) {
  if (kUserDataServer && useFirebaseBackend) {
    final session = ref.watch(boardAuthProvider);
    if (session != null &&
        session.role == BoardRole.courier &&
        !session.demo &&
        session.uid.isNotEmpty) {
      final uid = session.uid;
      final source = FirestoreCollectionSource(
        'courierClock',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return CourierClockRepository(source, uid: uid);
    }
  }
  return null;
});

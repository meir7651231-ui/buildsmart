// ─────────────────────────────────────────────────────────────────────────────
// erasure — Pillar-3 STUDIO · step 99 (PART B) — the customer-intelligence
// ERASURE SWEEP (GDPR right-to-erasure / תיקון-13 §14), as a PURE, testable Dart
// plan + executor over a tiny reader/deleter abstraction.
//
// THE PROBLEM (§4): a data subject's intel is spread across MANY keys and MANY
// collections — signed-in `uid` events AND pre-login ANON events (a DIFFERENT
// `actor_key`), `presence/{uid}` AND `presence/{actorKey}`, the `actorStitch/{uid}`
// mapping, sessions, and any displayName-bearing row. Deleting the `uid` events
// alone leaves ORPHANED pre-stitch anon events that are still the same person. The
// sweep must therefore be MULTI-KEY, and it must be COMPLETE — proven by
// `test/intel/erasure_completeness_test.dart` (§5, MANDATORY).
//
// THE JOIN (R1-3): the pre-login anon keys are recovered from `actorStitch/{uid}`
// (the sign-in stitch doc `actor_key.dart` persists behind the consent+backend
// gate), so a fully-anonymous event from BEFORE the account existed is still
// reachable — and erased.
//
// THE KEY-SET — the CANONICAL contract. The TS `deleteAccount` Cloud Function
// (functions/src/deleteAccount.ts, `purgeIntelForSubject`) executes the IDENTICAL
// set against LIVE Firestore; this Dart twin is the testable PLAN:
//   • events (intelEvents)   — actor_key ∈ {uid, ...anonKeys}
//   • presence               — doc-id ∈ {uid, ...anonKeys}  (presence/{uid} AND
//                              presence/{actorKey}, EVERY key)
//   • sessions (if present)  — actor_key ∈ {uid, ...anonKeys}
//   • displayName rows       — reset displayName→'' for actor_key ∈ {uid, ...}
//   • actorStitch/{uid}      — the mapping doc itself
//
// FIREBASE-FREE: the sweep speaks ONLY the two neutral ports below (a [reader] and
// a [deleter]), so the whole thing is unit-tested with an in-memory fake and ZERO
// Firebase — the intel_sink.dart `IntelBatchWriter` / realtime_wiring `_FakeSource`
// port idiom. The PRODUCTION execution is the TS callable named above.
// ─────────────────────────────────────────────────────────────────────────────

/// The intel collection identifiers + the pseudonymous key field — the SAME
/// literals the live writers use (intel_sink.dart: `kIntelCollection` /
/// `kPresenceCollection` / `kActorStitchCollection`; IntelEvent.toWire's
/// `actor_key`). Re-declared here so this PURE file never imports the
/// Firebase-bound sink, and kept in ONE place so the Dart plan and its TS twin
/// (functions/src/deleteAccount.ts) provably agree on the surface being swept.
abstract final class ErasureCollections {
  /// The append-only events collection (auto-id docs, keyed by `actor_key`).
  static const String events = 'intelEvents';

  /// The "who is online now" collection (doc-id = the pseudonymous key).
  static const String presence = 'presence';

  /// The (forward-ready) server session collection, if ever written.
  static const String sessions = 'sessions';

  /// The anon→uid mapping collection (doc-id = uid, holds the `anonKeys` array).
  static const String actorStitch = 'actorStitch';

  /// The pseudonymous field every event / session row is keyed by
  /// (IntelEvent.toWire → `'actor_key'`). NEVER a name / PII.
  static const String actorKeyField = 'actor_key';
}

/// The READ port — the sweep's ONLY input read: the anon keys stitched to a uid,
/// recovered from `actorStitch/{uid}` (R1-3) so PRE-login events stay reachable.
/// Firebase-free; the production impl reads the live Firestore doc inside the
/// `deleteAccount` callable.
// ignore: one_member_abstracts
abstract class ErasureReader {
  /// The anon keys accumulated under `actorStitch/{uid}` (its `anonKeys` array), or
  /// EMPTY when there is no stitch doc. Best-effort: a read failure yields empty —
  /// the uid-keyed rows are still swept.
  Future<List<String>> stitchedAnonKeys(String uid);
}

/// The DELETE port — every MUTATION the sweep performs, one method per target,
/// each keyed by the pseudonymous key-set (never a name / PII). A recording fake
/// drives `erasure_completeness_test.dart` Firebase-free; the production impl is
/// the `deleteAccount` Cloud Function's Firestore batch cascade.
abstract class ErasureDeleter {
  /// Delete every `intelEvents` doc whose `actor_key` ∈ [actorKeys].
  Future<void> deleteEvents(Set<String> actorKeys);

  /// Delete `presence/{docId}` for EVERY id in [presenceDocIds] — i.e.
  /// `presence/{uid}` AND `presence/{actorKey}` for every stitched key (§4).
  Future<void> deletePresence(Set<String> presenceDocIds);

  /// Delete every `sessions` doc whose `actor_key` ∈ [actorKeys] (best-effort — the
  /// collection may not exist; a no-op then).
  Future<void> deleteSessions(Set<String> actorKeys);

  /// Reset `displayName`→'' on any RETAINED row carrying it for [actorKeys]. PII
  /// (R1-4): IntelEvent.toWire NEVER persists a displayName, so this is a defensive
  /// scrub of any legacy / future retained-profile row — it does NOT delete.
  Future<void> resetDisplayNames(Set<String> actorKeys);

  /// Delete the `actorStitch/{uid}` mapping doc itself (§4) — done LAST, so a
  /// failure mid-sweep still leaves the join usable for a retry.
  Future<void> deleteStitch(String uid);
}

/// The erasure KEY-SET for one data subject — the canonical contract shared with
/// the TS `deleteAccount` sweep. Given the subject [uid] and its [anonKeys]
/// (recovered from `actorStitch`), events / sessions / displayName rows are matched
/// by `actor_key ∈` [actorKeys]; presence docs by id ∈ [presenceDocIds]. BOTH sets
/// are {uid, ...anonKeys} — the uid AND every pre-login anon key.
class ErasurePlan {
  ErasurePlan({required this.uid, required Iterable<String> anonKeys})
      : anonKeys = List<String>.unmodifiable(
          // dedupe + drop empties + never re-list the uid itself.
          <String>{...anonKeys}
              .where((String k) => k.isNotEmpty && k != uid)
              .toList(growable: false),
        );

  /// The account uid — the erasure subject + the events / presence / stitch join key.
  final String uid;

  /// The pre-login anon keys stitched to [uid] (deduped, non-empty, ≠ uid). Empty
  /// when the subject never had an anon→uid crossing (e.g. created signed-in).
  final List<String> anonKeys;

  /// The actor-key set that events / sessions / displayName rows are matched by:
  /// {uid, ...anonKeys}. Always contains [uid] (never empty).
  Set<String> get actorKeys => <String>{uid, ...anonKeys};

  /// The presence doc-id set: {uid, ...anonKeys} — `presence/{uid}` AND
  /// `presence/{actorKey}` for every stitched key (§4). Same membership as
  /// [actorKeys]; named apart because presence is DOC-ID-keyed, not field-matched.
  Set<String> get presenceDocIds => <String>{uid, ...anonKeys};
}

/// Erase the data subject [subjectUid] and everything joined to it. Reads the
/// stitched anon keys (R1-3), builds the MULTI-KEY [ErasurePlan], then sweeps EVERY
/// intel collection so ZERO residue remains for the subject — INCLUDING pre-stitch
/// anon events reachable only via `actorStitch` (`erasure_completeness_test.dart`).
///
/// Order: read stitch → delete events → delete presence → delete sessions → reset
/// displayName → delete the stitch doc LAST (so a mid-sweep failure leaves the join
/// intact for a retry). Returns the [ErasurePlan] so a caller / test can inspect the
/// exact key-set that was swept.
///
/// Firebase-free + testable; the PRODUCTION execution is the TS `deleteAccount`
/// callable (functions/src/deleteAccount.ts, `purgeIntelForSubject`), which runs the
/// IDENTICAL key-set against live Firestore (best-effort + paginated).
Future<ErasurePlan> eraseSubject(
  String subjectUid, {
  required ErasureReader reader,
  required ErasureDeleter deleter,
}) async {
  final anonKeys = await reader.stitchedAnonKeys(subjectUid);
  final plan = ErasurePlan(uid: subjectUid, anonKeys: anonKeys);
  await deleter.deleteEvents(plan.actorKeys);
  await deleter.deletePresence(plan.presenceDocIds);
  await deleter.deleteSessions(plan.actorKeys);
  await deleter.resetDisplayNames(plan.actorKeys);
  await deleter.deleteStitch(plan.uid);
  return plan;
}

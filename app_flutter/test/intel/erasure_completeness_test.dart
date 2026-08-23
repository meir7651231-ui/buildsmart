// Studio Pillar-3 · step 99 (PART B) — the ERASURE COMPLETENESS proof (§5,
// MANDATORY). Seeds an in-memory fake store with ALL key types a data subject
// leaves behind — PRE-STITCH anon events (a DIFFERENT actor_key), signed-in uid
// events, presence/{uid} AND presence/{actorKey}, a displayName-only RETAINED row,
// and the actorStitch/{uid} mapping — then runs `eraseSubject` and asserts ZERO
// residue for the subject in EVERY collection, INCLUDING the pre-login anon events
// (reachable only via actorStitch, R1-3). An UNRELATED subject's data SURVIVES
// (anti-vacuous: the sweep erases the subject, not the store).
//
// This is the completeness twin of the TS `deleteAccount` sweep
// (functions/src/deleteAccount.ts, `purgeIntelForSubject`) — both run the identical
// {uid, ...anonKeys} key-set; this proves it leaves nothing behind.

import 'package:buildsmart/state/intel/erasure.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal in-memory intel store that plays BOTH sweep ports. Mirrors the
/// recording-fake idiom (intel_sink_test.dart `_FakeSource implements <port>`): no
/// Firebase, deterministic, and inspectable after the sweep.
class _FakeIntelStore implements ErasureReader, ErasureDeleter {
  /// intelEvents — each a {actor_key, name} row.
  final List<Map<String, String>> events = <Map<String, String>>[];

  /// presence — docId (a uid OR an actorKey) → the doc.
  final Map<String, Map<String, String>> presence =
      <String, Map<String, String>>{};

  /// sessions — each a {actor_key, session_id} row (forward-ready surface).
  final List<Map<String, String>> sessions = <Map<String, String>>[];

  /// actorStitch — uid → its accumulated pre-login anon keys.
  final Map<String, List<String>> stitch = <String, List<String>>{};

  /// A RETAINED profile-style row carrying a human displayName (PII), keyed by
  /// actor_key — the sweep RESETS its displayName→'' (row survives, no name residue).
  final List<Map<String, String>> displayNameRows = <Map<String, String>>[];

  // ── ErasureReader ──────────────────────────────────────────────────────────
  @override
  Future<List<String>> stitchedAnonKeys(String uid) async =>
      List<String>.of(stitch[uid] ?? const <String>[]);

  // ── ErasureDeleter ─────────────────────────────────────────────────────────
  @override
  Future<void> deleteEvents(Set<String> actorKeys) async =>
      events.removeWhere((e) => actorKeys.contains(e['actor_key']));

  @override
  Future<void> deletePresence(Set<String> presenceDocIds) async =>
      presence.removeWhere((id, _) => presenceDocIds.contains(id));

  @override
  Future<void> deleteSessions(Set<String> actorKeys) async =>
      sessions.removeWhere((s) => actorKeys.contains(s['actor_key']));

  @override
  Future<void> resetDisplayNames(Set<String> actorKeys) async {
    for (final row in displayNameRows) {
      if (actorKeys.contains(row['actor_key'])) row['displayName'] = '';
    }
  }

  @override
  Future<void> deleteStitch(String uid) async => stitch.remove(uid);

  // ── residue probes ─────────────────────────────────────────────────────────
  int eventsFor(Set<String> keys) =>
      events.where((e) => keys.contains(e['actor_key'])).length;
  int presenceFor(Set<String> keys) => presence.keys.where(keys.contains).length;
  int sessionsFor(Set<String> keys) =>
      sessions.where((s) => keys.contains(s['actor_key'])).length;
}

void main() {
  // The subject: a uid with TWO pre-login anon keys stitched to it (R1-3), plus an
  // UNRELATED third party whose data must SURVIVE the sweep.
  const uid = 'uid-777';
  const anonA = 'anon-aaaa'; // stitched pre-login key #1
  const anonB = 'anon-bbbb'; // stitched pre-login key #2
  const other = 'uid-other'; // an unrelated subject — MUST NOT be touched
  const otherAnon = 'anon-zzzz';

  _FakeIntelStore seed() {
    final s = _FakeIntelStore();
    // (1) PRE-STITCH anon events — a DIFFERENT actor_key than the uid. These are the
    //     orphan-risk rows: reachable ONLY via actorStitch (R1-3).
    s.events.add(<String, String>{'actor_key': anonA, 'name': 'screen_view'});
    s.events.add(<String, String>{'actor_key': anonB, 'name': 'search_submit'});
    // (2) signed-in uid events.
    s.events.add(<String, String>{'actor_key': uid, 'name': 'add_to_cart'});
    s.events.add(<String, String>{'actor_key': uid, 'name': 'order_placed'});
    // (3) presence — BOTH presence/{uid} AND presence/{actorKey} (§4).
    s.presence[uid] = <String, String>{'actor_key': uid, 'screen': 'checkout'};
    s.presence[anonA] = <String, String>{'actor_key': anonA, 'screen': 'home'};
    // (4) a session row (forward-ready surface), keyed by an anon key.
    s.sessions.add(<String, String>{'actor_key': anonB, 'session_id': 'sess-1'});
    // (5) a displayName-only RETAINED row (PII to scrub, not delete).
    s.displayNameRows
        .add(<String, String>{'actor_key': uid, 'displayName': 'מאיר כהן'});
    // (6) the actorStitch/{uid} mapping — the join that reaches anonA + anonB.
    s.stitch[uid] = <String>[anonA, anonB];

    // UNRELATED subject — events (uid + anon), presence, session, stitch, displayName.
    // MUST all survive (anti-vacuous: no over-deletion).
    s.events.add(<String, String>{'actor_key': other, 'name': 'screen_view'});
    s.events
        .add(<String, String>{'actor_key': otherAnon, 'name': 'search_submit'});
    s.presence[other] = <String, String>{'actor_key': other, 'screen': 'home'};
    s.sessions.add(<String, String>{'actor_key': other, 'session_id': 'sess-2'});
    s.displayNameRows
        .add(<String, String>{'actor_key': other, 'displayName': 'דנה לוי'});
    s.stitch[other] = <String>[otherAnon];
    return s;
  }

  group('step 99B · erasure completeness — ZERO residue across every collection',
      () {
    test(
        'eraseSubject erases uid + pre-stitch anon events (via actorStitch, R1-3), '
        'presence/{uid} AND presence/{actorKey}, sessions, stitch; displayName reset',
        () async {
      final store = seed();
      const subjectKeys = <String>{uid, anonA, anonB};

      // Pre-condition (NON-VACUOUS): the subject IS present in every collection.
      expect(store.eventsFor(subjectKeys), 4, reason: 'seed: 2 anon + 2 uid events');
      expect(store.presenceFor(subjectKeys), 2,
          reason: 'seed: presence/{uid} + {anon}');
      expect(store.sessionsFor(subjectKeys), 1, reason: 'seed: 1 anon session');
      expect(store.stitch.containsKey(uid), isTrue,
          reason: 'seed: actorStitch/{uid}');
      expect(
        store.displayNameRows.any(
            (r) => r['actor_key'] == uid && r['displayName'] == 'מאיר כהן'),
        isTrue,
        reason: 'seed: a displayName-only row carrying PII',
      );

      final plan = await eraseSubject(uid, reader: store, deleter: store);

      // The sweep operated over the MULTI-KEY set {uid, anonA, anonB} (R1-3) —
      // proving the pre-login anon keys were joined in via actorStitch.
      expect(plan.actorKeys, <String>{uid, anonA, anonB});
      expect(plan.presenceDocIds, <String>{uid, anonA, anonB});
      expect(plan.anonKeys.toSet(), <String>{anonA, anonB});

      // ZERO residue for the subject — EVERY collection.
      expect(store.eventsFor(subjectKeys), 0,
          reason: 'events residue — incl the PRE-STITCH anon events (orphan risk)');
      expect(store.presenceFor(subjectKeys), 0,
          reason: 'presence residue — presence/{uid} AND presence/{actorKey}');
      expect(store.sessionsFor(subjectKeys), 0, reason: 'sessions residue');
      expect(store.stitch.containsKey(uid), isFalse,
          reason: 'actorStitch/{uid} mapping residue');

      // The displayName-only row is RETAINED but its PII is reset→'' (no name left).
      final subjectDn =
          store.displayNameRows.where((r) => r['actor_key'] == uid);
      expect(subjectDn, isNotEmpty,
          reason: 'the row is retained (reset, not delete)');
      for (final r in subjectDn) {
        expect(r['displayName'], '',
            reason: 'displayName PII must be scrubbed to empty');
      }
    });

    test('ANTI-VACUOUS — the UNRELATED subject is fully intact (no over-deletion)',
        () async {
      final store = seed();
      await eraseSubject(uid, reader: store, deleter: store);

      expect(store.eventsFor(<String>{other, otherAnon}), 2,
          reason: 'the other subject keeps BOTH its uid + anon events');
      expect(store.presence.containsKey(other), isTrue,
          reason: 'other presence survives');
      expect(store.sessionsFor(<String>{other}), 1,
          reason: 'other session survives');
      expect(store.stitch.containsKey(other), isTrue,
          reason: 'other stitch survives');
      expect(
        store.displayNameRows
            .firstWhere((r) => r['actor_key'] == other)['displayName'],
        'דנה לוי',
        reason: 'the other subject displayName is untouched',
      );
    });

    test(
        'a subject with NO stitch doc still erases its uid-keyed rows (best-effort '
        'read → empty anonKeys → uid-only key-set)', () async {
      final store = _FakeIntelStore();
      store.events.add(<String, String>{'actor_key': 'lone', 'name': 'screen_view'});
      store.presence['lone'] =
          <String, String>{'actor_key': 'lone', 'screen': 'home'};
      // no stitch['lone'] — stitchedAnonKeys returns empty.

      final plan = await eraseSubject('lone', reader: store, deleter: store);
      expect(plan.actorKeys, <String>{'lone'},
          reason: 'just the uid — no anon keys');
      expect(plan.anonKeys, isEmpty);
      expect(store.eventsFor(<String>{'lone'}), 0);
      expect(store.presence.containsKey('lone'), isFalse);
    });
  });
}

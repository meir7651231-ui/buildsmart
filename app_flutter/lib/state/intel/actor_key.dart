// ─────────────────────────────────────────────────────────────────────────────
// actor_key — Pillar-3 STUDIO · step 91 — the anon-but-stable ACTOR KEY + the
// sign-in stitch.
//
// THE ACTOR KEY (the pseudonymous id every intel event is stamped with, read by
// the bus's `_context`, step 89):
//   • signed-in  → the Firebase uid (currentUidProvider) — the erasure join key
//     (intel_event.dart:36);
//   • signed-out → a PER-INSTALL uuid, minted ONCE from a cryptographic
//     Random.secure (no `uuid` package in pubspec) and persisted to
//     SharedPreferences so it SURVIVES a restart — the always-on local id.
//
// THE LATE-LOAD GUARD (§4, the recently_viewed.dart:30-47 idiom): prefs load is
// async, so until it settles the anon key is DEFERRED (null) — the bus stamps
// null for that one cold-start event rather than MINTING A VOLATILE KEY on the
// race. The `_userTouched` one-shot guard makes mint/erase happen at most once and
// stops a late `_load` from clobbering it.
//
// THE SIGN-IN STITCH ([ActorStitch]): on an anon→uid transition it emits the
// `identify` bridge event (carrying the OLD anon key so the pre-login journey
// stays joinable) AND persists the `actorStitch/{uid}` mapping doc — but ONLY
// through the SAME consent+backend gate as the forward sink
// ([analyticsForwardEnabled], consent_gate.dart); OFF-BACKEND THE DOC IS NEVER
// WRITTEN (§3). The uid travels only as the event's pseudonymous top-level field +
// the doc id, NEVER in a user-visible prop (R1-4 / manager_role_assign_sheet:172).
//
// DORMANT + LAZY: nothing reads these providers until step 92 wires the bus's
// call-sites, so no prefs are written and no listener fires on the demo path —
// additive, byte-identical. The Firestore SDK is ISOLATED to intel_sink.dart (the
// stitch write routes through [FirestoreActorStitchWriter] there); THIS file is
// Firebase-free.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:math' show Random;

import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/auth_state.dart' show currentUidProvider;
import 'package:buildsmart/state/intel/consent_gate.dart'
    show analyticsForwardEnabled;
import 'package:buildsmart/state/intel/intel_bus.dart' show intelBusProvider;
import 'package:buildsmart/state/intel/intel_sink.dart'
    show FirestoreActorStitchWriter;
import 'package:flutter/foundation.dart' show debugPrint, visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The SharedPreferences key holding the per-install anon actor key. Versioned
/// (`.v1`) so a future key-schema migration (§6) can bump it without losing
/// history — the `bs.recently-viewed.v1` idiom.
const String kActorKeyPrefsKey = 'bs.intel.actor-key.v1';

/// The per-install anon actor key notifier: mints ONE cryptographic uuid on first
/// use and persists it so it survives a restart. State is null while DEFERRED
/// (prefs not yet loaded) or after [erase]. Clones the discipline of
/// `RecentlyViewedNotifier` (recently_viewed.dart): an async `_load` in the ctor +
/// the `_userTouched` one-shot late-load guard.
class AnonActorKeyNotifier extends StateNotifier<String?> {
  /// Kicks the async load (+ first-run mint) exactly once, lazily — the ctor runs
  /// only when [anonActorKeyProvider] is first read (step 92), so nothing writes
  /// prefs before then.
  AnonActorKeyNotifier() : super(null) {
    _ready = _load();
  }

  /// One-shot guard: set the moment the key is minted or [erase]d so a
  /// late-resolving [_load] can never clobber it (recently_viewed.dart:30-47).
  bool _userTouched = false;

  /// @visibleForTesting — completes when the ctor's async [_load] settles, so a
  /// test can deterministically await the first resolve / mint.
  @visibleForTesting
  Future<void> get ready => _ready;
  late final Future<void> _ready;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // A dispose or an [erase] during the async gap wins — never clobber it.
      if (!mounted || _userTouched) return;
      final stored = prefs.getString(kActorKeyPrefsKey);
      if (stored != null && stored.isNotEmpty) {
        state = stored; // restart → the SAME per-install key (stable)
        return;
      }
      // First run on this install: mint ONCE + persist ONCE (§4). The guard is
      // set here so a racing [erase] below cannot be resurrected.
      final minted = _mintKey();
      _userTouched = true;
      state = minted;
      await prefs.setString(kActorKeyPrefsKey, minted);
    } on Object catch (_) {
      // Storage unavailable (e.g. the Firebase-free bus test has no prefs
      // binding): keep the key DEFERRED (state stays null) — NEVER mint a volatile
      // key on a storage failure. A later successful resolve settles it.
    }
  }

  /// §9 "forget me": drop the local key so client-side continuity is SEVERED —
  /// past anon events can no longer be joined to a future key on THIS device. The
  /// guard blocks any in-flight [_load] from resurrecting it; the next cold start
  /// mints a brand-new, unlinkable key.
  Future<void> erase() async {
    _userTouched = true;
    state = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(kActorKeyPrefsKey);
    } on Object catch (_) {
      // best-effort — the in-memory key is already severed.
    }
  }

  /// Mint a fresh RFC-4122-v4-shaped id from a cryptographic [Random.secure] (16
  /// bytes → hex, version/variant nibbles set) — 122 random bits, collision-safe.
  /// Hand-rolled because pubspec carries no `uuid` package.
  static String _mintKey() {
    final rnd = Random.secure();
    final b = List<int>.generate(16, (_) => rnd.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40; // version 4
    b[8] = (b[8] & 0x3f) | 0x80; // RFC-4122 variant
    final out = StringBuffer();
    for (var i = 0; i < 16; i++) {
      out.write(b[i].toRadixString(16).padLeft(2, '0'));
      if (i == 3 || i == 5 || i == 7 || i == 9) out.write('-');
    }
    return out.toString();
  }
}

/// The per-install anon actor key (null while deferred / erased). Read by
/// [actorKeyProvider] when signed-out, and by [ActorStitch] for the continuity
/// key at sign-in.
final anonActorKeyProvider =
    StateNotifierProvider<AnonActorKeyNotifier, String?>(
  (_) => AnonActorKeyNotifier(),
);

/// The stable, pseudonymous ACTOR KEY the bus stamps on every event (step 91):
/// the signed-in [currentUidProvider] uid when present, else the per-install anon
/// key. NULL only in the cold-start DEFER window (signed-out AND prefs not loaded)
/// — the bus stamps null rather than minting a volatile key. Recomputes on
/// sign-in / key-load; the bus READS it fresh per track (it never subscribes).
final actorKeyProvider = Provider<String?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid != null && uid.isNotEmpty) return uid;
  return ref.watch(anonActorKeyProvider);
});

/// The tiny anon→uid STITCH-WRITE port (§2). Persists the mapping so the erasure
/// sweep (§7 / step 99) can re-attach PRE-login events to the account. Speaks only
/// neutral `uid` + `anonKey` strings — NOT Firestore types — so this file stays
/// Firebase-free and ONLY intel_sink.dart's impl imports the Firestore SDK. A
/// failure THROWS (the [ActorStitch] caller swallows it — screen-safety).
// ignore: one_member_abstracts
abstract class ActorStitchWriter {
  /// Merge-write the mapping doc `actorStitch/{uid}` (accumulate [anonKey] into
  /// `anonKeys`, stamp `at`). Called ONLY behind the consent+backend gate.
  Future<void> writeStitch({required String uid, required String anonKey});
}

/// The inert stitch writer — writes NOTHING. This is what every off-backend /
/// pre-consent / demo / test build gets (the gate below yields it), so the
/// persistent stitch NEVER touches Firestore there (§3 / DoD).
class NoopActorStitchWriter implements ActorStitchWriter {
  /// Const so the gate can return it without allocating.
  const NoopActorStitchWriter();

  @override
  Future<void> writeStitch({
    required String uid,
    required String anonKey,
  }) async {}
}

/// The consent+backend DOUBLE-GATE for the persistent stitch write — the SAME
/// predicate the forward sink uses ([analyticsForwardEnabled], consent_gate.dart):
/// the live [FirestoreActorStitchWriter] ONLY when current-version consent AND the
/// live backend AND the kIntelLive master switch all hold. Off ANY axis (every
/// demo / test / off-backend build) it is the inert [NoopActorStitchWriter] — so
/// `actorStitch/{uid}` is NEVER written off-backend (§3). `ref.read` — no reactive
/// consumer (the stitch reads it once per sign-in).
final actorStitchWriterProvider = Provider<ActorStitchWriter>((ref) {
  final settings = ref.read(appSettingsProvider);
  if (!analyticsForwardEnabled(settings)) return const NoopActorStitchWriter();
  return const FirestoreActorStitchWriter();
});

/// The sign-in STITCH (step 91): on an anon→uid transition it (a) emits the
/// `identify` bridge event through the bus — carrying the OLD anon key as the
/// pseudonymous actorKey so the pre-login journey stays joinable — and (b)
/// persists the `actorStitch/{uid}` mapping through the consent+backend gate. The
/// uid travels ONLY as the event's top-level pseudonymous field + the doc id —
/// NEVER in a user-visible prop (R1-4 / manager_role_assign_sheet.dart:172).
class ActorStitch {
  /// Holds the [Ref] so the stitch can READ (never watch) the bus, the anon key,
  /// and the gated writer on demand.
  ActorStitch(this._ref);

  final Ref _ref;

  /// Fired by [actorStitchProvider]'s `ref.listen` on each [currentUidProvider]
  /// change. A stitch happens only when we GAIN a distinct uid (sign-in /
  /// account-switch): [next] non-null and different from [prev].
  void onUidChanged(String? prev, String? next) {
    if (next == null || next.isEmpty || next == prev) return;
    _stitch(next);
  }

  void _stitch(String uid) {
    // The OLD anon key — the pre-login continuity key. Read the anon notifier
    // DIRECTLY (actorKeyProvider already resolves to the new uid).
    final anonKey = _ref.read(anonActorKeyProvider);
    // DEFER (§4): if prefs have not resolved the per-install key yet, SKIP — never
    // mint a volatile key just to stitch (a wrong key is worse than a missed one).
    // In production the anon key loads at app-start, long before any sign-in.
    if (anonKey == null || anonKey.isEmpty || anonKey == uid) return;

    // (a) the identify bridge — via the bus. props stay EMPTY, so no uid ever
    // lands in a visible prop; the uid rides only the pseudonymous top-level field.
    _ref.read(intelBusProvider).identify(anonKey: anonKey, uid: uid);

    // (b) the persistent mapping — through the gate. Off-backend the writer is the
    // Noop (no Firestore); the write never throws back to here regardless.
    unawaited(_write(_ref.read(actorStitchWriterProvider), uid, anonKey));
  }

  Future<void> _write(
    ActorStitchWriter writer,
    String uid,
    String anonKey,
  ) async {
    try {
      await writer.writeStitch(uid: uid, anonKey: anonKey);
    } on Object catch (e) {
      // guardWrite discipline: a failed stitch write is swallowed, never crashes a
      // screen. No identity is interpolated — the uid never reaches a log (DoD).
      debugPrint('ActorStitch: stitch write failed (ignored): $e');
    }
  }
}

/// The sign-in stitch listener. DORMANT until a later step reads it — defining it
/// now keeps the stitch wiring in ONE place. When first read it subscribes
/// (READ-only, zero rebuild) to [currentUidProvider] and stitches each anon→uid
/// gain. `ref.listen` does not fire on subscribe (default), so a restored
/// (already-signed-in) session — which had no anon→uid crossing to bridge — is
/// never spuriously stitched.
final actorStitchProvider = Provider<ActorStitch>((ref) {
  final stitch = ActorStitch(ref);
  ref.listen<String?>(currentUidProvider, stitch.onUidChanged);
  return stitch;
});

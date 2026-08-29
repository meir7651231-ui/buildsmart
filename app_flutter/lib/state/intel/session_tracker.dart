// ─────────────────────────────────────────────────────────────────────────────
// session_tracker — Pillar-3 STUDIO · step 97 — the session LIFECYCLE + the app's
// ONE global app-lifecycle hook, an engineering clone of `ConnectionStatusNotifier`
// (connection_status.dart:73 — StateNotifier + WidgetsBindingObserver + the
// `if (!active) return;` inert idiom).
//
// TWO LAYERS, ONE OWNER:
//   (1) The ALWAYS-ON LOCAL session (like screen_view, step 92): a per-session
//       [sessionId] (a local RFC-4122-v4 uuid minted the actor_key.dart:117 way) is
//       published to [sessionIdProvider] — which the bus stamps on EVERY event
//       (intel_bus.dart `_context`, previously null) — and `session_start` /
//       `session_end` are emitted to the bus (LOCAL ring buffer). This runs on
//       every path (demo + backend); it touches NO Firestore.
//   (2) The PRESENCE heartbeat (presence.dart): started ONLY behind the
//       customer-only double-gate ([presenceForwardEnabled]); INERT off-backend /
//       non-customer / pre-consent — ZERO timer, ZERO Firestore there.
//
// session_end fires on background (`paused`/`hidden`/`detached`), on idle
// (`>= kIdleEnd`, a re-armed timer — inert off-backend, the `_AutoLogout` idiom),
// and on logout (uid → null); it is idempotent (one end per session) and DELETES
// the presence doc immediately. The [WidgetsBindingObserver] is added in the ctor
// and REMOVED in dispose (no leak) — the connection_status.dart discipline.
//
// The first emission is DEFERRED one microtask out of the (possible) widget build
// that constructed us (main.dart reads the provider read-only), so it never
// modifies `intelLog`/`sessionId` DURING a build.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:math' show Random;

import 'package:buildsmart/data/repositories/backend.dart'
    show useFirebaseBackend;
import 'package:buildsmart/logic/intel/intel_config.dart' show kIdleEnd;
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/auth_state.dart'
    show currentUidProvider, roleProvider;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/intel/actor_key.dart' show actorKeyProvider;
import 'package:buildsmart/state/intel/consent_gate.dart'
    show presenceForwardEnabled;
import 'package:buildsmart/state/intel/intel_bus.dart' show intelBusProvider;
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:buildsmart/state/intel/presence.dart';
import 'package:buildsmart/state/intel/screen_view.dart' show screenKeyForTab;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The phase the tracker exposes as state. Born [ended] (no session until the
/// deferred [SessionTracker._startSession] emits `session_start` + flips to
/// [active]); back to [ended] on the first background / idle / logout.
enum SessionPhase {
  /// A session is live (a `session_start` was emitted, no `session_end` yet).
  active,

  /// No live session (pre-start, or after a `session_end`).
  ended,
}

/// The CURRENT session id — null until the first session starts (the cold-start
/// DEFER window) and between an end and the next start. A plain [StateProvider] so
/// the bus can READ it in `_context` WITHOUT constructing the tracker (no circular
/// construction); the tracker WRITES it on each session start.
final sessionIdProvider = StateProvider<String?>((_) => null);

/// The session tracker — clones `ConnectionStatusNotifier`'s structure. Manages
/// the always-on LOCAL session on every path; the presence heartbeat inside it is
/// inert off-backend / non-customer (the double-gate). Constructed ONCE from the
/// app root (main.dart, read-only) so its lifecycle observer is registered.
class SessionTracker extends StateNotifier<SessionPhase>
    with WidgetsBindingObserver {
  /// [clock] is injected (deterministic tests); [bindLifecycle] adds the real
  /// [WidgetsBindingObserver] (false in a pure-Dart test that drives
  /// [didChangeAppLifecycleState] by hand); [armIdle] gates the idle timer —
  /// defaults to [useFirebaseBackend] so the demo/test suite arms NO idle timer
  /// (the `_AutoLogout` inert idiom / DoD "zero timer off-backend").
  SessionTracker(
    this._ref, {
    DateTime Function()? clock,
    bool bindLifecycle = true,
    bool? armIdle,
  })  : _clock = clock ?? DateTime.now,
        _bindLifecycle = bindLifecycle,
        _armIdle = armIdle ?? useFirebaseBackend,
        super(SessionPhase.ended) {
    if (_bindLifecycle) WidgetsBinding.instance.addObserver(this);
    // logout (uid → null) ends the session. `_ref.listen` (never watch) — the
    // connection_status.dart:89 idiom; `.close` is called again in dispose.
    _authRemove = _ref.listen<String?>(currentUidProvider, _onUid).close;
    // DEFER the first emission out of the widget build that (may have) constructed
    // us: modifying intelLog / sessionId DURING a build would assert. A microtask
    // runs right after the synchronous build completes.
    scheduleMicrotask(() {
      if (mounted) _startSession();
    });
  }

  final Ref _ref;
  final DateTime Function() _clock;
  final bool _bindLifecycle;
  final bool _armIdle;

  String? _sessionId;
  DateTime? _startedAt;
  Timer? _idleTimer;
  VoidCallback? _authRemove;
  Presence? _presence;

  /// @visibleForTesting — the current local session id (null before start / after
  /// end), mirrored into [sessionIdProvider].
  @visibleForTesting
  String? get sessionId => _sessionId;

  void _startSession() {
    if (state == SessionPhase.active) return; // already live — no double-start
    _sessionId = _mintSessionId();
    _startedAt = _clock();
    _ref.read(sessionIdProvider.notifier).state = _sessionId;
    state = SessionPhase.active;
    final role = _ref.read(roleProvider);
    _ref.read(intelBusProvider).track(
      IntelEvents.sessionStart,
      // `actor_kind` is the only allowed prop (intel_events.dart:71); null role =
      // the main-app customer. No PII.
      props: <String, String>{'actor_kind': role ?? 'customer'},
    );
    _armIdleTimer();
    _maybeStartPresence();
  }

  void _endSession(String reason) {
    if (state != SessionPhase.active) return; // idempotent — one end per session
    final startedAt = _startedAt;
    final durS = startedAt == null ? 0 : _clock().difference(startedAt).inSeconds;
    _ref.read(intelBusProvider).track(
      IntelEvents.sessionEnd,
      // allowed props (intel_events.dart:73): `reason` + `dur_s`. Scalars, no PII.
      props: <String, String>{'reason': reason, 'dur_s': '$durS'},
    );
    state = SessionPhase.ended;
    _idleTimer?.cancel();
    _idleTimer = null;
    // session_end DELETES the presence doc immediately (never rely on TTL alone).
    final presence = _presence;
    _presence = null;
    unawaited(presence?.stop());
  }

  /// (Re)arm the single idle-countdown timer (the `_AutoLogout` main.dart:295
  /// idiom): inert off-backend (no timer), else `session_end('idle')` after
  /// [kIdleEnd] of silence.
  void _armIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = null;
    if (!_armIdle) return; // inert off-backend — zero timer (DoD)
    _idleTimer = Timer(kIdleEnd, () => _endSession('idle'));
  }

  /// Public activity signal — resets the idle countdown. Kept public so the app
  /// CAN feed real input (a `resumed` lifecycle already counts as activity).
  void onActivity() {
    if (state == SessionPhase.active) _armIdleTimer();
  }

  void _maybeStartPresence() {
    final settings = _ref.read(appSettingsProvider);
    final role = _ref.read(roleProvider);
    // The presence DOUBLE-GATE (customer-only). Off-backend / non-customer /
    // pre-consent this returns BEFORE reading actorKey/writer — INERT: no heartbeat
    // timer, no Firestore, no SharedPreferences touch on the demo path.
    if (!presenceForwardEnabled(settings, role)) return;
    final actorKey = _ref.read(actorKeyProvider);
    if (actorKey == null || actorKey.isEmpty) return; // cold-start defer window
    _presence = Presence(
      _ref.read(presenceWriterProvider),
      actorKey: actorKey,
      uid: _ref.read(currentUidProvider),
      screenOf: () => screenKeyForTab(_ref.read(mainTabProvider)),
    )..start();
  }

  @override
  // The base param is named `state`, which would shadow [StateNotifier.state]
  // (read in the body) — deliberately renamed.
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    switch (lifecycle) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _endSession('background');
      case AppLifecycleState.resumed:
        // Return-to-foreground: a fresh session if the last one ended, else just
        // count it as activity (reset the idle countdown).
        if (state == SessionPhase.ended) {
          _startSession();
        } else {
          onActivity();
        }
      case AppLifecycleState.inactive:
        break; // transient (a system dialog / app-switcher peek) — ignore
    }
  }

  void _onUid(String? prev, String? next) {
    // sign-OUT: had a uid, now none → end the live session.
    if ((prev != null && prev.isNotEmpty) && (next == null || next.isEmpty)) {
      _endSession('logout');
    }
  }

  /// Mint a fresh RFC-4122-v4-shaped id from a cryptographic [Random.secure] — the
  /// actor_key.dart:117 approach (pubspec carries no `uuid` package), reused per
  /// session so a local session is uniquely joinable without any PII.
  static String _mintSessionId() {
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

  @override
  void dispose() {
    if (_bindLifecycle) WidgetsBinding.instance.removeObserver(this);
    _idleTimer?.cancel();
    _idleTimer = null;
    _authRemove?.call();
    _authRemove = null;
    // Best-effort: delete the presence doc on teardown too (no leaked "online").
    unawaited(_presence?.stop());
    _presence = null;
    super.dispose();
  }
}

/// The session tracker provider — constructed ONCE from the app root (main.dart,
/// read-only) so its app-lifecycle observer is registered + the always-on LOCAL
/// session runs. Reads (never watches) its dependencies. The presence heartbeat
/// inside it is inert off-backend / non-customer (the double-gate), so the demo/
/// test build opens no timer + touches no Firestore.
final sessionTrackerProvider =
    StateNotifierProvider<SessionTracker, SessionPhase>(SessionTracker.new);

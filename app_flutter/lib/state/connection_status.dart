// ─────────────────────────────────────────────────────────────────────────────
// connection_status — the ALWAYS-ON live "are we talking to the server?" truth
// behind the top-of-screen connection pill (widgets/connection_indicator.dart).
//
// WHY THIS EXISTS: the launch-diagnostic BackendDebugBadge is debug-only and
// one-shot. Users need an HONEST, always-visible signal of whether their actions
// will actually persist — 🟢 מחובר לשרת / 🔴 מנותק (פעולות לא יישמרו) — that
// RECOMPUTES live (not a one-time check) and flips within ~2s of wifi off.
//
// THE COMBINE (most-decisive-first; each later clause only refines the prior):
//   1. !useFirebaseBackend          → demo          // no server at all — honest
//   2. !networkOnline               → disconnected  // wifi off (the ~2s DoD)
//   3. !signedIn                    → disconnected  // can't persist (no uid)
//   4. firestoreCacheOnly           → disconnected  // network up, server unreachable
//   5. else                         → connected
//
// SIGNALS:
//   • networkOnline   — connectivity_plus: seeded with checkConnectivity(), then
//                       kept live by onConnectivityChanged. THE fast signal — it
//                       is what makes "wifi off → 🔴 within ~2s" hold. (6.x emits
//                       a List<ConnectivityResult>; offline == empty list OR
//                       only ConnectivityResult.none.)
//   • signedIn / uid  — read from authStateProvider (Riverpod) via ref.listen.
//   • firestoreCacheOnly — diag/{uid}.snapshots(includeMetadataChanges:true) →
//                       snap.metadata.isFromCache. Self-only doc (S5 rules allow
//                       read self). We LISTEN, never write — the BackendDebugBadge
//                       owns the write. Defaults FALSE (assume live until proven
//                       cache-only) so there is NO startup 🔴 flicker.
//
// HARD RULES (mirroring auth_state.dart / firestore_cached_repo.dart):
//   1. On the DEMO / Firebase-free path (!useFirebaseBackend) this opens NO
//      listeners — neither connectivity nor Firestore. It is INERT (state stays
//      `demo`, zero cost), so the whole Firebase-free test suite + the no-config
//      sandbox build the app without ever touching a platform channel.
//   2. Nothing here may THROW into the app: every Firestore/connectivity touch is
//      guarded; a hiccup downgrades the pill, it never crashes a screen.
//   3. `FirebaseFirestore.instance` is read ONLY inside the guarded listener
//      (resolved lazily, on demand) — same discipline as FirestoreCollectionSource.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The three honest states the connection pill renders.
enum ConnectionStatus {
  /// Network up, signed in, and Firestore is serving live (not cache-only) — or
  /// at least not proven cache-only. Actions persist. 🟢 מחובר לשרת.
  connected,

  /// Wifi off, OR signed-out (can't persist), OR Firestore is serving only its
  /// offline cache (server unreachable). 🔴 מנותק · פעולות לא יישמרו.
  disconnected,

  /// No live backend at all (the demo build / Firebase-free run). There is no
  /// server to be (dis)connected from — showing 🟢 would be a lie, so this is a
  /// neutral "מצב דמו". Inert: opens no listeners.
  demo,
}

/// The notifier that fuses the three signals and RECOMPUTES on every change.
///
/// Constructed on the DEMO path (`!useFirebaseBackend`) it is born `demo` and
/// stays there forever — no connectivity subscription, no Firestore listener,
/// no `ref.listen`. That keeps it inert in tests / Firebase-free runs (HARD
/// RULE #1). On the live backend it wires connectivity + auth + a per-uid
/// Firestore metadata probe, all guarded (HARD RULE #2/#3).
class ConnectionStatusNotifier extends StateNotifier<ConnectionStatus> {
  ConnectionStatusNotifier(this._ref)
      : _active = useFirebaseBackend,
        super(
          // Born honest: demo when there is no server; otherwise OPTIMISTIC
          // `connected` (network defaults online, firestore defaults live) so a
          // signed-in cold start does not flash 🔴 before the first signals land.
          useFirebaseBackend ? ConnectionStatus.connected : ConnectionStatus.demo,
        ) {
    if (!_active) return; // DEMO: inert — no listeners, no Firebase touched.

    // Auth: seed + keep `signedIn`/`uid` live. Re-binds the Firestore probe when
    // the uid changes (sign-in / sign-out / account switch).
    final auth = _ref.read(authStateProvider);
    _signedIn = auth.signedIn;
    _uid = auth.user?.uid;
    _authRemove = _ref.listen<AuthSnapshot>(
      authStateProvider,
      (prev, next) {
        final prevUid = prev?.user?.uid;
        _signedIn = next.signedIn;
        _uid = next.user?.uid;
        if (next.user?.uid != prevUid) _bindFirestoreProbe();
        _recompute();
      },
    ).close;

    // Connectivity: seed asynchronously, then subscribe. Guarded — a platform
    // failure leaves `networkOnline` at its optimistic default (true) rather
    // than throwing or faking offline.
    _seedConnectivity();
    try {
      _connSub = Connectivity().onConnectivityChanged.listen(
        _onConnectivity,
        onError: (Object e, StackTrace _) =>
            debugPrint('ConnectionStatus: connectivity stream error: $e'),
      );
    } on Object catch (e) {
      debugPrint('ConnectionStatus: connectivity subscribe failed: $e');
    }

    _bindFirestoreProbe();
    _recompute();
  }

  final Ref _ref;

  /// True only on the live backend — the master gate for opening any listener.
  final bool _active;

  /// Live signals (optimistic defaults so a cold start reads `connected`, not a
  /// false 🔴 flicker, until the real values arrive).
  bool _networkOnline = true;
  bool _signedIn = false;
  String? _uid;
  bool _firestoreCacheOnly = false;

  VoidCallback? _authRemove;
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _fsSub;

  /// connectivity_plus 6.x: OFFLINE == the list is empty OR contains only
  /// `ConnectivityResult.none`. Any other entry (wifi/mobile/ethernet/vpn/…)
  /// counts as a live transport.
  static bool _resultsOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  Future<void> _seedConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (!mounted) return;
      _networkOnline = _resultsOnline(results);
      _recompute();
    } on Object catch (e) {
      debugPrint('ConnectionStatus: checkConnectivity failed (assume online): $e');
    }
  }

  void _onConnectivity(List<ConnectivityResult> results) {
    _networkOnline = _resultsOnline(results);
    _recompute();
  }

  /// (Re)open the diag/{uid} metadata probe. Only on the live backend + with a
  /// uid. Cancels any prior listener first (uid changed / signed out). Fully
  /// guarded: a Firestore hiccup leaves `firestoreCacheOnly` at its last value
  /// and never throws.
  void _bindFirestoreProbe() {
    _fsSub?.cancel();
    _fsSub = null;
    final uid = _uid;
    if (!_active || uid == null) {
      // No probe possible — reset to the optimistic default so a later sign-in
      // does not inherit a stale cache-only verdict.
      _firestoreCacheOnly = false;
      return;
    }
    try {
      _fsSub = FirebaseFirestore.instance
          .collection('diag')
          .doc(uid)
          .snapshots(includeMetadataChanges: true)
          .listen(
        (snap) {
          _firestoreCacheOnly = snap.metadata.isFromCache;
          _recompute();
        },
        onError: (Object e, StackTrace _) {
          // A listen error (permission/network) must not downgrade-by-throw;
          // leave the verdict as-is and log.
          debugPrint('ConnectionStatus: diag listen error: $e');
        },
      );
    } on Object catch (e) {
      debugPrint('ConnectionStatus: diag probe bind failed: $e');
    }
  }

  /// THE COMBINE (see the header) — most-decisive clause first.
  void _recompute() {
    if (!mounted) return;
    final ConnectionStatus next;
    if (!_active) {
      next = ConnectionStatus.demo;
    } else if (!_networkOnline) {
      next = ConnectionStatus.disconnected;
    } else if (!_signedIn) {
      next = ConnectionStatus.disconnected;
    } else if (_firestoreCacheOnly) {
      next = ConnectionStatus.disconnected;
    } else {
      next = ConnectionStatus.connected;
    }
    if (next != state) state = next;
  }

  @override
  void dispose() {
    _authRemove?.call();
    _authRemove = null;
    _connSub?.cancel();
    _connSub = null;
    _fsSub?.cancel();
    _fsSub = null;
    super.dispose();
  }
}

/// The live connection status every always-on pill reads. On the DEMO /
/// Firebase-free path (tests + the no-config sandbox) the notifier is inert and
/// this is a constant `demo` — zero regression, no platform channel touched.
final connectionStatusProvider =
    StateNotifierProvider<ConnectionStatusNotifier, ConnectionStatus>((ref) {
  return ConnectionStatusNotifier(ref);
});

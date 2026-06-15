// SERVER-SWAP (SPEC-A4-A6 §server-swap, SW5) — unit coverage for the
// Firebase-Auth identity source of the role boards. Two halves:
//
//   1. the PURE helper [boardSessionFromAuthSnapshot] — derives a board
//      identity (uid + role-claim) from an [AuthSnapshot], tested directly
//      with NO container and NO compile-time flag;
//   2. the GATED binding in [BoardAuthNotifier] — with `bindFirebase: true`
//      (the constructor seam that makes the ON path testable without a
//      `--dart-define`), the board session MIRRORS the live Firebase identity:
//      sign-in with a board role-claim → a session carrying the real uid;
//      sign-out → null. The uid it carries IS `currentUidProvider` (the
//      invariant that makes the A4-A6 order-claim scope to the same identity).
//
// NO Firebase / no new packages: the auth seam is the SAME hand-rolled
// [AuthGateway] fake the S1 suite uses (auth_state_test.dart). The flag-OFF
// (seed) path stays covered by board_auth_test.dart — this file is the ON path.

import 'dart:async';

import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A hand-rolled fake [AuthGateway] — a manually-driven auth stream + the
/// claims a signed-in user resolves with. Every other flow method is an inert
/// stub (this suite only drives sign-in / sign-out + claims).
class _FakeAuthGateway implements AuthGateway {
  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? current;
  Map<String, dynamic> claims = const {};

  /// Sign a user in "from outside" with the given role claims.
  void signInAs(AuthUser user, {Map<String, dynamic> withClaims = const {}}) {
    claims = withClaims;
    current = user;
    _controller.add(user);
  }

  /// Emit a raw event (used to sign out: `emit(null)`).
  void emit(AuthUser? user) {
    current = user;
    if (user == null) claims = const {};
    _controller.add(user);
  }

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield current; // seam contract: current state on subscribe
    yield* _controller.stream;
  }

  @override
  AuthUser? get currentUser => current;

  @override
  Future<Map<String, dynamic>> idTokenClaims({bool forceRefresh = false}) async =>
      claims;

  @override
  Future<String> sendOtp(String phone) async => 'vid';
  @override
  Future<void> signInWithSmsCode(String verificationId, String smsCode) async {}
  @override
  Future<void> signInWithEmailPassword(String email, String password) async {}
  @override
  Future<void> createUserWithEmailPassword(
      String email, String password) async {}
  @override
  Future<void> signOut() async => emit(null);
  @override
  Future<void> deleteAccount() async => emit(null);
  @override
  Future<void> setRole({required String uid, required String role}) async {}

  @override
  Future<void> resetPassword(String email) async {}

  Future<void> close() => _controller.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ───────────────────────────────────────────────────────────────────────
  // 1. PURE helper — no container, no flag.
  // ───────────────────────────────────────────────────────────────────────
  group('boardSessionFromAuthSnapshot — pure derivation (SW2)', () {
    test('signed-out (no user) → null (מבחוץ לא רואים כלום)', () {
      expect(boardSessionFromAuthSnapshot(const AuthSnapshot()), isNull);
      // A roles list with no user is still null — identity needs a uid.
      expect(
        boardSessionFromAuthSnapshot(const AuthSnapshot(roles: ['store'])),
        isNull,
      );
    });

    test('a store role-claim → store session carrying the uid', () {
      final s = boardSessionFromAuthSnapshot(
        const AuthSnapshot(
          user: AuthUser(uid: 'u-store-1', displayName: 'ליפסקי'),
          roles: ['store'],
        ),
      );
      expect(s, isNotNull);
      expect(s!.role, BoardRole.store);
      expect(s.uid, 'u-store-1');
      expect(s.username, 'u-store-1'); // username carries the uid on this path
      expect(s.displayName, 'ליפסקי'); // the account's name when it has one
      expect(s.demo, isFalse); // a real Firebase identity is never a demo
    });

    test('each board role-claim maps to its BoardRole', () {
      for (final entry in {
        'worker': BoardRole.worker,
        'courier': BoardRole.courier,
        'store': BoardRole.store,
        'manager': BoardRole.manager,
      }.entries) {
        final s = boardSessionFromAuthSnapshot(
          AuthSnapshot(
            user: const AuthUser(uid: 'u'),
            roles: [entry.key],
          ),
        );
        expect(s?.role, entry.value, reason: '${entry.key} → ${entry.value}');
      }
    });

    test('contractor-only claim → null (the contractor is NOT a board)', () {
      expect(
        boardSessionFromAuthSnapshot(
          const AuthSnapshot(
            user: AuthUser(uid: 'u-c'),
            roles: ['contractor'],
          ),
        ),
        isNull,
      );
    });

    test('multi-role [contractor, store] → the first BOARD role (store)', () {
      final s = boardSessionFromAuthSnapshot(
        const AuthSnapshot(
          user: AuthUser(uid: 'u-multi'),
          roles: ['contractor', 'store'],
        ),
      );
      expect(s?.role, BoardRole.store);
      expect(s?.uid, 'u-multi');
    });

    test('no displayName → falls back to the role title', () {
      final s = boardSessionFromAuthSnapshot(
        const AuthSnapshot(
          user: AuthUser(uid: 'u-courier'), // no displayName
          roles: ['courier'],
        ),
      );
      expect(s?.displayName, kBoardDemoNames[BoardRole.courier]); // 'שליח'
    });

    test('empty claims (still resolving) → null', () {
      expect(
        boardSessionFromAuthSnapshot(
          const AuthSnapshot(user: AuthUser(uid: 'u')),
        ),
        isNull,
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────
  // 2. GATED binding — bindFirebase:true mirrors the live Firebase identity.
  // ───────────────────────────────────────────────────────────────────────
  group('BoardAuthNotifier(bindFirebase: true) — live Firebase mirror (SW3)',
      () {
    /// A container whose board auth is FORCED onto the server-swap path
    /// (bindFirebase:true) over a fake gateway. authStateProvider is read
    /// eagerly so the gateway subscription is live before we sign anyone in.
    ({ProviderContainer c, _FakeAuthGateway gw}) bound() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final gw = _FakeAuthGateway();
      final c = ProviderContainer(
        overrides: [
          authGatewayProvider.overrideWithValue(gw),
          boardAuthProvider.overrideWith(
            (ref) => BoardAuthNotifier(ref, bindFirebase: true),
          ),
        ],
      );
      addTearDown(c.dispose);
      addTearDown(gw.close);
      c
        ..read(authStateProvider) // eager — subscribe the stream
        ..read(boardAuthProvider); // eager — bind the mirror (fireImmediately)
      return (c: c, gw: gw);
    }

    test('starts signed-out → no board session (gate shut)', () async {
      final h = bound();
      await pumpEventQueue();
      expect(h.c.read(boardAuthProvider), isNull);
    });

    test('sign-in with a store role-claim → store board session w/ the uid',
        () async {
      final h = bound();
      h.gw.signInAs(
        const AuthUser(uid: 'u-store-9', displayName: 'חנות ספק'),
        withClaims: const {'role': 'store'},
      );
      await pumpEventQueue();

      final s = h.c.read(boardAuthProvider);
      expect(s, isNotNull, reason: 'a signed-in board user must open the board');
      expect(s!.role, BoardRole.store);
      expect(s.uid, 'u-store-9');
    });

    test('INVARIANT: the board session uid == currentUidProvider', () async {
      final h = bound();
      h.gw.signInAs(
        const AuthUser(uid: 'u-courier-7'),
        withClaims: const {'role': 'courier'},
      );
      await pumpEventQueue();

      expect(h.c.read(boardAuthProvider)?.uid, 'u-courier-7');
      // The SAME uid the A4-A6 order claim (sys_orders) stamps — the two
      // identity systems are now one.
      expect(h.c.read(boardAuthProvider)?.uid, h.c.read(currentUidProvider));
    });

    test('a contractor-only claim opens NO board (contractor = main app)',
        () async {
      final h = bound();
      h.gw.signInAs(
        const AuthUser(uid: 'u-con'),
        withClaims: const {'role': 'contractor'},
      );
      await pumpEventQueue();
      expect(h.c.read(boardAuthProvider), isNull);
    });

    test('sign-OUT clears the board session (back to the gate)', () async {
      final h = bound();
      h.gw.signInAs(
        const AuthUser(uid: 'u-mgr'),
        withClaims: const {'role': 'manager'},
      );
      await pumpEventQueue();
      expect(h.c.read(boardAuthProvider)?.role, BoardRole.manager);

      h.gw.emit(null); // signed out
      await pumpEventQueue();
      expect(h.c.read(boardAuthProvider), isNull);
    });
  });
}

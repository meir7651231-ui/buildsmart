// S1 AUTHENTICATION — unit coverage for auth_state: the AuthGateway seam, the
// providers (authState / role / roleSwitchLocked), role-from-claims parsing,
// the `_loaded`/generation guard, and the S1.7/S1.8 wipes.
//
// NO Firebase here: the auth seam ([AuthGateway]) is driven by a HAND-ROLLED
// fake ([_FakeAuthGateway]) — no firebase_auth_mocks, no new packages (the
// firestore_cached_repo_test.dart pattern). The fake records every call and
// lets a test emit auth-stream events + control claim resolution timing, so
// the whole pipeline (event → claims fetch → snapshot → role) is asserted
// deterministically.
//
// Pins (the S1 contract):
//   • without a gateway (Firebase-free) the app behaves EXACTLY as today:
//     signed-out, born `loaded`, role = the client persona pick;
//   • `_loaded` flips only once the first auth event FULLY resolves;
//   • a SLOW claims fetch can never resurrect a signed-out user (gen guard);
//   • single claim role → persona = identity (client pick ignored, picker
//     locked); multi-role / no-claims → today's picker behavior;
//   • logout/deletion clear the local identity (profile + persona + prefs);
//   • a FAILED deletion (requires-recent-login) wipes NOTHING.

import 'dart:async';

import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A hand-rolled fake [AuthGateway]: a manually-driven auth stream + an
/// in-memory record of every flow call, with failure/timing knobs.
class _FakeAuthGateway implements AuthGateway {
  final _controller = StreamController<AuthUser?>.broadcast();

  AuthUser? current;

  /// The claims [idTokenClaims] resolves with for the signed-in user.
  Map<String, dynamic> claims = const {};

  /// When non-null, [idTokenClaims] waits on it — the stale-guard tests.
  Completer<void>? claimsHold;

  /// When non-null, the next [sendOtp] throws this code.
  String? failSendCode;

  /// When true, [deleteAccount] throws `requires-recent-login`.
  bool failDelete = false;

  String nextVerificationId = 'vid-1';

  /// When non-null, the next [createUserWithEmailPassword] throws this code —
  /// the honest-error tests (`email-already-in-use` / `weak-password` /
  /// `invalid-email`).
  String? failCreateCode;

  final List<String> otpPhones = [];
  final List<String> smsConfirms = [];
  final List<String> emailLogins = [];
  final List<String> emailCreations = [];
  final List<({String uid, String role})> setRoleCalls = [];
  int signOutCalls = 0;
  int deleteCalls = 0;

  /// Emit one auth-stream event (and keep [currentUser] consistent).
  void emit(AuthUser? user) {
    current = user;
    _controller.add(user);
  }

  /// Sign a user in "from outside" (restored session / auto-verification).
  void signInAs(AuthUser user, {Map<String, dynamic> withClaims = const {}}) {
    claims = withClaims;
    emit(user);
  }

  @override
  Stream<AuthUser?> authStateChanges() async* {
    // The seam CONTRACT (FirebaseAuth semantics): current state on subscribe.
    yield current;
    yield* _controller.stream;
  }

  @override
  AuthUser? get currentUser => current;

  @override
  Future<String> sendOtp(String phone) async {
    final code = failSendCode;
    if (code != null) {
      failSendCode = null;
      throw AuthGatewayException(code);
    }
    otpPhones.add(phone);
    return nextVerificationId;
  }

  @override
  Future<void> signInWithSmsCode(String verificationId, String smsCode) async {
    if (smsCode != '123456') {
      throw const AuthGatewayException('invalid-verification-code');
    }
    smsConfirms.add('$verificationId:$smsCode');
    emit(const AuthUser(uid: 'u-phone', phone: '+972501234567'));
  }

  @override
  Future<void> signInWithEmailPassword(String email, String password) async {
    if (password != 'secret') {
      throw const AuthGatewayException('wrong-password');
    }
    emailLogins.add(email);
    emit(AuthUser(uid: 'u-mail', email: email));
  }

  @override
  Future<void> createUserWithEmailPassword(String email, String password) async {
    final code = failCreateCode;
    if (code != null) {
      failCreateCode = null;
      throw AuthGatewayException(code);
    }
    emailCreations.add(email);
    // A real createUser signs the NEW user in (same as FirebaseAuth) — lands
    // on the stream so the welcome flow / login sheet enters the app.
    emit(AuthUser(uid: 'u-new', email: email));
  }

  @override
  Future<Map<String, dynamic>> idTokenClaims({bool forceRefresh = false}) async {
    final hold = claimsHold;
    if (hold != null) await hold.future;
    return claims;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    emit(null);
  }

  @override
  Future<void> deleteAccount() async {
    if (failDelete) throw const AuthGatewayException('requires-recent-login');
    deleteCalls++;
    emit(null);
  }

  @override
  Future<void> setRole({required String uid, required String role}) async {
    setRoleCalls.add((uid: uid, role: role));
  }

  @override
  Future<void> resetPassword(String email) async {}

  Future<void> close() => _controller.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// A container whose auth gateway is [gateway] (null = Firebase-free run).
  /// The real authStateProvider wiring (incl. the identity-wipe hook into
  /// userProfileProvider / activePersonaProvider) is exercised as-is. The auth
  /// provider is created EAGERLY (like the app, where the profile screen
  /// watches it) so its stream subscription is live before tests emit.
  ProviderContainer makeContainer(_FakeAuthGateway? gateway) {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final c = ProviderContainer(
      overrides: [authGatewayProvider.overrideWithValue(gateway)],
    );
    addTearDown(c.dispose);
    if (gateway != null) addTearDown(gateway.close);
    c.read(authStateProvider);
    return c;
  }

  group('rolesFromClaims — S1.5 claim parsing', () {
    test('null / empty / role-less claims → no roles', () {
      expect(rolesFromClaims(null), isEmpty);
      expect(rolesFromClaims(const {}), isEmpty);
      expect(rolesFromClaims(const {'iss': 'firebase'}), isEmpty);
    });

    test('a single `role` string claim → that role', () {
      expect(rolesFromClaims(const {'role': 'store'}), ['store']);
    });

    test('an unknown `role` value is filtered (never locks the UI)', () {
      expect(rolesFromClaims(const {'role': 'admin'}), isEmpty);
    });

    test('a `roles` LIST claim wins over a single `role`', () {
      expect(
        rolesFromClaims(const {
          'roles': ['store', 'courier'],
          'role': 'manager',
        }),
        ['store', 'courier'],
      );
    });

    test('`roles` filters unknown/non-string entries and de-dups', () {
      expect(
        rolesFromClaims(const {
          'roles': ['store', 'admin', 7, 'store', 'worker'],
        }),
        ['store', 'worker'],
      );
    });

    test('an all-unknown `roles` list falls back to the single `role`', () {
      expect(
        rolesFromClaims(const {
          'roles': ['admin'],
          'role': 'manager',
        }),
        ['manager'],
      );
    });
  });

  group('without Firebase (gateway = null) — zero regression', () {
    test('born loaded + signed-out (nothing to wait for)', () {
      final c = makeContainer(null);
      final snap = c.read(authStateProvider);
      expect(snap.loaded, isTrue);
      expect(snap.user, isNull);
      expect(snap.roles, isEmpty);
      expect(c.read(roleSwitchLockedProvider), isFalse);
    });

    test('roleProvider mirrors the client persona pick byte-for-byte', () {
      final c = makeContainer(null);
      expect(c.read(roleProvider), isNull); // null = contractor, as today
      c.read(activePersonaProvider.notifier).state = 'store';
      expect(c.read(roleProvider), 'store');
      c.read(activePersonaProvider.notifier).state = null;
      expect(c.read(roleProvider), isNull);
    });

    test('flow methods throw the neutral `unavailable` (Hebrew-toasted)', () {
      final c = makeContainer(null);
      final notifier = c.read(authStateProvider.notifier);
      expect(
        () => notifier.sendOtp('+972501234567'),
        throwsA(
          isA<AuthGatewayException>()
              .having((e) => e.code, 'code', 'unavailable'),
        ),
      );
      expect(
        () => notifier.assignRole(uid: 'u1', role: 'store'),
        throwsA(
          isA<AuthGatewayException>()
              .having((e) => e.code, 'code', 'unavailable'),
        ),
      );
    });
  });

  group('_loaded guard — S1.4', () {
    test('with a gateway: not loaded until the first auth event', () async {
      final gw = _FakeAuthGateway();
      final c = makeContainer(gw);
      expect(c.read(authStateProvider).loaded, isFalse);

      gw.emit(null); // signed-out is a fully-resolved first event
      await pumpEventQueue();
      final snap = c.read(authStateProvider);
      expect(snap.loaded, isTrue);
      expect(snap.user, isNull);
    });

    test('signed-in event: user lands immediately, loaded only after claims',
        () async {
      final gw = _FakeAuthGateway()
        ..claims = const {'role': 'store'}
        ..claimsHold = Completer<void>();
      final c = makeContainer(gw);

      gw.emit(const AuthUser(uid: 'u1', phone: '+972501234567'));
      await pumpEventQueue();
      var snap = c.read(authStateProvider);
      expect(snap.user?.uid, 'u1', reason: 'the user must not wait on claims');
      expect(snap.loaded, isFalse, reason: 'claims still in flight');
      expect(snap.roles, isEmpty);

      gw.claimsHold!.complete();
      await pumpEventQueue();
      snap = c.read(authStateProvider);
      expect(snap.loaded, isTrue);
      expect(snap.roles, ['store']);
    });

    test('a SLOW claims fetch cannot resurrect a signed-out user (gen guard)',
        () async {
      final gw = _FakeAuthGateway()
        ..claims = const {'role': 'store'}
        ..claimsHold = Completer<void>();
      final c = makeContainer(gw);

      gw.emit(const AuthUser(uid: 'u1'));
      await pumpEventQueue();
      // Sign out BEFORE the claims for u1 resolve.
      await c.read(authStateProvider.notifier).signOut();
      await pumpEventQueue();
      // Now the stale claims arrive — they must be dropped.
      gw.claimsHold!.complete();
      await pumpEventQueue();

      final snap = c.read(authStateProvider);
      expect(snap.user, isNull, reason: 'stale claims must not resurrect');
      expect(snap.roles, isEmpty);
      expect(snap.loaded, isTrue);
    });
  });

  group('login flows — S1.1/S1.2/S1.3', () {
    test('sendOtp resolves with the verificationId (S1.1)', () async {
      final gw = _FakeAuthGateway()..nextVerificationId = 'vid-42';
      final c = makeContainer(gw);
      final vid =
          await c.read(authStateProvider.notifier).sendOtp('+972501234567');
      expect(vid, 'vid-42');
      expect(gw.otpPhones, ['+972501234567']);
    });

    test('signInWithSmsCode signs in via the auth stream (S1.2)', () async {
      final gw = _FakeAuthGateway()..claims = const {'role': 'store'};
      final c = makeContainer(gw);
      await c
          .read(authStateProvider.notifier)
          .signInWithSmsCode('vid-1', '123456');
      await pumpEventQueue();

      final snap = c.read(authStateProvider);
      expect(gw.smsConfirms, ['vid-1:123456']);
      expect(snap.user?.uid, 'u-phone');
      expect(snap.user?.phone, '+972501234567');
      expect(snap.roles, ['store']);
      expect(snap.loaded, isTrue);
    });

    test('a wrong code throws the neutral code and signs nobody in', () async {
      final gw = _FakeAuthGateway();
      final c = makeContainer(gw);
      await expectLater(
        c.read(authStateProvider.notifier).signInWithSmsCode('vid-1', '000000'),
        throwsA(
          isA<AuthGatewayException>()
              .having((e) => e.code, 'code', 'invalid-verification-code'),
        ),
      );
      await pumpEventQueue();
      expect(c.read(authStateProvider).user, isNull);
    });

    test('email+password fallback signs in (S1.3)', () async {
      final gw = _FakeAuthGateway();
      final c = makeContainer(gw);
      await c
          .read(authStateProvider.notifier)
          .signInWithEmailPassword('a@b.co', 'secret');
      await pumpEventQueue();
      expect(gw.emailLogins, ['a@b.co']);
      expect(c.read(authStateProvider).user?.email, 'a@b.co');
    });
  });

  group('createUser — server-gate-auth (REAL account, not local-register)', () {
    test('createUserWithEmailPassword mints + signs in a NEW user', () async {
      final gw = _FakeAuthGateway();
      final c = makeContainer(gw);
      await c
          .read(authStateProvider.notifier)
          .createUserWithEmailPassword('new@b.co', 'hunter2');
      await pumpEventQueue();
      expect(gw.emailCreations, ['new@b.co'],
          reason: 'a real createUser call reached the gateway');
      final snap = c.read(authStateProvider);
      expect(snap.user?.uid, 'u-new', reason: 'the new account is signed in');
      expect(snap.user?.email, 'new@b.co');
      expect(snap.signedIn, isTrue);
    });

    // The three honest error mappings: the neutral codes the seam surfaces,
    // which login_sheet's hebrewAuthError turns into honest Hebrew.
    test('email-already-in-use surfaces verbatim (→ "כבר רשום" Hebrew)',
        () async {
      final gw = _FakeAuthGateway()..failCreateCode = 'email-already-in-use';
      final c = makeContainer(gw);
      await expectLater(
        c
            .read(authStateProvider.notifier)
            .createUserWithEmailPassword('dup@b.co', 'hunter2'),
        throwsA(
          isA<AuthGatewayException>()
              .having((e) => e.code, 'code', 'email-already-in-use'),
        ),
      );
      await pumpEventQueue();
      expect(c.read(authStateProvider).user, isNull,
          reason: 'a failed create signs nobody in');
      expect(gw.emailCreations, isEmpty);
    });

    test('weak-password surfaces verbatim (→ "סיסמה חלשה" Hebrew)', () async {
      final gw = _FakeAuthGateway()..failCreateCode = 'weak-password';
      final c = makeContainer(gw);
      await expectLater(
        c
            .read(authStateProvider.notifier)
            .createUserWithEmailPassword('w@b.co', '123'),
        throwsA(
          isA<AuthGatewayException>()
              .having((e) => e.code, 'code', 'weak-password'),
        ),
      );
    });

    test('invalid-email surfaces verbatim', () async {
      final gw = _FakeAuthGateway()..failCreateCode = 'invalid-email';
      final c = makeContainer(gw);
      await expectLater(
        c
            .read(authStateProvider.notifier)
            .createUserWithEmailPassword('not-an-email', 'hunter2'),
        throwsA(
          isA<AuthGatewayException>()
              .having((e) => e.code, 'code', 'invalid-email'),
        ),
      );
    });

    test('without a gateway (Firebase-free): throws the neutral `unavailable`',
        () {
      final c = makeContainer(null);
      expect(
        () => c
            .read(authStateProvider.notifier)
            .createUserWithEmailPassword('a@b.co', 'hunter2'),
        throwsA(
          isA<AuthGatewayException>()
              .having((e) => e.code, 'code', 'unavailable'),
        ),
      );
    });
  });

  group('role from claims — S1.5/S1.6 (persona = identity)', () {
    test('ONE claim role beats the client pick and locks the switcher',
        () async {
      final gw = _FakeAuthGateway();
      final c = makeContainer(gw);
      // The user "picked" courier client-side — the server says store-only.
      c.read(activePersonaProvider.notifier).state = 'courier';
      gw.signInAs(
        const AuthUser(uid: 'u-store'),
        withClaims: const {'role': 'store'},
      );
      await pumpEventQueue();

      expect(c.read(roleProvider), 'store', reason: 'server identity wins');
      expect(c.read(roleSwitchLockedProvider), isTrue);
    });

    test('a single contractor role speaks the persona dialect (null)',
        () async {
      final gw = _FakeAuthGateway();
      final c = makeContainer(gw);
      gw.signInAs(
        const AuthUser(uid: 'u-con'),
        withClaims: const {'role': 'contractor'},
      );
      await pumpEventQueue();
      expect(c.read(roleProvider), isNull); // null = contractor / main app
      expect(c.read(roleSwitchLockedProvider), isTrue);
    });

    test('multi-role keeps today’s picker behavior', () async {
      final gw = _FakeAuthGateway();
      final c = makeContainer(gw);
      gw.signInAs(
        const AuthUser(uid: 'u-multi'),
        withClaims: const {
          'roles': ['store', 'courier'],
        },
      );
      await pumpEventQueue();

      expect(c.read(authStateProvider).roles, ['store', 'courier']);
      expect(c.read(roleSwitchLockedProvider), isFalse);
      expect(c.read(roleProvider), isNull); // falls back to the client pick
      c.read(activePersonaProvider.notifier).state = 'courier';
      expect(c.read(roleProvider), 'courier');
    });

    test('a signed-in user WITHOUT role claims keeps the picker too',
        () async {
      final gw = _FakeAuthGateway();
      final c = makeContainer(gw);
      gw.signInAs(const AuthUser(uid: 'u-none'));
      await pumpEventQueue();
      expect(c.read(roleSwitchLockedProvider), isFalse);
      expect(c.read(roleProvider), isNull);
    });
  });

  group('currentUidProvider — A2 (launch uid seam)', () {
    test('Firebase-free / signed-out → null (zero regression)', () {
      final c = makeContainer(null);
      expect(c.read(currentUidProvider), isNull);
    });

    test('signed-in → the auth uid, and tracks sign-out back to null',
        () async {
      final gw = _FakeAuthGateway();
      final c = makeContainer(gw);
      expect(c.read(currentUidProvider), isNull, reason: 'starts signed-out');
      gw.signInAs(const AuthUser(uid: 'u-42'));
      await pumpEventQueue();
      expect(c.read(currentUidProvider), 'u-42');
      await c.read(authStateProvider.notifier).signOut();
      await pumpEventQueue();
      expect(c.read(currentUidProvider), isNull,
          reason: 'sign-out clears the seam');
    });
  });

  group('logout — S1.7 (sign-out + cache clear)', () {
    test('signs out remotely AND wipes the local identity', () async {
      final gw = _FakeAuthGateway();
      final c = makeContainer(gw);
      // A registered local profile + a picked persona + a signed-in user.
      c
          .read(userProfileProvider.notifier)
          .register(name: 'מאיר', contact: '050-1234567');
      c.read(activePersonaProvider.notifier).state = 'store';
      gw.signInAs(
        const AuthUser(uid: 'u1'),
        withClaims: const {'role': 'store'},
      );
      await pumpEventQueue();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kUserProfileKey), isNotNull);

      await c.read(authStateProvider.notifier).signOut();
      await pumpEventQueue();

      expect(gw.signOutCalls, 1);
      final snap = c.read(authStateProvider);
      expect(snap.user, isNull);
      expect(snap.roles, isEmpty);
      expect(snap.loaded, isTrue);
      // The identity-coupled local state is gone (S1.7 ניקוי-cache).
      expect(c.read(userProfileProvider).registered, isFalse);
      expect(c.read(userProfileProvider).name, isEmpty);
      expect(c.read(activePersonaProvider), isNull);
      expect(prefs.getString(kUserProfileKey), isNull);
    });
  });

  group('account deletion — S1.8 (Apple requirement)', () {
    test('delete calls the gateway and wipes the local user data', () async {
      final gw = _FakeAuthGateway();
      final c = makeContainer(gw);
      c
          .read(userProfileProvider.notifier)
          .register(name: 'מאיר', contact: '050-1234567');
      gw.signInAs(const AuthUser(uid: 'u1'));
      await pumpEventQueue();

      await c.read(authStateProvider.notifier).deleteAccount();
      await pumpEventQueue();

      expect(gw.deleteCalls, 1);
      expect(c.read(authStateProvider).user, isNull);
      expect(c.read(userProfileProvider).name, isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kUserProfileKey), isNull);
    });

    test('a FAILED delete (requires-recent-login) wipes NOTHING', () async {
      final gw = _FakeAuthGateway()..failDelete = true;
      final c = makeContainer(gw);
      c
          .read(userProfileProvider.notifier)
          .register(name: 'מאיר', contact: '050-1234567');
      gw.signInAs(const AuthUser(uid: 'u1'));
      await pumpEventQueue();

      await expectLater(
        c.read(authStateProvider.notifier).deleteAccount(),
        throwsA(
          isA<AuthGatewayException>()
              .having((e) => e.code, 'code', 'requires-recent-login'),
        ),
      );
      await pumpEventQueue();

      // Account still exists → the user and their local data must too.
      expect(c.read(authStateProvider).user?.uid, 'u1');
      expect(c.read(userProfileProvider).name, 'מאיר');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kUserProfileKey), isNotNull);
    });
  });

  group('setRole call-site — S1.9', () {
    test('assignRole forwards {uid, role} to the callable seam', () async {
      final gw = _FakeAuthGateway();
      final c = makeContainer(gw);
      await c
          .read(authStateProvider.notifier)
          .assignRole(uid: 'u-target', role: 'courier');
      expect(gw.setRoleCalls, [(uid: 'u-target', role: 'courier')]);
    });
  });
}

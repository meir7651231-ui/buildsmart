// U1.4.3 — AuthStateNotifier.reloadRole: a role (re)assigned server-side applies
// on a forced claims refresh, WITHOUT a re-login. Firebase-free (a minimal fake
// AuthGateway drives the claims), mirroring auth_state_test.dart's seam pattern.

import 'dart:async';

import 'package:buildsmart/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A minimal [AuthGateway] fake: a manually-driven stream + a settable claims
/// map. Only the members reloadRole touches are implemented; the rest route to
/// noSuchMethod (never called here).
class _RoleFake implements AuthGateway {
  AuthUser? current;
  Map<String, dynamic> claims = const <String, dynamic>{};
  final StreamController<AuthUser?> _c = StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield current;
    yield* _c.stream;
  }

  @override
  AuthUser? get currentUser => current;

  @override
  Future<Map<String, dynamic>> idTokenClaims({bool forceRefresh = false}) async =>
      claims;

  void signIn(AuthUser user, {Map<String, dynamic> withClaims = const {}}) {
    claims = withClaims;
    current = user;
    _c.add(user);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();

  Future<void> close() => _c.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer container(_RoleFake gw) {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final c = ProviderContainer(
      overrides: [authGatewayProvider.overrideWithValue(gw)],
    );
    addTearDown(c.dispose);
    addTearDown(gw.close);
    c.read(authStateProvider); // eager — subscribe the stream before events
    return c;
  }

  test('reloadRole applies a server-assigned role without a re-login', () async {
    final gw = _RoleFake();
    final c = container(gw);

    // Signed in with NO role claim yet.
    gw.signIn(const AuthUser(uid: 'u1', email: 'x@y.co'));
    await pumpEventQueue();
    expect(c.read(authStateProvider).roles, isEmpty);

    // An admin assigns 'store' server-side → the claim changes; refresh it in.
    gw.claims = const {'role': 'store'};
    await c.read(authStateProvider.notifier).reloadRole();

    expect(c.read(authStateProvider).roles, ['store']);
    expect(c.read(authStateProvider).singleRole, isTrue);
  });

  test('reloadRole is a no-op when signed-out', () async {
    final gw = _RoleFake();
    final c = container(gw);
    await pumpEventQueue();

    await c.read(authStateProvider.notifier).reloadRole();

    expect(c.read(authStateProvider).signedIn, isFalse);
    expect(c.read(authStateProvider).roles, isEmpty);
  });
  // A role refresh must not drop the worker→employer link: the refreshed
  // snapshot used to omit employerId, so one tap on the role chip un-scoped the
  // worker's board session (employerId '') and their HR writes.
  test('reloadRole keeps the employerId claim', () async {
    final gw = _RoleFake();
    final c = container(gw);

    gw.signIn(
      const AuthUser(uid: 'w1', email: 'w@y.co'),
      withClaims: const {'role': 'worker', 'employerId': 'contractor-9'},
    );
    await pumpEventQueue();
    expect(c.read(authStateProvider).employerId, 'contractor-9');

    await c.read(authStateProvider.notifier).reloadRole();

    expect(c.read(authStateProvider).roles, ['worker']);
    expect(c.read(authStateProvider).employerId, 'contractor-9',
        reason: 'a forced claims refresh re-reads the employer link');
  });

  test('reloadRole picks up an employer assigned server-side', () async {
    final gw = _RoleFake();
    final c = container(gw);

    gw.signIn(const AuthUser(uid: 'w2', email: 'w2@y.co'),
        withClaims: const {'role': 'worker'});
    await pumpEventQueue();
    expect(c.read(authStateProvider).employerId, isNull);

    gw.claims = const {'role': 'worker', 'employerId': 'contractor-7'};
    await c.read(authStateProvider.notifier).reloadRole();

    expect(c.read(authStateProvider).employerId, 'contractor-7');
  });

  test('reloadRole clears an employer link revoked server-side', () async {
    final gw = _RoleFake();
    final c = container(gw);

    gw.signIn(const AuthUser(uid: 'w3', email: 'w3@y.co'),
        withClaims: const {'role': 'worker', 'employerId': 'contractor-1'});
    await pumpEventQueue();

    gw.claims = const {'role': 'worker'};
    await c.read(authStateProvider.notifier).reloadRole();

    expect(c.read(authStateProvider).employerId, isNull,
        reason: 'the refresh mirrors the server claims, both ways');
  });
}

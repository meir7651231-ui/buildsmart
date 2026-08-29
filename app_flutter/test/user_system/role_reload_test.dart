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
}

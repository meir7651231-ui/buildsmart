// GO-LIVE — guest anonymous auth for the server catalog (the pure decision).
//
// Proves: sign a guest in ONLY when there is no user; never replace a real session.

import 'package:buildsmart/state/server_catalog_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('signs in anonymously when there is NO user yet', () async {
    var calls = 0;
    await ensureAnonAuthForServerCatalog(
      hasUser: false,
      signInAnon: () async => calls++,
    );
    expect(calls, 1);
  });

  test('is a NO-OP when a user is already signed in (never clobbers a login)',
      () async {
    var calls = 0;
    await ensureAnonAuthForServerCatalog(
      hasUser: true,
      signInAnon: () async => calls++,
    );
    expect(calls, 0);
  });
}

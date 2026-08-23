// U0.5 — the byte-identity / zero-regression invariant for the OFF build.
//
// `flutter test` never forwards --dart-define to library consts (see
// feature_flags.dart), so [kUserSystem] is FALSE here — exactly the shipped
// default. This pins the OFF contract behaviorally (the established task-#45
// flag-OFF assertion pattern): with the flag off the users layer routes to the
// in-memory [LocalUsersRepository] and NEVER touches Firestore, and the signed-in
// user is null — so the whole user-system surface is inert and the build is
// byte-identical to today.

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/users_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('kUserSystem is OFF by default (the shipped build)', () {
    expect(kUserSystem, isFalse);
  });

  test('OFF path: usersRepository is the in-memory Local impl (no Firestore)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final repo = container.read(usersRepositoryProvider);
    expect(repo, isA<LocalUsersRepository>());
    expect(container.read(currentUserProvider), isNull);
  });
}

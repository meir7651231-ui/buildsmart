// U1 — the RBAC providers: bsRoleProvider's signed-out default and the
// pending-approval gate over the U0 currentUserProvider. Firebase-free.

import 'package:buildsmart/data/bs_user.dart';
import 'package:buildsmart/data/repositories/users_repository.dart';
import 'package:buildsmart/state/rbac.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bsRoleProvider defaults to contractor (signed-out / Firebase-free)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // No Firebase → auth gateway null → signed-out → guest → contractor.
    expect(container.read(bsRoleProvider), BsRole.contractor);
  });

  group('pendingApprovalProvider', () {
    test('true when the signed-in user is pending', () {
      final container = ProviderContainer(overrides: [
        currentUserProvider.overrideWithValue(
          const BsUser(uid: 'u1'), // status defaults to pending
        ),
      ]);
      addTearDown(container.dispose);
      expect(container.read(pendingApprovalProvider), isTrue);
    });

    test('false when the user is active', () {
      final container = ProviderContainer(overrides: [
        currentUserProvider.overrideWithValue(
          const BsUser(uid: 'u1', status: UserStatus.active),
        ),
      ]);
      addTearDown(container.dispose);
      expect(container.read(pendingApprovalProvider), isFalse);
    });

    test('false when there is no user record (guest / kUserSystem OFF)', () {
      final container = ProviderContainer(overrides: [
        currentUserProvider.overrideWithValue(null),
      ]);
      addTearDown(container.dispose);
      expect(container.read(pendingApprovalProvider), isFalse);
    });
  });
}

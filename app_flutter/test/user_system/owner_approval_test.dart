// Pins `withOwnerApproval` (users_repository) — the owner (verified email) is
// never trapped behind a `pending` users-doc status (the 2026-07-19 bootstrap set
// the admin claim/role but not the status; the pending gate blocks EVERY action
// even for an admin, so the superuser was locked out live). Scoped to the owner
// email — no other account is touched. Firebase-free, pure.
import 'package:buildsmart/data/board_accounts_local.dart' show kOwnerEmails;
import 'package:buildsmart/data/bs_user.dart';
import 'package:buildsmart/data/repositories/users_repository.dart'
    show withOwnerApproval;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('withOwnerApproval — owner is never trapped as pending', () {
    final owner = kOwnerEmails.first;

    test('owner + pending → active (the bootstrap-gap fix)', () {
      final u = BsUser(uid: 'o1', email: owner, status: UserStatus.pending);
      expect(withOwnerApproval(u)!.status, UserStatus.active);
    });

    test('owner + already active → unchanged', () {
      final u = BsUser(uid: 'o1', email: owner, status: UserStatus.active);
      expect(withOwnerApproval(u)!.status, UserStatus.active);
    });

    test('non-owner + pending → stays pending (scoped to the owner)', () {
      const u = BsUser(
        uid: 'u1',
        email: 'someone@else.com',
        status: UserStatus.pending,
      );
      expect(withOwnerApproval(u)!.status, UserStatus.pending);
    });

    test('null user → null (guest / no record)', () {
      expect(withOwnerApproval(null), isNull);
    });
  });
}

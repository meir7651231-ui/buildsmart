// Nobody waits in a queue that cannot see them.
//
// THE TRAP THIS CLOSES — one I created earlier the same day. Making the approval
// gate airtight (`_UserDocSync`, main.dart) meant everyone who signs in is held
// at `pending`. But the reviewer's inbox reads `roleRequests`, and that document
// was written by exactly one screen: the welcome-screen registration button.
//
// So a person arriving through the login sheet — phone code, or the new Google
// button — was held AND invisible: blocked from acting, and absent from the only
// list anyone reviews. Before the fix they walked past the gate; after it they
// were stuck behind it forever. A leak traded for a lockout.
//
// The queueing now happens SERVER-side (`onUserCreatedQueueApproval`, in
// functions/src/reviewRoleRequest.ts) on the creation of `users/{uid}`. That
// placement is the substance of the fix, so these tests pin the rules it must
// obey — expressed as the pure decision, because a Firestore trigger cannot run
// in this suite:
//
//   • fires only for a record that is actually waiting;
//   • never overwrites a decision that already exists;
//   • covers doors that do not exist yet — anything that creates a user record
//     enrols the person, with no per-door wiring to remember.

import 'package:buildsmart/data/bs_user.dart';
import 'package:buildsmart/state/rbac.dart';
import 'package:buildsmart/state/role_requests.dart'
    show approvableRolesForClaims;
import 'package:flutter_test/flutter_test.dart';

/// Mirrors `onUserCreatedQueueApproval`: given the freshly-created user record's
/// status and whether a request already exists, should a request be written?
bool shouldQueue({
  required String? status,
  required bool requestAlreadyExists,
}) {
  if (status != 'pending') return false;
  if (requestAlreadyExists) return false;
  return true;
}

void main() {
  group('who gets queued for approval', () {
    test('THE FIX: a sign-in-created pending account is queued', () {
      // The case that was invisible: no registration form, so no request — the
      // trigger is what puts them in front of the reviewer.
      expect(
        shouldQueue(status: 'pending', requestAlreadyExists: false),
        isTrue,
      );
    });

    test('a registration that already filed its own request is left alone', () {
      // The welcome screen still writes its own request with the role the person
      // actually asked for; overwriting it would flatten that to 'contractor'.
      expect(
        shouldQueue(status: 'pending', requestAlreadyExists: true),
        isFalse,
      );
    });

    test('⚠️ an APPROVED person is never re-queued', () {
      // Their request doc exists carrying the decision. Rewriting it would drop
      // them back into the queue and, worse, back into review.
      expect(
        shouldQueue(status: 'active', requestAlreadyExists: true),
        isFalse,
      );
    });

    test('an admin-seeded active record needs no approval', () {
      expect(
        shouldQueue(status: 'active', requestAlreadyExists: false),
        isFalse,
      );
    });

    test('a suspended account is not quietly re-queued for reinstatement', () {
      expect(
        shouldQueue(status: 'suspended', requestAlreadyExists: false),
        isFalse,
      );
    });

    test('an unknown status is treated as not-waiting', () {
      expect(shouldQueue(status: null, requestAlreadyExists: false), isFalse);
    });
  });

  group('the two halves have to agree', () {
    // The gate holds on `pending`; the queue shows `pending`. If those two ever
    // disagree the result is someone stuck with nobody able to see them, which
    // is exactly the state this file exists to prevent.
    test('every status the gate BLOCKS is either queued or already decided', () {
      for (final status in [UserStatus.pending, UserStatus.suspended]) {
        final blocked = !permitAction(
          role: BsRole.contractor,
          perm: Permission.placeOrder,
          status: status,
        );
        expect(blocked, isTrue, reason: 'precondition: $status is held');
      }
      // pending → queued (when no decision exists yet)
      expect(shouldQueue(status: 'pending', requestAlreadyExists: false), isTrue);
      // suspended → NOT queued, and that is correct: a suspension is a decision
      // already taken, not a person waiting to be seen.
      expect(
        shouldQueue(status: 'suspended', requestAlreadyExists: false),
        isFalse,
      );
    });

    test('a status the gate lets through is never queued', () {
      expect(
        permitAction(
          role: BsRole.contractor,
          perm: Permission.placeOrder,
          status: UserStatus.active,
        ),
        isTrue,
      );
      expect(
        shouldQueue(status: 'active', requestAlreadyExists: false),
        isFalse,
      );
    });
  });

  group('who can review what — unchanged by moving the button', () {
    // The inbox entry moved to the manager dashboard, but the OTHER approver
    // tiers do not have that dashboard: a store owner signs off couriers, a
    // contractor signs off workers. Their profile link has to stay, and this is
    // the check that says why.
    test('a store owner approves couriers', () {
      expect(approvableRolesForClaims(const ['store']), contains('courier'));
    });

    test('a contractor approves workers', () {
      expect(approvableRolesForClaims(const ['contractor']), contains('worker'));
    });

    test('a manager approves stores and contractors', () {
      final can = approvableRolesForClaims(const ['manager']);
      expect(can, containsAll(<String>['store', 'contractor']));
    });

    test('admin approves everything', () {
      expect(approvableRolesForClaims(const ['admin']), isNotEmpty);
    });

    test('a plain user approves nothing — no inbox for them', () {
      expect(approvableRolesForClaims(const []), isEmpty);
    });
  });
}

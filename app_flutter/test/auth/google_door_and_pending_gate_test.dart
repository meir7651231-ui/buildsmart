// The second door, and the gate it must not walk past.
//
// TWO FINDINGS, one commit, because the first makes the second dangerous.
//
// 1. GOOGLE WAS OWNER-ONLY. `signInWithGoogle` existed, but every entry point to
//    it was `_managerGoogleLogin` — gated on an owner-email allowlist. A normal
//    person had no Google button anywhere. With email+password closed that left
//    exactly one way in: an SMS, which costs money per send and depends on a
//    carrier region policy that has already blocked this project once.
//
// 2. THE APPROVAL GATE LEAKED. Registration is all-by-approval, enforced by
//    `permitAction` — which blocks on `status == pending`. A user with NO
//    `users/{uid}` document has no status at all, so the check falls through to
//    the role's permissions, and `bsRoleFrom` gives a signed-in user with no
//    server role the default contractor role. "No document" therefore meant
//    APPROVED, not "waiting".
//
//    And the document was created in exactly one place: the welcome screen's
//    registration button. Anyone signing in through the login sheet instead got
//    a real identity, no document, and walked past the gate — live, today,
//    before any Google button existed.
//
// Wiring Google without fixing (2) would have added a second leaking door. So
// the fix is a listener on auth state (`_UserDocSync`, main.dart) that ensures
// the record on EVERY real sign-in: there is no door left to forget.

import 'package:buildsmart/data/board_accounts_local.dart' show kOwnerEmails;
import 'package:buildsmart/data/bs_user.dart';
import 'package:buildsmart/data/repositories/users_repository.dart';
import 'package:buildsmart/state/rbac.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:buildsmart/state/user_system_sync.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('THE LEAK: a signed-in user with no document', () {
    test('is NOT held by the approval gate — the bug, stated plainly', () {
      // No users/{uid} document ⇒ status is null ⇒ nothing to be pending about.
      expect(
        permitAction(
          role: BsRole.contractor,
          perm: Permission.placeOrder,
          status: null,
        ),
        isTrue,
        reason: 'this is why the document has to exist for every sign-in',
      );
    });

    test('while the SAME user WITH a pending document is held', () {
      expect(
        permitAction(
          role: BsRole.contractor,
          perm: Permission.placeOrder,
          status: UserStatus.pending,
        ),
        isFalse,
      );
    });

    test('a pending user can still browse the catalog', () {
      // The gate is a hold, not a wall — the point is that they cannot ACT.
      expect(
        permitAction(
          role: BsRole.contractor,
          perm: Permission.viewCatalog,
          status: UserStatus.pending,
        ),
        isTrue,
      );
    });
  });

  group('the fix: any sign-in creates the pending record', () {
    late LocalUsersRepository repo;
    late UserSystemSync sync;
    final now = DateTime(2026, 7, 19, 10);

    setUp(() {
      repo = LocalUsersRepository(currentUid: 'u1');
      sync = UserSystemSync(repo);
    });

    test('a first-time sign-in is born pending', () async {
      await sync.onRegisteredLogin(
        uid: 'u1',
        profile: const UserProfile(name: 'מאיר', contact: '0501234567'),
        isAnonymous: false,
        now: now,
      );
      expect(repo.byUid('u1')?.status, UserStatus.pending);
    });

    test('and is then held by the gate — the two halves joined', () async {
      await sync.onRegisteredLogin(
        uid: 'u1',
        profile: const UserProfile(name: 'מאיר', contact: '0501234567'),
        isAnonymous: false,
        now: now,
      );
      expect(
        permitAction(
          role: BsRole.contractor,
          perm: Permission.placeOrder,
          status: repo.byUid('u1')?.status,
        ),
        isFalse,
        reason: 'the whole point of ensuring the record on every door',
      );
    });

    test('⚠️ an APPROVED user is never demoted by signing in again', () async {
      // The listener fires on every sign-in, so this must be safe to repeat —
      // otherwise the fix would knock people back to pending on each login.
      repo.upsertUser(
        BsUser(uid: 'u1', status: UserStatus.active, createdAt: now),
      );
      await sync.onRegisteredLogin(
        uid: 'u1',
        profile: const UserProfile(name: 'מאיר', contact: '0501234567'),
        isAnonymous: false,
        now: now.add(const Duration(days: 3)),
      );
      expect(repo.byUid('u1')?.status, UserStatus.active);
    });

    test('a suspended user is not silently reinstated either', () async {
      repo.upsertUser(
        BsUser(uid: 'u1', status: UserStatus.suspended, createdAt: now),
      );
      await sync.onRegisteredLogin(
        uid: 'u1',
        profile: const UserProfile(name: 'מאיר', contact: '0501234567'),
        isAnonymous: false,
        now: now.add(const Duration(days: 1)),
      );
      expect(repo.byUid('u1')?.status, UserStatus.suspended);
    });

    test('an anonymous guest is never written to users', () async {
      // A catalog browser is not a user record — writing one would put every
      // visitor in the approval queue.
      await sync.onRegisteredLogin(
        uid: 'anon-1',
        profile: const UserProfile(),
        isAnonymous: true,
        now: now,
      );
      expect(repo.byUid('anon-1'), isNull);
    });

    test('an empty uid writes nothing', () async {
      await sync.onRegisteredLogin(
        uid: '',
        profile: const UserProfile(),
        isAnonymous: false,
        now: now,
      );
      expect(repo.currentUser(), isNull);
    });
  });

  group('Google identity carries no privilege of its own', () {
    // The owner path grants admin from an email allowlist. The NEW button must
    // not: it proves who you are, and nothing more — approval is still the
    // owner's to give.
    test('a Google account outside the allowlist is a plain contractor', () {
      expect(
        bsRoleFrom(
          signedIn: true,
          email: 'someone@gmail.com',
          serverRoles: const [],
        ),
        BsRole.contractor,
      );
    });

    test('and is held pending exactly like a phone sign-up', () {
      expect(
        permitAction(
          role: BsRole.contractor,
          perm: Permission.placeOrder,
          status: UserStatus.pending,
        ),
        isFalse,
      );
    });

    test('the owner email still resolves to admin — unchanged', () {
      // Guard against closing the door on the person who has to open it.
      expect(
        bsRoleFrom(
          signedIn: true,
          email: kOwnerEmails.first,
          serverRoles: const [],
        ),
        BsRole.admin,
      );
    });
  });
}

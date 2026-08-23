// U0.3 — the login → users/{uid} synchroniser: ensure-on-register (pending),
// lastSeen refresh, guests skipped, and no self-downgrade. Zero backend.

import 'package:buildsmart/data/bs_user.dart';
import 'package:buildsmart/data/repositories/users_repository.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:buildsmart/state/user_system_sync.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildLoginSeed maps the profile to a pending, timestamped BsUser', () {
    const p = UserProfile(name: 'משה', contact: '0501234567');
    final now = DateTime.fromMillisecondsSinceEpoch(1710000000000);
    final seed = buildLoginSeed(uid: 'u1', profile: p, now: now);
    expect(seed.uid, 'u1');
    expect(seed.name, 'משה');
    expect(seed.phone, '0501234567');
    expect(seed.status, UserStatus.pending);
    expect(seed.createdAt, now);
    expect(seed.lastSeen, now);
  });

  group('onRegisteredLogin', () {
    test('a registered login creates a pending record + sets lastSeen', () async {
      final repo = LocalUsersRepository(currentUid: 'u1');
      final sync = UserSystemSync(repo);
      final now = DateTime.fromMillisecondsSinceEpoch(1710000000000);

      await sync.onRegisteredLogin(
        uid: 'u1',
        profile: const UserProfile(name: 'משה', contact: '0501234567'),
        isAnonymous: false,
        now: now,
      );

      final u = repo.currentUser()!;
      expect(u.status, UserStatus.pending);
      expect(u.name, 'משה');
      expect(u.lastSeen, now);
    });

    test('an anonymous guest is NEVER written to users', () async {
      final repo = LocalUsersRepository(currentUid: 'guest');
      final sync = UserSystemSync(repo);

      await sync.onRegisteredLogin(
        uid: 'guest',
        profile: const UserProfile(),
        isAnonymous: true,
        now: DateTime.fromMillisecondsSinceEpoch(1),
      );

      expect(repo.byUid('guest'), isNull);
    });

    test('an empty uid is skipped', () async {
      final repo = LocalUsersRepository();
      final sync = UserSystemSync(repo);
      await sync.onRegisteredLogin(
        uid: '',
        profile: const UserProfile(name: 'x', contact: '0501234567'),
        isAnonymous: false,
        now: DateTime.fromMillisecondsSinceEpoch(1),
      );
      expect(repo.byUid(''), isNull);
    });

    test('a re-login preserves a server-assigned status/role, advances lastSeen',
        () async {
      // Simulate the server already having approved + roled this user.
      final repo = LocalUsersRepository(currentUid: 'u1')
        ..upsertUser(BsUser(
          uid: 'u1',
          name: 'משה',
          role: 'store',
          status: UserStatus.active,
          lastSeen: DateTime.fromMillisecondsSinceEpoch(1),
        ));
      final sync = UserSystemSync(repo);
      final later = DateTime.fromMillisecondsSinceEpoch(1710000000000);

      await sync.onRegisteredLogin(
        uid: 'u1',
        profile: const UserProfile(name: 'משה', contact: '0501234567'),
        isAnonymous: false,
        now: later,
      );

      final u = repo.currentUser()!;
      expect(u.status, UserStatus.active); // NOT downgraded to pending
      expect(u.role, 'store');
      expect(u.lastSeen, later); // but lastSeen moved
    });
  });
}

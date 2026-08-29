// Approval has to reach the person who is waiting.
//
// THE FAILURE THIS FIXES: registration is all-by-approval, so a new account is
// born `pending` and most of the app is locked. Activation was then completely
// silent from the user's side — nothing was sent, AND the app never noticed:
// `currentUserProvider` was a plain Provider over the repository INSTANCE, so
// it recomputed on login/logout and never on a change to the user's own
// document. The value was decided at sign-in and cached from then on.
//
// So an approved person kept looking at "החשבון שלך ממתין לאישור" with the app
// still locked, believed it, and had no reason to try again. Only a full
// restart caught up.
//
// Three things now carry the news, deliberately overlapping because each one
// alone has a hole:
//   • the live provider — the banner disappears and the app unlocks by itself;
//   • an in-app toast on the pending → active edge — needs no permission;
//   • a push (`onUserActivated`, functions/src/push.ts) — reaches someone whose
//     app is closed, but ONLY if notifications were allowed. The live site is
//     regularly opened in a browser that denied them, which is exactly why the
//     in-app half is not redundant.

import 'package:buildsmart/data/bs_user.dart';
import 'package:buildsmart/data/repositories/users_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A users repository that is a [ChangeNotifier] — the shape the live Firestore
/// one has, so the subscription under test is the real one.
class _LiveRepo extends ChangeNotifier implements UsersRepository {
  _LiveRepo(this._user);

  BsUser? _user;

  /// Stand in for a server snapshot arriving.
  void push(BsUser? next) {
    _user = next;
    notifyListeners();
  }

  @override
  BsUser? currentUser() => _user;

  @override
  BsUser? byUid(String uid) => _user?.uid == uid ? _user : null;

  @override
  void upsertUser(BsUser user) => push(user);

  @override
  Future<void> ensureUser(BsUser seed) async {}

  @override
  void touchLastSeen(String uid, DateTime at) {}
}

/// The Firebase-free repository: NOT a notifier. Pins that the local path is
/// untouched by the subscription.
class _PlainRepo implements UsersRepository {
  _PlainRepo(this.user);

  BsUser? user;

  @override
  BsUser? currentUser() => user;

  @override
  BsUser? byUid(String uid) => user?.uid == uid ? user : null;

  @override
  void upsertUser(BsUser u) => user = u;

  @override
  Future<void> ensureUser(BsUser seed) async {}

  @override
  void touchLastSeen(String uid, DateTime at) {}
}

const _waiting = BsUser(uid: 'u1');
const _approved = BsUser(uid: 'u1', status: UserStatus.active);

void main() {
  group('the app notices approval without being restarted', () {
    test('THE BUG: a status change on the server reaches currentUserProvider',
        () async {
      final repo = _LiveRepo(_waiting);
      final container = ProviderContainer(
        overrides: [usersRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      // Something must be listening for a Provider to stay subscribed — the
      // same thing the banner does.
      final seen = <UserStatus?>[];
      container.listen<BsUser?>(
        currentUserProvider,
        (_, next) => seen.add(next?.status),
        fireImmediately: true,
      );
      expect(seen, [UserStatus.pending]);

      // The admin approves; the server document flips.
      repo.push(_approved);

      // The new value is available at once…
      expect(container.read(currentUserProvider)?.status, UserStatus.active,
          reason: 'without the subscription this stayed pending forever');

      // …and dependents are notified on the next tick, which is Riverpod's
      // normal batching — in the app that is one frame, so the banner drops and
      // the screen unlocks on its own.
      await Future<void>.delayed(Duration.zero);
      expect(seen, [UserStatus.pending, UserStatus.active]);
    });

    test('suspension is seen just as live as approval', () {
      // The same seam in the other direction — an account pulled back must not
      // keep working until the next restart.
      final repo = _LiveRepo(_approved);
      final container = ProviderContainer(
        overrides: [usersRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen<BsUser?>(currentUserProvider, (_, __) {},
          fireImmediately: true);

      repo.push(const BsUser(uid: 'u1', status: UserStatus.suspended));
      expect(container.read(currentUserProvider)?.status, UserStatus.suspended);
    });

    test('sign-out still propagates', () {
      final repo = _LiveRepo(_approved);
      final container = ProviderContainer(
        overrides: [usersRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen<BsUser?>(currentUserProvider, (_, __) {},
          fireImmediately: true);

      repo.push(null);
      expect(container.read(currentUserProvider), isNull);
    });

    test('the Firebase-free repository is untouched — zero regression', () {
      // It is not a ChangeNotifier, so nothing is subscribed and the read path
      // is exactly what it was before.
      final container = ProviderContainer(
        overrides: [
          usersRepositoryProvider.overrideWithValue(_PlainRepo(_waiting)),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(currentUserProvider)?.status, UserStatus.pending);
    });

    test('no listener leaks when the container is disposed', () {
      final repo = _LiveRepo(_waiting);
      final container = ProviderContainer(
        overrides: [usersRepositoryProvider.overrideWithValue(repo)],
      );
      container.listen<BsUser?>(currentUserProvider, (_, __) {},
          fireImmediately: true);
      expect(repo.hasListeners, isTrue);

      container.dispose();
      expect(repo.hasListeners, isFalse,
          reason: 'a leaked listener would call invalidateSelf on a dead '
              'container on every later snapshot');
    });
  });

  group('the announcement fires on the EDGE, not the state', () {
    // Mirrors the banner's `ref.listen` body. A person who was already active
    // when the app opened must not be congratulated for nothing, and the toast
    // must not repeat on every rebuild.
    bool announces(bool? wasPending, bool isPending) =>
        (wasPending ?? false) && !isPending;

    test('waiting → approved announces', () {
      expect(announces(true, false), isTrue);
    });

    test('already approved at launch says nothing', () {
      // `previous` is null on the first build.
      expect(announces(null, false), isFalse);
    });

    test('still waiting says nothing', () {
      expect(announces(true, true), isFalse);
    });

    test('approved → approved does not repeat', () {
      expect(announces(false, false), isFalse);
    });

    test('being put back on hold is not an approval', () {
      expect(announces(false, true), isFalse);
    });
  });
}

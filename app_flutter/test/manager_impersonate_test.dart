// שלב 3 — the manager "access all screens" impersonation engine
// (board_auth.impersonate / returnFromImpersonation):
//   • a manager swaps the session to a role's SEED account (worker→ran, carrying
//     its real employerId) and back, with isImpersonating tracking the state;
//   • impersonate is a NO-OP unless the current session is a manager;
//   • a store impersonation carries no employer link (a store has none).
import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('manager impersonates a worker (seed ran) and returns', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(boardAuthProvider.notifier);

    expect(n.login(BoardRole.manager, 'admin', '5555'), isTrue);
    expect(c.read(boardAuthProvider)?.role, BoardRole.manager);
    expect(n.isImpersonating, isFalse);

    n.impersonate(BoardRole.worker);
    final s = c.read(boardAuthProvider);
    expect(s?.role, BoardRole.worker);
    expect(s?.username, 'ran', reason: 'the first worker seed');
    expect(s?.employerId, kDemoContractorId,
        reason: 'impersonation carries the seed worker → contractor link');
    expect(n.isImpersonating, isTrue);

    n.returnFromImpersonation();
    expect(c.read(boardAuthProvider)?.role, BoardRole.manager,
        reason: 'the saved manager session is restored');
    expect(n.isImpersonating, isFalse);
  });

  test('impersonate is a no-op when the current session is NOT a manager', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(boardAuthProvider.notifier);

    n.login(BoardRole.worker, 'ran', '1111'); // a worker, not a manager
    n.impersonate(BoardRole.store);
    expect(c.read(boardAuthProvider)?.role, BoardRole.worker,
        reason: 'only a manager may impersonate');
    expect(n.isImpersonating, isFalse);
  });

  test('store impersonation carries no employer link', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(boardAuthProvider.notifier);

    n.login(BoardRole.manager, 'admin', '5555');
    n.impersonate(BoardRole.store);
    final s = c.read(boardAuthProvider);
    expect(s?.role, BoardRole.store);
    expect(s?.username, 'lipskey');
    expect(s?.employerId, '', reason: 'a store has no employer');

    n.returnFromImpersonation();
    expect(c.read(boardAuthProvider)?.role, BoardRole.manager);
  });

  test('logout DURING impersonation returns to the manager (no stranded session)',
      () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(boardAuthProvider.notifier);

    expect(n.login(BoardRole.manager, 'admin', '5555'), isTrue);
    n.impersonate(BoardRole.worker);
    expect(n.isImpersonating, isTrue);

    // The impersonated seed's OWN profile exposes a logout. Pressing it must NOT
    // drop the (never-persisted) manager session — it ends the view instead, so
    // the owner isn't logged out entirely on the next restart.
    n.logout();
    expect(c.read(boardAuthProvider)?.role, BoardRole.manager,
        reason: 'logout while impersonating ends the view, keeps the manager');
    expect(n.isImpersonating, isFalse);
  });

  test('logout OUTSIDE impersonation still fully clears the board session', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(boardAuthProvider.notifier);

    n.login(BoardRole.manager, 'admin', '5555');
    n.logout();
    expect(c.read(boardAuthProvider), isNull,
        reason: 'a normal logout is unchanged — full sign-out');
  });
}

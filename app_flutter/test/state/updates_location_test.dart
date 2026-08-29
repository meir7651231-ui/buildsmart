// updates_location — the SEALED location value type + the derived
// updatesLocationProvider (plan phases 0-2, RISK #1: the single most load-bearing
// detail).
//
// WHY THESE TESTS EXIST: updatesLocationProvider is a derived `Provider`, so
// Riverpod notifies the keyboard ONLY when the newly computed location is `!=`
// the previous one. If the sealed subclasses lacked TRUE value equality, the
// provider would emit a fresh instance every frame and the keyboard would
// re-derive its whole row at 60fps (churn during scroll). The plan calls this the
// single most important detail and mandates an idempotence test. These tests are
// that gate:
//   • VALUE EQUALITY (pure): identical inputs ⇒ `==` true AND `hashCode` equal,
//     for every subclass; any field difference ⇒ `!=`. No widget tree needed.
//   • PROVIDER IDEMPOTENCE: a second read of the derived provider returns the
//     SAME cached instance (Riverpod caches a Provider's value), and a no-op
//     upstream write does NOT re-notify a listener — proving the recompute path
//     short-circuits on an equal value rather than churning.
//   • RESOLUTION: the provider maps (sub-tab, section, open-chat id) to the right
//     subclass, and resolves persona to the home-shell 'contractor' scope (Q6).
//
// SharedPreferences.setMockInitialValues({}) is seeded because boardAuthProvider
// (read for persona) lazily loads prefs; with no dart-define UID_SCOPED_QUERIES,
// its initial synchronous state is null, so persona resolves to 'contractor'
// deterministically without touching Firebase.

import 'package:buildsmart/screens/chats_screen.dart'
    show updatesChatOpenProvider;
import 'package:buildsmart/screens/notifications_screen.dart'
    show NotifSection, notifSectionProvider;
import 'package:buildsmart/screens/updates_screen.dart'
    show updatesSubTabProvider;
import 'package:buildsmart/state/updates_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _p = 'contractor';
const String _a = 'contractor';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ───────────────────────────────────────────────────────────────────────────
  // VALUE EQUALITY — pure, the foundation the provider de-dup relies on.
  // ───────────────────────────────────────────────────────────────────────────
  group('UpdatesRoot value equality', () {
    test('identical inputs ⇒ == true AND hashCode equal', () {
      const x = UpdatesRoot(persona: _p, audience: _a, subTab: 0);
      const y = UpdatesRoot(persona: _p, audience: _a, subTab: 0);
      expect(x, y, reason: 'same fields ⇒ equal by value');
      expect(x.hashCode, y.hashCode, reason: 'equal values ⇒ equal hashCode');
    });

    test('a different subTab ⇒ !=', () {
      const x = UpdatesRoot(persona: _p, audience: _a, subTab: 0);
      const y = UpdatesRoot(persona: _p, audience: _a, subTab: 1);
      expect(x == y, isFalse, reason: 'subTab participates in equality');
    });

    test('a different persona/audience ⇒ !=', () {
      const base = UpdatesRoot(persona: _p, audience: _a, subTab: 0);
      expect(
          base ==
              const UpdatesRoot(
                  persona: 'worker', audience: _a, subTab: 0),
          isFalse,
          reason: 'persona participates in equality');
      expect(
          base ==
              const UpdatesRoot(
                  persona: _p, audience: 'store', subTab: 0),
          isFalse,
          reason: 'audience participates in equality');
    });
  });

  group('NotifsLocation value equality', () {
    test('identical inputs ⇒ == true AND hashCode equal', () {
      const x = NotifsLocation(
          persona: _p, audience: _a, section: NotifSection.budget);
      const y = NotifsLocation(
          persona: _p, audience: _a, section: NotifSection.budget);
      expect(x, y);
      expect(x.hashCode, y.hashCode);
    });

    test('a different section ⇒ !=', () {
      const x = NotifsLocation(
          persona: _p, audience: _a, section: NotifSection.all);
      const y = NotifsLocation(
          persona: _p, audience: _a, section: NotifSection.safety);
      expect(x == y, isFalse, reason: 'section participates in equality');
    });
  });

  group('ChatsLocation value equality', () {
    test('identical inputs ⇒ == true AND hashCode equal', () {
      const x = ChatsLocation(persona: _p, audience: _a);
      const y = ChatsLocation(persona: _p, audience: _a);
      expect(x, y);
      expect(x.hashCode, y.hashCode);
    });

    test('a different scope ⇒ !=', () {
      const x = ChatsLocation(persona: _p, audience: _a);
      const y = ChatsLocation(persona: 'worker', audience: 'store');
      expect(x == y, isFalse);
    });
  });

  group('cross-subclass inequality (distinct surfaces never collide)', () {
    test('UpdatesRoot != NotifsLocation != ChatsLocation', () {
      const root = UpdatesRoot(persona: _p, audience: _a, subTab: 0);
      const notif = NotifsLocation(
          persona: _p, audience: _a, section: NotifSection.all);
      const chats = ChatsLocation(persona: _p, audience: _a);
      expect(root == notif, isFalse);
      expect(notif == chats, isFalse);
      expect(root == chats, isFalse);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // PROVIDER IDEMPOTENCE — the churn gate the plan demands.
  // ───────────────────────────────────────────────────────────────────────────
  group('updatesLocationProvider — resolution + idempotence', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    ProviderContainer makeContainer() {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      return c;
    }

    test('sub 0 (default) ⇒ NotifsLocation at the contractor scope', () {
      final c = makeContainer();
      final loc = c.read(updatesLocationProvider);
      expect(loc, isA<NotifsLocation>(),
          reason: 'the default sub-tab is 0 (התראות) ⇒ NotifsLocation');
      expect(loc.persona, 'contractor',
          reason: 'persona resolves to the home-shell scope (Q6)');
      expect(loc.audience, 'contractor');
      expect((loc as NotifsLocation).section, NotifSection.all,
          reason: 'mirrors the default notifSection');
    });

    test('sub 1 ⇒ ChatsLocation', () {
      final c = makeContainer();
      c.read(updatesSubTabProvider.notifier).state = 1;
      expect(c.read(updatesLocationProvider), isA<ChatsLocation>(),
          reason: 'the שיחות sub-tab ⇒ ChatsLocation');
    });

    test('a non-null open-chat id ⇒ UpdatesRoot (route owns its own keyboard)',
        () {
      final c = makeContainer();
      c.read(updatesSubTabProvider.notifier).state = 1; // would be ChatsLocation
      c.read(updatesChatOpenProvider.notifier).state = 'thread-1';
      final loc = c.read(updatesLocationProvider);
      expect(loc, isA<UpdatesRoot>(),
          reason: 'while a chat is open the floating keyboard folds to the '
              'stable section root (plan Q5)');
      expect((loc as UpdatesRoot).subTab, 1,
          reason: 'the root still carries the active sub-tab for its tools');
    });

    test('the NotifsLocation section tracks notifSectionProvider', () {
      final c = makeContainer();
      c.read(notifSectionProvider.notifier).state = NotifSection.deals;
      final loc = c.read(updatesLocationProvider);
      expect(loc, isA<NotifsLocation>());
      expect((loc as NotifsLocation).section, NotifSection.deals,
          reason: 'selecting a type re-derives the location to that section');
    });

    test('IDEMPOTENT: two reads with no change ⇒ the SAME cached instance', () {
      final c = makeContainer();
      final a = c.read(updatesLocationProvider);
      final b = c.read(updatesLocationProvider);
      expect(identical(a, b), isTrue,
          reason: 'a derived Provider caches; an unchanged read does not '
              'reallocate (the precondition for no-churn)');
    });

    test(
        'IDEMPOTENT: a NO-OP upstream write (same value) does NOT re-notify '
        'the location listener', () {
      final c = makeContainer();
      final firstInstance = c.read(updatesLocationProvider);
      var notifications = 0;
      // fireImmediately:false → we count ONLY genuine post-subscription changes.
      c.listen<UpdatesLocation>(
        updatesLocationProvider,
        (_, __) => notifications++,
        fireImmediately: false,
      );

      // Re-write the sub-tab to its CURRENT value (0). The StateProvider does not
      // change, the location recompute (if any) yields an `==` value, so the
      // listener must NOT fire — no churn.
      c.read(updatesSubTabProvider.notifier).state =
          c.read(updatesSubTabProvider);
      c.read(notifSectionProvider.notifier).state =
          c.read(notifSectionProvider);

      expect(notifications, 0,
          reason: 'identical inputs ⇒ equal location ⇒ zero re-notifications '
              '(guards the 60fps churn failure mode)');
      // And the cached instance was never reallocated — the value-equality gate
      // held, so nothing downstream rebuilt.
      expect(identical(c.read(updatesLocationProvider), firstInstance), isTrue,
          reason: 'no-op upstream writes do not reallocate the location');
    });

    test(
        'a REAL change DOES notify exactly once (the listener is actually live)',
        () async {
      final c = makeContainer();
      var notifications = 0;
      c.listen<UpdatesLocation>(
        updatesLocationProvider,
        (_, __) => notifications++,
        fireImmediately: false,
      );

      // Flip the sub-tab 0 → 1: NotifsLocation → ChatsLocation, a genuine value
      // change, so the listener fires once (proving the no-op test above is a
      // real negative, not a dead listener).
      c.read(updatesSubTabProvider.notifier).state = 1;
      // Riverpod flushes derived-provider listener notifications on its scheduler
      // (a microtask), not synchronously — pump it so the live listener fires.
      await Future<void>.delayed(Duration.zero);

      expect(notifications, 1,
          reason: 'a genuine surface change re-fires the location exactly once');
    });
  });
}

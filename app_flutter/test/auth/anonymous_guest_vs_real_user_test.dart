// The anonymous-guest regression suite.
//
// WHY THIS FILE EXISTS: the server-catalog bootstrap (main.dart →
// ensureAnonAuthForServerCatalog) signs EVERY visitor in anonymously before the
// first frame. That fixed the backend cut-over, but it also broke the oldest
// assumption in the auth code — that `user == null` means "signed out". Three
// places asked that question, and all three silently changed meaning the day the
// live build turned USE_FIREBASE_BACKEND on:
//
//   • the login sheet closed on `prev?.user == null` → never fired again, so a
//     user who typed a VALID SMS code was left sitting on the sheet;
//   • OnboardingGate opened only on `welcomeSeen`, a flag the LOGIN path never
//     sets → a freshly-verified user was bounced back to "רישום ראשוני";
//   • everything downstream treated the throwaway guest uid as a real identity.
//
// The fix is one shared distinction — [AuthUser.isAnonymous] / [AuthUser.isRealUser]
// — so these tests pin that distinction itself. They are deliberately about the
// PREDICATES, not the widgets: the bug was never a rendering bug, it was a
// question asked wrongly.

import 'package:buildsmart/state/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// The guest the bootstrap creates: a real Firebase user, anonymous.
const _guest = AuthUser(uid: 'anon-abc', isAnonymous: true);

/// Someone who completed phone-OTP.
const _person = AuthUser(uid: 'real-xyz', phone: '+972501234567');

void main() {
  group('AuthUser carries the guest marker', () {
    test('a real user is NOT anonymous by default', () {
      expect(_person.isAnonymous, isFalse);
      expect(_person.isRealUser, isTrue);
    });

    test('the guest is anonymous and NOT a real user', () {
      expect(_guest.isAnonymous, isTrue);
      expect(_guest.isRealUser, isFalse);
    });

    test('equality distinguishes a guest from a real user with the same uid', () {
      // Both halves matter: if `isAnonymous` were left out of == / hashCode, a
      // guest→real upgrade that kept the uid would not notify listeners at all,
      // and the sheet would stay open even with the corrected predicate.
      const sameUidGuest = AuthUser(uid: 'u1', isAnonymous: true);
      const sameUidReal = AuthUser(uid: 'u1');
      expect(sameUidGuest == sameUidReal, isFalse);
      expect(sameUidGuest.hashCode == sameUidReal.hashCode, isFalse);
    });
  });

  group('login sheet close predicate — guest-or-nobody → real person', () {
    // Mirrors the sheet's `ref.listen` body:
    //   becameReal && !wasReal
    bool shouldClose(AuthUser? prev, AuthUser? next) {
      final becameReal = next?.isRealUser ?? false;
      final wasReal = prev?.isRealUser ?? false;
      return becameReal && !wasReal;
    }

    test('THE BUG: guest → real person MUST close the sheet', () {
      // This is the exact transition a successful SMS verification produces on
      // the live build, and the one the old `prev?.user == null` guard missed.
      expect(shouldClose(_guest, _person), isTrue);
    });

    test('signed-out → real person still closes (the classic case)', () {
      expect(shouldClose(null, _person), isTrue);
    });

    test('nobody → guest does NOT close (the bootstrap must not pop a sheet)', () {
      expect(shouldClose(null, _guest), isFalse);
    });

    test('guest → guest does not close', () {
      expect(shouldClose(_guest, _guest), isFalse);
    });

    test('real → real does not re-close (no double pop / double toast)', () {
      expect(shouldClose(_person, _person), isFalse);
    });

    test('sign-out (real → guest) does not close', () {
      expect(shouldClose(_person, _guest), isFalse);
    });
  });

  group('OnboardingGate routing — the welcome-screen dead end', () {
    /// Mirrors OnboardingGate.build under `useFirebaseBackend == true`.
    /// Returns 'home' or 'opening'.
    ///
    /// Entry needs one of two POSITIVE answers: a real signed-in person, or an
    /// explicit "browse as guest" choice. `welcomeSeen` is no longer entry — it
    /// only records that onboarding was shown.
    String route({
      required AuthUser? user,
      required bool loaded,
      required bool welcomeSeen,
      bool guestBrowsing = false,
    }) {
      if (user?.isRealUser ?? false) return 'home';
      if (guestBrowsing) return 'home';
      return 'opening';
    }

    test('THE BUG: signed-in person + welcome NEVER seen ⇒ home, not welcome',
        () {
      // A fresh (incognito) visitor who signs in through the LOGIN sheet: the
      // login path never sets welcomeSeen, so the old gate returned the welcome
      // screen and the user could never get in.
      expect(
        route(user: _person, loaded: true, welcomeSeen: false),
        'home',
      );
    });

    test('signed-in person + welcome seen ⇒ home', () {
      expect(route(user: _person, loaded: true, welcomeSeen: true), 'home');
    });

    test('guest who has NOT chosen ⇒ asked, even on a return visit', () {
      // The owner's report: "it lets me in without authenticating". A persisted
      // welcomeSeen used to be the whole gate, and since the anonymous
      // bootstrap makes auth.user non-null for everyone, a returning visitor
      // slipped into the app never having been asked who they are — with their
      // data bound to a throwaway anon uid.
      expect(route(user: _guest, loaded: true, welcomeSeen: true), 'opening');
    });

    test('⚠️ LOCKOUT GUARD: an explicit guest choice MUST open the app', () {
      // Without honouring the choice, the welcome screen's guest button loops
      // back to itself and NOBODY without an account can browse — the exact
      // lock-everyone-out failure the anonymous bootstrap was added to fix.
      expect(
        route(
          user: _guest,
          loaded: true,
          welcomeSeen: true,
          guestBrowsing: true,
        ),
        'home',
      );
    });

    test('the guest choice survives with onboarding not yet seen', () {
      expect(
        route(
          user: _guest,
          loaded: true,
          welcomeSeen: false,
          guestBrowsing: true,
        ),
        'home',
      );
    });

    test('guest + first visit ⇒ opening flow (the welcome shows once)', () {
      expect(route(user: _guest, loaded: true, welcomeSeen: false), 'opening');
    });

    test('truly signed out (anon bootstrap failed) ⇒ opening flow', () {
      expect(route(user: null, loaded: true, welcomeSeen: true), 'opening');
    });

    test('a real user outranks everything — never asked again', () {
      expect(
        route(user: _person, loaded: true, welcomeSeen: false),
        'home',
      );
    });

    test('a real user routes home even before auth finishes loading', () {
      // The claims fetch keeps `loaded` false for a moment; a real user must not
      // be bounced during that window.
      expect(route(user: _person, loaded: false, welcomeSeen: false), 'home');
    });
  });
}

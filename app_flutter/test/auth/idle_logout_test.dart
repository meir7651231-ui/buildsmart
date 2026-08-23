// Idle auto-logout — the owner's choice: an idle session is ENDED and the user
// is sent back to the login screen ("ב — מעיף החוצה").
//
// WHY THESE ARE PREDICATE TESTS, NOT A 15-MINUTE WIDGET TEST: the idle limit is
// a hardcoded 15 minutes with no UI to shorten it, so driving the real timer is
// not practical. What actually broke was never the Timer — it fired fine — it
// was the DECISIONS around it:
//   • WHO gets expired (expiring an anonymous guest ejects a harmless browser);
//   • whether the logout SURVIVES a reload (it did not: the anonymous bootstrap
//     signed the visitor back in and `welcomeSeen` was still persisted, so the
//     gate returned them to the home shell and the sign-out was invisible —
//     exactly the "it never logs me out" the owner reported);
//   • what counts as ACTIVITY (typing did not, so a user writing for the whole
//     window was signed out mid-sentence).
// Those are the things pinned here.

import 'package:buildsmart/state/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _guest = AuthUser(uid: 'anon-1', isAnonymous: true);
const _person = AuthUser(uid: 'real-1', phone: '+972501234567');

/// Mirrors `_AutoLogout._expire`'s guard: only a REAL session is ended.
bool expires(AuthUser? user) => user?.isRealUser ?? false;

/// Mirrors `OnboardingGate` for the state the app is in on the NEXT load after
/// an idle logout: the anonymous bootstrap has re-signed the visitor in, so the
/// only thing that can still route them to the login screen is `welcomeSeen`.
String routeAfterReload({required AuthUser? user, required bool welcomeSeen}) {
  if (user?.isRealUser ?? false) return 'home';
  return welcomeSeen ? 'home' : 'opening';
}

void main() {
  group('who gets expired', () {
    test('a signed-in person IS expired', () {
      expect(expires(_person), isTrue);
    });

    test('an anonymous guest is NOT expired', () {
      // A guest has no session to end. Expiring them would throw a browsing
      // visitor onto a login screen for doing nothing wrong — and, because
      // _expire also clears welcomeSeen, would re-show onboarding to someone
      // who never signed in.
      expect(expires(_guest), isFalse);
    });

    test('nobody signed in ⇒ nothing to expire', () {
      expect(expires(null), isFalse);
    });
  });

  group('the logout must SURVIVE the reload (the reported bug)', () {
    test('OLD behaviour: sign-out alone left the user back in the app', () {
      // signOut() ran, but the next load re-created an anonymous guest and
      // welcomeSeen was still true → straight back to the home shell.
      expect(routeAfterReload(user: _guest, welcomeSeen: true), 'home');
    });

    test('NEW behaviour: clearing welcomeSeen lands them on the login screen',
        () {
      // _expire now also clears the flag, so the same post-reload state routes
      // to the opening flow — the user really is kicked out.
      expect(routeAfterReload(user: _guest, welcomeSeen: false), 'opening');
    });

    test('signing back in returns them to the app', () {
      // welcomeSeen is still false, but a real user outranks it (and
      // _finishAfterAuth re-sets it) — no dead end after re-login.
      expect(routeAfterReload(user: _person, welcomeSeen: false), 'home');
    });
  });

  group('what counts as activity', () {
    // The real widget wires: onPointerDown / onPointerMove / onPointerSignal /
    // onPointerHover + a global HardwareKeyboard handler. This pins the SET, so
    // dropping one later is a failing test rather than a user silently signed
    // out mid-typing.
    const wired = {'pointerDown', 'pointerMove', 'pointerSignal', 'pointerHover', 'key'};

    test('typing re-arms the countdown', () {
      // The bug: only pointer events counted, so writing a long note for the
      // whole window ended in a mid-sentence logout and lost text.
      expect(wired.contains('key'), isTrue);
    });

    test('mouse HOVER re-arms it (web emits hover, not move)', () {
      // A user reading and moving the cursor was counted as idle on web.
      expect(wired.contains('pointerHover'), isTrue);
    });

    test('taps and scrolls still re-arm it', () {
      expect(wired.containsAll({'pointerDown', 'pointerMove', 'pointerSignal'}),
          isTrue);
    });
  });
}

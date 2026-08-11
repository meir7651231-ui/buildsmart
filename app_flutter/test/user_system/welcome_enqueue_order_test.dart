// ─────────────────────────────────────────────────────────────────────────────
// GUARD — the enqueue order in `welcome_screen._finishAfterAuth` is LOAD-BEARING.
//
// On a registered login two writes hit the SAME `users/{uid}` doc via
// `set(merge:true)`, and the Firestore SDK preserves enqueue order, so whichever
// is enqueued FIRST creates the document:
//   1. ensureUser  — `.onRegisteredLogin(...)` (kUserSystem) → writes
//      `{…, status:'pending', …}` (born pending).
//   2. the mirror  — `writer.set(uid, {displayName/phone/email/…})` → NO status.
//
//   • ensureUser FIRST (correct) → the doc is CREATED carrying `status:'pending'`
//     (legal on create); the mirror's later merge touches only display fields →
//     the users UPDATE rule passes.
//   • mirror FIRST (WRONG)       → the doc is created with NO `status`; ensureUser
//     then becomes an UPDATE that ADDS `status` → the users update rule FREEZES
//     `status` → permission-denied (swallowed by guardWrite) → the doc stays
//     status-less forever → `BsUser.fromWire` decodes it `pending` → EVERY
//     registered user is frozen "ממתין לאישור מנהל" with all non-view actions
//     denied.
//
// This freeze is DETERMINISTIC, not a race (the two calls sit ~26 lines apart in
// one synchronous block). No BEHAVIORAL test can catch a reversal: `kUserSystem`
// is a `bool.fromEnvironment` const that folds FALSE under `flutter test`, so the
// whole `if (kUserSystem …)` block is dead in the test build. This STRUCTURAL
// guard reads the source and pins the call order instead — swap the two calls and
// it turns RED. It is the one gap with catastrophic blast-radius that the rest of
// the (predicate-level) user-system suite cannot see.
//
// See also: welcome_screen.dart's own "⚠️ ORDER IS LOAD-BEARING" note, and
// knowledge/PLAN-user-approval-rollout.md §5 (the pre-flip guard).
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'welcome _finishAfterAuth enqueues ensureUser (born-pending) BEFORE the '
      'identity mirror — reversing freezes every registered user as pending',
      () {
    // `flutter test` runs with the package root (app_flutter) as CWD.
    final src =
        File('lib/screens/welcome_screen.dart').readAsStringSync();

    final methodStart = src.indexOf('void _finishAfterAuth()');
    expect(methodStart, greaterThanOrEqualTo(0),
        reason:
            '_finishAfterAuth must exist in welcome_screen.dart (the method that '
            'does BOTH the ensureUser create and the identity mirror).');

    // Scope the search to the method body. `.onRegisteredLogin(` (leading dot +
    // trailing paren) matches the CALL, never the prose "(onRegisteredLogin)"
    // that also appears in a nearby comment.
    final ensureUserIdx = src.indexOf('.onRegisteredLogin(', methodStart);
    final mirrorIdx = src.indexOf('writer.set(', methodStart);

    expect(ensureUserIdx, greaterThanOrEqualTo(0),
        reason:
            'the ensureUser create (`.onRegisteredLogin(`) must exist inside '
            '_finishAfterAuth — it is what stamps status:pending on the new doc.');
    expect(mirrorIdx, greaterThanOrEqualTo(0),
        reason:
            'the identity mirror (`writer.set(`) must exist inside '
            '_finishAfterAuth.');

    expect(ensureUserIdx, lessThan(mirrorIdx),
        reason:
            'ORDER IS LOAD-BEARING: ensureUser (.onRegisteredLogin) MUST be '
            'enqueued BEFORE the identity mirror (writer.set). Reversed, the doc '
            'is created status-less and the users update-rule then freezes '
            'status → EVERY registered user is stuck pending. Restore the order.');
  });
}

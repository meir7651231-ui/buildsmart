// Checkout asks the server's questions, not the device's.
//
// WHAT WAS WRONG. The gate read `userProfileProvider.registered` — a device-local
// SharedPreferences bool that `user_profile.dart` flips true the moment a typed
// name and contact validate. It never consulted the account, so:
//   • the ANONYMOUS catalog guest, who has no account at all, cleared it by
//     typing two fields into the profile screen;
//   • a registered account still waiting for admin approval cleared it too,
//     because registering is what sets the flag.
// Either order then landed on the store and courier boards indistinguishable
// from an approved contractor's, which is precisely what "all-by-approval" was
// written to prevent.
//
// WHY THE LOGIC IS A PURE FUNCTION. The gate lives behind `kUserSystem`, a
// compile-time const that folds FALSE in every test build, so a widget test
// walks straight through it and proves nothing about the path that ships. That
// is how the old gate stayed broken while its tests stayed green — see
// `contractor_checkout_engine_test`, which asserts, correctly and uselessly,
// that "an UNREGISTERED contractor still places a live order". Passing the flag
// as an argument is what makes the ON path reachable from a test at all.
//
// THE PAIRING THAT MATTERS. These cases mirror `rules_test/approval.test.js`
// one-for-one. The rules are the enforcement; this is the courtesy that turns a
// silent permission-denied — arriving after the cart has been cleared — into a
// Hebrew sentence with the action that resolves it.

import 'package:buildsmart/data/bs_user.dart' show UserStatus;
import 'package:buildsmart/state/rbac.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('checkoutBlock — the same two questions the rules ask', () {
    test('an approved person goes through', () {
      expect(
        checkoutBlock(userSystemOn: true, isRealUser: true, isPending: false),
        CheckoutBlock.none,
      );
    });

    test('THE BUG: a PENDING account is stopped', () {
      expect(
        checkoutBlock(userSystemOn: true, isRealUser: true, isPending: true),
        CheckoutBlock.pendingApproval,
        reason: 'registering is what set the old flag — so it let them through',
      );
    });

    test('THE BUG: the ANONYMOUS guest is stopped', () {
      expect(
        checkoutBlock(userSystemOn: true, isRealUser: false, isPending: false),
        CheckoutBlock.notRegistered,
      );
    });

    test('no account outranks pending — the message must fit the situation',
        () {
      // An anonymous session cannot be "waiting for approval": there is nothing
      // to approve. Telling them to wait would be advice that never resolves.
      expect(
        checkoutBlock(userSystemOn: true, isRealUser: false, isPending: true),
        CheckoutBlock.notRegistered,
      );
    });

    test('every refusal names a state a person can actually leave', () {
      // notRegistered → the login sheet. pendingApproval → the role-request
      // sheet. The old gate offered neither: it said "register" and pointed at a
      // screen an already-signed-in person cannot reach, leaving closing the app
      // as the only move.
      expect(CheckoutBlock.values, hasLength(3));
    });
  });

  group('flag OFF is byte-identical behaviour', () {
    test('with the user system off NOTHING is blocked, whatever the inputs', () {
      for (final real in [true, false]) {
        for (final pending in [true, false]) {
          expect(
            checkoutBlock(
              userSystemOn: false,
              isRealUser: real,
              isPending: pending,
            ),
            CheckoutBlock.none,
            reason: 'demo/test builds must behave exactly as before',
          );
        }
      }
    });
  });

  group('permitAction agrees — one story, not two', () {
    test('a pending user is denied everything except the catalog', () {
      // The typed gate always held the right rule; it simply had no call sites.
      // Pinning it here so the two enforcement paths cannot drift apart.
      expect(
        permitAction(
          role: BsRole.contractor,
          perm: Permission.placeOrder,
          status: UserStatus.pending,
        ),
        isFalse,
      );
      expect(
        permitAction(
          role: BsRole.contractor,
          perm: Permission.viewCatalog,
          status: UserStatus.pending,
        ),
        isTrue,
        reason: 'browsing stays open — only the commercial act is gated',
      );
    });

    test('an active contractor may place an order', () {
      expect(
        permitAction(
          role: BsRole.contractor,
          perm: Permission.placeOrder,
          status: UserStatus.active,
        ),
        isTrue,
      );
    });
  });
}

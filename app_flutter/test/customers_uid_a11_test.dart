// A11 (launch uid-migration) — focused coverage for the additive,
// display-neutral `ownerId` on the customer mapping.
//
// FINDING (pinned by these tests): the 👥 לקוחות list is DERIVED from the orders
// engine (`mgrCustomerList` over `Order.who` display names, not uids) and the
// [CustomersRepository] interface carries NO public write method that creates a
// customer doc. So on the live path `ownerId` is ALWAYS '' — there is nowhere to
// stamp an owner uid, and no write path is fabricated. The field is wired through
// end-to-end (`ManagerCustomer.ownerId` ⇄ the Firestore `ownerId`) so that:
//   • a doc the console/server writes WITH `ownerId` round-trips losslessly;
//   • a FUTURE customer-write path can stamp it from `currentUidProvider`.
// Until then it must be ZERO-regression (the A3 `contractorUid` discipline):
//   • written ONLY when non-empty — the four seed customers (derived, ownerId
//     '') round-trip byte-identical;
//   • read back losslessly when present, defaulting to '' when absent.
//
// No Firebase here: the repo's toDoc/fromDoc are pure mappers, round-tripped
// through a hand-built [RemoteDoc] (the `orders_uid_a3_test` construction).

import 'package:buildsmart/data/repositories/customers_firebase.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repo = FirebaseCustomersRepository();

  group('FINDING — the derived seed customers carry no ownerId', () {
    test('every seed customer has ownerId == "" → toDoc omits it (zero regr.)',
        () {
      // mgrCustomerList() folds over Order.who display names — no uid to stamp.
      for (final c in mgrCustomerList()) {
        expect(c.ownerId, '', reason: 'derived aggregate has no owner uid');
        expect(
          repo.toDoc(c).containsKey('ownerId'),
          isFalse,
          reason: 'omitted when empty → seed doc round-trips unchanged',
        );
      }
    });
  });

  group('FirebaseCustomersRepository.toDoc/fromDoc — ownerId (Firestore shape)',
      () {
    test('an ownerId is WRITTEN to the doc and round-trips through fromDoc', () {
      // Forward-ready: a future write path constructs ManagerCustomer with the
      // owning manager's uid; the mapper carries it both ways.
      const c = ManagerCustomer(
        name: 'יוסי כהן',
        orderCount: 2,
        totalSpend: 1240,
        creditLimit: 50000,
        ownerId: 'u-7',
      );
      final doc = repo.toDoc(c);
      expect(doc['ownerId'], 'u-7', reason: 'present when non-empty');

      // Inverse mapping: the doc-id becomes `name`, ownerId comes off `data`.
      final back = repo.fromDoc(RemoteDoc(c.name, doc));
      expect(back.ownerId, 'u-7');
      expect(back.name, 'יוסי כהן'); // untouched
      expect(back.totalSpend, 1240); // used → totalSpend untouched
    });

    test('an EMPTY ownerId is OMITTED from the doc (seed/legacy parity)', () {
      const c = ManagerCustomer(
        name: 'משה אברהם',
        orderCount: 3,
        totalSpend: 3150,
        creditLimit: 80000,
      );
      expect(
        repo.toDoc(c).containsKey('ownerId'),
        isFalse,
        reason: 'omitted when empty → seed doc round-trips unchanged',
      );
    });

    test("fromDoc DEFAULTS to '' when the field is absent (legacy doc)", () {
      // A seed/legacy Firestore doc (or one written pre-A11) has no ownerId.
      const doc = RemoteDoc('דוד לוי', {
        'name': 'דוד לוי',
        'used': 420,
        'creditLimit': 30000,
        'balance': 29580,
        'orderCount': 1,
      });
      expect(repo.fromDoc(doc).ownerId, '', reason: 'zero-regression default');
    });

    test('fromDoc reads a console/server-written ownerId tolerantly', () {
      const doc = RemoteDoc('אבי מזרחי', {
        'name': 'אבי מזרחי',
        'used': 680,
        'creditLimit': 50000,
        'balance': 49320,
        'orderCount': 1,
        'ownerId': 'u-99', // written by a future server/console path
      });
      expect(repo.fromDoc(doc).ownerId, 'u-99');
    });
  });
}

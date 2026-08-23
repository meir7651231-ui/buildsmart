// Wave-0 worker→contractor link — regression guard.
//
// The seed worker accounts (ran/omer) MUST carry the demo contractor's
// employerId. Without it a seed-LOGIN worker's session employerId is '' and:
//   • their leave / cert / training / material records never reach the
//     contractor's employer-scoped views (strict `== employerId` match), and
//   • the HARD required-docs gate FAILS OPEN (requiredDocsForEmployer('') → []).
// Stamping the seed at the SOURCE keeps the deliberate strict scoping (and its
// back-compat exclusion of legacy '' records) intact while making seed-login
// workers behave exactly like the demo-entry worker (board_auth.dart:274).
import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/state/board_auth.dart'
    show BoardRole, kDemoContractorId;
import 'package:flutter_test/flutter_test.dart';

void main() {
  BoardAccount acct(String username) =>
      kBoardAccounts.firstWhere((a) => a.username == username);

  group('seed worker accounts carry the demo-contractor employer link', () {
    test('worker seeds (ran/omer) are employed by the demo contractor', () {
      expect(acct('ran').employerId, kDemoContractorId);
      expect(acct('omer').employerId, kDemoContractorId);
    });

    test('every worker seed has a non-empty employer (no silent drop)', () {
      for (final a in kBoardAccounts.where((a) => a.role == BoardRole.worker)) {
        expect(
          a.employerId.isNotEmpty,
          isTrue,
          reason: 'worker ${a.username} has no employer → HR/docs would drop it',
        );
      }
    });

    test('non-worker seeds keep no contractor employer link', () {
      // A courier is employed by a STORE, not the contractor; store/manager
      // have no employer. Leaving these '' keeps them out of the contractor's
      // worker-scoped views.
      expect(acct('dudi').employerId, ''); // courier
      expect(acct('lipskey').employerId, ''); // store
      expect(acct('admin').employerId, ''); // manager
    });
  });
}

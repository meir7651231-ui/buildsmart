// U1 — the typed RBAC core: role/permission mapping, the claim bridge, the pure
// permission check, the pending-aware action gate, and the server-authoritative
// role decision. All pure — zero Riverpod, zero backend.

import 'package:buildsmart/data/bs_user.dart' show UserStatus;
import 'package:buildsmart/state/rbac.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('roleFromClaim / claimOf', () {
    test('decodes every known claim', () {
      expect(roleFromClaim('contractor'), BsRole.contractor);
      expect(roleFromClaim('store'), BsRole.store);
      expect(roleFromClaim('courier'), BsRole.courier);
      expect(roleFromClaim('worker'), BsRole.worker);
      expect(roleFromClaim('manager'), BsRole.manager);
      expect(roleFromClaim('admin'), BsRole.admin);
    });

    test('null / empty / unknown → contractor (least privilege)', () {
      expect(roleFromClaim(null), BsRole.contractor);
      expect(roleFromClaim(''), BsRole.contractor);
      expect(roleFromClaim('  '), BsRole.contractor);
      expect(roleFromClaim('superuser'), BsRole.contractor);
      expect(roleFromClaim('ADMIN'), BsRole.contractor); // case-sensitive
    });

    test('claimOf round-trips through roleFromClaim for every role', () {
      for (final r in BsRole.values) {
        expect(roleFromClaim(claimOf(r)), r, reason: 'round-trip $r');
      }
    });
  });

  group('roleToPermissions structure', () {
    test('every role has an entry', () {
      for (final r in BsRole.values) {
        expect(roleToPermissions.containsKey(r), isTrue, reason: '$r missing');
      }
    });

    test('every role may view the catalog (open catalog — decision #2)', () {
      for (final r in BsRole.values) {
        expect(hasPermission(r, Permission.viewCatalog), isTrue, reason: '$r');
      }
    });

    test('admin holds EVERY permission and is a superset of all roles', () {
      for (final p in Permission.values) {
        expect(hasPermission(BsRole.admin, p), isTrue, reason: 'admin lacks $p');
      }
      for (final r in BsRole.values) {
        expect(
          roleToPermissions[BsRole.admin]!.containsAll(roleToPermissions[r]!),
          isTrue,
          reason: 'admin should be a superset of $r',
        );
      }
    });

    test('assignRole is admin-ONLY (mirrors setRole admin-claim gate)', () {
      for (final r in BsRole.values) {
        expect(
          hasPermission(r, Permission.assignRole),
          r == BsRole.admin,
          reason: 'assignRole for $r',
        );
      }
    });
  });

  group('hasPermission — block AND allow per role', () {
    test('contractor: places orders, cannot approve / edit inventory', () {
      expect(hasPermission(BsRole.contractor, Permission.placeOrder), isTrue);
      expect(hasPermission(BsRole.contractor, Permission.approveOrder), isFalse);
      expect(hasPermission(BsRole.contractor, Permission.editInventory), isFalse);
      expect(hasPermission(BsRole.contractor, Permission.manageUsers), isFalse);
    });

    test('store: edits inventory + manages store + advances, cannot approve', () {
      expect(hasPermission(BsRole.store, Permission.editInventory), isTrue);
      expect(hasPermission(BsRole.store, Permission.manageStore), isTrue);
      expect(hasPermission(BsRole.store, Permission.advanceOrder), isTrue);
      expect(hasPermission(BsRole.store, Permission.placeOrder), isFalse);
      expect(hasPermission(BsRole.store, Permission.approveOrder), isFalse);
    });

    test('courier: advances orders only (+ view)', () {
      expect(hasPermission(BsRole.courier, Permission.advanceOrder), isTrue);
      expect(hasPermission(BsRole.courier, Permission.editInventory), isFalse);
      expect(hasPermission(BsRole.courier, Permission.placeOrder), isFalse);
    });

    test('worker: view only', () {
      expect(hasPermission(BsRole.worker, Permission.viewCatalog), isTrue);
      expect(hasPermission(BsRole.worker, Permission.placeOrder), isFalse);
      expect(hasPermission(BsRole.worker, Permission.advanceOrder), isFalse);
      expect(hasPermission(BsRole.worker, Permission.manageStore), isFalse);
    });

    test('manager: approves + manages users + studio, but NOT assignRole', () {
      expect(hasPermission(BsRole.manager, Permission.approveOrder), isTrue);
      expect(hasPermission(BsRole.manager, Permission.manageUsers), isTrue);
      expect(hasPermission(BsRole.manager, Permission.editStudio), isTrue);
      expect(hasPermission(BsRole.manager, Permission.assignRole), isFalse);
    });
  });

  group('permitAction — role × status (pending/suspended gate)', () {
    test('active status defers entirely to hasPermission', () {
      expect(
        permitAction(
          role: BsRole.contractor,
          perm: Permission.placeOrder,
          status: UserStatus.active,
        ),
        isTrue,
      );
      expect(
        permitAction(
          role: BsRole.contractor,
          perm: Permission.approveOrder,
          status: UserStatus.active,
        ),
        isFalse,
      );
    });

    test('null status (guest / kUserSystem OFF) defers to hasPermission', () {
      expect(
        permitAction(
          role: BsRole.store,
          perm: Permission.editInventory,
          status: null,
        ),
        isTrue,
      );
    });

    test('pending blocks EVERY non-view action — even for admin', () {
      expect(
        permitAction(
          role: BsRole.admin,
          perm: Permission.placeOrder,
          status: UserStatus.pending,
        ),
        isFalse,
      );
      expect(
        permitAction(
          role: BsRole.manager,
          perm: Permission.approveOrder,
          status: UserStatus.pending,
        ),
        isFalse,
      );
    });

    test('pending still allows viewing the catalog (open catalog)', () {
      expect(
        permitAction(
          role: BsRole.contractor,
          perm: Permission.viewCatalog,
          status: UserStatus.pending,
        ),
        isTrue,
      );
    });

    test('suspended blocks non-view actions too', () {
      expect(
        permitAction(
          role: BsRole.store,
          perm: Permission.editInventory,
          status: UserStatus.suspended,
        ),
        isFalse,
      );
      expect(
        permitAction(
          role: BsRole.store,
          perm: Permission.viewCatalog,
          status: UserStatus.suspended,
        ),
        isTrue,
      );
    });
  });

  group('bsRoleFrom — server-authoritative role decision', () {
    test('a guest (signed-out) is contractor, whatever persona is picked', () {
      expect(
        bsRoleFrom(signedIn: false, email: null, serverRoles: const []),
        BsRole.contractor,
      );
      // even if a stale "role" leaked in, signed-out short-circuits first:
      expect(
        bsRoleFrom(signedIn: false, email: null, serverRoles: const ['manager']),
        BsRole.contractor,
      );
    });

    test('the owner email → admin', () {
      expect(
        bsRoleFrom(
          signedIn: true,
          email: 'meir7651231@gmail.com',
          serverRoles: const [],
        ),
        BsRole.admin,
      );
      expect(
        bsRoleFrom(
          signedIn: true,
          email: 'MEIR7651231@gmail.com', // case-insensitive
          serverRoles: const [],
        ),
        BsRole.admin,
      );
    });

    test('a single server role → that typed role', () {
      expect(
        bsRoleFrom(signedIn: true, email: 'x@y.co', serverRoles: const ['store']),
        BsRole.store,
      );
      expect(
        bsRoleFrom(
          signedIn: true,
          email: 'x@y.co',
          serverRoles: const ['manager'],
        ),
        BsRole.manager,
      );
    });

    test('signed-in with 0 or many roles → contractor (least privilege)', () {
      expect(
        bsRoleFrom(signedIn: true, email: 'x@y.co', serverRoles: const []),
        BsRole.contractor,
      );
      expect(
        bsRoleFrom(
          signedIn: true,
          email: 'x@y.co',
          serverRoles: const ['store', 'courier'],
        ),
        BsRole.contractor,
      );
    });
  });
}

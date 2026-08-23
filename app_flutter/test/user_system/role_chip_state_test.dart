// Pins `roleChipStateFor` — the pure mapping behind the status chip under the
// logo (the "ללא באנר" replacement). Four states the owner asked for:
//   🟠 needsRegistration · 🟡 inProcess · 🟢 approved · 🔴 rejected.
// Firebase-free, pure — no provider container needed.
import 'package:buildsmart/state/role_requests.dart'
    show RoleChipState, roleChipStateFor;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('roleChipStateFor — the status chip mapping', () {
    test('not registered → 🟠 needsRegistration (even mid-request)', () {
      // A guest / anonymous visitor. Registration is the gate; nothing else
      // matters until they are a real user.
      expect(
        roleChipStateFor(
          isRegistered: false,
          isActive: false,
          hasServerRole: false,
          requestStatus: 'pending',
        ),
        RoleChipState.needsRegistration,
      );
    });

    test('registered, active account → 🟢 approved', () {
      expect(
        roleChipStateFor(
          isRegistered: true,
          isActive: true,
          hasServerRole: false,
          requestStatus: null,
        ),
        RoleChipState.approved,
      );
    });

    test('registered, holds a server role → 🟢 approved', () {
      expect(
        roleChipStateFor(
          isRegistered: true,
          isActive: false,
          hasServerRole: true,
          requestStatus: 'pending', // claim already landed; role wins
        ),
        RoleChipState.approved,
      );
    });

    test('registered, own request approved → 🟢 approved', () {
      expect(
        roleChipStateFor(
          isRegistered: true,
          isActive: false,
          hasServerRole: false,
          requestStatus: 'approved',
        ),
        RoleChipState.approved,
      );
    });

    test('registered, own request denied → 🔴 rejected', () {
      expect(
        roleChipStateFor(
          isRegistered: true,
          isActive: false,
          hasServerRole: false,
          requestStatus: 'denied',
        ),
        RoleChipState.rejected,
      );
    });

    test('registered, own request pending → 🟡 inProcess', () {
      expect(
        roleChipStateFor(
          isRegistered: true,
          isActive: false,
          hasServerRole: false,
          requestStatus: 'pending',
        ),
        RoleChipState.inProcess,
      );
    });

    test('registered but never requested a role → 🟠 needsRegistration', () {
      // The honest prompt: they still have to ASK for a role.
      expect(
        roleChipStateFor(
          isRegistered: true,
          isActive: false,
          hasServerRole: false,
          requestStatus: null,
        ),
        RoleChipState.needsRegistration,
      );
    });

    test('active OUTRANKS a denied request (approval is the final word)', () {
      // An admin re-activation after a stale denial doc still reads approved.
      expect(
        roleChipStateFor(
          isRegistered: true,
          isActive: true,
          hasServerRole: false,
          requestStatus: 'denied',
        ),
        RoleChipState.approved,
      );
    });
  });
}

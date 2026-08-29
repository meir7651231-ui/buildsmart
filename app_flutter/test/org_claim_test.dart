// STAGE-3.3 St2 — the org-claim client plumbing (inert until an admin runs
// the setOrg callable; query scoping arrives with ORG_SCOPED_QUERIES later).
//
// Mirrors the rolesFromClaims parsing group (auth_state_test.dart:182) for the
// new orgIdFromClaims helper + pins the AuthSnapshot field's null default —
// the zero-regression contract: no claim ⇒ null everywhere, nothing changes.

import 'package:buildsmart/state/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('orgIdFromClaims — stage-3.3 St2 claim parsing', () {
    test('null / empty / org-less claims → null', () {
      expect(orgIdFromClaims(null), isNull);
      expect(orgIdFromClaims(const {}), isNull);
      expect(orgIdFromClaims(const {'iss': 'firebase'}), isNull);
    });

    test('a non-empty orgId claim → the trimmed id', () {
      expect(orgIdFromClaims(const {'orgId': 'acme'}), 'acme');
      expect(orgIdFromClaims(const {'orgId': '  acme  '}), 'acme');
    });

    test('empty / whitespace / non-string orgId → null (never a junk tenant)',
        () {
      expect(orgIdFromClaims(const {'orgId': ''}), isNull);
      expect(orgIdFromClaims(const {'orgId': '   '}), isNull);
      expect(orgIdFromClaims(const {'orgId': 42}), isNull);
    });
  });

  group('AuthSnapshot.orgId — additive, null by default', () {
    test('default construction carries no org (the pre-3.3 shape)', () {
      const snap = AuthSnapshot();
      expect(snap.orgId, isNull);
    });

    test('an explicit orgId is carried', () {
      const snap = AuthSnapshot(orgId: 'acme');
      expect(snap.orgId, 'acme');
    });
  });
}

// HR-enablement — the employer-claim client plumbing (the worker→employer link
// minted by the setEmployer callable, carried into a worker's board session).
//
// Mirrors org_claim_test.dart for the new employerIdFromClaims helper + pins the
// AuthSnapshot field's null default — the zero-regression contract: no claim ⇒
// null everywhere, nothing changes. `boardSessionFromAuthSnapshot` reads it into
// a worker session's employerId so worker-HR reads can later prove employment.

import 'package:buildsmart/state/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('employerIdFromClaims — worker→employer claim parsing', () {
    test('null / empty / employer-less claims → null', () {
      expect(employerIdFromClaims(null), isNull);
      expect(employerIdFromClaims(const {}), isNull);
      expect(employerIdFromClaims(const {'iss': 'firebase'}), isNull);
    });

    test('a non-empty employerId claim → the trimmed contractor uid', () {
      expect(employerIdFromClaims(const {'employerId': 'contractor-9'}),
          'contractor-9');
      expect(employerIdFromClaims(const {'employerId': '  contractor-9  '}),
          'contractor-9');
    });

    test('empty / whitespace / non-string employerId → null (never junk)', () {
      expect(employerIdFromClaims(const {'employerId': ''}), isNull);
      expect(employerIdFromClaims(const {'employerId': '   '}), isNull);
      expect(employerIdFromClaims(const {'employerId': 42}), isNull);
    });
  });

  group('AuthSnapshot.employerId — additive, null by default', () {
    test('default construction carries no employer (the pre-HR shape)', () {
      const snap = AuthSnapshot();
      expect(snap.employerId, isNull);
    });

    test('an explicit employerId is carried', () {
      const snap = AuthSnapshot(employerId: 'contractor-9');
      expect(snap.employerId, 'contractor-9');
    });
  });
}

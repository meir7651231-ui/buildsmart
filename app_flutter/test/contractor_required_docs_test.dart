// cluster #101 · מדיניות מסמכים-נדרשים — proof that the WORKER documents
// readiness gate ENFORCES the contractor's employer-scoped required-docs
// policy as an ADD-ON layer, by NORMALIZED-EXACT cert-name match:
//
//   • a required type with NO present cert blocks (missing line);
//   • a present VALID cert of that type satisfies it;
//   • an EXPIRED cert of the required name does NOT satisfy it;
//   • the match is normalized (leading/trailing/case) — never substring;
//   • an EMPTY policy = today's behavior EXACTLY (back-compat).
//
// Plus a regression smoke that the COURIER rule (kCourierCertPresets) is
// unchanged — the courier path was NOT touched by this wave.

import 'package:buildsmart/state/courier_hr.dart' show kCourierCertPresets;
import 'package:buildsmart/state/docs_readiness.dart';
import 'package:buildsmart/state/worker_certs.dart';
import 'package:buildsmart/state/worker_forms.dart';
import 'package:flutter_test/flutter_test.dart';

/// A signed + declared Form101 for (username, year) — the readiness "happy" 101
/// (mirrors docs_readiness_test.dart).
Form101 _signed101(String username, int year) => Form101(
      username: username,
      year: year,
      fullName: 'רן עובד',
      idNumber: '123456789',
      phone: '0500000000',
      specialty: 'אינסטלציה',
      maritalStatus: 'רווק/ה',
      savedTs: DateTime(year, 1, 1),
      signature: 'data:image/png;base64,AAAA', // non-empty ⇒ signed
      declared: true,
    );

WorkerCert _cert(
  String username,
  String name,
  DateTime expiry, {
  String id = '',
}) =>
    WorkerCert(
      id: id.isEmpty ? 'c-$name' : id,
      username: username,
      name: name,
      issuer: 'משרד העבודה',
      expiry: expiry,
      addedTs: DateTime(2020, 1, 1),
    );

void main() {
  final now = DateTime(2026, 6, 14); // matches the project's "today"

  group('workerDocsReadiness under a required-docs policy (PURE)', () {
    test('a required type with NO matching cert blocks', () {
      final r = workerDocsReadiness(
        username: 'ran',
        forms: WorkerFormsState(forms: [_signed101('ran', now.year)]),
        certs: const [],
        now: now,
        requiredCertNames: const ['היתר עבודה בגובה'],
      );
      expect(r.ready, isFalse);
      expect(r.missing, contains('חסרה תעודה נדרשת: היתר עבודה בגובה'));
    });

    test('a present VALID cert of the required type satisfies it', () {
      final r = workerDocsReadiness(
        username: 'ran',
        forms: WorkerFormsState(forms: [_signed101('ran', now.year)]),
        certs: [_cert('ran', 'היתר עבודה בגובה', DateTime(2030, 1, 1))],
        now: now,
        requiredCertNames: const ['היתר עבודה בגובה'],
      );
      expect(r.ready, isTrue);
      expect(r.missing, isEmpty);
    });

    test('an EXPIRED cert of the required name does NOT satisfy it', () {
      final r = workerDocsReadiness(
        username: 'ran',
        forms: WorkerFormsState(forms: [_signed101('ran', now.year)]),
        certs: [_cert('ran', 'היתר עבודה בגובה', DateTime(2025, 1, 1))],
        now: now,
        requiredCertNames: const ['היתר עבודה בגובה'],
      );
      expect(r.ready, isFalse);
      // Both the expired-cert block AND the unmet-requirement line are honest.
      expect(r.missing, contains('תעודה פגה: היתר עבודה בגובה'));
      expect(r.missing, contains('חסרה תעודה נדרשת: היתר עבודה בגובה'));
    });

    test('NORMALIZED match — leading/trailing/case still satisfies', () {
      final r = workerDocsReadiness(
        username: 'ran',
        forms: WorkerFormsState(forms: [_signed101('ran', now.year)]),
        // cert name has leading/trailing whitespace vs. the requirement.
        certs: [_cert('ran', ' היתר עבודה בגובה ', DateTime(2030, 1, 1))],
        now: now,
        requiredCertNames: const ['היתר עבודה בגובה'],
      );
      expect(r.ready, isTrue);
      expect(r.missing, isEmpty);
    });

    test('empty policy = today behavior EXACTLY (back-compat)', () {
      final r = workerDocsReadiness(
        username: 'ran',
        forms: WorkerFormsState(forms: [_signed101('ran', now.year)]),
        certs: const [],
        now: now,
        requiredCertNames: const [], // no policy
      );
      expect(r.ready, isTrue);
      expect(r.missing, isEmpty);
    });

    test('a substring-only cert does NOT satisfy a longer requirement', () {
      // E2 guard: 'בטיחות' must NOT satisfy a 'בטיחות בגובה' requirement.
      final r = workerDocsReadiness(
        username: 'ran',
        forms: WorkerFormsState(forms: [_signed101('ran', now.year)]),
        certs: [_cert('ran', 'בטיחות', DateTime(2030, 1, 1))],
        now: now,
        requiredCertNames: const ['בטיחות בגובה'],
      );
      expect(r.ready, isFalse);
      expect(r.missing, contains('חסרה תעודה נדרשת: בטיחות בגובה'));
    });
  });

  group('regression — courier rule unchanged', () {
    test('courierDocsReadiness with all presets in-date is still READY', () {
      final certs = [
        for (final name in kCourierCertPresets)
          _cert('dudi', name, DateTime(2030, 1, 1), id: 'c-$name'),
      ];
      final r = courierDocsReadiness(username: 'dudi', certs: certs, now: now);
      expect(r.ready, isTrue);
      expect(r.missing, isEmpty);
    });

    test('courierDocsReadiness still blocks on a missing preset', () {
      final r = courierDocsReadiness(
        username: 'dudi',
        certs: const [],
        now: now,
      );
      expect(r.ready, isFalse);
      expect(r.missing, hasLength(kCourierCertPresets.length));
    });
  });
}

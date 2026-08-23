// #101 · שער-מוכנות מסמכים (HARD gate) — proof of the PURE readiness rule
// (worker + courier) and the live board gate.
//
//   PURE: workerDocsReadiness / courierDocsReadiness compute `ready` + the
//   honest missing/expiring lists from real forms/certs + a clock.
//   WIDGET: the worker board, with an UNREADY seeded session and NO override,
//   shows the '🔒 מסמכים חסרים…' gate and NOT the board ('🦺 עובד' AppBar);
//   flipping docsGateOverrideProvider→true opens the board.

import 'package:buildsmart/screens/worker_app_screen.dart';
import 'package:buildsmart/state/docs_readiness.dart';
import 'package:buildsmart/state/worker_certs.dart';
import 'package:buildsmart/state/worker_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A signed + declared Form101 for (username, year) — the readiness "happy" 101.
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

  group('workerDocsReadiness (PURE)', () {
    test('READY — signed current-year 101 + no expired cert', () {
      final state = WorkerFormsState(forms: [_signed101('ran', now.year)]);
      final r = workerDocsReadiness(
        username: 'ran',
        forms: state,
        certs: [_cert('ran', 'היתר עבודה בגובה', DateTime(2030, 1, 1))],
        now: now,
      );
      expect(r.ready, isTrue);
      expect(r.missing, isEmpty);
      expect(r.expiring, isEmpty);
    });

    test('NOT ready — no 101 at all', () {
      final r = workerDocsReadiness(
        username: 'ran',
        forms: const WorkerFormsState(),
        certs: const [],
        now: now,
      );
      expect(r.ready, isFalse);
      expect(r.missing, contains('טופס 101 חתום לשנת ${now.year}'));
    });

    test('NOT ready — 101 exists but UNSIGNED (no signature)', () {
      final unsigned = _signed101('ran', now.year).copyWith(signature: '');
      final r = workerDocsReadiness(
        username: 'ran',
        forms: WorkerFormsState(forms: [unsigned]),
        certs: const [],
        now: now,
      );
      expect(r.ready, isFalse);
      expect(r.missing, contains('טופס 101 חתום לשנת ${now.year}'));
    });

    test('NOT ready — 101 signed but declaration NOT ticked', () {
      final undeclared = _signed101('ran', now.year).copyWith(declared: false);
      final r = workerDocsReadiness(
        username: 'ran',
        forms: WorkerFormsState(forms: [undeclared]),
        certs: const [],
        now: now,
      );
      expect(r.ready, isFalse);
    });

    test('NOT ready — a signed 101 but an EXPIRED cert blocks', () {
      final r = workerDocsReadiness(
        username: 'ran',
        forms: WorkerFormsState(forms: [_signed101('ran', now.year)]),
        certs: [_cert('ran', 'היתר עבודה בגובה', DateTime(2025, 1, 1))],
        now: now,
      );
      expect(r.ready, isFalse);
      expect(r.missing, contains('תעודה פגה: היתר עבודה בגובה'));
    });

    test('READY with a WARNING — expiringSoon cert does NOT block', () {
      // 10 days out ⇒ expiringSoon (≤31) — a warning, not a block.
      final r = workerDocsReadiness(
        username: 'ran',
        forms: WorkerFormsState(forms: [_signed101('ran', now.year)]),
        certs: [_cert('ran', 'היתר עבודה בגובה', now.add(const Duration(days: 10)))],
        now: now,
      );
      expect(r.ready, isTrue);
      expect(r.missing, isEmpty);
      expect(r.expiring, contains('תעודה תפוג בקרוב: היתר עבודה בגובה'));
    });

    test('a 101 for a DIFFERENT year does not satisfy the current year', () {
      final r = workerDocsReadiness(
        username: 'ran',
        forms: WorkerFormsState(forms: [_signed101('ran', now.year - 1)]),
        certs: const [],
        now: now,
      );
      expect(r.ready, isFalse);
    });

    test("another user's expired cert does not block this user", () {
      final r = workerDocsReadiness(
        username: 'ran',
        forms: WorkerFormsState(forms: [_signed101('ran', now.year)]),
        // omer's expired cert — filtered out by username.
        certs: [_cert('omer', 'היתר עבודה בגובה', DateTime(2025, 1, 1))],
        now: now,
      );
      expect(r.ready, isTrue);
    });
  });

  group('courierDocsReadiness (PURE)', () {
    // All three required presets, all in-date ⇒ ready.
    List<WorkerCert> allPresets(String u, DateTime exp) => [
          _cert(u, 'רישיון נהיגה', exp, id: 'c1'),
          _cert(u, 'ביטוח רכב', exp, id: 'c2'),
          _cert(u, 'רישיון רכב', exp, id: 'c3'),
        ];

    test('READY — all 3 presets present and in-date', () {
      final r = courierDocsReadiness(
        username: 'dudi',
        certs: allPresets('dudi', DateTime(2030, 1, 1)),
        now: now,
      );
      expect(r.ready, isTrue);
      expect(r.missing, isEmpty);
    });

    test('NOT ready — a required preset is missing', () {
      final r = courierDocsReadiness(
        username: 'dudi',
        certs: [
          _cert('dudi', 'רישיון נהיגה', DateTime(2030, 1, 1), id: 'c1'),
          _cert('dudi', 'ביטוח רכב', DateTime(2030, 1, 1), id: 'c2'),
          // 'רישיון רכב' absent
        ],
        now: now,
      );
      expect(r.ready, isFalse);
      expect(r.missing, contains('חסרה תעודה: רישיון רכב'));
    });

    test('NOT ready — all present but one EXPIRED blocks', () {
      final certs = [
        _cert('dudi', 'רישיון נהיגה', DateTime(2030, 1, 1), id: 'c1'),
        _cert('dudi', 'ביטוח רכב', DateTime(2030, 1, 1), id: 'c2'),
        _cert('dudi', 'רישיון רכב', DateTime(2025, 1, 1), id: 'c3'), // expired
      ];
      final r = courierDocsReadiness(username: 'dudi', certs: certs, now: now);
      expect(r.ready, isFalse);
      expect(r.missing, contains('תעודה פגה: רישיון רכב'));
    });

    test('NOT ready — no certs at all → all three missing', () {
      final r = courierDocsReadiness(username: 'dudi', certs: const [], now: now);
      expect(r.ready, isFalse);
      expect(r.missing, hasLength(3));
    });
  });

  // Two SEPARATE tests: Riverpod forbids changing the number of overrides on a
  // re-pump of the same ProviderScope (0→1), so the "no override" and "with
  // override" cases each get their own fresh pump.
  testWidgets(
      'worker board: an UNREADY session is HARD-blocked by the docs gate '
      '(real predicate, no override)', (t) async {
    // Seed an UNREADY worker (ran): a logged session but NO signed 101 / certs.
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"worker","username":"ran","displayName":"רן","demo":false}',
    });
    await t.binding.setSurfaceSize(const Size(440, 1000));
    addTearDown(() => t.binding.setSurfaceSize(null));

    // No override → the HARD gate (the real workerDocsReadyProvider) blocks it.
    await t.pumpWidget(
      const ProviderScope(child: MaterialApp(home: WorkerAppScreen())),
    );
    await t.pump();
    await t.pump(const Duration(milliseconds: 100)); // boardAuth _load resolves

    expect(find.text('🔒 מסמכים חסרים — לא ניתן להתחיל עבודה'), findsOneWidget);
    // The blocking reason is shown honestly (current tax year).
    expect(find.text('טופס 101 חתום לשנת ${DateTime.now().year}'),
        findsOneWidget);
    // The board itself is NOT built (its AppBar title is absent).
    expect(find.text('🦺 עובד'), findsNothing);
  });

  testWidgets(
      'worker board: the docsGateOverride seam opens the board (bypass)',
      (t) async {
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"worker","username":"ran","displayName":"רן","demo":false}',
    });
    await t.binding.setSurfaceSize(const Size(440, 1000));
    addTearDown(() => t.binding.setSurfaceSize(null));

    // The test seam forces the gate open → the board renders (no gate).
    await t.pumpWidget(
      ProviderScope(
        overrides: [docsGateOverrideProvider.overrideWith((ref) => true)],
        child: const MaterialApp(home: WorkerAppScreen()),
      ),
    );
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));

    expect(find.text('🦺 עובד'), findsOneWidget);
    expect(find.text('🔒 מסמכים חסרים — לא ניתן להתחיל עבודה'), findsNothing);
  });
}

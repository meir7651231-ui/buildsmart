// Guard tests for cluster #85ח · בקשות חופשה — lib/state/vacation_requests.dart.
// The shared HR queue both boards watch: the WORKER submits (→ pending), the
// MANAGER approves/rejects (stamping decidedTs); a decision is final (re-decide
// is a no-op), the queue persists under 'bs.vacation-requests.v1' and survives
// a simulated restart (providers are LAZY — touch before settle), and a late
// _load() never clobbers a fresh submit (the ticket-#24 _userTouched race,
// mirrored from board_auth_test.dart).
//
// #86.3 — the queue now serves the COURIER board too: [VacationRequest.role]
// ('worker' default · 'courier') rides through submit → toJson ('role' key) →
// restart; an OLD persisted record carries no 'role' and must decode as
// 'worker' (back-compat — every pre-courier request really was a worker's).
import 'dart:convert';

import 'package:buildsmart/state/vacation_requests.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('submit — files a PENDING request carrying the session identity',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(vacationRequestsProvider.notifier);

    final r = n.submit(
      username: 'ran',
      workerName: 'רן',
      from: DateTime(2026, 6, 12),
      to: DateTime(2026, 6, 14),
      reason: '  חתונה משפחתית  ',
    );

    expect(r.status, kVacationPending,
        reason: 'a fresh request starts pending — the manager decides');
    expect(r.username, 'ran');
    expect(r.workerName, 'רן');
    expect(r.reason, 'חתונה משפחתית', reason: 'free-text reason is trimmed');
    expect(r.decidedTs, isNull, reason: 'no decision yet → no decidedTs');
    expect(r.range, '12.6.2026–14.6.2026',
        reason: 'the human range both boards render');
    expect(c.read(vacationRequestsProvider).single.id, r.id,
        reason: 'the submit landed in the shared queue');
  });

  test('single-day request renders one date (no dash range)', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final r = c.read(vacationRequestsProvider.notifier).submit(
          username: 'omer',
          workerName: 'עומר',
          from: DateTime(2026, 7, 1),
          to: DateTime(2026, 7, 1),
          reason: '',
        );
    expect(r.range, '1.7.2026');
    expect(r.reason, '', reason: 'an empty reason is allowed');
  });

  test('create → pending → approve flow stamps decidedTs; decision is final',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(vacationRequestsProvider.notifier);

    final r = n.submit(
      username: 'ran',
      workerName: 'רן',
      from: DateTime(2026, 6, 12),
      to: DateTime(2026, 6, 14),
      reason: 'חופשה',
    );
    expect(c.read(vacationRequestsProvider).single.status, kVacationPending);

    n.approve(r.id);
    final approved = c.read(vacationRequestsProvider).single;
    expect(approved.status, kVacationApproved,
        reason: 'manager approve flips pending → approved');
    expect(approved.decidedTs, isNotNull,
        reason: 'the decision moment is stamped');

    // A decided request is immutable — re-reject / re-approve are no-ops.
    n.reject(r.id);
    final still = c.read(vacationRequestsProvider).single;
    expect(still.status, kVacationApproved,
        reason: 'reject on a DECIDED request must be a no-op');
    expect(still.decidedTs, approved.decidedTs,
        reason: 'the original decision stamp is untouched');
  });

  test('reject flow — pending → rejected with decidedTs', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(vacationRequestsProvider.notifier);

    final r = n.submit(
      username: 'omer',
      workerName: 'עומר',
      from: DateTime(2026, 8, 2),
      to: DateTime(2026, 8, 6),
      reason: 'טיול',
    );
    n.reject(r.id);

    final rejected = c.read(vacationRequestsProvider).single;
    expect(rejected.status, kVacationRejected);
    expect(rejected.decidedTs, isNotNull);

    n.approve(r.id); // final — cannot resurrect
    expect(c.read(vacationRequestsProvider).single.status, kVacationRejected);
  });

  test('decision touches ONLY the given id', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(vacationRequestsProvider.notifier);

    final a = n.submit(
        username: 'ran',
        workerName: 'רן',
        from: DateTime(2026, 6, 12),
        to: DateTime(2026, 6, 12),
        reason: 'א');
    final b = n.submit(
        username: 'omer',
        workerName: 'עומר',
        from: DateTime(2026, 6, 20),
        to: DateTime(2026, 6, 21),
        reason: 'ב');

    n.approve(a.id);
    final byId = {
      for (final r in c.read(vacationRequestsProvider)) r.id: r,
    };
    expect(byId[a.id]!.status, kVacationApproved);
    expect(byId[b.id]!.status, kVacationPending,
        reason: 'the other request stays pending');
  });

  test('persist round-trip — queue + decision survive a simulated restart',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c1 = ProviderContainer();
    final n1 = c1.read(vacationRequestsProvider.notifier);
    final r = n1.submit(
      username: 'ran',
      workerName: 'רן',
      from: DateTime(2026, 6, 12),
      to: DateTime(2026, 6, 14),
      reason: 'חתונה',
    );
    n1.approve(r.id);
    await _settle(); // let _persist() finish before "shutting down"
    c1.dispose();

    // Fresh container = fresh notifier → must reload from prefs (lazy —
    // touch the provider so _load() actually starts).
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    c2.read(vacationRequestsProvider);
    await _settle();

    final restored = c2.read(vacationRequestsProvider).single;
    expect(restored.id, r.id);
    expect(restored.username, 'ran');
    expect(restored.workerName, 'רן');
    expect(restored.status, kVacationApproved,
        reason: 'the manager decision must survive an app restart');
    expect(restored.decidedTs, isNotNull);
    expect(restored.range, '12.6.2026–14.6.2026');
  });

  test('late _load does not clobber a fresh submit (#24 race guard)',
      () async {
    // Seed an OLD persisted queue, mutate synchronously before the lazy
    // notifier's async _load() resolves — the fresh write must survive.
    SharedPreferences.setMockInitialValues({
      kVacationRequestsKey: jsonEncode([
        VacationRequest(
          id: 'vac-old',
          username: 'omer',
          workerName: 'עומר',
          from: DateTime(2026, 1, 5),
          to: DateTime(2026, 1, 6),
          reason: 'ישן',
          createdTs: DateTime(2026, 1, 1),
        ).toJson(),
      ]),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(vacationRequestsProvider.notifier);

    final fresh = n.submit(
      username: 'ran',
      workerName: 'רן',
      from: DateTime(2026, 6, 12),
      to: DateTime(2026, 6, 12),
      reason: 'טרי',
    );
    await _settle();

    final ids = c.read(vacationRequestsProvider).map((r) => r.id).toList();
    expect(ids, contains(fresh.id),
        reason: 'the fresh submit must survive the late prefs load');
    expect(ids, isNot(contains('vac-old')),
        reason: 'the late load is dropped once a user write landed');
  });

  test('corrupt persisted payload — load keeps an empty queue, no crash',
      () async {
    SharedPreferences.setMockInitialValues({kVacationRequestsKey: '[broken'});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(vacationRequestsProvider); // lazy — start its _load()
    await _settle();

    expect(c.read(vacationRequestsProvider), isEmpty,
        reason: 'a corrupt payload is dropped, never thrown');
  });

  // ── #86.3 · role — the shared queue serves the courier board too ─────────

  test('#86.3 role — submit defaults to worker; role:courier is preserved',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(vacationRequestsProvider.notifier);

    // The demo username is SHARED across roles — exactly the case that makes
    // username-only "mine" filtering wrong (vacation_requests.dart doc).
    final w = n.submit(
      username: 'demo',
      workerName: 'עובד דמו',
      from: DateTime(2026, 6, 20),
      to: DateTime(2026, 6, 21),
      reason: 'עובד',
    );
    final k = n.submit(
      username: 'demo',
      workerName: 'שליח דמו',
      from: DateTime(2026, 6, 22),
      to: DateTime(2026, 6, 23),
      reason: 'שליח',
      role: 'courier',
    );

    expect(w.role, 'worker',
        reason: 'no role argument → worker (legacy callers unchanged)');
    expect(k.role, 'courier',
        reason: 'the courier forms screen passes role:courier — must stick');

    // Filtering "mine" needs username && role (#86.3) — by role the shared
    // demo username separates cleanly.
    final all = c.read(vacationRequestsProvider);
    final courierMine =
        all.where((r) => r.username == 'demo' && r.role == 'courier');
    expect(courierMine.map((r) => r.id), [k.id],
        reason: "username+role isolates the courier's own requests");
    final workerMine =
        all.where((r) => r.username == 'demo' && r.role == 'worker');
    expect(workerMine.map((r) => r.id), [w.id],
        reason: "username+role isolates the worker's own requests");
  });

  test('#86.3 role round-trip — courier role survives a simulated restart '
      "(json carries 'role')", () async {
    SharedPreferences.setMockInitialValues({});
    final c1 = ProviderContainer();
    final n1 = c1.read(vacationRequestsProvider.notifier);
    final r = n1.submit(
      username: 'demo',
      workerName: 'שליח דמו',
      from: DateTime(2026, 7, 5),
      to: DateTime(2026, 7, 7),
      reason: 'חופשת שליח',
      role: 'courier',
    );
    await _settle(); // let _persist() finish before "shutting down"
    c1.dispose();

    // The persisted JSON itself carries the 'role' key (the wire contract the
    // back-compat decode keys off).
    final prefs = await SharedPreferences.getInstance();
    final stored =
        jsonDecode(prefs.getString(kVacationRequestsKey)!) as List;
    expect((stored.single as Map)['role'], 'courier',
        reason: "toJson must write 'role' so a restart can tell boards apart");

    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    c2.read(vacationRequestsProvider); // lazy — start its _load()
    await _settle();

    final restored = c2.read(vacationRequestsProvider).single;
    expect(restored.id, r.id);
    expect(restored.role, 'courier',
        reason: 'the courier role must survive an app restart');
  });

  test("#86.3 back-compat — old persisted record without 'role' decodes as "
      'worker', () async {
    // A pre-#86.3 payload — handcrafted WITHOUT a 'role' key (NOT via
    // toJson(), which now always writes it).
    SharedPreferences.setMockInitialValues({
      kVacationRequestsKey: jsonEncode([
        {
          'id': 'vac-legacy',
          'username': 'ran',
          'workerName': 'רן',
          'from': DateTime(2026, 2).toIso8601String(),
          'to': DateTime(2026, 2, 2).toIso8601String(),
          'reason': 'ישן',
          'createdTs': DateTime(2026, 1, 20).toIso8601String(),
          'status': kVacationPending,
        },
      ]),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(vacationRequestsProvider); // lazy — start its _load()
    await _settle();

    final r = c.read(vacationRequestsProvider).single;
    expect(r.id, 'vac-legacy');
    expect(r.role, 'worker',
        reason: "every pre-courier request really was a worker's (doc "
            'contract in vacation_requests.dart)');

    // Decoder contract directly: a non-string role is also coerced to worker.
    final coerced = VacationRequest.tryFromJson({
      'id': 'vac-x',
      'username': 'ran',
      'workerName': 'רן',
      'from': DateTime(2026, 3).toIso8601String(),
      'to': DateTime(2026, 3).toIso8601String(),
      'createdTs': DateTime(2026, 2, 20).toIso8601String(),
      'role': 42, // malformed — must fall back, never crash
    });
    expect(coerced!.role, 'worker',
        reason: 'a malformed role falls back to worker, never throws');
  });
}

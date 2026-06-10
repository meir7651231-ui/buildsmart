// Guard tests for cluster #85ח · בקשות חופשה — lib/state/vacation_requests.dart.
// The shared HR queue both boards watch: the WORKER submits (→ pending), the
// MANAGER approves/rejects (stamping decidedTs); a decision is final (re-decide
// is a no-op), the queue persists under 'bs.vacation-requests.v1' and survives
// a simulated restart (providers are LAZY — touch before settle), and a late
// _load() never clobbers a fresh submit (the ticket-#24 _userTouched race,
// mirrored from board_auth_test.dart).
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
}

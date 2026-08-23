// Wave H1c · CONTRACTOR vacation approval — lib/state/vacation_requests.dart.
// Per [[manager-is-platform-admin-not-hr]] the EMPLOYER (contractor), not the
// admin manager, decides worker vacation. Server-ready: each request carries an
// `employerId` so the contractor's queue (`requestsForEmployer`) scopes to THEIR
// own workers. This locks the FROZEN cross-file contract (Builder H1a engine):
//   • VacationRequest.employerId (default '', additive, back-compat decode → '')
//   • submit({...existing..., String employerId=''}) stamps it
//   • requestsForEmployer(String) — Provider.family, role=='worker' &&
//     employerId==arg, newest-first
//   • approve(id) / reject(id) UNCHANGED — the contractor reuses the SAME
//     decision logic on the SAME shared queue (ONE bell, manager untouched).
//
// A worker request files PENDING into the contractor's scoped queue; approve
// flips it to approved (and it leaves the pending filter); reject carries
// through; a request under a DIFFERENT/empty employerId is OUT of scope; and an
// OLD payload without an 'employerId' key decodes to '' (thus excluded from a
// non-empty-employer query — back-compat). ProviderContainer, Firebase-free —
// mirrors vacation_requests_test.dart.
import 'dart:convert';

import 'package:buildsmart/state/vacation_requests.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The contractor whose worker-HR queue is under test.
const String kEmployer = 'contractor-demo';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

/// Ids currently PENDING in the contractor's scoped queue.
Iterable<String> _pendingIds(ProviderContainer c) => c
    .read(requestsForEmployer(kEmployer))
    .where((r) => r.status == kVacationPending)
    .map((r) => r.id);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      "worker submit(employerId) lands PENDING in the contractor's scoped queue",
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
      reason: 'חתונה',
      role: 'worker',
      employerId: kEmployer,
    );

    expect(r.status, kVacationPending,
        reason: 'a fresh request starts pending — the contractor decides');
    expect(r.employerId, kEmployer,
        reason: 'submit stamps the employerId onto the request');

    final queue = c.read(requestsForEmployer(kEmployer));
    expect(queue.map((x) => x.id), [r.id],
        reason: "the worker request is in the contractor's scoped queue");
    expect(queue.single.status, kVacationPending);
    expect(_pendingIds(c), contains(r.id),
        reason: 'it shows up as a pending decision for the contractor');
  });

  test('contractor approve(id) → approved; the id leaves the pending filter',
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
      role: 'worker',
      employerId: kEmployer,
    );
    expect(_pendingIds(c), contains(r.id), reason: 'pending before the decision');

    // REUSE the unchanged manager decision logic — the contractor calls the
    // SAME approve(id) on the SAME shared queue (ONE bell, not a fork).
    n.approve(r.id);

    final decided = c.read(requestsForEmployer(kEmployer)).single;
    expect(decided.id, r.id,
        reason: 'the request stays in the contractor scope after a decision');
    expect(decided.status, kVacationApproved,
        reason: 'contractor approve flips pending → approved');
    expect(decided.decidedTs, isNotNull, reason: 'the decision moment is stamped');
    expect(_pendingIds(c), isNot(contains(r.id)),
        reason: 'an approved request drops out of the PENDING filter');
  });

  test('contractor reject(id) → rejected carries through the scoped queue',
      () async {
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
      role: 'worker',
      employerId: kEmployer,
    );

    n.reject(r.id);

    final decided = c.read(requestsForEmployer(kEmployer)).single;
    expect(decided.status, kVacationRejected,
        reason: 'contractor reject flips pending → rejected');
    expect(decided.decidedTs, isNotNull);
    expect(_pendingIds(c), isNot(contains(r.id)),
        reason: 'a rejected request also drops out of the PENDING filter');

    // Decision is final — the contractor reuses _decide's no-op-on-decided rule.
    n.approve(r.id);
    expect(c.read(requestsForEmployer(kEmployer)).single.status,
        kVacationRejected,
        reason: 'approve on a DECIDED request must be a no-op');
  });

  test(
      'SCOPE — a different/empty employerId is NOT in this contractor\'s queue',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(vacationRequestsProvider.notifier);

    final mine = n.submit(
      username: 'ran',
      workerName: 'רן',
      from: DateTime(2026, 6, 12),
      to: DateTime(2026, 6, 14),
      reason: 'שלי',
      role: 'worker',
      employerId: kEmployer,
    );
    final otherEmployer = n.submit(
      username: 'gad',
      workerName: 'גד',
      from: DateTime(2026, 6, 15),
      to: DateTime(2026, 6, 16),
      reason: 'מעסיק אחר',
      role: 'worker',
      employerId: 'contractor-other',
    );
    final noEmployer = n.submit(
      username: 'dan',
      workerName: 'דן',
      from: DateTime(2026, 6, 17),
      to: DateTime(2026, 6, 18),
      reason: 'ללא מעסיק',
      role: 'worker',
      // employerId omitted → defaults to ''
    );

    final ids = c.read(requestsForEmployer(kEmployer)).map((r) => r.id).toList();
    expect(ids, [mine.id],
        reason: 'only requests stamped with THIS employerId are in scope');
    expect(ids, isNot(contains(otherEmployer.id)),
        reason: "another contractor's worker request must not leak in");
    expect(ids, isNot(contains(noEmployer.id)),
        reason: 'an unscoped (empty employerId) request must not leak in');

    // The default really is empty (server-ready additive contract).
    expect(noEmployer.employerId, '',
        reason: 'submit without employerId defaults to empty string');
  });

  test(
      'SCOPE — a courier request under the same employerId is NOT in the '
      'queue (worker-only)', () async {
    // requestsForEmployer filters role=='worker' too: the contractor's HR queue
    // is worker vacation, not the store-courier queue (#86.3 role split).
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(vacationRequestsProvider.notifier);

    final worker = n.submit(
      username: 'ran',
      workerName: 'רן',
      from: DateTime(2026, 6, 12),
      to: DateTime(2026, 6, 14),
      reason: 'עובד',
      role: 'worker',
      employerId: kEmployer,
    );
    final courier = n.submit(
      username: 'kobi',
      workerName: 'קובי',
      from: DateTime(2026, 6, 20),
      to: DateTime(2026, 6, 21),
      reason: 'שליח',
      role: 'courier',
      employerId: kEmployer,
    );

    final ids = c.read(requestsForEmployer(kEmployer)).map((r) => r.id).toList();
    expect(ids, [worker.id],
        reason: 'the worker request is in the contractor queue');
    expect(ids, isNot(contains(courier.id)),
        reason: 'a courier request is filtered out (role=="worker" scope)');
  });

  test('queue is newest-first', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(vacationRequestsProvider.notifier);

    final first = n.submit(
      username: 'ran',
      workerName: 'רן',
      from: DateTime(2026, 6, 1),
      to: DateTime(2026, 6, 2),
      reason: 'ראשון',
      role: 'worker',
      employerId: kEmployer,
    );
    final second = n.submit(
      username: 'omer',
      workerName: 'עומר',
      from: DateTime(2026, 6, 3),
      to: DateTime(2026, 6, 4),
      reason: 'שני',
      role: 'worker',
      employerId: kEmployer,
    );

    expect(c.read(requestsForEmployer(kEmployer)).map((r) => r.id),
        [second.id, first.id],
        reason: 'the contractor queue lists the newest request first');
  });

  test(
      "back-compat — an OLD payload without 'employerId' decodes to '' and is "
      'excluded from a non-empty-employer query', () async {
    // A pre-H1 persisted record — handcrafted WITHOUT an 'employerId' key (NOT
    // via toJson, which uses field-economy and omits empty employerId anyway).
    // It must decode to employerId=='' (additive back-compat) and therefore
    // fall OUTSIDE the contractor's non-empty-employer queue.
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
          'role': 'worker',
          // NOTE: no 'employerId' key — the pre-H1 wire shape.
        },
      ]),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(vacationRequestsProvider); // lazy — start its _load()
    await _settle();

    final loaded = c.read(vacationRequestsProvider).single;
    expect(loaded.id, 'vac-legacy');
    expect(loaded.employerId, '',
        reason: "a role-less, employerId-less legacy record decodes to '' "
            '(additive back-compat default)');

    expect(c.read(requestsForEmployer(kEmployer)), isEmpty,
        reason: 'an unscoped legacy request is excluded from a contractor '
            'queue (non-empty employerId)');

    // Decoder contract directly — a record whose 'employerId' key is absent
    // decodes to '' (the additive `raw['employerId'] as String? ?? ''`
    // default), exactly the pre-H1 wire shape above but asserted on tryFromJson.
    final decoded = VacationRequest.tryFromJson({
      'id': 'vac-x',
      'username': 'ran',
      'workerName': 'רן',
      'from': DateTime(2026, 3).toIso8601String(),
      'to': DateTime(2026, 3).toIso8601String(),
      'createdTs': DateTime(2026, 2, 20).toIso8601String(),
      'role': 'worker',
      // no 'employerId' key
    });
    expect(decoded!.employerId, '',
        reason: 'a record without an employerId key decodes to empty');
  });
}

// Wave H2a · CONTRACTOR training approval — lib/state/worker_trainings.dart.
// Per [[manager-is-platform-admin-not-hr]] the EMPLOYER (contractor) decides a
// worker's training, not the admin manager. Server-ready: each training carries
// an `employerId` so the contractor's queue (`trainingsForEmployer`) scopes to
// THEIR workers, and trainings gain a real approve/reject lifecycle:
//   • WorkerTraining.employerId (default '', additive, back-compat decode → '')
//   • add({...existing..., String employerId=''}) stamps it
//   • trainingsForEmployer(String) — Provider.family, employerId==arg,
//     newest-first
//   • approve(id) → kTrainingApproved · reject(id) → kTrainingRejected, both
//     no-op once decided (the _decide guard is status==pending). Decisions flow
//     through the SAME shared provider, so the worker's own forUser() list flips
//     live (the cross-persona pattern, mirrors contractor_vacation_approval).
//
// A training lands in the contractor's scoped queue; sendForApproval flips it to
// pending; approve flips pending → approved AND the worker's forUser() shows it;
// reject carries through; approve on a non-pending (recorded) row is a no-op; a
// decision touches ONLY the given id; the queue is newest-first.
// ProviderContainer, Firebase-free.
import 'package:buildsmart/state/worker_trainings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The contractor whose worker-training queue is under test.
const String kEmployer = 'contractor-demo';

/// An EMPTY (not absent) persisted store so the demo seed does NOT run — the
/// queue stays hermetic and we assert only our own added rows.
void _emptyStore() => SharedPreferences.setMockInitialValues({
      kWorkerTrainingsKey: '[]',
    });

/// Ids currently PENDING in the contractor's scoped queue.
Iterable<String> _pendingIds(ProviderContainer c) => c
    .read(trainingsForEmployer(kEmployer))
    .where((t) => t.status == kTrainingPending)
    .map((t) => t.id);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("add(employerId) lands in the contractor's scoped queue", () async {
    _emptyStore();
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerTrainingsProvider.notifier);

    final t = await n.add(
      username: 'ran',
      title: 'עבודה בגובה',
      by: 'ממונה בטיחות',
      date: DateTime(2026, 3, 12),
      employerId: kEmployer,
    );
    expect(t, isNotNull);
    expect(t!.employerId, kEmployer, reason: 'add stamps the employerId');
    expect(t.status, kTrainingRecorded, reason: 'a fresh training is recorded');

    final queue = c.read(trainingsForEmployer(kEmployer));
    expect(queue.map((x) => x.id), [t.id],
        reason: "the training is in the contractor's scoped queue");
  });

  test('sendForApproval → pending (still in the queue, now a decision)',
      () async {
    _emptyStore();
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerTrainingsProvider.notifier);

    final t = await n.add(
      username: 'ran',
      title: 'א',
      by: 'x',
      date: DateTime(2026, 1, 1),
      employerId: kEmployer,
    );
    n.sendForApproval(t!.id);

    final row = c.read(trainingsForEmployer(kEmployer)).single;
    expect(row.status, kTrainingPending,
        reason: 'recorded flips to pending — now the contractor decides');
    expect(_pendingIds(c), contains(t.id),
        reason: 'a pending training shows up as a decision for the contractor');
  });

  test('approve(id) → approved AND the worker\'s own forUser() flips live',
      () async {
    _emptyStore();
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerTrainingsProvider.notifier);

    final t = await n.add(
      username: 'ran',
      title: 'א',
      by: 'x',
      date: DateTime(2026, 1, 1),
      employerId: kEmployer,
    );
    n.sendForApproval(t!.id);
    expect(_pendingIds(c), contains(t.id), reason: 'pending before the decision');

    n.approve(t.id);

    final decided = c.read(trainingsForEmployer(kEmployer)).single;
    expect(decided.status, kTrainingApproved,
        reason: 'contractor approve flips pending → approved');
    expect(_pendingIds(c), isNot(contains(t.id)),
        reason: 'an approved training drops out of the PENDING filter');

    // BIDIRECTIONAL — the worker reads the SAME shared provider, so its own
    // list reflects the contractor's decision.
    final mine = n.forUser('ran');
    expect(mine.single.status, kTrainingApproved,
        reason: "the worker's own list reflects the approval (shared provider)");
  });

  test('reject(id) → rejected carries through the scoped queue', () async {
    _emptyStore();
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerTrainingsProvider.notifier);

    final t = await n.add(
      username: 'omer',
      title: 'ב',
      by: 'x',
      date: DateTime(2026, 2, 1),
      employerId: kEmployer,
    );
    n.sendForApproval(t!.id);
    n.reject(t.id);

    final decided = c.read(trainingsForEmployer(kEmployer)).single;
    expect(decided.status, kTrainingRejected,
        reason: 'contractor reject flips pending → rejected');
    expect(_pendingIds(c), isNot(contains(t.id)),
        reason: 'a rejected training also drops out of the PENDING filter');
    expect(n.forUser('omer').single.status, kTrainingRejected,
        reason: "the worker's own list reflects the rejection");
  });

  test('approve on a non-pending (recorded) training is a no-op', () async {
    _emptyStore();
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerTrainingsProvider.notifier);

    final t = await n.add(
      username: 'ran',
      title: 'א',
      by: 'x',
      date: DateTime(2026, 1, 1),
      employerId: kEmployer,
    );
    expect(t!.status, kTrainingRecorded, reason: 'never sent for approval');

    // _decide guards on status==pending, so a recorded row is untouched.
    n.approve(t.id);
    expect(c.read(trainingsForEmployer(kEmployer)).single.status,
        kTrainingRecorded,
        reason: 'approve must NOT skip the pending step (recorded stays recorded)');

    // And a decision is final — approve after reject is a no-op too.
    n.sendForApproval(t.id);
    n.reject(t.id);
    n.approve(t.id);
    expect(c.read(trainingsForEmployer(kEmployer)).single.status,
        kTrainingRejected,
        reason: 'approve on a DECIDED (rejected) training must be a no-op');
  });

  test('a decision touches ONLY the given id', () async {
    _emptyStore();
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerTrainingsProvider.notifier);

    final a = await n.add(
      username: 'ran',
      title: 'א',
      by: 'x',
      date: DateTime(2026, 1, 1),
      employerId: kEmployer,
    );
    final b = await n.add(
      username: 'omer',
      title: 'ב',
      by: 'x',
      date: DateTime(2026, 2, 1),
      employerId: kEmployer,
    );
    n.sendForApproval(a!.id);
    n.sendForApproval(b!.id);

    n.approve(a.id);

    final byId = {
      for (final t in c.read(trainingsForEmployer(kEmployer))) t.id: t.status,
    };
    expect(byId[a.id], kTrainingApproved, reason: 'the targeted row is approved');
    expect(byId[b.id], kTrainingPending,
        reason: 'the other pending row is untouched (id-scoped decision)');
  });

  test('queue is newest-first', () async {
    _emptyStore();
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerTrainingsProvider.notifier);

    final first = await n.add(
      username: 'ran',
      title: 'ראשון',
      by: 'x',
      date: DateTime(2026, 1, 1),
      employerId: kEmployer,
    );
    final second = await n.add(
      username: 'omer',
      title: 'שני',
      by: 'x',
      date: DateTime(2026, 2, 1),
      employerId: kEmployer,
    );

    expect(c.read(trainingsForEmployer(kEmployer)).map((t) => t.id),
        [second!.id, first!.id],
        reason: 'the contractor queue lists the newest training first');
  });

  test('DEMO-SEED — the demo rows are scoped to the demo contractor', () async {
    // A FRESH (absent-key) store seeds the 3 demo rows; they are stamped with
    // kDemoContractorId (== kEmployer here) so the demo contractor sees them.
    SharedPreferences.setMockInitialValues({}); // no key → seed runs
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(workerTrainingsProvider); // lazy — start its _load()/seed
    await Future<void>.delayed(const Duration(milliseconds: 60));

    final seeded = c.read(trainingsForEmployer(kEmployer));
    expect(seeded.length, 3,
        reason: 'the 3 demo rows are scoped to the demo contractor');
    expect(seeded.every((t) => t.username == kTrainingDemoUser), isTrue);
  });
}

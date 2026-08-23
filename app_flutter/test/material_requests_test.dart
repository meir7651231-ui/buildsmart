// Wave E3b · material-request engine tests — Firebase-free (ProviderContainer +
// mock SharedPreferences), the `vacation_requests_test.dart` idiom. Asserts the
// bidirectional-live contract the worker board (submit) and the contractor inbox
// (setStatus) both depend on:
//   • a worker submit appears live in BOTH the contractor's `requestsForEmployer`
//     view AND the worker's own `requestsForWorker` view, status=requested;
//   • a contractor `setStatus(ordered → supplied)` reflects live in the worker's
//     `requestsForWorker` view (each step);
//   • empty/whitespace item lines are dropped (אין-המצאות);
//   • two rapid submits mint distinct ids (the `_seq` collision guard).
//
// The engine is constructed through `materialRequestsProvider` so the test
// exercises the real provider graph the UI uses — no internals reached into.

import 'package:buildsmart/state/material_requests_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const employerId = 'contractor-demo';
  const workerUid = 'worker-uid-1';
  const workerName = 'דני העובד';

  group('material requests · bidirectional-live', () {
    test(
        'worker submit → appears in BOTH requestsForEmployer AND '
        'requestsForWorker with status=requested', () {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final id = c.read(materialRequestsProvider.notifier).submit(
        employerId: employerId,
        workerUid: workerUid,
        username: workerUid,
        workerName: workerName,
        items: const ['מלט', 'חול'],
        note: 'דחוף לאתר',
      );

      // Contractor inbox view (the E3b sheet reads this).
      final employerView = c.read(requestsForEmployer(employerId));
      expect(employerView, hasLength(1));
      expect(employerView.single.id, id);
      expect(employerView.single.workerName, workerName);
      expect(employerView.single.items, const ['מלט', 'חול']);
      expect(employerView.single.note, 'דחוף לאתר');
      expect(employerView.single.status, kMatReqRequested);

      // Worker's own view (the E3a sheet reads this) — the SAME request, live.
      final workerView = c.read(requestsForWorker(workerUid));
      expect(workerView, hasLength(1));
      expect(workerView.single.id, id);
      expect(workerView.single.status, kMatReqRequested);
    });

    test(
        'contractor setStatus(ordered) then (supplied) → the worker\'s '
        'requestsForWorker view reflects each step live', () {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final id = c.read(materialRequestsProvider.notifier).submit(
        employerId: employerId,
        workerUid: workerUid,
        username: workerUid,
        workerName: workerName,
        items: const ['ברגים'],
      );

      // requested → ordered: the worker sees 'ordered' live.
      c.read(materialRequestsProvider.notifier).setStatus(id, kMatReqOrdered);
      expect(
        c.read(requestsForWorker(workerUid)).single.status,
        kMatReqOrdered,
      );
      // The contractor inbox view agrees (same engine, same request).
      expect(
        c.read(requestsForEmployer(employerId)).single.status,
        kMatReqOrdered,
      );

      // ordered → supplied: the worker sees 'supplied' live.
      c.read(materialRequestsProvider.notifier).setStatus(id, kMatReqSupplied);
      expect(
        c.read(requestsForWorker(workerUid)).single.status,
        kMatReqSupplied,
      );
    });

    test('contractor can decline a request → status=declined live', () {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final id = c.read(materialRequestsProvider.notifier).submit(
        employerId: employerId,
        workerUid: workerUid,
        username: workerUid,
        workerName: workerName,
        items: const ['צבע'],
      );

      c.read(materialRequestsProvider.notifier).setStatus(id, kMatReqDeclined);
      expect(
        c.read(requestsForWorker(workerUid)).single.status,
        kMatReqDeclined,
      );
    });

    test('a terminal request (supplied) is not re-opened by a later setStatus',
        () {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final id = c.read(materialRequestsProvider.notifier).submit(
        employerId: employerId,
        workerUid: workerUid,
        username: workerUid,
        workerName: workerName,
        items: const ['דבק'],
      );

      c.read(materialRequestsProvider.notifier).setStatus(id, kMatReqSupplied);
      // Attempt to walk it back — the engine guards terminal requests.
      c.read(materialRequestsProvider.notifier).setStatus(id, kMatReqOrdered);
      expect(
        c.read(requestsForWorker(workerUid)).single.status,
        kMatReqSupplied,
      );
    });

    test('empty / whitespace-only item lines are dropped (אין-המצאות)', () {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final id = c.read(materialRequestsProvider.notifier).submit(
        employerId: employerId,
        workerUid: workerUid,
        username: workerUid,
        workerName: workerName,
        items: const ['מלט', '   ', '', '  חול  '],
      );

      final r = c.read(requestsForEmployer(employerId)).single;
      expect(r.id, id);
      // Blank lines gone; surviving lines trimmed — only what was actually typed.
      expect(r.items, const ['מלט', 'חול']);
    });

    test('two rapid submits mint distinct ids (the _seq collision guard)', () {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final notifier = c.read(materialRequestsProvider.notifier);
      final id1 = notifier.submit(
        employerId: employerId,
        workerUid: workerUid,
        username: workerUid,
        workerName: workerName,
        items: const ['פריט 1'],
      );
      final id2 = notifier.submit(
        employerId: employerId,
        workerUid: workerUid,
        username: workerUid,
        workerName: workerName,
        items: const ['פריט 2'],
      );

      expect(id1, isNot(equals(id2)));
      expect(c.read(requestsForEmployer(employerId)), hasLength(2));
    });

    test(
        'requestsForEmployer scopes to the addressed contractor only '
        '(another employer\'s request is not in this inbox)', () {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final notifier = c.read(materialRequestsProvider.notifier);
      notifier.submit(
        employerId: employerId,
        workerUid: workerUid,
        username: workerUid,
        workerName: workerName,
        items: const ['שלי'],
      );
      notifier.submit(
        employerId: 'other-contractor',
        workerUid: 'other-worker',
        username: 'other-worker',
        workerName: 'מישהו אחר',
        items: const ['לא שלי'],
      );

      final mine = c.read(requestsForEmployer(employerId));
      expect(mine, hasLength(1));
      expect(mine.single.items, const ['שלי']);
    });

    test(
        'requestsForWorker scopes per-USERNAME even when workerUid is empty '
        '(the seed-session cross-user leak)', () {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final n = c.read(materialRequestsProvider.notifier);
      // Two seed workers: BOTH carry workerUid '' (session.uid is unset on the
      // local/seed path) — only the username tells them apart.
      n.submit(
        employerId: employerId,
        workerUid: '',
        username: 'ran',
        workerName: 'רן',
        items: const ['מלט'],
      );
      n.submit(
        employerId: employerId,
        workerUid: '',
        username: 'omer',
        workerName: 'עומר',
        items: const ['חול'],
      );

      final ran = c.read(requestsForWorker('ran'));
      expect(ran, hasLength(1));
      expect(ran.single.items, const ['מלט']);
      // omer must NOT see ran's request (RED before the fix: both workerUid ''
      // → requestsForWorker('') returned BOTH).
      final omer = c.read(requestsForWorker('omer'));
      expect(omer, hasLength(1));
      expect(omer.single.items, const ['חול']);
    });
  });
}

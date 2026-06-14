// Guard tests for cluster #85ח · נוכחות עובד — lib/state/worker_attendance.dart.
// The notifier must be airtight: a clockIn→clockOut round-trip stamps both
// instants on ONE AttendanceDay (one shift per calendar day), the ledger
// persists under 'bs.worker-attendance.v1' and survives a simulated restart
// (fresh container re-reads prefs; providers are LAZY — touch before settle),
// the pure month-filter/total helpers the screen shares stay correct, and a
// late _load() never clobbers a fresh clock-in (the ticket-#24 _userTouched
// race, mirrored from board_auth_test.dart).
//
// P-15 (F-38) · the WIDGET-LEVEL sent-guard: once 'שלח דוח נוכחות לקבלן' posts
// the monthly report into th-worker-contractor, the button flips to a disabled
// 'הדוח נשלח ✓' and a second tap CANNOT post a duplicate report line.
import 'dart:convert';

import 'package:buildsmart/screens/worker_attendance_screen.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/worker_attendance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('clockIn → clockOut round-trip stamps both instants on one record',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerAttendanceProvider.notifier);

    expect(n.clockIn('ran'), true,
        reason: 'first clock-in of the day must succeed');
    // Make the shift measurably long so `worked` is strictly positive.
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(n.clockOut('ran'), true, reason: 'an open shift must close');

    final today = n.todayFor('ran');
    expect(today, isNotNull);
    expect(today!.date, attendanceDateKey(DateTime.now()));
    expect(today.inTs, isNotNull);
    expect(today.outTs, isNotNull);
    expect(today.worked, isNotNull,
        reason: 'a closed shift exposes its duration');
    expect(today.worked!.inMicroseconds, greaterThan(0),
        reason: 'clock-out after clock-in → positive worked duration');
    expect(c.read(workerAttendanceProvider).length, 1,
        reason: 'the whole round-trip is ONE AttendanceDay');
  });

  test('one shift per day — double clockIn / orphan clockOut are no-ops',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerAttendanceProvider.notifier);

    expect(n.clockOut('ran'), false,
        reason: 'no open clock-in → clockOut must refuse');
    expect(n.clockIn('ran'), true);
    expect(n.clockIn('ran'), false,
        reason: 'a second clock-in the same day must refuse');
    expect(n.clockOut('ran'), true);
    expect(n.clockOut('ran'), false,
        reason: 'already clocked out → clockOut is a no-op');
    expect(c.read(workerAttendanceProvider).length, 1);
  });

  test('per-username isolation — ran\'s shift never leaks to omer', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerAttendanceProvider.notifier);

    n.clockIn('ran');
    expect(n.todayFor('omer'), isNull,
        reason: 'omer has no record — the ledger is per-username (#66)');
    expect(n.clockOut('omer'), false,
        reason: 'omer cannot close ran\'s shift');
    expect(n.clockIn('omer'), true,
        reason: 'omer\'s own clock-in is independent of ran\'s');
    expect(c.read(workerAttendanceProvider).length, 2);
  });

  test('persist round-trip — the ledger survives a simulated restart',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c1 = ProviderContainer();
    final n1 = c1.read(workerAttendanceProvider.notifier);
    n1.clockIn('ran');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    n1.clockOut('ran');
    await _settle(); // let _persist() finish before "shutting down"
    c1.dispose();

    // Fresh container = fresh notifier → must reload from prefs. Providers
    // are lazy — touch it so the notifier (and its _load()) actually starts.
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    c2.read(workerAttendanceProvider);
    await _settle();

    final days = c2.read(workerAttendanceProvider);
    expect(days.length, 1,
        reason: 'the persisted day must survive an app restart');
    expect(days.single.username, 'ran');
    expect(days.single.date, attendanceDateKey(DateTime.now()));
    expect(days.single.inTs, isNotNull);
    expect(days.single.outTs, isNotNull);
    expect(days.single.worked!.inMicroseconds, greaterThan(0),
        reason: 'both stamps round-trip through prefs');
  });

  test(
      'monthly total — attendanceMonth filters user+month (sorted), '
      'attendanceTotal sums only CLOSED shifts', () {
    AttendanceDay d(String u, String date, int hours, {bool open = false}) {
      final inTs = DateTime.parse('${date}T08:00:00');
      return AttendanceDay(
        username: u,
        date: date,
        inTs: inTs,
        outTs: open ? null : inTs.add(Duration(hours: hours)),
      );
    }

    final all = [
      d('ran', '2026-06-02', 4), // out of order on purpose — must sort
      d('ran', '2026-06-01', 8),
      d('ran', '2026-06-03', 0, open: true), // still clocked in → counts 0
      d('ran', '2026-05-30', 9), // other month — excluded
      d('omer', '2026-06-01', 7), // other user — excluded
    ];

    final june = attendanceMonth(all, 'ran', 2026, 6);
    expect(june.map((x) => x.date).toList(),
        ['2026-06-01', '2026-06-02', '2026-06-03'],
        reason: 'user+month only, oldest→newest');
    expect(attendanceTotal(june), const Duration(hours: 12),
        reason: '8h + 4h; the open day honestly counts 0');
  });

  test('late _load does not clobber a fresh clock-in (#24 race guard)',
      () async {
    // Seed an OLD persisted ledger, mutate synchronously before the lazy
    // notifier's async _load() resolves, then assert the fresh write SURVIVED.
    SharedPreferences.setMockInitialValues({
      kWorkerAttendanceKey: jsonEncode([
        AttendanceDay(
          username: 'ran',
          date: '2026-01-05',
          inTs: DateTime(2026, 1, 5, 8),
          outTs: DateTime(2026, 1, 5, 16),
        ).toJson(),
      ]),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerAttendanceProvider.notifier);

    n.clockIn('ran'); // synchronous write BEFORE the async _load resolves
    await _settle();

    final today = n.todayFor('ran');
    expect(today, isNotNull,
        reason: 'the fresh clock-in must survive the late prefs load');
    expect(today!.inTs, isNotNull);
  });

  test('corrupt persisted payload — load keeps an empty ledger, no crash',
      () async {
    SharedPreferences.setMockInitialValues({kWorkerAttendanceKey: '{not json'});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(workerAttendanceProvider); // lazy — start its _load()
    await _settle();

    expect(c.read(workerAttendanceProvider), isEmpty,
        reason: 'a corrupt payload is dropped, never thrown');
    expect(c.read(workerAttendanceProvider.notifier).clockIn('ran'), true,
        reason: 'the notifier stays usable after a corrupt load');
  });

  // ── P-15 (F-38) · widget · send-report double-tap guard ──────────────────

  // Count the report lines '📋 דוח נוכחות …' currently in th-worker-contractor.
  int reportLines(ProviderContainer c) {
    final thread = c
        .read(chatEngineProvider)
        .firstWhere((t) => t.id == 'th-worker-contractor');
    return thread.messages
        .where((m) => m.text.startsWith('📋 דוח נוכחות'))
        .length;
  }

  testWidgets(
      'P-15 send-report — after sending the button shows "הדוח נשלח ✓" and a '
      'second tap does NOT post a duplicate report', (tester) async {
    // #65 gate: seed a logged-in worker session (ran) so the board renders.
    // Seed ONE closed shift for the current month so the report button is
    // enabled (monthDays.isNotEmpty) — built from DateTime.now() so it always
    // lands in the month the screen opens on.
    final now = DateTime.now();
    final todayKey = attendanceDateKey(now);
    final shiftIn = DateTime(now.year, now.month, now.day, 8);
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"worker","username":"ran","displayName":"רן","demo":false}',
      kWorkerAttendanceKey: jsonEncode([
        AttendanceDay(
          username: 'ran',
          date: todayKey,
          inTs: shiftIn,
          outTs: shiftIn.add(const Duration(hours: 8)),
        ).toJson(),
      ]),
    });

    // Own container so we can inspect the chat thread the report posts into.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: WorkerAttendanceScreen()),
      ),
    );
    await tester.pump();
    // Let the lazy boardAuthProvider + attendance _load() resolve, then rebuild
    // gate→board.
    await tester.pump(const Duration(milliseconds: 100));

    // Pre-condition: the board rendered with the active send label and no
    // report yet.
    expect(find.text('🕐 נוכחות'), findsOneWidget,
        reason: 'the worker attendance board rendered, not the gate');
    // #105 — the send button now sits below the monthly calendar grid inside a
    // lazy ListView, so scroll it into view before asserting/tapping.
    await tester.scrollUntilVisible(
      find.text('📨 שלח דוח נוכחות לקבלן'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('📨 שלח דוח נוכחות לקבלן'), findsOneWidget,
        reason: 'the seeded month has records → the send button is active');
    expect(find.text('הדוח נשלח ✓'), findsNothing);
    expect(reportLines(container), 0, reason: 'no report posted yet');

    // First tap — posts the report.
    await tester.tap(find.text('📨 שלח דוח נוכחות לקבלן'));
    await tester.pump();

    expect(reportLines(container), 1,
        reason: 'one tap posts exactly one report line to the contractor');
    expect(find.text('הדוח נשלח ✓'), findsOneWidget,
        reason: 'the button flips to the sent label (F-38 guard)');
    expect(find.text('📨 שלח דוח נוכחות לקבלן'), findsNothing,
        reason: 'the active label is gone once sent');

    // Second tap on the now-disabled sent label must be a no-op (the InkWell
    // onTap is null when !enabled) — no duplicate report.
    await tester.tap(find.text('הדוח נשלח ✓'), warnIfMissed: false);
    await tester.pump();

    expect(reportLines(container), 1,
        reason: 'the second tap cannot post a duplicate report (P-15)');
  });
}

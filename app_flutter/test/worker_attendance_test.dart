// Guard tests for cluster #85ח · נוכחות עובד — lib/state/worker_attendance.dart.
// The notifier must be airtight: a clockIn→clockOut round-trip stamps both
// instants on ONE AttendanceDay (one shift per calendar day), the ledger
// persists under 'bs.worker-attendance.v1' and survives a simulated restart
// (fresh container re-reads prefs; providers are LAZY — touch before settle),
// the pure month-filter/total helpers the screen shares stay correct, and a
// late _load() never clobbers a fresh clock-in (the ticket-#24 _userTouched
// race, mirrored from board_auth_test.dart).
import 'dart:convert';

import 'package:buildsmart/state/worker_attendance.dart';
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
}

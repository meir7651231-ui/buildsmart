// Wave S-a · CONTRACTOR view of worker attendance —
// lib/state/worker_attendance.dart. Mirrors the worker_certs H2a server-ready
// pattern: an AttendanceDay carries an `employerId` (the worker→contractor
// LINK) so the contractor's roster (`attendanceForEmployer`) scopes to THEIR
// workers, and `clockedInNow` (a pure helper sharing one definition with the
// sheet) names who is on-site today. This locks the additive cross-file
// contract:
//   • AttendanceDay.employerId (default '', additive, back-compat decode → '')
//   • clockIn(username, {..., String employerId=''}) stamps it at birth
//   • clockOut PRESERVES it (copyWith does not drop the field)
//   • attendanceForEmployer(String) — Provider.family, employerId==arg, worker
//     store only (couriers excluded by construction), insertion order
//   • clockedInNow(days, todayKey) — pure, open-day filter, no DateTime.now()
//
// ProviderContainer + SharedPreferences.setMockInitialValues, Firebase-free —
// harness mirrored from worker_attendance_test.dart / contractor_certs_test.dart.
import 'package:buildsmart/state/worker_attendance.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The contractor whose worker-attendance roster is under test.
const String kEmployer = 'c1';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('clockIn(employerId) lands in the contractor roster; other is empty',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerAttendanceProvider.notifier);

    expect(n.clockIn('ran', employerId: kEmployer), true,
        reason: 'first clock-in of the day must succeed');

    final today = n.todayFor('ran');
    expect(today, isNotNull);
    expect(today!.employerId, kEmployer,
        reason: 'clockIn stamps the employerId onto the day it is born');

    final mine = c.read(attendanceForEmployer(kEmployer));
    expect(mine.map((d) => d.username).toList(), ['ran'],
        reason: "the record is in THIS contractor's roster");
    expect(c.read(attendanceForEmployer('c2')), isEmpty,
        reason: "a different contractor's roster does not see ran");
  });

  test('SCOPE — an unstamped (empty employerId) record is excluded', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerAttendanceProvider.notifier);

    // ran is stamped with the employer; omer clocks in with no employerId
    // (back-compat / unstamped) and must fall OUTSIDE the non-empty query.
    expect(n.clockIn('ran', employerId: kEmployer), true);
    expect(n.clockIn('omer'), true,
        reason: 'omer clocks in without an employerId (defaults to "")');

    expect(n.todayFor('omer')!.employerId, '',
        reason: 'clockIn without employerId defaults to empty string');

    final roster = c.read(attendanceForEmployer(kEmployer));
    expect(roster.map((d) => d.username).toList(), ['ran'],
        reason: 'only records stamped with THIS employerId are in scope');
    expect(roster.map((d) => d.username), isNot(contains('omer')),
        reason: 'an unstamped (empty employerId) record must not leak in');
  });

  test('clockIn → clockOut PRESERVES the employerId (closed day still c1)',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerAttendanceProvider.notifier);

    expect(n.clockIn('ran', employerId: kEmployer), true);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(n.clockOut('ran'), true, reason: 'an open shift must close');

    final today = n.todayFor('ran');
    expect(today, isNotNull);
    expect(today!.outTs, isNotNull, reason: 'the day is now closed');
    expect(today.employerId, kEmployer,
        reason: 'clockOut (copyWith) must NOT drop the clock-in employerId');
    expect(c.read(attendanceForEmployer(kEmployer)).map((d) => d.username),
        ['ran'],
        reason: 'a closed shift stays in the contractor roster');
  });

  group('clockedInNow — open-day filter (pure, fixed todayKey)', () {
    const todayKey = '2026-06-14';

    AttendanceDay day(
      String username,
      String date, {
      required bool open,
    }) {
      final inTs = DateTime.parse('${date}T08:00:00');
      return AttendanceDay(
        username: username,
        date: date,
        inTs: inTs,
        outTs: open ? null : inTs.add(const Duration(hours: 8)),
        employerId: kEmployer,
      );
    }

    test('an open day today is listed; closed + other-day are NOT', () {
      final days = [
        day('ran', todayKey, open: true), // open today → ON-SITE
        day('omer', todayKey, open: false), // closed today → not on-site
        day('dan', '2026-06-13', open: true), // open but yesterday → not today
      ];

      final live = clockedInNow(days, todayKey);
      expect(live.map((d) => d.username).toList(), ['ran'],
          reason: 'only an open day on todayKey counts as clocked-in now');
      expect(live.map((d) => d.username), isNot(contains('omer')),
          reason: 'a closed (clocked-out) day is not on-site');
      expect(live.map((d) => d.username), isNot(contains('dan')),
          reason: "a different day's open record is not on-site today");
    });

    test('no open day today → empty', () {
      expect(clockedInNow([day('omer', todayKey, open: false)], todayKey),
          isEmpty);
    });
  });

  test('back-compat decode — a row without employerId loads as "" (no crash)',
      () {
    // Pre-S wire shape: the persisted JSON has no 'employerId' key. It must
    // decode to '' (additive back-compat) and stay OUT of a non-empty query.
    final decoded = AttendanceDay.tryFromJson({
      'username': 'ran',
      'date': '2026-01-05',
      'inTs': DateTime(2026, 1, 5, 8).toIso8601String(),
      'outTs': DateTime(2026, 1, 5, 16).toIso8601String(),
      'ilat': 32.1,
      'ilng': 34.8,
      // NOTE: no 'employerId' key — the pre-S persisted shape.
    });
    expect(decoded, isNotNull, reason: 'a legacy row still decodes');
    expect(decoded!.employerId, '',
        reason: 'a row without an employerId key decodes to empty');
    expect(decoded.username, 'ran');
    expect(decoded.inLat, 32.1, reason: 'existing fields still round-trip');

    // And such a row is excluded from a non-empty employer roster.
    expect(clockedInNow([decoded], '2026-01-05'), isEmpty,
        reason: 'a closed legacy day is not clocked-in now');
  });

  test('attendanceForEmployer — deterministic ledger insertion order',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerAttendanceProvider.notifier);

    // Two workers clock in under the same contractor, ran first then omer.
    // The roster keeps ledger insertion order (oldest→newest) — documented,
    // deterministic, free of timestamp-tie instability.
    expect(n.clockIn('ran', employerId: kEmployer), true);
    expect(n.clockIn('omer', employerId: kEmployer), true);
    await _settle();

    expect(c.read(attendanceForEmployer(kEmployer)).map((d) => d.username),
        ['ran', 'omer'],
        reason: 'the roster preserves the order rows were clocked in');
  });
}

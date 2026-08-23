// Guard tests for the WAVE-2 location surface of lib/state/worker_attendance.dart
// — AttendanceDay's optional GPS coordinates + the mapsQueryForDay formatter.
// The Wave-1 round-trip / persistence / send-report guard already live in
// worker_attendance_test.dart; this file covers ONLY the new state-level
// location surface (contract 1):
//
//   • toJson writes the coordinates under the on-disk contract keys
//     ilat/ilng/olat/olng and tryFromJson round-trips them back;
//   • back-compat: a pre-location payload (no ilat/… keys) decodes with null
//     coordinates and never crashes — both via tryFromJson directly AND via
//     the notifier's _load() from a legacy persisted ledger;
//   • clockIn(username, lat:, lng:) / clockOut(...) stamp the coordinates onto
//     that day's record (and stay null when no location is passed — honest, no
//     invented point);
//   • mapsQueryForDay → "lat,lng" when a clock-in coordinate exists, null
//     otherwise.
//
// SCOPE NOTE (contract 2 · tasksForDay, contract 3 · geo currentGeoFix):
// both are intentionally OUT of this file — see the test_run caveats. The pure
// helper tasksForDay and the GeoFix seam live in / behind files that transitively
// import services/geo.dart (→ package:web + dart:js_interop). With the worktree's
// pinned web-1.1.1 against Dart 3.12.0 those imports FAIL TO COMPILE on the
// native test VM, so neither can be exercised here (the EXISTING
// worker_attendance_test.dart, which imports the screen, is broken by the very
// same toolchain issue). Skipping per the brief ("אם לא ניתן לבידוד — caveats+דלג").
import 'dart:convert';

import 'package:buildsmart/state/worker_attendance.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── AttendanceDay GPS coordinates — toJson / tryFromJson round-trip ────────

  group('AttendanceDay — GPS location fields', () {
    test(
        'toJson writes ilat/ilng/olat/olng and tryFromJson round-trips them back',
        () {
      const day = AttendanceDay(
        username: 'ran',
        date: '2026-06-14',
        inLat: 32.0853,
        inLng: 34.7818,
        outLat: 32.1010,
        outLng: 34.8050,
      );
      final json = day.toJson();

      // The on-disk contract keys are the short ilat/ilng/olat/olng (NOT the
      // Dart field names) — the persisted ledger + back-compat depend on these.
      expect(json['ilat'], 32.0853);
      expect(json['ilng'], 34.7818);
      expect(json['olat'], 32.1010);
      expect(json['olng'], 34.8050);

      final back = AttendanceDay.tryFromJson(json);
      expect(back, isNotNull, reason: 'a well-formed map decodes');
      expect(back!.inLat, 32.0853);
      expect(back.inLng, 34.7818);
      expect(back.outLat, 32.1010);
      expect(back.outLng, 34.8050);
      expect(back.username, 'ran');
      expect(back.date, '2026-06-14');
    });

    test('numeric-string coordinates decode leniently (back-compat _tryDouble)',
        () {
      // A payload whose coordinates arrived as strings (e.g. a JSON source that
      // quoted the numbers) still decodes to doubles — never throws.
      final back = AttendanceDay.tryFromJson({
        'username': 'ran',
        'date': '2026-06-14',
        'ilat': '32.5',
        'ilng': '34.5',
      });
      expect(back, isNotNull);
      expect(back!.inLat, 32.5);
      expect(back.inLng, 34.5);
      expect(back.outLat, isNull);
      expect(back.outLng, isNull);
    });

    test('malformed coordinate value decodes to null, never throws', () {
      final back = AttendanceDay.tryFromJson({
        'username': 'ran',
        'date': '2026-06-14',
        'ilat': 'not-a-number',
        'ilng': {'nested': 'junk'},
      });
      expect(back, isNotNull, reason: 'the row still decodes');
      expect(back!.inLat, isNull, reason: 'an unparsable lat is null');
      expect(back.inLng, isNull, reason: 'a non-scalar lng is null');
    });

    test(
        'back-compat — a pre-location payload (no ilat/… keys) loads with null '
        'coordinates and never crashes', () async {
      // Simulate an OLD persisted ledger row that predates the location fields:
      // username/date/inTs/outTs but NONE of ilat/ilng/olat/olng. It must
      // decode without throwing, with all coordinates null.
      final legacyRow = {
        'username': 'ran',
        'date': '2026-01-05',
        'inTs': DateTime(2026, 1, 5, 8).toIso8601String(),
        'outTs': DateTime(2026, 1, 5, 16).toIso8601String(),
      };
      expect(legacyRow.containsKey('ilat'), isFalse,
          reason: 'the legacy row genuinely lacks the location keys');

      // Direct decode is null-safe.
      final decoded = AttendanceDay.tryFromJson(legacyRow);
      expect(decoded, isNotNull);
      expect(decoded!.inLat, isNull);
      expect(decoded.inLng, isNull);
      expect(decoded.outLat, isNull);
      expect(decoded.outLng, isNull);
      expect(decoded.inTs, isNotNull,
          reason: 'the non-location fields still decode');

      // And the notifier loads such a ledger from prefs without a crash.
      SharedPreferences.setMockInitialValues({
        kWorkerAttendanceKey: jsonEncode([legacyRow]),
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(workerAttendanceProvider); // lazy — start _load()
      await _settle();

      final days = c.read(workerAttendanceProvider);
      expect(days.length, 1,
          reason: 'the legacy row loads as one AttendanceDay');
      expect(days.single.inLat, isNull,
          reason: 'a pre-location row carries no coordinate (honest null)');
      expect(mapsQueryForDay(days.single), isNull,
          reason: 'no coordinate → no maps query');
    });
  });

  // ── clockIn / clockOut with coordinates ───────────────────────────────────

  group('clockIn / clockOut — coordinate capture', () {
    test('clockIn(lat:, lng:) stamps the in-coordinates onto today\'s record',
        () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(workerAttendanceProvider.notifier);

      expect(n.clockIn('ran', lat: 31.7683, lng: 35.2137), true);
      final today = n.todayFor('ran');
      expect(today, isNotNull);
      expect(today!.inLat, 31.7683,
          reason: 'the clock-in latitude is recorded on the day');
      expect(today.inLng, 35.2137);
      // No clock-out yet → the out-coordinates stay null (no invention).
      expect(today.outLat, isNull);
      expect(today.outLng, isNull);
    });

    test(
        'clockOut(lat:, lng:) stamps the out-coordinates without disturbing the '
        'in-coordinates', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(workerAttendanceProvider.notifier);

      n.clockIn('ran', lat: 31.0, lng: 34.0);
      expect(n.clockOut('ran', lat: 32.0, lng: 35.0), true);

      final today = n.todayFor('ran');
      expect(today, isNotNull);
      expect(today!.inLat, 31.0, reason: 'the in-coordinate is preserved');
      expect(today.inLng, 34.0);
      expect(today.outLat, 32.0, reason: 'the clock-out latitude is recorded');
      expect(today.outLng, 35.0);
    });

    test('clockIn/clockOut without lat/lng keep the coordinates null (honest)',
        () async {
      // The pre-Wave-2 callers pass no location — the day must still be valid
      // with null coordinates (no invented point).
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(workerAttendanceProvider.notifier);

      n.clockIn('ran');
      n.clockOut('ran');
      final today = n.todayFor('ran');
      expect(today, isNotNull);
      expect(today!.inLat, isNull);
      expect(today.inLng, isNull);
      expect(today.outLat, isNull);
      expect(today.outLng, isNull);
      expect(mapsQueryForDay(today), isNull);
    });

    test('GPS coordinates survive a persist → restart round-trip', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      final n1 = c1.read(workerAttendanceProvider.notifier);
      n1.clockIn('ran', lat: 32.0853, lng: 34.7818);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      n1.clockOut('ran', lat: 32.1, lng: 34.8);
      await _settle(); // let _persist() flush
      c1.dispose();

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      c2.read(workerAttendanceProvider); // lazy — start _load()
      await _settle();

      final day = c2.read(workerAttendanceProvider).single;
      expect(day.inLat, 32.0853,
          reason: 'the in-coordinate round-trips through prefs');
      expect(day.inLng, 34.7818);
      expect(day.outLat, 32.1);
      expect(day.outLng, 34.8);
      expect(mapsQueryForDay(day), '32.0853,34.7818',
          reason: 'the persisted day still produces its maps query');
    });
  });

  // ── mapsQueryForDay ───────────────────────────────────────────────────────

  group('mapsQueryForDay', () {
    test('returns "lat,lng" when a clock-in coordinate exists', () {
      const day = AttendanceDay(
        username: 'ran',
        date: '2026-06-14',
        inLat: 32.0853,
        inLng: 34.7818,
      );
      expect(mapsQueryForDay(day), '32.0853,34.7818');
    });

    test('returns null when no clock-in coordinate was captured', () {
      const noLoc = AttendanceDay(username: 'ran', date: '2026-06-14');
      expect(mapsQueryForDay(noLoc), isNull,
          reason: 'no coordinate → no query (never invented)');

      // A half-coordinate (lat only, no lng) is also honestly null.
      const half = AttendanceDay(
        username: 'ran',
        date: '2026-06-14',
        inLat: 32.0,
      );
      expect(mapsQueryForDay(half), isNull,
          reason: 'a lat with no lng is not a usable point');
    });

    test('uses the IN coordinate, ignoring the OUT coordinate', () {
      const day = AttendanceDay(
        username: 'ran',
        date: '2026-06-14',
        inLat: 1.0,
        inLng: 2.0,
        outLat: 9.0,
        outLng: 9.0,
      );
      expect(mapsQueryForDay(day), '1.0,2.0',
          reason: 'the query targets the clock-IN location');
    });
  });
}

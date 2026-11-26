// Regression guard — a worker's clock-in / clock-out must NOT be lost when the
// screen is closed while the GPS fix is still pending.
//
// Before the fix, `_clockIn` / `_clockOut` (worker_attendance_screen.dart) and
// `_clockWithGps` (worker_app_screen.dart) did
//     final fix = await currentGeoFix();
//     if (!mounted) return;          // ← dropped the attendance write
//     notifier.clockIn(...);
// A cold GPS / first-time permission prompt routinely takes seconds; a worker
// who tapped "כניסה" and navigated back got NO attendance record and no error.
//
// The test holds the geolocator platform channel open (the first call,
// `isLocationServiceEnabled`, never answers until we say so), taps the clock
// button, unmounts the screen, then releases the channel. The ledger must hold
// the stamp regardless.
import 'dart:async';
import 'dart:convert';

import 'package:buildsmart/screens/worker_app_screen.dart';
import 'package:buildsmart/screens/worker_attendance_screen.dart';
import 'package:buildsmart/state/docs_readiness.dart';
import 'package:buildsmart/state/worker_attendance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _geoChannel = MethodChannel('flutter.baseflow.com/geolocator');
const _workerAuth =
    '{"role":"worker","username":"ran","displayName":"רן","demo":false}';

/// Installs a geolocator mock whose `isLocationServiceEnabled` blocks on the
/// returned completer (answer `false` → honest null fix, no coordinates).
Completer<bool> _holdGps(WidgetTester tester) {
  final gate = Completer<bool>();
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(_geoChannel,
      (call) async {
    if (call.method == 'isLocationServiceEnabled') return gate.future;
    return null;
  });
  addTearDown(() => tester.binding.defaultBinaryMessenger
      .setMockMethodCallHandler(_geoChannel, null));
  return gate;
}

Future<ProviderContainer> _pump(WidgetTester tester, Widget home) async {
  // The board's #101 docs-readiness gate is bypassed via its test seam — this
  // file exercises the clock flow, not the gate.
  final container = ProviderContainer(
      overrides: [docsGateOverrideProvider.overrideWith((ref) => true)]);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(home: home),
  ));
  await tester.pump();
  // Lazy boardAuthProvider + attendance _load() resolve → gate → board.
  await tester.pump(const Duration(milliseconds: 100));
  return container;
}

/// Unmount the screen (the worker navigated away) but keep the container.
Future<void> _leave(WidgetTester tester, ProviderContainer c) async {
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: const MaterialApp(home: SizedBox()),
  ));
}

AttendanceDay? _today(ProviderContainer c) =>
    c.read(workerAttendanceProvider.notifier).todayFor('ran');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'attendance screen — clock-in is recorded even if the screen closes '
      'during the GPS lookup', (tester) async {
    SharedPreferences.setMockInitialValues({'bs.board-auth.v1': _workerAuth});
    final gate = _holdGps(tester);
    final c = await _pump(tester, const WorkerAttendanceScreen());

    expect(_today(c), isNull, reason: 'no shift yet');
    await tester.tap(find.text('🟢 כניסה'));
    await tester.pump();
    await _leave(tester, c);

    gate.complete(false);
    await tester.pump(const Duration(milliseconds: 50));

    final day = _today(c);
    expect(day?.inTs, isNotNull,
        reason: 'the clock-in must be written although the screen is gone');
    expect(day?.inLat, isNull, reason: 'no fix → no invented coordinate');
  });

  testWidgets(
      'attendance screen — clock-out is recorded even if the screen closes '
      'during the GPS lookup', (tester) async {
    final now = DateTime.now();
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1': _workerAuth,
      kWorkerAttendanceKey: jsonEncode([
        AttendanceDay(
          username: 'ran',
          date: attendanceDateKey(now),
          inTs: now.subtract(const Duration(hours: 1)),
        ).toJson(),
      ]),
    });
    final gate = _holdGps(tester);
    final c = await _pump(tester, const WorkerAttendanceScreen());

    expect(_today(c)?.outTs, isNull, reason: 'open shift');
    await tester.tap(find.text('🔴 יציאה'));
    await tester.pump();
    await _leave(tester, c);

    gate.complete(false);
    await tester.pump(const Duration(milliseconds: 50));

    expect(_today(c)?.outTs, isNotNull,
        reason: 'the clock-out must be written although the screen is gone');
  });

  testWidgets(
      'worker board — "כניסה עם מיקום" is recorded even if the board closes '
      'during the GPS lookup', (tester) async {
    SharedPreferences.setMockInitialValues({'bs.board-auth.v1': _workerAuth});
    final gate = _holdGps(tester);
    final c = await _pump(tester, const WorkerAppScreen());

    final btn = find.text('🟢 כניסה עם מיקום');
    await tester.scrollUntilVisible(btn, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(_today(c), isNull, reason: 'no shift yet');
    await tester.tap(btn);
    await tester.pump();
    await _leave(tester, c);

    gate.complete(false);
    await tester.pump(const Duration(milliseconds: 50));

    expect(_today(c)?.inTs, isNotNull,
        reason: 'the clock-in must be written although the board is gone');
  });
}

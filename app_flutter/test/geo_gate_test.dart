// C6 — guard for the HONEST GPS gate (lib/services/geo_gate.dart), the
// platform-free decision logic that geo_native.dart wires the real `geolocator`
// plugin into. This file deliberately imports ONLY geo_gate.dart — NOT
// services/geo.dart (→ package:web / dart:js_interop, which does not compile on
// the Dart test VM; the same toolchain limit that forced worker_attendance_geo_test
// to skip the seam). So the gate's contract is fully exercisable headless even
// though the real device fetch (geolocator's platform channel) cannot run here.
//
// The contract under test (never a fabricated coordinate):
//   • service OFF                          → null, and NO permission prompt;
//   • permission denied (and still denied
//     after a request)                     → null;
//   • permission deniedForever             → null, NOT re-prompted;
//   • permission granted (whileInUse/always
//     mapped upstream)                      → the platform reading;
//   • a denied check that flips to granted
//     on request                           → the reading (the prompt path);
//   • any thrown error in any step          → null.
import 'package:buildsmart/services/geo_gate.dart';
import 'package:flutter_test/flutter_test.dart';

/// A scripted set of platform callbacks for [resolveGeoFix], recording how many
/// times each step ran so we can assert the gate's short-circuiting.
class _FakePlatform {
  _FakePlatform({
    required this.serviceEnabled,
    required this.checkResult,
    this.requestResult,
    this.reading = const GeoReading(32, 34, accuracy: 5),
    this.throwInGetReading = false,
  });

  final bool serviceEnabled;
  final GeoPermissionState checkResult;

  /// What requestPermission returns; defaults to whatever check returned (i.e.
  /// the prompt didn't change the answer) unless overridden.
  final GeoPermissionState? requestResult;
  final GeoReading reading;
  final bool throwInGetReading;

  int serviceChecks = 0;
  int permissionChecks = 0;
  int permissionRequests = 0;
  int readings = 0;

  Future<bool> isServiceEnabled() async {
    serviceChecks++;
    return serviceEnabled;
  }

  Future<GeoPermissionState> checkPermission() async {
    permissionChecks++;
    return checkResult;
  }

  Future<GeoPermissionState> requestPermission() async {
    permissionRequests++;
    return requestResult ?? checkResult;
  }

  Future<GeoReading?> getReading() async {
    readings++;
    if (throwInGetReading) throw StateError('sensor boom');
    return reading;
  }

  Future<GeoReading?> run() => resolveGeoFix(
        isServiceEnabled: isServiceEnabled,
        checkPermission: checkPermission,
        requestPermission: requestPermission,
        getReading: getReading,
      );
}

void main() {
  group('resolveGeoFix — granted path', () {
    test('service on + permission granted → returns the platform reading', () async {
      final p = _FakePlatform(
        serviceEnabled: true,
        checkResult: GeoPermissionState.granted,
        reading: const GeoReading(32.0728, 34.7912, accuracy: 12),
      );
      final fix = await p.run();
      expect(fix, isNotNull);
      expect(fix!.lat, 32.0728);
      expect(fix.lng, 34.7912);
      expect(fix.accuracy, 12);
      // Already granted → no permission prompt was shown.
      expect(p.permissionRequests, 0);
      expect(p.readings, 1);
    });

    test('denied check that the prompt upgrades to granted → returns the reading',
        () async {
      final p = _FakePlatform(
        serviceEnabled: true,
        checkResult: GeoPermissionState.denied,
        requestResult: GeoPermissionState.granted, // user grants at the prompt
        reading: const GeoReading(31.7683, 35.2137),
      );
      final fix = await p.run();
      expect(fix, isNotNull);
      expect(fix!.lat, 31.7683);
      expect(fix.lng, 35.2137);
      expect(fix.accuracy, isNull, reason: 'no accuracy reported → null, honest');
      expect(p.permissionRequests, 1, reason: 'a denied check triggers one prompt');
      expect(p.readings, 1);
    });

    test('unableToDetermine that the prompt upgrades to granted → reading',
        () async {
      final p = _FakePlatform(
        serviceEnabled: true,
        checkResult: GeoPermissionState.unableToDetermine,
        requestResult: GeoPermissionState.granted,
      );
      final fix = await p.run();
      expect(fix, isNotNull);
      expect(p.permissionRequests, 1);
    });
  });

  group('resolveGeoFix — honest null paths (NEVER a fabricated coordinate)', () {
    test('location service OFF → null, and NO fetch / NO permission prompt',
        () async {
      final p = _FakePlatform(
        serviceEnabled: false,
        checkResult: GeoPermissionState.granted, // irrelevant, service is off
      );
      final fix = await p.run();
      expect(fix, isNull);
      expect(p.serviceChecks, 1);
      expect(p.permissionChecks, 0, reason: 'no point checking perms when off');
      expect(p.permissionRequests, 0);
      expect(p.readings, 0, reason: 'no coordinate is ever invented');
    });

    test('permission denied and still denied after the prompt → null', () async {
      final p = _FakePlatform(
        serviceEnabled: true,
        checkResult: GeoPermissionState.denied,
        requestResult: GeoPermissionState.denied, // user declines the prompt
      );
      final fix = await p.run();
      expect(fix, isNull);
      expect(p.permissionRequests, 1);
      expect(p.readings, 0);
    });

    test('deniedForever → null and NOT re-prompted', () async {
      final p = _FakePlatform(
        serviceEnabled: true,
        checkResult: GeoPermissionState.deniedForever,
      );
      final fix = await p.run();
      expect(fix, isNull);
      expect(
        p.permissionRequests,
        0,
        reason: 'a permanent denial is not re-prompted (the OS ignores it)',
      );
      expect(p.readings, 0);
    });

    test('granted but the fetch throws → null (sensor error, not invented)',
        () async {
      final p = _FakePlatform(
        serviceEnabled: true,
        checkResult: GeoPermissionState.granted,
        throwInGetReading: true,
      );
      final fix = await p.run();
      expect(fix, isNull);
      expect(p.readings, 1, reason: 'the fetch was attempted then failed safely');
    });

    test('granted but the platform itself returns null → null (no invention)',
        () async {
      final fix = await resolveGeoFix(
        isServiceEnabled: () async => true,
        checkPermission: () async => GeoPermissionState.granted,
        requestPermission: () async => GeoPermissionState.granted,
        getReading: () async => null,
      );
      expect(fix, isNull);
    });

    test('a throwing service check collapses to null, never throws', () async {
      final fix = await resolveGeoFix(
        isServiceEnabled: () async => throw StateError('channel missing'),
        checkPermission: () async => GeoPermissionState.granted,
        requestPermission: () async => GeoPermissionState.granted,
        getReading: () async => const GeoReading(1, 2),
      );
      expect(fix, isNull, reason: 'headless VM (no channel) is an honest null');
    });
  });
}

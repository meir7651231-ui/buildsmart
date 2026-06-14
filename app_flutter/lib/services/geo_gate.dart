// C6 — PURE, platform-free decision logic for the native GPS fix (the gating
// that geo_native.dart wires the real `geolocator` plugin into).
//
// WHY a separate file: services/geo.dart transitively imports `package:web` +
// `dart:js_interop` (for the web seam), which does NOT compile on the Dart test
// VM — the same reason worker_attendance_geo_test.dart had to skip the seam.
// This file imports NEITHER geo.dart NOR geolocator, so the gate (the honest
// granted→fetch / denied|disabled→null contract) is unit-testable headless,
// while geo_native.dart stays the thin, device-only adapter.
//
// The gate NEVER invents a coordinate: it returns the platform's fix only when
// the service is enabled AND permission is granted; on a disabled service,
// denied/deniedForever permission, or a fetch error it returns null.
import 'dart:async';

/// A plain lat/lng/accuracy triple — the platform-free echo of the public
/// `GeoFix` (in services/geo.dart) so the gate carries no dependency on it.
/// geo_native.dart maps this back to a `GeoFix` for the public seam.
class GeoReading {
  const GeoReading(this.lat, this.lng, {this.accuracy});

  final double lat;
  final double lng;
  final double? accuracy;
}

/// The permission outcome the gate reasons about — a platform-free mirror of
/// the plugin's permission enum. Only [granted] (≈ whileInUse/always) lets a
/// fetch proceed; everything else is honest null.
enum GeoPermissionState { granted, denied, deniedForever, unableToDetermine }

/// Resolve a current fix through the injected platform callbacks, applying the
/// honest gate. Used by geo_native.dart with the real `Geolocator` bound to the
/// callbacks, and by tests with fakes.
///
///   1. service OFF                         → null (no fetch attempted)
///   2. permission not granted, and after a
///      request still not granted           → null
///   3. permission granted                  → the platform fix (or null if the
///      fetch itself fails / returns null)
///
/// Any thrown error anywhere collapses to null — never a fabricated point.
Future<GeoReading?> resolveGeoFix({
  required Future<bool> Function() isServiceEnabled,
  required Future<GeoPermissionState> Function() checkPermission,
  required Future<GeoPermissionState> Function() requestPermission,
  required Future<GeoReading?> Function() getReading,
}) async {
  try {
    // 1 — location services switched off at the OS level: honest null, and we
    // do NOT pop a permission prompt for a service that can't deliver.
    if (!await isServiceEnabled()) return null;

    // 2 — permission gate. Ask once if we don't already hold it; a permanent
    // denial (deniedForever) is NOT re-prompted (the OS would ignore it).
    var perm = await checkPermission();
    if (perm == GeoPermissionState.denied ||
        perm == GeoPermissionState.unableToDetermine) {
      perm = await requestPermission();
    }
    if (perm != GeoPermissionState.granted) return null;

    // 3 — granted: hand back exactly what the platform reports (or null).
    return await getReading();
  } on Object catch (_) {
    // Sensor error / timeout / channel failure — honest null, never invented.
    return null;
  }
}

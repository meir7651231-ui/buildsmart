// C6 — NATIVE/VM implementation of the GPS seam (#100 · contract 2), now backed
// by the real `geolocator` plugin. Replaces the old null-only stub: on a device
// it returns a LIVE fix; headless (the Dart test VM, where the platform channel
// is absent) and on any denial/disabled-service/error it returns null — never a
// fabricated coordinate (אין קואורדינטה מומצאת). Selected on every NON-web
// target by the conditional import in geo.dart, so `package:web` never reaches
// this compile path.
//
// The honest gate (service-enabled → permission-granted → fetch, else null)
// lives in the platform-free geo_gate.dart so it is unit-testable on the VM
// without importing services/geo.dart (→ package:web). This file is the thin
// adapter that binds the live `Geolocator` calls to that gate and maps the
// plugin's Position/LocationPermission onto the gate's plain types.
import 'package:buildsmart/services/geo.dart';
import 'package:buildsmart/services/geo_gate.dart';
import 'package:geolocator/geolocator.dart';

/// Map the plugin's permission enum onto the gate's platform-free mirror. Only
/// whileInUse/always count as granted (foreground location is all the app asks
/// for); denied/deniedForever/unableToDetermine each stay honest-null gates.
GeoPermissionState _mapPermission(LocationPermission p) {
  switch (p) {
    case LocationPermission.whileInUse:
    case LocationPermission.always:
      return GeoPermissionState.granted;
    case LocationPermission.deniedForever:
      return GeoPermissionState.deniedForever;
    case LocationPermission.unableToDetermine:
      return GeoPermissionState.unableToDetermine;
    case LocationPermission.denied:
      return GeoPermissionState.denied;
  }
}

/// Native current position, or null — never invented. Delegates the gating to
/// [resolveGeoFix] with the live `Geolocator` bound to each step; a missing
/// platform channel (headless VM) throws inside a step and collapses to null.
Future<GeoFix?> currentGeoFix() async {
  final reading = await resolveGeoFix(
    isServiceEnabled: Geolocator.isLocationServiceEnabled,
    checkPermission: () async => _mapPermission(await Geolocator.checkPermission()),
    requestPermission: () async =>
        _mapPermission(await Geolocator.requestPermission()),
    getReading: () async {
      // Foreground, one-shot fix. medium accuracy is enough to tag a site /
      // clock-in and is faster + lighter than `best`.
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      return GeoReading(pos.latitude, pos.longitude, accuracy: pos.accuracy);
    },
  );
  if (reading == null) return null;
  return GeoFix(reading.lat, reading.lng, accuracy: reading.accuracy);
}

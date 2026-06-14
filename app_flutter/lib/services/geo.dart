// SERVER-SWAP — GPS fix service (#100 · Wave-2 contract 2).
//
// One public seam: [currentGeoFix] returns the device's current position as a
// [GeoFix], or null. NEVER an invented coordinate (אין קואורדינטה מומצאת).
//
// Conditional import keeps `package:web` / `dart:js_interop` OFF the native +
// VM compile path (flutter test runs on the Dart VM, where package:web's
// js-interop helpers do not compile) — the suite stays green — while the web
// build picks up the real Geolocation implementation. Same pattern the codebase
// already uses for photo_downscale_web.dart.
//   • WEB (geo_web.dart) — browser Geolocation API; null on deny/error/timeout.
//   • NATIVE/VM (geo_stub.dart) — STUB returning null. SERVER-SWAP: bind a real
//     platform geolocator here; the [GeoFix] shape + `Future<GeoFix?>` contract
//     stay byte-identical so callers (clock-in/out lat/lng — contract 4) need no
//     change.
import 'geo_stub.dart' if (dart.library.js_interop) 'geo_web.dart' as impl;

/// An immutable GPS reading. [accuracy] is the radius in metres reported by the
/// platform (null when the source does not give one).
class GeoFix {
  const GeoFix(this.lat, this.lng, {this.accuracy});

  final double lat;
  final double lng;
  final double? accuracy;
}

/// The device's current position, or null — never a fabricated point. Returns
/// null when the location is unavailable for ANY reason: permission denied,
/// hardware/sensor error, timeout, or an unsupported (native/VM) target until
/// the SERVER-SWAP lands.
Future<GeoFix?> currentGeoFix() => impl.currentGeoFix();

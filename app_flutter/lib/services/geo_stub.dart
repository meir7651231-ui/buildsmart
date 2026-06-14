// SERVER-SWAP — native/VM stub for the GPS seam (#100). No package:web here, so
// the file compiles on every non-web target (and on the flutter-test VM). Bind a
// real platform geolocator (e.g. the `geolocator` plugin) here when going native;
// the contract (Future<GeoFix?>, null = unavailable) stays byte-identical.
import 'geo.dart';

/// Native/VM: no sensor wired yet — honest null (never an invented coordinate).
Future<GeoFix?> currentGeoFix() => Future<GeoFix?>.value();

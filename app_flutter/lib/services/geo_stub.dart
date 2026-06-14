// LEGACY — the original native/VM null-only stub for the GPS seam (#100).
// SUPERSEDED by geo_native.dart (C6), which binds the real `geolocator` plugin;
// geo.dart's conditional import now selects geo_native.dart on non-web targets,
// so this file is NO LONGER WIRED. Kept for history (the SERVER-SWAP note it
// documented is now fulfilled). Its contract (Future<GeoFix?>, null =
// unavailable) is preserved by geo_native.dart byte-identically.
import 'geo.dart';

/// Native/VM null stub (unwired) — honest null (never an invented coordinate).
Future<GeoFix?> currentGeoFix() => Future<GeoFix?>.value();

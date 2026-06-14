// WEB implementation of the GPS seam (#100 · contract 2). Selected only on web
// via the conditional import in geo.dart (dart.library.js_interop), so package:web
// never reaches the native/VM compile path. Wraps the callback-based
// `navigator.geolocation.getCurrentPosition(success, error)` in a Future; any
// rejection (permission denied, sensor error, timeout) or an unsupported browser
// completes with null. No coordinate is ever invented.
import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'geo.dart';

Future<GeoFix?> currentGeoFix() {
  // Single-shot: the browser fires exactly one of success/error, but stay
  // defensive against a double-callback completing the Future twice.
  final completer = Completer<GeoFix?>();
  void finish(GeoFix? v) {
    if (!completer.isCompleted) completer.complete(v);
  }

  try {
    web.window.navigator.geolocation.getCurrentPosition(
      (web.GeolocationPosition pos) {
        final c = pos.coords;
        finish(GeoFix(c.latitude, c.longitude, accuracy: c.accuracy));
      }.toJS,
      // Error (permission-deny / position-unavailable / timeout): honest null.
      (web.GeolocationPositionError _) {
        finish(null);
      }.toJS,
    );
  } on Object catch (_) {
    finish(null);
  }
  return completer.future;
}

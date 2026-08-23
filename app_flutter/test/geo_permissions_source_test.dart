// C6 — SOURCE-GUARD for the GPS permission declarations. The real device
// permission flow (geolocator over the platform channel) cannot run in a
// headless test, so instead we lock the manifest/plist SOURCE that authorises
// it: if a future edit drops the location permissions, this test goes red.
//
//   • AndroidManifest.xml — ACCESS_FINE_LOCATION + ACCESS_COARSE_LOCATION
//     requested; the location hardware feature marked NOT required (Play
//     installability); and NO background-location permission (foreground-only).
//   • ios/Runner/Info.plist — NSLocationWhenInUseUsageDescription present, in
//     Hebrew, naming the site/clock-in purpose, and foreground-only (the app
//     must NOT request NSLocationAlwaysAndWhenInUseUsageDescription).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String relative) {
  final f = File(relative);
  expect(f.existsSync(), isTrue, reason: 'expected $relative to exist');
  return f.readAsStringSync();
}

void main() {
  group('C6 — Android location permissions (source-guard)', () {
    late final manifest = _read('android/app/src/main/AndroidManifest.xml');

    test('requests FINE + COARSE location', () {
      expect(
        manifest,
        contains('android.permission.ACCESS_FINE_LOCATION'),
      );
      expect(
        manifest,
        contains('android.permission.ACCESS_COARSE_LOCATION'),
      );
    });

    test('marks the location hardware feature NOT required (installability)', () {
      // The uses-feature for location must be present with required="false".
      expect(
        manifest,
        contains('android.hardware.location'),
      );
      expect(
        manifest,
        contains('android.hardware.location.gps'),
      );
      // Both location uses-feature lines carry required="false".
      final featureLines = manifest.split('\n').where(
            (l) =>
                l.contains('uses-feature') &&
                l.contains('android.hardware.location'),
          );
      expect(featureLines, isNotEmpty);
      for (final l in featureLines) {
        expect(
          l,
          contains('required="false"'),
          reason: 'location hardware must not block install: $l',
        );
      }
    });

    test('does NOT declare a background-location uses-permission '
        '(foreground-only)', () {
      // Check the actual permission DECLARATION, not a mention in a comment:
      // a uses-permission element naming ACCESS_BACKGROUND_LOCATION.
      final declaresBackground = manifest.split('\n').any(
            (l) =>
                l.contains('uses-permission') &&
                l.contains('ACCESS_BACKGROUND_LOCATION'),
          );
      expect(
        declaresBackground,
        isFalse,
        reason: 'the app only needs location while open — never in the background',
      );
    });
  });

  group('C6 — iOS location usage description (source-guard)', () {
    late final plist = _read('ios/Runner/Info.plist');

    test('declares NSLocationWhenInUseUsageDescription', () {
      expect(plist, contains('NSLocationWhenInUseUsageDescription'));
    });

    test('the description is the specific Hebrew site/clock-in purpose', () {
      // Pull the string immediately following the key.
      final idx = plist.indexOf('NSLocationWhenInUseUsageDescription');
      expect(idx, greaterThanOrEqualTo(0));
      final after = plist.substring(idx);
      final start = after.indexOf('<string>');
      final end = after.indexOf('</string>');
      expect(start, greaterThanOrEqualTo(0));
      expect(end, greaterThan(start));
      final desc = after.substring(start + '<string>'.length, end);

      expect(desc.trim(), isNotEmpty);
      expect(desc, contains('BuildSmart'));
      // Hebrew + the specific purpose (site/attendance) + foreground-only.
      expect(desc, contains('מיקום'));
      expect(
        desc,
        anyOf(contains('אתר'), contains('נוכחות'), contains('כניסה')),
      );
      expect(
        desc,
        contains('ברקע'),
        reason: 'states there is NO background collection',
      );
    });

    test('does NOT request the "Always" (background) location authorisation',
        () {
      expect(
        plist.contains('NSLocationAlwaysAndWhenInUseUsageDescription'),
        isFalse,
        reason: 'foreground-only; never the always/background authorisation',
      );
      expect(
        plist.contains('NSLocationAlwaysUsageDescription'),
        isFalse,
      );
    });
  });
}

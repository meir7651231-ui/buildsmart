// F2 — App Check NATIVE provider selection (lib/main.dart appCheckProvidersFor)
// + the LIVE default of the prod flag (lib/data/repositories/backend.dart
// kAppCheckProd).
//
// PROVED HERE (the F2 zero-regression invariant):
//   1. kAppCheckProd is OFF by default — no `--dart-define=APP_CHECK_PROD` in
//      the suite, so the build keeps the dev/demo attestation. (The same
//      compile-time-flag-default discipline as backend_flag_test.dart pins for
//      kUseFirebaseBackend.)
//   2. appCheckProvidersFor(false) → AndroidProvider.debug / AppleProvider.debug
//      — BYTE-IDENTICAL to the providers the activate call shipped with.
//   3. appCheckProvidersFor(true) → AndroidProvider.playIntegrity /
//      AppleProvider.appAttestWithDeviceCheckFallback — the production native
//      providers (App Attest on iOS 14+/macOS 14+, DeviceCheck fallback).
//   4. The web reCAPTCHA site key defaults to empty → the web App Check path
//      stays SKIPPED exactly as today.
//
// The selection is a pure helper so BOTH flag values are asserted WITHOUT
// initialising Firebase / calling FirebaseAppCheck.instance.activate (tests
// never touch Firebase — same as telemetry_test.dart / debug_badge_gate_test).
//
// MUTATION-VERIFY: flip the OFF branch of appCheckProvidersFor to
// AndroidProvider.playIntegrity (or swap the two record arms) → the
// OFF→debug / live-default expectations turn RED; restoring is GREEN.
import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/main.dart' show appCheckProvidersFor;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('F2 — kAppCheckProd live default (zero regression)', () {
    test('kAppCheckProd is OFF without a dart-define — dev attestation default',
        () {
      // No `--dart-define=APP_CHECK_PROD` in the test run → the compile-time
      // flag is false, so the build keeps the debug providers the app shipped
      // with until the owner flips it post F1 + console-key registration.
      expect(kAppCheckProd, isFalse);
    });

    test('the web reCAPTCHA site key defaults to empty — web stays SKIPPED', () {
      // With no key supplied the web App Check path is not activated (the
      // current web-skipped behaviour is preserved byte-for-byte).
      expect(kAppCheckRecaptchaSiteKey, isEmpty);
    });
  });

  group('F2 — appCheckProvidersFor (pure selection, no Firebase)', () {
    test('OFF (default) → debug providers (BYTE-IDENTICAL to today)', () {
      final p = appCheckProvidersFor(prod: false);
      expect(p.android, AndroidProvider.debug);
      expect(p.apple, AppleProvider.debug);
    });

    test('ON → playIntegrity + appAttestWithDeviceCheckFallback', () {
      final p = appCheckProvidersFor(prod: true);
      expect(p.android, AndroidProvider.playIntegrity);
      expect(p.apple, AppleProvider.appAttestWithDeviceCheckFallback);
    });

    test('the live flag value selects the dev providers (pinned OFF)', () {
      // Wiring the const through the helper exactly as main() does: with
      // kAppCheckProd false the activate call gets the dev/demo providers.
      expect(kAppCheckProd, isFalse);
      final p = appCheckProvidersFor(prod: kAppCheckProd);
      expect(p.android, AndroidProvider.debug);
      expect(p.apple, AppleProvider.debug);
    });
  });
}

// Pins the Studio master gate (#studio · Pillar 1 · step 4): default OFF — the
// zero-regression contract for the entire platform. The test build sets no
// `--dart-define=STUDIO`, so the flag MUST read false; if this ever goes green
// while true, the whole Studio would ship live by accident.
import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/state/studio/studio_flags.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('kStudioFlag is OFF by default (no STUDIO dart-define in the test build)',
      () {
    expect(kStudioFlag, isFalse);
  });

  test('the runtime flag-name is the canonical kStudio', () {
    expect(kStudioFlagName, 'kStudio');
  });

  // Step 5 — 'kStudio' is recognised as a runtime flag but is NEVER force-enabled
  // (absent from FeatureFlagsNotifier._forcedOnFlags); owner-staged only.
  test('a fresh FeatureFlagsNotifier does NOT force-enable kStudio (default OFF)',
      () {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final flags = FeatureFlagsNotifier();
    addTearDown(flags.dispose);
    expect(flags.isOn(kStudioFlagName), isFalse,
        reason: 'kStudio must stay owner-staged only — never force-enabled');
  });
}

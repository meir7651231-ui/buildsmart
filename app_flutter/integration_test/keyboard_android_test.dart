// Renders the KB_GLOBAL floating keyboard on a REAL Android emulator (in CI —
// local emulation is blocked on the dev box by missing hardware virtualization).
// A GREEN run proves the keyboard actually builds + renders on genuine Android.
//
// Scope is deliberately the on-device RENDER smoke. The Android hardware-BACK
// handling is verified deterministically in the VM test test/screens/
// android_back_test.dart (it drives the exact `popRoute` platform message the OS
// sends). We do NOT re-assert BACK here: under `flutter drive` /
// IntegrationTestWidgetsFlutterBinding the integration-test driver owns the
// `flutter/navigation` channel, so a simulated BACK is swallowed before it reaches
// the keyboard's didPopRoute observer — an on-device test artifact, not app
// behavior. Run via `flutter drive` + test_driver/integration_test.dart.

import 'package:buildsmart/screens/floating_card_keyboard.dart';
import 'package:buildsmart/state/keyboard_overlay.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'KB_GLOBAL floating keyboard renders on a real Android emulator',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer(
        overrides: [keyboardOverlayOpenProvider.overrideWith((_) => true)],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: Consumer(
                  builder: (context, ref, _) {
                    final open = ref.watch(keyboardOverlayOpenProvider);
                    return Stack(
                      children: [
                        const Center(child: Text('screen-underneath')),
                        if (open)
                          const Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: FloatingCardKeyboard(),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The KB_GLOBAL keyboard built + rendered on genuine Android hardware.
      expect(find.byType(BsKeyboard), findsOneWidget,
          reason: 'the KB_GLOBAL floating keyboard renders on the Android emulator');

      // Best-effort on-device screenshot (uploaded as a CI artifact so the
      // keyboard-on-real-Android is VISIBLE). Guarded: surface->image conversion
      // can no-op on a headless swiftshader GPU, and a missing shot must NOT fail
      // the render proof above.
      try {
        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('android-keyboard');
      } on Object catch (_) {
        // Screenshot is best-effort; the render assertion above is the proof.
      }
    },
  );
}

// Renders the KB_GLOBAL floating keyboard on a REAL Android emulator (in CI —
// local emulation is blocked on the dev box by missing hardware virtualization).
// A GREEN run proves the keyboard actually builds + renders on genuine Android.
//
// Scope is deliberately the on-device RENDER smoke. The Android hardware-BACK
// handling is verified deterministically in the VM test test/screens/
// android_back_test.dart (it drives the exact `popRoute` platform message the OS
// sends, and asserts the keyboard closes). We do NOT re-assert BACK here because
// the SAME simulated `popRoute` that passes in the VM binding flakes under this
// one: IntegrationTestWidgetsFlutterBinding extends LiveTestWidgetsFlutterBinding
// (real wall-clock + real engine), while the VM uses AutomatedTestWidgetsFlutter-
// Binding (deterministic FakeAsync). `didPopRoute` is async and only unmounts the
// keyboard on a follow-up frame after it flips keyboardOverlayOpenProvider; that
// settles deterministically under FakeAsync but races real-time frame scheduling
// under the live binding, so the assertion can catch the pre-close frame. It is a
// harness-timing artifact, NOT app behavior: in the real app BACK closes the
// keyboard (it lives in a sibling Overlay, never a pushed route, so on a home tab
// bsNavigatorKey.canPop()==false and didPopRoute falls through to _close()).
// NOTE: an earlier revision of this comment blamed the flake on the driver
// "owning the flutter/navigation channel" — that mechanism was not substantiated
// (nothing in integration_test/flutter_driver registers a handler on that channel;
// handlePlatformMessage dispatches straight to the binding's inbound handler). To
// prove BACK on-device would need a real `adb shell input keyevent 4` bridged from
// the test; the driver `handler:` hook that would carry it does not exist in the
// pinned Flutter 3.44 integrationDriver, so that is deferred, not wired here.
// Run via `flutter drive` + test_driver/integration_test.dart.

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

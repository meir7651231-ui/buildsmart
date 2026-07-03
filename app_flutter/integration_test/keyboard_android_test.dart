// Runs the floating keyboard on a REAL Android emulator (in CI — local emulation
// is blocked here by missing hardware virtualization). Proves, on genuine Android:
//   1. the KB_GLOBAL floating keyboard RENDERS (captures a screenshot artifact);
//   2. the Android system BACK, delivered by the real OS, steps OUT of the
//      keyboard (closes it) instead of backgrounding the app — the audit's fix,
//      confirmed on-device rather than only in the VM widget test.
//
// Driven via `flutter drive` + test_driver/integration_test.dart so the screenshot
// bytes are written to /screenshots and uploaded by the workflow.

import 'package:buildsmart/screens/floating_card_keyboard.dart';
import 'package:buildsmart/state/keyboard_overlay.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'KB_GLOBAL floating keyboard renders + Android BACK closes it (real device)',
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

      // (1) It RENDERS on Android — capture the proof screenshot.
      expect(find.byType(BsKeyboard), findsOneWidget,
          reason: 'the floating keyboard renders on the Android emulator');
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('android-keyboard-open');

      // (2) The REAL Android system BACK (popRoute over the platform channel, the
      // exact message the OS sends) steps OUT of the keyboard — closes it, does
      // NOT background the app.
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/navigation',
        const JSONMethodCodec()
            .encodeMethodCall(const MethodCall('popRoute')),
        (_) {},
      );
      await tester.pumpAndSettle();

      expect(container.read(keyboardOverlayOpenProvider), isFalse,
          reason: 'Android BACK closed the keyboard (did not exit the app)');
      expect(find.byType(BsKeyboard), findsNothing);
    },
  );
}

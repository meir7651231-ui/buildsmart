// ANDROID hardware / gesture BACK — deterministic verification WITHOUT a device.
//
// The KB_GLOBAL audit's blocker was: the floating keyboard ignored Android BACK
// (it backgrounded the app). The fix registers the keyboard as a
// [WidgetsBindingObserver] and handles [didPopRoute] (Overlay-safe, Router-free —
// the app is a classic MaterialApp). There is no Android device / emulator in the
// build env, so we simulate the OS BACK the way the framework delivers it: the
// `flutter/navigation` `popRoute` platform message, which WidgetsBinding routes to
// every observer's didPopRoute. This exercises the EXACT production path on the VM.

import 'package:buildsmart/screens/floating_card_keyboard.dart';
import 'package:buildsmart/state/keyboard_overlay.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Pumps the REAL floating keyboard, mounted ONLY while the overlay-open
  /// provider is true (as in the shell), so a BACK that closes it actually
  /// removes it — letting us assert the overlay dismissed.
  Future<ProviderContainer> pumpKeyboard(WidgetTester tester) async {
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
    return container;
  }

  /// Deliver an Android system BACK exactly as the engine does — the
  /// `flutter/navigation` popRoute message → WidgetsBinding → observers'
  /// didPopRoute (the keyboard's handler).
  Future<void> pressSystemBack(WidgetTester tester) async {
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/navigation',
      const JSONMethodCodec()
          .encodeMethodCall(const MethodCall('popRoute')),
      (_) {},
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Android BACK closes the open keyboard (does NOT background the app)',
    (tester) async {
      final container = await pumpKeyboard(tester);

      // The keyboard is up.
      expect(find.byType(BsKeyboard), findsOneWidget,
          reason: 'sanity: the floating keyboard is open');
      expect(container.read(keyboardOverlayOpenProvider), isTrue);

      // Android BACK, delivered the way the OS delivers it.
      await pressSystemBack(tester);

      // The keyboard's didPopRoute handled it: the overlay is dismissed — the
      // app was NOT backgrounded (a plain MaterialApp would otherwise have let
      // the pop bubble to the engine and closed the app).
      expect(container.read(keyboardOverlayOpenProvider), isFalse,
          reason: 'BACK stepped OUT of the keyboard (closed it), not the app');
      expect(find.byType(BsKeyboard), findsNothing,
          reason: 'the floating keyboard is gone after BACK');
    },
  );

  testWidgets(
    'Android BACK pops a drilled tool layer before closing (staged unwind)',
    (tester) async {
      final container = await pumpKeyboard(tester);

      // Drill INTO the tools: the ▦ grid toggle opens the home-tools layer over
      // the letters (a real branch on the keyboard's morph stack).
      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pumpAndSettle();
      expect(find.text('מחלקות'), findsOneWidget,
          reason: 'sanity: a tool layer is now open (drilled in)');

      // First BACK: unwinds the tool layer back to the letters — it must NOT
      // close the whole keyboard yet.
      await pressSystemBack(tester);
      expect(container.read(keyboardOverlayOpenProvider), isTrue,
          reason: 'BACK popped the tool layer, keyboard still open');
      expect(find.text('מחלקות'), findsNothing,
          reason: 'the tool layer was dismissed by BACK');
      expect(find.byType(BsKeyboard), findsOneWidget);

      // Second BACK: now at the base (letters) — closes the keyboard.
      await pressSystemBack(tester);
      expect(container.read(keyboardOverlayOpenProvider), isFalse,
          reason: 'a second BACK from the base closes the keyboard');
    },
  );
}

// BsKeyboardField — the drop-in field that docks our keyboard instead of the
// device's. These tests pin the two contracts that make it safe to spread across
// the app's ~109 fields:
//
//   1. STRICT PASSTHROUGH when off — flag OFF (or a screen reader on) must give
//      back a plain, editable TextField with NO overlay, so wiring a call site is
//      a no-op until the owner flips SMART_INPUT.
//   2. NO LOCKED FIELD when on — `readOnly` and the docked keyboard are one
//      decision; a field may never be readOnly with no keyboard to type on.
//
// Plus the lifecycle bug that would bite in production: an OverlayEntry left
// behind after the field loses focus or is disposed.

import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard_field.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard_host.dart';
import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<TextEditingController> _pump(
  WidgetTester tester, {
  required bool enableFlag,
  bool accessibleNavigation = false,
  bool showField = true,
}) async {
  final controller = TextEditingController();
  addTearDown(controller.dispose);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  if (enableFlag) {
    container.read(featureFlagsProvider.notifier).enable(kSmartInputFlag);
  }
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(accessibleNavigation: accessibleNavigation),
          child: Scaffold(
            body: showField
                ? BsKeyboardField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'חיפוש'),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    ),
  );
  return controller;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('passthrough — flag OFF', () {
    testWidgets('renders a plain editable TextField, no docked keyboard',
        (tester) async {
      await _pump(tester, enableFlag: false);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.readOnly, isFalse,
          reason: 'OFF must leave the device keyboard in charge');
      expect(find.byType(BsKeyboardHost), findsNothing);
    });

    testWidgets('focusing does NOT dock a keyboard', (tester) async {
      await _pump(tester, enableFlag: false);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.byType(BsKeyboardHost), findsNothing,
          reason: 'no overlay may appear while the feature is off');
    });
  });

  group('active — flag ON', () {
    testWidgets('field is readOnly with a visible caret', (tester) async {
      await _pump(tester, enableFlag: true);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.readOnly, isTrue);
      expect(field.showCursor, isTrue);
    });

    testWidgets('focus docks the keyboard — so the field is never locked',
        (tester) async {
      await _pump(tester, enableFlag: true);
      expect(find.byType(BsKeyboardHost), findsNothing); // not before focus
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.byType(BsKeyboardHost), findsOneWidget,
          reason: 'readOnly without a keyboard = a field nobody can type into');
    });

    testWidgets('losing focus removes the docked keyboard', (tester) async {
      await _pump(tester, enableFlag: true);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.byType(BsKeyboardHost), findsOneWidget);

      // Drop focus the way a real navigation/tap-away would.
      final ctx = tester.element(find.byType(TextField));
      FocusScope.of(ctx).unfocus();
      await tester.pumpAndSettle();
      expect(find.byType(BsKeyboardHost), findsNothing,
          reason: 'the overlay must not linger once the field is unfocused');
    });

    testWidgets('disposing the field leaves no overlay behind', (tester) async {
      await _pump(tester, enableFlag: true);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.byType(BsKeyboardHost), findsOneWidget);

      // Swap the field out — dispose() must tear the entry down, or it would
      // keep typing into a disposed controller.
      await _pump(tester, enableFlag: true, showField: false);
      await tester.pumpAndSettle();
      expect(find.byType(BsKeyboardHost), findsNothing);
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('a11y fallback', () {
    testWidgets('screen reader ON ⇒ plain field, device keyboard back',
        (tester) async {
      await _pump(tester, enableFlag: true, accessibleNavigation: true);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.readOnly, isFalse);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.byType(BsKeyboardHost), findsNothing);
    });
  });
}

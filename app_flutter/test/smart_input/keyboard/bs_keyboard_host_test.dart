// BsKeyboardHost — the self-gating, bottom-docked keyboard mount.
//
// Five behaviours:
//   1. flag OFF (default mock prefs)                 → no BsKeyboard.
//   2. flag ON                                       → BsKeyboard mounts.
//   3. flag ON but screen reader active (a11y)       → no BsKeyboard.
//   4. flag ON: tap 'א' inserts 'א', then tap the    → controller mutates as
//      backspace icon deletes it back to ''.            expected.
//   5. flag ON: tap '?123' switches to the symbols   → a digit key '5' becomes
//      layer.                                            findable.
//
// The host reads `featureFlagsProvider`, so every pump is inside a
// ProviderScope; the RTL Directionality mirrors the real (Hebrew) call site. We
// pumpAndSettle so the FeatureFlagsNotifier's async `_load()` resolves first.

import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Default: no flags enabled. Individual tests override before pumping.
    SharedPreferences.setMockInitialValues({});
  });

  /// Pumps a [BsKeyboardHost] bound to [controller]/[focusNode] over a fresh
  /// ProviderScope. [a11y] toggles the `accessibleNavigation` MediaQuery flag.
  /// Returns after `pumpAndSettle` so the async flag load resolves.
  Future<void> pumpHost(
    WidgetTester tester, {
    required TextEditingController controller,
    required FocusNode focusNode,
    bool a11y = false,
  }) async {
    Widget tree = Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: BsKeyboardHost(
          controller: controller,
          focusNode: focusNode,
          onSend: () {}, // send is exercised by the screen wiring, not here
        ),
      ),
    );
    if (a11y) {
      tree = MediaQuery(
        data: const MediaQueryData(accessibleNavigation: true),
        child: tree,
      );
    }
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: tree)),
    );
    await tester.pumpAndSettle(); // let the notifier's async _load() resolve
  }

  testWidgets('flag OFF → no BsKeyboard', (tester) async {
    SharedPreferences.setMockInitialValues({}); // default: no flags enabled
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await pumpHost(tester, controller: controller, focusNode: focusNode);

    expect(find.byType(BsKeyboard), findsNothing);
  });

  testWidgets('flag ON → BsKeyboard mounts', (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': ['kSmartInput'],
    });
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await pumpHost(tester, controller: controller, focusNode: focusNode);

    expect(find.byType(BsKeyboard), findsOneWidget);
  });

  testWidgets('flag ON but screen-reader active → no BsKeyboard',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': ['kSmartInput'],
    });
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await pumpHost(
      tester,
      controller: controller,
      focusNode: focusNode,
      a11y: true,
    );

    // a11y fallback: even with the flag ON, an accessible-navigation session
    // shows no in-app keyboard (the OS keyboard is used instead).
    expect(find.byType(BsKeyboard), findsNothing);
  });

  testWidgets('flag ON: tapping א inserts, backspace deletes', (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': ['kSmartInput'],
    });
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await pumpHost(tester, controller: controller, focusNode: focusNode);

    // Tap the 'א' letter key → it inserts at the caret (append on a fresh,
    // selection-less controller), leaving a valid collapsed caret after it.
    await tester.tap(find.text('א'));
    await tester.pump();
    expect(controller.text, 'א');

    // Tap the backspace key (rendered as an icon, no text) → deletes the one
    // grapheme back to empty.
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();
    expect(controller.text, '');
  });

  testWidgets('flag ON: tapping ?123 toggles to the symbols layer',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': ['kSmartInput'],
    });
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await pumpHost(tester, controller: controller, focusNode: focusNode);

    // On the letter layer, '5' exists only as a tiny superscript hint on 'א'
    // (not a standalone digit key). Tap '?123' to switch to the symbols layer.
    await tester.tap(find.text('?123'));
    await tester.pumpAndSettle();

    // The symbols layer renders a full '5' digit key, and tapping it inserts a
    // '5' — proving the layer actually toggled.
    expect(find.text('5'), findsOneWidget);
    await tester.tap(find.text('5'));
    await tester.pump();
    expect(controller.text, '5');
  });

  testWidgets('tapping globe toggles to the English layer', (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': ['kSmartInput'],
    });
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await pumpHost(tester, controller: controller, focusNode: focusNode);

    // Start on Hebrew: a Hebrew-only key ('ק') is present. Tap the globe key
    // (rendered as Icons.language) to switch to the English layer.
    expect(find.text('ק'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.language));
    await tester.pump();

    // The English QWERTY layer is now showing: 'q' appears and the Hebrew-only
    // 'ק' is gone — proving the language actually toggled.
    expect(find.text('q'), findsOneWidget);
    expect(find.text('ק'), findsNothing);
  });
}

// The app-wide keyboard: one keyboard for EVERY field, and no device keyboard.
//
// WHAT THESE TESTS ARE FOR: wave-1 wiring converts fields one at a time, and 99
// of ~109 are still unconverted. This layer answers for all of them at once by
// registering a [TextInputControl], so the single question worth pinning is the
// PAIR — "the device keyboard is gone" and "ours is there instead" must be one
// event, never two that can drift apart. A field that is blocked with no
// replacement is a field nobody can type into and no error to explain why; on
// the registration form that is a person who cannot sign up. That is the
// silent-lockout failure this project already spent a day escaping, and the
// LOCKOUT GUARD test below is what stops it coming back.
//
// The proof that the device keyboard is really blocked is not a proxy: while a
// custom control is installed the framework rewrites the platform config's
// `inputType` to `TextInputType.none`, and `tester.testTextInput.setClientArgs`
// is the platform's own record of what it was told.
//
// `flutter test` does not forward `--dart-define` to library consts, so
// [kAppKbOnly] is always false here; the layer's `force` flag is the only way
// the ON path — the entire feature — is reachable from a test at all.

import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/widgets/smart_input/caret.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/app_keyboard_only.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard_field.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard_host.dart';
import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mirrors the production mount in main.dart: the layer lives in its own Overlay,
/// a Stack sibling of the app content, so it clears dialogs and sheets.
Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required bool on,
  required Widget field,
  bool flag = true,
  bool a11y = false,
}) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  if (flag) {
    container.read(featureFlagsProvider.notifier).enable(kSmartInputFlag);
  }
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(accessibleNavigation: a11y),
            child: Stack(
              children: [
                Scaffold(body: Center(child: field)),
                Positioned.fill(
                  child: Overlay(
                    initialEntries: [
                      OverlayEntry(
                        builder: (_) => AppKeyboardOnlyLayer(force: on),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// What the platform was told about the focused field's keyboard type.
String _platformInputType(WidgetTester tester) {
  final args = tester.testTextInput.setClientArgs;
  if (args == null) return '<never attached>';
  return (args['inputType'] as Map<String, dynamic>)['name'] as String;
}

/// Type one character the way a tapped key does — through the docked host's
/// controller, which is the host's own `onKey` seam.
void _type(WidgetTester tester, String ch) {
  final host = tester.widget<BsKeyboardHost>(find.byType(BsKeyboardHost));
  insertAtCaret(host.controller, ch);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  // The installed input control is global static state; leaving a custom one
  // behind would silently change every later test in the suite.
  tearDown(TextInput.restorePlatformInputControl);

  group('the pair — blocked AND replaced, or neither', () {
    testWidgets(
        '⚠️ LOCKOUT GUARD: a field whose device keyboard is blocked ALWAYS has '
        'ours to type on', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await _pump(tester, on: true, field: TextField(controller: controller));

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Both halves, asserted together on purpose: either one alone is the bug.
      expect(_platformInputType(tester), 'TextInputType.none',
          reason: 'the device keyboard must not be raised');
      expect(find.byType(BsKeyboardHost), findsOneWidget,
          reason: 'blocked with no keyboard = a field nobody can type into');
    });

    testWidgets("OFF: the platform keeps the real inputType — today's behaviour",
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await _pump(tester, on: false, field: TextField(controller: controller));

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(_platformInputType(tester), 'TextInputType.text');
      expect(find.byType(BsKeyboardHost), findsNothing);
    });

    testWidgets('runtime flag off ⇒ nothing is blocked and nothing is shown',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        on: true,
        flag: false,
        field: TextField(controller: controller),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(_platformInputType(tester), 'TextInputType.text');
      expect(find.byType(BsKeyboardHost), findsNothing);
    });

    testWidgets('a11y: a screen reader keeps the real platform keyboard',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        on: true,
        a11y: true,
        field: TextField(controller: controller),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(_platformInputType(tester), 'TextInputType.text',
          reason: 'the a11y fallback is the whole reason the gate is shared');
      expect(find.byType(BsKeyboardHost), findsNothing);
    });
  });

  group('every field, not just the wired ones', () {
    testWidgets('a plain, NEVER-wired TextField gets the keyboard on focus',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await _pump(tester, on: true, field: TextField(controller: controller));

      expect(find.byType(BsKeyboardHost), findsNothing); // not before focus
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.byType(BsKeyboardHost), findsOneWidget,
          reason: 'this is the whole point: no per-field wiring needed');
    });

    testWidgets('losing focus takes the keyboard away', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await _pump(tester, on: true, field: TextField(controller: controller));
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.byType(BsKeyboardHost), findsOneWidget);

      FocusScope.of(tester.element(find.byType(TextField))).unfocus();
      await tester.pumpAndSettle();
      expect(find.byType(BsKeyboardHost), findsNothing);
    });

    testWidgets('a wave-1 BsKeyboardField gets ONE keyboard, not two',
        (tester) async {
      // It is read-only and docks its own host; a second one from here would be
      // two keyboards stacked on the same field.
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        on: true,
        field: BsKeyboardField(controller: controller),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.byType(BsKeyboardHost), findsOneWidget);
    });
  });

  group('typing actually reaches the field', () {
    testWidgets('a tapped key lands in the field AND fires onChanged',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final changes = <String>[];
      await _pump(
        tester,
        on: true,
        field: TextField(controller: controller, onChanged: changes.add),
      );
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ש'));
      await tester.pumpAndSettle();

      expect(controller.text, 'ש');
      // onChanged is the real assertion here: it only fires when the edit goes
      // through the field's own input path. Poking its controller directly would
      // put the text on screen and silently skip every listener — search boxes
      // that never search, forms whose submit button never enables.
      expect(changes, <String>['ש']);
      expect(find.byType(BsKeyboardHost), findsOneWidget,
          reason: 'tapping a key must not read as "tapped outside the field"');
    });

    testWidgets("the field's own maxLength still applies", (tester) async {
      // Proves the edit runs through the field's input formatters, not around
      // them.
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        on: true,
        field: TextField(controller: controller, maxLength: 2),
      );
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      for (final ch in <String>['א', 'ב', 'ג']) {
        _type(tester, ch);
        await tester.pump();
      }
      expect(controller.text, 'אב');
    });

    testWidgets('backspace deletes through the same path', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final changes = <String>[];
      await _pump(
        tester,
        on: true,
        field: TextField(controller: controller, onChanged: changes.add),
      );
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Type first, so the caret is where typing left it — the real sequence,
      // and it also pins that the caret survives the round trip.
      _type(tester, 'ש');
      await tester.pump();
      _type(tester, 'ל');
      await tester.pump();
      expect(controller.text, 'של');

      deleteBackward(
        tester.widget<BsKeyboardHost>(find.byType(BsKeyboardHost)).controller,
      );
      await tester.pump();

      expect(controller.text, 'ש');
      expect(changes, <String>['ש', 'של', 'ש']);
    });

    testWidgets('the app catches up when the field is changed from code',
        (tester) async {
      // A "clear" button, a prefilled form: the keyboard must be typing into the
      // field's CURRENT value, not a stale copy.
      final controller = TextEditingController(text: 'abc');
      addTearDown(controller.dispose);
      await _pump(tester, on: true, field: TextField(controller: controller));
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      controller.clear();
      await tester.pumpAndSettle();
      _type(tester, 'ד');
      await tester.pump();

      expect(controller.text, 'ד', reason: 'not "abcד" — the mirror resynced');
    });
  });

  group('the keys that are not characters', () {
    testWidgets('Enter on a single-line field submits — it does not type a '
        'newline', (tester) async {
      final controller = TextEditingController(text: 'שלום');
      addTearDown(controller.dispose);
      final submits = <String>[];
      await _pump(
        tester,
        on: true,
        field: TextField(controller: controller, onSubmitted: submits.add),
      );
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      _type(tester, '\n');
      await tester.pumpAndSettle();

      expect(controller.text, 'שלום', reason: 'no stray newline in the value');
      expect(submits, <String>['שלום']);
    });

    testWidgets('Enter on a multi-line field DOES type a newline',
        (tester) async {
      final controller = TextEditingController(text: 'a');
      addTearDown(controller.dispose);
      await _pump(
        tester,
        on: true,
        field: TextField(controller: controller, maxLines: 3),
      );
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      _type(tester, '\n');
      await tester.pumpAndSettle();

      expect(controller.text, 'a\n');
    });

    testWidgets('the send key runs the submit action', (tester) async {
      final controller = TextEditingController(text: 'חיפוש');
      addTearDown(controller.dispose);
      final submits = <String>[];
      await _pump(
        tester,
        on: true,
        field: TextField(controller: controller, onSubmitted: submits.add),
      );
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      tester.widget<BsKeyboardHost>(find.byType(BsKeyboardHost)).onSend();
      await tester.pumpAndSettle();

      expect(submits, <String>['חיפוש']);
    });
  });

  group('the keyboard does not cover the field it is typing into', () {
    testWidgets('its height is published while open and cleared when closed',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final container =
          await _pump(tester, on: true, field: TextField(controller: controller));
      expect(container.read(appKeyboardInsetProvider), 0);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(container.read(appKeyboardInsetProvider), greaterThan(0),
          reason: 'without this the keyboard sits on top of the form');

      FocusScope.of(tester.element(find.byType(TextField))).unfocus();
      await tester.pumpAndSettle();
      expect(container.read(appKeyboardInsetProvider), 0);
    });

    testWidgets('AppKeyboardInsets folds that height into viewInsets',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(appKeyboardInsetProvider.notifier).state = 260;

      late MediaQueryData seen;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: AppKeyboardInsets(
              child: Builder(
                builder: (context) {
                  seen = MediaQuery.of(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(seen.viewInsets.bottom, 260,
          reason: 'Scaffold + every sheet already read this to clear the '
              'keyboard, so they all get it right for free');
    });

    testWidgets('zero height leaves MediaQuery untouched', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      late MediaQueryData seen;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: AppKeyboardInsets(
              child: Builder(
                builder: (context) {
                  seen = MediaQuery.of(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(seen.viewInsets.bottom, 0);
    });
  });

  group('appKeyboardVisible — the read-only case a VM test cannot reach', () {
    test('a read-only field gets NO keyboard even once one is asked for', () {
      // On web a read-only field still opens a platform connection (so its text
      // stays selectable), so `show` really does arrive for one. Without this
      // guard a wave-1 BsKeyboardField — read-only, with its own docked host —
      // would get a second keyboard stacked on top of it.
      expect(
        appKeyboardVisible(
          gateOpen: true,
          asked: true,
          hasField: true,
          readOnly: true,
        ),
        isFalse,
      );
    });

    test('an editable field with a keyboard asked for shows it', () {
      expect(
        appKeyboardVisible(
          gateOpen: true,
          asked: true,
          hasField: true,
          readOnly: false,
        ),
        isTrue,
      );
    });

    test('no field, no keyboard', () {
      expect(
        appKeyboardVisible(
          gateOpen: true,
          asked: true,
          hasField: false,
          readOnly: false,
        ),
        isFalse,
      );
    });

    test('gate shut ⇒ never, whatever else is true', () {
      expect(
        appKeyboardVisible(
          gateOpen: false,
          asked: true,
          hasField: true,
          readOnly: false,
        ),
        isFalse,
      );
    });
  });
}

// The registration form under the app-wide keyboard.
//
// WHY THIS FILE IS SEPARATE FROM THE MECHANISM TESTS: if the global keyboard is
// wrong ANYWHERE, this is the screen where it costs the most. A field that is
// blocked with no keyboard to replace it looks exactly like a field that simply
// does not respond — no error, no clue — and on this form that is a person who
// cannot open an account. Every other screen degrades; this one locks people out.
//
// So these tests rebuild the real form's field configurations — phone, SMS code,
// name, email, password, and a validated TextFormField — and put them where the
// real ones live: inside a MODAL BOTTOM SHEET (login_sheet.dart is one) and
// inside a dialog. Those two are the structural risk, because a sheet's fields
// live in the Navigator's overlay, and a keyboard that docks below the Navigator
// would be painted underneath the very sheet it is meant to serve.
//
// Field configs mirror lib/screens/login_sheet.dart (:443-541) and
// lib/screens/welcome_screen.dart (:526-873).

import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/widgets/smart_input/caret.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/app_keyboard_only.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard_host.dart';
import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One field of the real form, described the way the real one describes itself.
class _Field {
  const _Field(this.label, {this.keyboardType, this.obscure = false, this.hints});

  final String label;
  final TextInputType? keyboardType;
  final bool obscure;
  final List<String>? hints;

  TextField build(TextEditingController controller) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        autofillHints: hints,
        decoration: InputDecoration(labelText: label),
      );
}

const _formFields = <_Field>[
  _Field('טלפון',
      keyboardType: TextInputType.phone,
      hints: [AutofillHints.telephoneNumber]),
  _Field('קוד מהודעה',
      keyboardType: TextInputType.number, hints: [AutofillHints.oneTimeCode]),
  _Field('שם', hints: [AutofillHints.name]),
  _Field('מייל',
      keyboardType: TextInputType.emailAddress, hints: [AutofillHints.email]),
  _Field('סיסמה', obscure: true, hints: [AutofillHints.newPassword]),
];

Future<void> _pump(WidgetTester tester, Widget body) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  container.read(featureFlagsProvider.notifier).enable(kSmartInputFlag);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Stack(
          children: [
            Scaffold(body: body),
            Positioned.fill(
              child: Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (_) => const AppKeyboardOnlyLayer(force: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

String _platformInputType(WidgetTester tester) =>
    (tester.testTextInput.setClientArgs!['inputType']
        as Map<String, dynamic>)['name'] as String;

void _type(WidgetTester tester, String text) {
  final host = tester.widget<BsKeyboardHost>(find.byType(BsKeyboardHost));
  for (final ch in text.split('')) {
    insertAtCaret(host.controller, ch);
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));
  tearDown(TextInput.restorePlatformInputControl);

  group('every field of the sign-up form is typable', () {
    for (final field in _formFields) {
      testWidgets('${field.label} — blocked, replaced, and accepts input',
          (tester) async {
        final controller = TextEditingController();
        addTearDown(controller.dispose);
        await _pump(tester, Center(child: field.build(controller)));

        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        expect(_platformInputType(tester), 'TextInputType.none',
            reason: 'the device keyboard must not open on ${field.label}');
        expect(find.byType(BsKeyboardHost), findsOneWidget,
            reason: 'NOBODY COULD SIGN UP if ${field.label} had no keyboard');

        _type(tester, '05');
        await tester.pump();
        expect(controller.text, '05');
      });
    }
  });

  group('where the real form actually lives', () {
    testWidgets('a field inside a MODAL BOTTOM SHEET gets the keyboard on top',
        (tester) async {
      // login_sheet.dart is a modal bottom sheet. Its fields live in the
      // Navigator's overlay, so a keyboard docked below the Navigator would be
      // painted UNDER the sheet — visible in a screenshot, unusable in practice.
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ),
              child: const Text('התחברות'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('התחברות'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(_platformInputType(tester), 'TextInputType.none');
      expect(find.byType(BsKeyboardHost), findsOneWidget);

      _type(tester, '050');
      await tester.pump();
      expect(controller.text, '050');
    });

    testWidgets('a field inside a DIALOG is typable too', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  content: TextField(controller: controller),
                ),
              ),
              child: const Text('פתח'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('פתח'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.byType(BsKeyboardHost), findsOneWidget);
      _type(tester, 'א');
      await tester.pump();
      expect(controller.text, 'א');
    });
  });

  group('form validation still runs', () {
    testWidgets('a TextFormField validator sees text typed on our keyboard',
        (tester) async {
      // Validation hangs off the field's own input path. If our keys reached the
      // controller some other way, the form would look filled in and still
      // refuse to submit — the worst kind of bug to debug from a user report.
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Center(
            child: TextFormField(
              controller: controller,
              validator: (v) =>
                  (v ?? '').length < 3 ? 'קצר מדי' : null,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      _type(tester, 'אב');
      await tester.pumpAndSettle();
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('קצר מדי'), findsOneWidget);

      _type(tester, 'ג');
      await tester.pumpAndSettle();
      expect(formKey.currentState!.validate(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('קצר מדי'), findsNothing);
    });
  });

  group('moving between fields', () {
    testWidgets('the keyboard follows focus from one field to the next',
        (tester) async {
      final first = TextEditingController();
      final second = TextEditingController();
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      await _pump(
        tester,
        Column(
          children: [
            TextField(controller: first, decoration: const InputDecoration(labelText: 'שם')),
            TextField(controller: second, decoration: const InputDecoration(labelText: 'מייל')),
          ],
        ),
      );

      await tester.tap(find.widgetWithText(TextField, 'שם'));
      await tester.pumpAndSettle();
      _type(tester, 'א');
      await tester.pump();

      await tester.tap(find.widgetWithText(TextField, 'מייל'));
      await tester.pumpAndSettle();
      _type(tester, 'ב');
      await tester.pump();

      expect(find.byType(BsKeyboardHost), findsOneWidget,
          reason: 'exactly one keyboard, following the focus');
      expect(first.text, 'א');
      expect(second.text, 'ב', reason: 'typing must not land in the old field');
    });

    testWidgets('Enter with action "next" jumps on, leaving no stray newline',
        (tester) async {
      // A form field wired to `next` keeps the keyboard open and moves the focus
      // on. Anything the keyboard was still holding from the Enter press would
      // be prepended to whatever is typed in the field it lands on.
      final first = TextEditingController();
      final second = TextEditingController();
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      await _pump(
        tester,
        Column(
          children: [
            TextField(
              controller: first,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'שם'),
            ),
            TextField(
              controller: second,
              decoration: const InputDecoration(labelText: 'מייל'),
            ),
          ],
        ),
      );

      await tester.tap(find.widgetWithText(TextField, 'שם'));
      await tester.pumpAndSettle();
      _type(tester, 'א');
      await tester.pump();

      _type(tester, '\n'); // the Enter key
      await tester.pumpAndSettle();

      expect(first.text, 'א', reason: 'no newline may land in the first field');

      _type(tester, 'ב');
      await tester.pump();
      expect(second.text, 'ב',
          reason: 'the focus moved on and typing is clean — not "\\nב"');
    });
  });
}

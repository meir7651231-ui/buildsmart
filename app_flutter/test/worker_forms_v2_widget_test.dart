// Widget-level guard for cluster #85ח · forms v2 (#106/#107) — the DECLARATION +
// SIGNATURE gate on טופס-101 inside WorkerFormsScreen. The pure-state round-trip
// lives in worker_forms_v2_test.dart; this asserts the SCREEN behaviour the
// state test can't see:
//   (a) '📨 שלח לקבלן' tapped WITHOUT the declaration ticked does NOT post the
//       submission notice into the worker↔contractor thread
//       ('th-worker-contractor') — the message count is unchanged — and the
//       101 form is still on screen (honest gate, never a fake success);
//   (b) the declaration text (kDeclarationText) + a '✍️' signature affordance
//       actually render.
//
// Lightweight + deterministic: no real signature drawing (the canvas is
// exercised by signature_pad_test.dart); we assert the GATE, not the pixels.
import 'package:buildsmart/screens/worker_forms_screen.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/worker_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Count messages currently in the shared worker↔contractor thread.
  int contractorMsgCount(ProviderContainer c) {
    final threads = c.read(chatEngineProvider);
    final th = threads.where((t) => t.id == 'th-worker-contractor');
    return th.isEmpty ? -1 : th.first.messages.length;
  }

  Future<ProviderContainer> pumpForms(WidgetTester t) async {
    // #65 gate: with no board session the screen builds ONLY the registration
    // gate — seed a logged-in worker session (ran) so the real forms render.
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"worker","username":"ran","displayName":"רן","demo":false}',
    });
    await t.binding.setSurfaceSize(const Size(440, 1400));
    addTearDown(() => t.binding.setSurfaceSize(null));

    await t.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('he'),
          home: WorkerFormsScreen(),
        ),
      ),
    );
    // Let the lazy boardAuthProvider _load() resolve, then rebuild gate→board.
    for (var i = 0; i < 6; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    return ProviderScope.containerOf(
      t.element(find.byType(WorkerFormsScreen)),
    );
  }

  testWidgets(
      'טופס 101: send WITHOUT the declaration does NOT post to the contractor '
      'thread and the form stays', (t) async {
    final c = await pumpForms(t);

    // The board rendered (not the WelcomeScreen gate): the 101 card title shows.
    expect(find.text('📄 טופס 101 — שנת ${DateTime.now().year}'),
        findsOneWidget,
        reason: 'the worker forms board rendered, not the registration gate');

    // The seeded worker↔contractor thread exists with its 2 seed messages.
    final before = contractorMsgCount(c);
    expect(before, greaterThanOrEqualTo(0),
        reason: 'the th-worker-contractor thread is seeded');

    // Fill VALID employee fields so format validation passes — this isolates the
    // DECLARATION gate (not the field validation) as the reason the send blocks.
    // (Name is prefilled from the session; fill id/phone + pick marital.)
    await t.enterText(find.widgetWithText(TextField, 'תעודת זהות (9 ספרות)'),
        '123456782');
    await t.enterText(
        find.widgetWithText(TextField, 'טלפון נייד'), '0501234567');
    await t.pump();
    // Pick a marital status from the dropdown.
    await t.tap(find.text('מצב משפחתי'));
    await t.pumpAndSettle();
    await t.tap(find.text('נשוי/אה').last);
    await t.pumpAndSettle();

    // Tap '📨 שלח לקבלן' with the declaration STILL UNCHECKED.
    final sendBtn = find.text('📨 שלח לקבלן');
    expect(sendBtn, findsOneWidget);
    await t.ensureVisible(sendBtn);
    await t.tap(sendBtn);
    for (var i = 0; i < 4; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }

    // GATE: nothing was posted into the contractor thread.
    expect(contractorMsgCount(c), before,
        reason: 'an unsigned/undeclared 101 must not post to the contractor');
    // GATE: the form was NOT marked sent (no Form101 carries a sentTs).
    final saved = c.read(workerFormsProvider).form101For('ran', DateTime.now().year);
    expect(saved?.sentTs, isNull,
        reason: 'the 101 was not marked sent through the blocked gate');
    // The form is still on screen (the send was blocked, not navigated away).
    expect(find.text('📨 שלח לקבלן'), findsOneWidget);
  });

  testWidgets(
      'טופס 101: the declaration text and a ✍️ signature affordance render',
      (t) async {
    await pumpForms(t);

    // (b1) the declaration wording is on screen (at least once — it appears on
    // the 101, vacation and sick cards).
    expect(find.text(kDeclarationText), findsWidgets,
        reason: 'the kDeclarationText declaration renders on the forms');

    // (b2) a '✍️ הוסף חתימה' signature affordance renders for the 101 form.
    expect(find.text('✍️ הוסף חתימה'), findsWidgets,
        reason: 'the signature capture affordance renders');
  });
}

// #36 — the worker-board voice dictation toggle. Tapping the mic runs the
// (injected) STT and APPENDS the recognized text into the field's controller,
// so a worker can speak a task instead of typing. The field still types
// normally — this only adds a voice path. A fake listenFn drives dictation
// without a real microphone.
import 'package:buildsmart/widgets/voice_dictate_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dictation appends recognized text into the field (#36)',
      (tester) async {
    final controller = TextEditingController(text: 'התקנת');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VoiceDictateButton(
            controller: controller,
            // fake STT: immediately deliver a final transcript.
            listenFn: ({required onFinal, onError, localeId = 'he-IL'}) async {
              onFinal('ברז במטבח');
              return true;
            },
            stopFn: () async {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(controller.text, 'התקנת ברז במטבח',
        reason: 'dictation augments (space-joins) the typed text, never erases');
  });

  testWidgets('dictation into an empty field sets it verbatim (#36)',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VoiceDictateButton(
            controller: controller,
            listenFn: ({required onFinal, onError, localeId = 'he-IL'}) async {
              onFinal('להחליף סיפון');
              return true;
            },
            stopFn: () async {},
          ),
        ),
      ),
    );
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(controller.text, 'להחליף סיפון');
  });
}

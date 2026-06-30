import 'package:buildsmart/features/card_keyboard/opening_inputs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no capabilities → only word-grid + text', () {
    expect(
      liveOpeningInputs(aiAvailable: false, voiceAvailable: false),
      [OpeningInput.wordGrid, OpeningInput.text],
    );
  });

  test('all capabilities → all four inputs in order', () {
    expect(
      liveOpeningInputs(aiAvailable: true, voiceAvailable: true),
      [
        OpeningInput.wordGrid,
        OpeningInput.text,
        OpeningInput.voice,
        OpeningInput.ai,
      ],
    );
  });

  test('word-grid + text are present in every capability combo', () {
    for (final ai in [true, false]) {
      for (final voice in [true, false]) {
        expect(
          liveOpeningInputs(aiAvailable: ai, voiceAvailable: voice),
          containsAll([OpeningInput.wordGrid, OpeningInput.text]),
        );
      }
    }
  });

  test('voice / ai appear iff their capability is on', () {
    final voiceOnly =
        liveOpeningInputs(aiAvailable: false, voiceAvailable: true);
    expect(voiceOnly, contains(OpeningInput.voice));
    expect(voiceOnly, isNot(contains(OpeningInput.ai)));

    final aiOnly = liveOpeningInputs(aiAvailable: true, voiceAvailable: false);
    expect(aiOnly, contains(OpeningInput.ai));
    expect(aiOnly, isNot(contains(OpeningInput.voice)));
  });
}

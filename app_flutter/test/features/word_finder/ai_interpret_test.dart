import 'package:buildsmart/features/word_finder/ai_interpret.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('strips filler and folds synonyms', () {
    // 'אני צריך' (I need) is filler; 'copper' folds to נחושת.
    expect(aiLiteralInterpret('אני צריך copper'), 'נחושת');
  });

  test('keeps product nouns, drops filler verbs', () {
    final tokens = aiLiteralInterpret('אני רוצה ברז כדורי').split(' ');
    expect(tokens, contains('ברז'));
    expect(tokens, contains('כדורי'));
    expect(tokens, isNot(contains('רוצה')));
  });

  test('never empty — an all-filler request falls back to the text', () {
    expect(aiLiteralInterpret('אני צריך משהו'), isNotEmpty);
  });

  test('defaultAiInterpret is the offline literal path', () async {
    expect(await defaultAiInterpret('תביא לי copper'), 'נחושת');
  });
}

// chat_suggestion_source.dart — the chat composer's eligible-phrase pool.
//
// A blank query returns the whole pool (quick-replies + order-stage labels); a
// query filters case-insensitively by `contains`; a non-matching query returns
// an empty list. Mirrors `StaticSuggestionSource`'s contract.

import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/widgets/smart_input/chat_suggestion_source.dart';
import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const source = ChatSuggestionSource();
  const ctx = SmartInputContext(kind: InputFieldKind.freeTextHe);

  // The full eligible pool = quick-replies followed by the order-stage labels.
  final poolSize = kChatQuickReplies.length + kOrderStageLabel.values.length;

  test('blank query returns the full pool (quick-replies + order labels)', () {
    final out = source.candidates(ctx, '');
    expect(out, isNotEmpty);
    expect(out.length, poolSize);
    final texts = out.map((s) => s.text).toList();
    // Sanity: both pools contributed.
    expect(texts, contains(kChatQuickReplies.first)); // 'קיבלתי, תודה'
    expect(texts, contains(kOrderStageLabel.values.first)); // 'התקבלה'
  });

  test('whitespace-only query also returns the full pool', () {
    final out = source.candidates(ctx, '   ');
    expect(out.length, poolSize);
  });

  test('a query filters case-insensitively by contains', () {
    // 'תודה' appears in both 'קיבלתי, תודה' and 'תודה רבה'.
    final out = source.candidates(ctx, 'תודה');
    final texts = out.map((s) => s.text).toList();
    expect(texts, contains('קיבלתי, תודה'));
    expect(texts, contains('תודה רבה'));
    // Pool order is preserved: 'קיבלתי, תודה' precedes 'תודה רבה'.
    expect(
      texts.indexOf('קיבלתי, תודה') < texts.indexOf('תודה רבה'),
      isTrue,
    );
    // It really filtered (a non-matching phrase is gone).
    expect(texts, isNot(contains('מעולה')));
  });

  test('a non-matching query returns empty', () {
    final out = source.candidates(ctx, 'zzz-no-such-phrase');
    expect(out, isEmpty);
  });
}

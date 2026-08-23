// Pins the AI business-summary feature (#ai-business-summary): the prompt HANDS
// Claude the REAL computed insight lines and forbids inventing/changing numbers —
// Claude only narrates. A summary that invents a number is worse than none. Pure —
// no gateway, no widget pump.
import 'package:buildsmart/screens/business_summary_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('businessSummaryPrompt carries every real insight line', () {
    const lines = [
      '📦 6 הזמנות · ₪48,000 סה״כ רכש — מתוך מנוע ההזמנות המשותף',
      '💵 שווי הזמנה ממוצע: ₪8,000 — ממוצע על פני כל ההזמנות',
      '📊 ניצול תקציב: 40% — נותרו ₪72,000 מתוך ₪120,000',
    ];
    final p = businessSummaryPrompt(lines);
    for (final line in lines) {
      expect(p, contains(line), reason: 'real insight line preserved: $line');
    }
  });

  test('businessSummaryPrompt forbids inventing or changing numbers', () {
    final p = businessSummaryPrompt(const ['📊 ניצול תקציב: 40%']);
    expect(p, contains('אך ורק במספרים שניתנו'),
        reason: 'must use only the given numbers');
    expect(p, contains('אל תמציא'),
        reason: 'the model may not invent a number');
  });
}

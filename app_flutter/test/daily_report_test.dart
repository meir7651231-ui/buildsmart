// Pins the shared AI daily-report narrator (#ai-daily-report): the prompt HANDS
// Claude the real recorded report lines and forbids inventing/changing numbers —
// Claude only weaves them into a sentence. Pure — no gateway, no widget pump.
import 'package:buildsmart/screens/daily_report_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dailyReportPrompt carries the title + every real report line', () {
    const lines = [
      '✅ אושרו: 8',
      '📸 הוגשו וממתינות לאישור: 1',
      '🔨 בביצוע: 2',
    ];
    final p = dailyReportPrompt('דוח-יום — רן', lines);
    expect(p, contains('דוח-יום — רן'), reason: 'the title is included');
    for (final line in lines) {
      expect(p, contains(line), reason: 'real report line preserved: $line');
    }
  });

  test('dailyReportPrompt forbids inventing or changing numbers', () {
    final p = dailyReportPrompt('דוח', const ['📦 נמסרו: 12']);
    expect(p, contains('אך ורק במספרים שניתנו'),
        reason: 'must use only the given numbers');
    expect(p, contains('אל תמציא'),
        reason: 'the model may not invent a number');
  });
}

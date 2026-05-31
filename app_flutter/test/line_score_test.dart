// Roadmap step 30 — line-level readiness score.
import 'package:buildsmart/data/line_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('perfect: no gaps, several safety items → "מצוין" (score ≥ 80)', () {
    final r = lineReadinessFromCounts(gapCount: 0, safetyKitSize: 5);
    expect(r.score, greaterThanOrEqualTo(80));
    expect(r.label, 'מצוין');
  });

  test('no gaps, no safety → connectivity only', () {
    final r = lineReadinessFromCounts(gapCount: 0, safetyKitSize: 0);
    // raw = 50/75 → 67%
    expect(r.score, 67);
    expect(r.label, 'טוב');
  });

  test('many gaps, no safety → "חלקי" (score < 30)', () {
    final r = lineReadinessFromCounts(gapCount: 5, safetyKitSize: 0);
    expect(r.score, 0);
    expect(r.label, 'חלקי');
  });

  test('one gap, full safety → mid range', () {
    final r = lineReadinessFromCounts(gapCount: 1, safetyKitSize: 5);
    // raw = (50-15) + 25 = 60 → 60/75*100 = 80
    expect(r.score, 80);
    expect(r.label, 'מצוין');
  });

  test('safety is capped at 25 (≥5 items)', () {
    final r1 = lineReadinessFromCounts(gapCount: 0, safetyKitSize: 5);
    final r2 = lineReadinessFromCounts(gapCount: 0, safetyKitSize: 10);
    expect(r1.score, r2.score, reason: 'capped at 5 items × +5 = 25');
  });

  test('connectivity floors at 0 (≥4 gaps)', () {
    final r1 = lineReadinessFromCounts(gapCount: 4, safetyKitSize: 0);
    final r2 = lineReadinessFromCounts(gapCount: 10, safetyKitSize: 0);
    expect(r1.score, r2.score, reason: 'floor 0');
  });

  test('score is in [0, 100] for any inputs', () {
    for (final gaps in [0, 1, 5, 100]) {
      for (final kit in [0, 1, 5, 50]) {
        final r = lineReadinessFromCounts(
            gapCount: gaps, safetyKitSize: kit);
        expect(r.score, inInclusiveRange(0, 100), reason: '$gaps gaps, $kit kit');
      }
    }
  });
}

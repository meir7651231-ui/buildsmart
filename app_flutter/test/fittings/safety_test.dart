// 🔑🛡️ Phase B (step 32) — hot-line safety: the advisory set for a hot PP-R line,
// with the M5 discipline enforced (every item carries the non-binding caveat; a
// cold line surfaces NOTHING — no phantom requirement).
import 'package:buildsmart/features/fittings/plan/safety.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('step 32 — hot-line advisories', () {
    test('a hot PP-R line surfaces PRV + expansion-vessel + pipe-expansion + anti-scald + insulation', () {
      final a = hotLineSafetyFor('PPR', 70);
      expect(a.length, 5);
      final titles = a.map((s) => s.title).join(' | ');
      expect(titles, allOf(contains('PRV'), contains('מיכל'), contains('התפשטות'),
          contains('כוויה'), contains('בידוד'),),);
    });

    test('🛡️ under-warning fix — a hot FASER/PP-RCT line is NOT dropped', () {
      // The strict ==\'PPR\' bug (caught by adversarial review) silently dropped
      // the fiber-reinforced labels — exactly the hot-line pipes.
      for (final mat in [
        'PPR · מחוזק בסיבי זכוכית (faser)',
        'PPR · faser',
        'PPRCT',
        'PP-RCT',
      ]) {
        expect(hotLineSafetyFor(mat, 70), isNotEmpty,
            reason: 'hot $mat line must surface safety advisories',);
      }
    });

    test('the hot threshold is 60°C (≥ hot, < cold)', () {
      expect(hotLineSafetyFor('PPR', 60), isNotEmpty); // boundary is hot
      expect(hotLineSafetyFor('PPR', 59), isEmpty);
      expect(kHotLineThresholdC, 60);
    });

    test('a cold line surfaces NOTHING (no phantom safety requirement · M1)', () {
      expect(hotLineSafetyFor('PPR', 20), isEmpty);
      expect(hotLineSafetyFor('PPR', 40), isEmpty);
    });

    test('scoped to PP-R (a non-PP-R material yields no PP-R advisories)', () {
      expect(hotLineSafetyFor('HDPE', 70), isEmpty);
      expect(hotLineSafetyFor('פליז', 70), isEmpty);
    });
  });

  group('🛡️ M5 — safety discipline', () {
    test('EVERY advisory carries the mandatory non-binding caveat', () {
      for (final s in hotLineSafetyFor('PPR', 80)) {
        expect(s.caveat, isNotEmpty);
        expect(s.caveat, contains('לא ערך-מחייב')); // advisory, NOT binding
        expect(s.caveat, contains('מוסמך')); // licensed installer/engineer
        expect(s.caveat, contains('קוד המקומי')); // per local code
      }
    });

    test('no advisory smuggles a BINDING numeric value as a requirement', () {
      // The advisories are qualitative reminders; the only number is the
      // descriptive scald threshold (≥60°C), never a binding pressure/time/torque
      // VALUE (a digit immediately followed by a unit).
      final binding = RegExp(r'\d+\s*(בר|שנ|דק|Nm|kPa|MPa)');
      for (final s in hotLineSafetyFor('PPR', 70)) {
        expect(binding.hasMatch(s.whyHe), isFalse,
            reason: 'no binding numeric requirement in: ${s.whyHe}',);
      }
    });

    test('the caveat constant names the standards + non-binding + certified', () {
      expect(kSafetyCaveat, contains('לא ערך-מחייב'));
      expect(kSafetyCaveat, contains('מוסמך'));
      expect(kSafetyCaveat, allOf(contains('ISO 15874'), contains('DVS 2207-11')));
    });
  });
}

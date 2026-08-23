// 🔑 Phase B (step 28) — envelope golden: every bounding field is a projection of
// a golden engine letter, so it is transitively byte-identical to pure_engine.py.
// + mutation-L3 (OD-sensitive) + out-of-domain null (M1).
import 'package:buildsmart/features/fittings/engine/fitting_dims.dart';
import 'package:buildsmart/features/fittings/plan/envelope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('envelope ≡ engine letters (transitively golden)', () {
    test('every family projects the right letters', () {
      final c = generate('מצמד', 32);
      expect(envelopeFor('מצמד', 32),
          Envelope(axialLength: c['A']!, radialDiameter: c['B']!),);

      final e = generate('ברך 90°', 32);
      expect(envelopeFor('ברך 90°', 32),
          Envelope(axialLength: e['l']!, radialDiameter: e['D']!, secondaryExtent: e['l']),);

      final t = generate('מסעף (טי)', 50);
      expect(envelopeFor('מסעף (טי)', 50),
          Envelope(axialLength: t['E']!, radialDiameter: t['B']!, secondaryExtent: t['A']),);

      final r = generate('מצרה', 50, od2: 40);
      expect(envelopeFor('מצרה', 50, od2: 40),
          Envelope(axialLength: r['A']!, radialDiameter: r['B1']!),);

      final v = generate('ברז כדורי', 32);
      expect(envelopeFor('ברז כדורי', 32),
          Envelope(axialLength: v['l']! * 2, radialDiameter: v['D']!, secondaryExtent: v['h']),);

      final s = generate('רוכב', 63);
      expect(envelopeFor('רוכב', 63),
          Envelope(axialLength: s['d1']!, radialDiameter: s['D']!, secondaryExtent: s['l']),);

      final co = generate('צווארון', 110);
      expect(envelopeFor('צווארון', 110),
          Envelope(axialLength: co['A']!, radialDiameter: co['D1']!),);
    });

    test('every single-diameter family + reducer yields a non-null envelope', () {
      for (final fam in kFittingFamilies) {
        for (final od in kDepth.keys) {
          expect(envelopeFor(fam, od), isNotNull, reason: '$fam · $od');
        }
      }
      expect(envelopeFor('מצרה', 50, od2: 40), isNotNull);
      expect(envelopeFor('ברך מחותכת', 200), isNotNull);
    });
  });

  group('mutation-L3 — envelope is dimension-bearing', () {
    test('a different OD changes the envelope (an OD mutation is caught)', () {
      for (final fam in kFittingFamilies) {
        expect(envelopeFor(fam, 32), isNot(envelopeFor(fam, 50)),
            reason: '$fam envelope is OD-blind',);
      }
    });
    test('the secondary extent is null for straight families, set for bent/branched', () {
      expect(envelopeFor('מצמד', 32)!.secondaryExtent, isNull);
      expect(envelopeFor('פקק', 32)!.secondaryExtent, isNull);
      expect(envelopeFor('ברך 90°', 32)!.secondaryExtent, isNotNull);
      expect(envelopeFor('מסעף (טי)', 50)!.secondaryExtent, isNotNull);
    });
  });

  test('out-of-domain → null (M1 fallback, never a wrong box)', () {
    // an OD with no DEPTH entry makes the letters NaN → the projected fields are
    // NaN, but an unknown family returns null outright.
    expect(envelopeFor('לא-משפחה', 32), isNull);
  });
}

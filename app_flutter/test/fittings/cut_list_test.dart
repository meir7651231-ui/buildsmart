// 🔑 Phase B (step 33) — Z-cut golden: the deduction per family equals the engine
// letters (transitively golden vs pure_engine.py); cut-length = center↔center − Z₁ − Z₂.
import 'package:buildsmart/features/fittings/engine/fitting_dims.dart';
import 'package:buildsmart/features/fittings/plan/cut_list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cutDeductionFor ≡ engine geometry', () {
    test('elbow Z = z (center→socket-bottom = l − F)', () {
      for (final od in kDepth.keys) {
        final e = generate('ברך 90°', od);
        expect(cutDeductionFor('ברך 90°', od), e['z']);
        expect(cutDeductionFor('ברך 90°', od), r1(e['l']! - e['F']!));
      }
    });

    test('coupler Z = A/2 − F (= 1mm, the half center-stop)', () {
      for (final od in kDepth.keys) {
        final c = generate('מצמד', od);
        expect(cutDeductionFor('מצמד', od), r1(c['A']! / 2 - c['F']!));
      }
      expect(cutDeductionFor('מצמד', 32), 1.0); // A=38,F=18 → 19−18
    });

    test('tee run Z = B/2, branch Z = A − F', () {
      final t = generate('מסעף (טי)', 50);
      expect(cutDeductionFor('מסעף (טי)', 50), r1(t['B']! / 2));
      expect(cutDeductionFor('מסעף (טי)', 50, socket: 'branch'), r1(t['A']! - t['F']!));
    });

    test('undefined families → null (M1, never a wrong deduction)', () {
      for (final fam in ['מצרה', 'פקק', 'ברז כדורי', 'רוכב', 'צווארון',
        'מתאם תבריג', 'ברך מחותכת', 'לא-משפחה',]) {
        expect(cutDeductionFor(fam, 50), isNull, reason: fam);
      }
    });
  });

  group('pipeCutLength', () {
    test('length = center↔center − Z₁ − Z₂', () {
      // two DN32 elbows 1000mm apart, centre-to-centre.
      final z = cutDeductionFor('ברך 90°', 32)!;
      expect(pipeCutLength(1000, z, z), r1(1000 - 2 * z));
    });
    test('the deduction shortens the cut (a real field correction)', () {
      final z = cutDeductionFor('ברך 90°', 50)!;
      expect(pipeCutLength(500, z, z), lessThan(500));
    });
  });

  group('mutation-L3 — the deduction is dimension-bearing', () {
    test('a different OD changes the elbow deduction', () {
      expect(cutDeductionFor('ברך 90°', 32), isNot(cutDeductionFor('ברך 90°', 50)));
    });
    test('tee run and branch deductions differ', () {
      expect(cutDeductionFor('מסעף (טי)', 50),
          isNot(cutDeductionFor('מסעף (טי)', 50, socket: 'branch')),);
    });
  });
}

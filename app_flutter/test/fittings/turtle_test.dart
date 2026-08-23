// 🔑 Phase C (step 41) — turtle layout deltas: each ex/ey/turn is a projection of a
// golden engine letter (⇒ transitively byte-identical to pure_engine.py) and
// matches gen3d.html elemMeshes. + mutation-L3 + out-of-domain null (M1).
import 'dart:math' as math;

import 'package:buildsmart/features/fittings/engine/fitting_dims.dart';
import 'package:buildsmart/features/fittings/layout/turtle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('layout deltas ≡ gen3d elemMeshes (from golden letters)', () {
    test('straight families advance by the right letter, no turn', () {
      expect(layoutDeltaFor('מצמד', 32)!.ex, generate('מצמד', 32)['A']);
      expect(layoutDeltaFor('מסעף (טי)', 50)!.ex, generate('מסעף (טי)', 50)['E']);
      expect(layoutDeltaFor('מתאם תבריג', 20)!.ex, generate('מתאם תבריג', 20)['l']);
      for (final fam in ['מצמד', 'מסעף (טי)', 'מתאם תבריג', 'ברז כדורי', 'מצרה', 'פקק', 'רוכב', 'צווארון']) {
        final d = layoutDeltaFor(fam, 32)!;
        expect(d.ey, 0, reason: '$fam is straight (no bend)');
        expect(d.turn, 0, reason: '$fam does not turn');
      }
    });

    test('elbow 90° turns π/2: ex=l, ey=l', () {
      final l = generate('ברך 90°', 32)['l']!;
      final d = layoutDeltaFor('ברך 90°', 32)!;
      expect(d.turn, math.pi / 2);
      expect(d.ex, closeTo(l, 1e-9)); // l·cos(90°)=0 → ex=l
      expect(d.ey, closeTo(l, 1e-9));
    });

    test('elbow 45° turns π/4: ex=l(1+cos45), ey=l·sin45', () {
      final l = generate('ברך 45°', 32)['l']!;
      final d = layoutDeltaFor('ברך 45°', 32)!;
      expect(d.turn, math.pi / 4);
      expect(d.ex, closeTo(l + l * math.cos(math.pi / 4), 1e-9));
      expect(d.ey, closeTo(l * math.sin(math.pi / 4), 1e-9));
    });

    test('plug is terminal; the run ends after it', () {
      expect(layoutDeltaFor('פקק', 40)!.terminal, isTrue);
      expect(layoutDeltaFor('מצמד', 40)!.terminal, isFalse);
    });

    test('reducer advance = F1 + 4 + F2', () {
      final g = generate('מצרה', 50, od2: 40);
      expect(layoutDeltaFor('מצרה', 50, od2: 40)!.ex, closeTo(g['F1']! + 4 + g['F2']!, 1e-9));
    });
  });

  group('mutation-L3 + fallback', () {
    test('a different OD changes the delta (OD-sensitive)', () {
      for (final fam in ['מצמד', 'ברך 90°', 'מסעף (טי)', 'רוכב']) {
        expect(layoutDeltaFor(fam, 32), isNot(layoutDeltaFor(fam, 50)), reason: fam);
      }
    });
    test('unknown family → null (M1 — image fallback, never a wrong layout)', () {
      expect(layoutDeltaFor('לא-משפחה', 32), isNull);
      expect(layoutDeltaFor('ברך מחותכת', 200), isNull); // not a turtle family (yet)
    });
  });
}

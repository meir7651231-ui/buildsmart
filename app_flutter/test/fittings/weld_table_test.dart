// 🔑🛡️ Phase B (step 31) — welding params: golden vs the verified DVS source,
// and the M5 discipline enforced — every result carries the mandatory caveat, an
// unknown OD returns null (never an invented safety value).
import 'package:buildsmart/features/fittings/plan/weld_table.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('golden — verbatim from gen3d.html WELD (DVS 2207-11)', () {
    test('every table OD returns its exact [heat, join, cool] @ 260°C', () {
      const expected = <int, List<int>>{
        16: [5, 4, 2], 20: [5, 4, 2], 25: [7, 4, 2], 32: [8, 6, 4],
        40: [12, 6, 4], 50: [18, 6, 4], 63: [24, 8, 6], 75: [30, 8, 8],
        90: [40, 8, 8], 110: [50, 10, 8], 125: [60, 10, 8],
      };
      for (final e in expected.entries) {
        final p = weldParamsFor(e.key);
        expect(p, isNotNull, reason: 'OD ${e.key}');
        expect([p!.heatSec, p.joinSec, p.coolMin], e.value, reason: 'OD ${e.key}');
        expect(p.headTempC, 260);
      }
    });
  });

  group('🛡️ M5 — safety discipline', () {
    test('EVERY returned WeldParams carries the mandatory manufacturer caveat', () {
      for (final od in [16, 20, 32, 50, 110, 125]) {
        final p = weldParamsFor(od)!;
        expect(p.caveat, isNotEmpty);
        expect(p.caveat, contains('DVS 2207-11'));
        expect(p.caveat, contains('מתקין מוסמך')); // certified installer only
        expect(p.caveat, contains('לאמת')); // must verify vs manufacturer
      }
    });

    test('an OD with no verified value → null (never an invented weld time)', () {
      for (final od in [10, 18, 45, 140, 160, 200, 999]) {
        expect(weldParamsFor(od), isNull, reason: 'OD $od has no DVS reference');
      }
    });

    test('the caveat constant matches the reference wording (DVS + verify + installer)', () {
      expect(kWeldCaveat, contains('DVS 2207-11'));
      expect(kWeldCaveat, contains('מתקין מוסמך בלבד'));
      expect(kWeldHeadTempC, 260);
    });
  });

  group('mutation-L3 — the table is value-bearing', () {
    test('larger OD ⇒ non-decreasing heat time (a scrambled table would fail)', () {
      final ods = [20, 32, 50, 63, 90, 125];
      for (var i = 1; i < ods.length; i++) {
        expect(weldParamsFor(ods[i])!.heatSec,
            greaterThan(weldParamsFor(ods[i - 1])!.heatSec),
            reason: 'heat ${ods[i]} vs ${ods[i - 1]}',);
      }
    });
  });
}

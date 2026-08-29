// 🔑 Phase D slice 5 — cut-list golden: pipe cut length between adjacent fittings
// = centre-to-centre − socket deduction A − socket deduction B. Grounded in the
// phase-B cut_list engine (cutDeductionFor / pipeCutLength). Pure geometry.
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/intel/line_cuts.dart';
import 'package:buildsmart/features/fittings/plan/cut_list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('🔑 a coupler→coupler gap: cut = c2c − 2·(coupler deduction), engine-anchored', () {
    const route = [RunElement(Family.coupler, 32), RunElement(Family.coupler, 32)];
    final cuts = cutList(route, const [200]);
    expect(cuts, hasLength(1));
    final ded = cutDeductionFor('מצמד', 32) ?? 0;
    expect(cuts.single.cutLength, pipeCutLength(200, ded, ded));
    expect(cuts.single.od, 32);
    expect(cuts.single.fromFamily, 'מצמד');
  });

  test('a fitting with no defined deduction contributes 0 (M1 fallback, no crash)', () {
    // reducer has no symmetric cut deduction → treated as 0.
    const route = [RunElement(Family.reducer, 50, od2: 32), RunElement(Family.coupler, 32)];
    final cuts = cutList(route, const [180]);
    expect(cuts, hasLength(1));
    final dedCoupler = cutDeductionFor('מצמד', 32) ?? 0;
    expect(cuts.single.cutLength, pipeCutLength(180, 0, dedCoupler));
  });

  test('multi-gap route yields one segment per gap; ODs track the downstream fitting', () {
    const route = [
      RunElement(Family.coupler, 50),
      RunElement(Family.elbow90, 50, dir: Dir.up),
      RunElement(Family.coupler, 32),
    ];
    final cuts = cutList(route, const [200, 150]);
    expect(cuts, hasLength(2));
    expect(cuts[0].od, 50);
    expect(cuts[1].od, 32);
  });

  test('a route shorter than 2, or missing spacings, yields no crash', () {
    expect(cutList(const [RunElement(Family.coupler, 32)], const [200]), isEmpty);
    expect(cutList(const [], const []), isEmpty);
    // fewer spacings than gaps → stops at the available spacings
    const route = [
      RunElement(Family.coupler, 32),
      RunElement(Family.coupler, 32),
      RunElement(Family.coupler, 32),
    ];
    expect(cutList(route, const [200]), hasLength(1));
  });

  test('cutListUniform applies one spacing to every gap', () {
    const route = [
      RunElement(Family.coupler, 32),
      RunElement(Family.coupler, 32),
      RunElement(Family.coupler, 32),
    ];
    final cuts = cutListUniform(route, 250);
    expect(cuts, hasLength(2));
    expect(cuts.every((c) => c.centerToCenter == 250), isTrue);
  });
}

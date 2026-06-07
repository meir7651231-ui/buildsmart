// B2 safety/correctness gates for the connection engine.
//
//  P2.4 — cross-system fail-closed: buildInstallation must NEVER bridge a
//  supply product to a drainage product. The verified BFS already enforces this
//  (system-intersection), and _findBridge now matches it. A cross-system pair
//  must surface as a GAP, never as a silently-bridged chain. This gate locks the
//  invariant so a future spec-less catalog fitting can't reopen the hole.
//
//  P2.5 — tee ≠ manifold: manifoldOutlets must report parallel outlets ONLY for
//  real distribution manifolds ("מחלקים"). A tee/מסעף (3+ same-size ends) is a
//  single branch off a run, not a multi-outlet manifold (regression: 116565 was
//  classified as a 3-outlet manifold).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String sku) =>
    kCompatCatalog.firstWhere((q) => q.sku == sku);

void main() {
  test(timeout: const Timeout(Duration(minutes: 3)),
      'P2.4 — buildInstallation never bridges supply↔drainage (gaps, not bridge)',
      () {
    final withSpec =
        kCompatCatalog.where((p) => kVerifiedSpecs[p.sku] != null).toList();
    bool only(LipskeyCatalogProduct p, WaterSystem s) =>
        productSystems(p).length == 1 && productSystems(p).contains(s);
    final supply = withSpec.where((p) => only(p, WaterSystem.supply)).toList();
    final drain = withSpec.where((p) => only(p, WaterSystem.drainage)).toList();
    expect(supply.length, greaterThan(20)); // non-vacuous sample
    expect(drain.length, greaterThan(20));

    final bridged = <String>[];
    final sN = supply.length < 40 ? supply.length : 40;
    final dN = drain.length < 40 ? drain.length : 40;
    for (var i = 0; i < sN; i++) {
      for (var j = 0; j < dN; j++) {
        final s = supply[i], d = drain[j];
        final plan = buildInstallation([s, d], tempC: 20);
        // Cross-system: a safe engine records a gap (no physical path). An empty
        // gap list means _findBridge produced a forbidden cross-system bridge.
        if (plan.gaps.isEmpty) {
          bridged.add('${s.nameHe}(${s.sku}) → ${d.nameHe}(${d.sku}) :: '
              '${plan.items.map((p) => p.sku).join(">")}');
        }
      }
    }
    expect(bridged, isEmpty,
        reason: 'cross-system bridges (must be 0): ${bridged.length}\n'
            '${bridged.take(15).join("\n")}');
  });

  group('P2.5 — manifoldOutlets classifies by taxonomy, not end-count', () {
    test('real manifolds report their outlet counts', () {
      expect(manifoldOutlets(_p('76032204')), 4); // מחלק 1" 4 יציאות
      expect(manifoldOutlets(_p('76032202')), 2); // מחלק 1" 2 יציאות
      expect(manifoldOutlets(_p('77603204')), 4); // מחלק 3/4" 4 יציאות
    });
    test('a tee (3 same-size ends) is NOT a manifold', () {
      // 116565 "מסעף 45° תבריג כפול" — spec ends [50,50,50]; categoryHe is
      // 'אביזרי תבריג', not 'מחלקים'. End-count alone said 3; taxonomy says 0.
      final tee = _p('116565');
      expect(tee.categoryHe, isNot('מחלקים')); // guards the premise
      expect(kVerifiedSpecs['116565']!.ends.length, greaterThanOrEqualTo(3));
      expect(manifoldOutlets(tee), 0);
    });
    test('a plain pipe is not a manifold', () {
      expect(manifoldOutlets(_p('116113')), 0); // צינור ניקוז 110
    });
  });

  group('terminal devices — one per line, no terminal→terminal (D1/D3/D5/D6)', () {
    test('two traps never connect (double-trap)', () {
      // bottle trap ↔ bottle trap, and siphon ↔ open trap — each is one fixture's
      // single water seal; a second downstream is a prohibited double-trap.
      expect(findShortestPath(_p('218553'), _p('217861')), isNull);
      expect(findShortestPath(_p('77003221'), _p('116635')), isNull);
    });
    test('two draw-off taps never connect (two fixtures in series)', () {
      expect(findShortestPath(_p('779096G'), _p('77777114')), isNull); // מטבח↔כיור
      expect(findShortestPath(_p('77777345'), _p('77777114')), isNull); // גן↔כיור
    });
    test('two floor drains never connect', () {
      expect(findShortestPath(_p('220542'), _p('218681')), isNull);
    });
    test('separated terminals caught at line level (trap → pipe → trap)', () {
      // The pairwise path search sees only one terminal per adjacent pair; the
      // line-level guard in buildInstallation must still flag the double-trap.
      final plan =
          buildInstallation([_p('218553'), _p('116180'), _p('217861')], tempC: 20);
      expect(plan.gaps, isNotEmpty);
      expect(plan.isComplete, isFalse);
    });
    test('a valid one-terminal line still connects', () {
      expect(findShortestPath(_p('77777313'), _p('779096G')), isNotNull); // valve→faucet
      expect(findShortestPath(_p('217861'), _p('116180')), isNotNull); // trap→pipe
    });
  });
}

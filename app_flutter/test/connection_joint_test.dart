// connectionJoint / jointLabelHe are the single source of truth for "how do
// these two products join" — shared by the תאימות carousel
// (connectionExplainHe) and the install-studio chain diagram (ChainDiagram).
// These tests guard that the wording stays unified and that every real edge in
// a built chain gets a label.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('jointLabelHe is canonical per joint kind', () {
    expect(jointLabelHe(EndType.bspMale, '1/2"'), 'תבריג 1/2"');
    expect(jointLabelHe(EndType.bspFemale, '3/4"'), 'תבריג 3/4"');
    expect(jointLabelHe(EndType.pexPress, '16'), 'Press PEX 16');
    expect(jointLabelHe(EndType.copperPress, '22'), 'Press נחושת 22');
    expect(jointLabelHe(EndType.hdpeCompression, '32'), 'אום הידוק DN32');
    expect(jointLabelHe(EndType.drainOpening, '110'), 'ניקוז ⌀110');
  });

  test('carousel label == diagram label for the same joint (unified wording)',
      () {
    // The carousel uses connectionExplainHe; the diagram uses
    // jointLabelHe(connectionJoint(...)). They must agree for every pair.
    final specced =
        kLipskeyCatalog.where((p) => kVerifiedSpecs.containsKey(p.sku)).toList();
    var checked = 0;
    for (var i = 0; i < specced.length && checked < 400; i += 7) {
      final src = specced[i];
      for (final h in compatibleProductsFor(src).take(6)) {
        final carousel = connectionExplainHe(src, h);
        final j = connectionJoint(src, h);
        final diagram = j == null ? '' : jointLabelHe(j.type, j.size);
        expect(carousel, diagram,
            reason: 'wording diverged for ${src.sku} ↔ ${h.sku}');
        expect(carousel, isNotEmpty);
        checked++;
      }
    }
    expect(checked, greaterThan(50));
  });

  test('every real engine edge in a path gets a chain-diagram label', () {
    // Use findShortestPath (the TRUE physical sequence) so consecutive items
    // are genuine engine edges. Each must produce a non-empty
    // chainEdgeLabelHe — either a direct/compression joint or an implicit-pipe
    // bridge — so the studio diagram never leaves a real edge blank.
    final supply = kLipskeyCatalog
        .where((p) =>
            kVerifiedSpecs.containsKey(p.sku) &&
            productSystems(p).contains(WaterSystem.supply))
        .toList();
    expect(supply.length, greaterThan(10));

    var edgesChecked = 0;
    for (var i = 0; i + 1 < supply.length && edgesChecked < 80; i += 11) {
      final path =
          findShortestPath(supply[i], supply[i + 1], maxDepth: 8, tempC: 20);
      if (path == null) continue;
      for (var k = 0; k + 1 < path.length; k++) {
        final a = path[k], b = path[k + 1];
        expect(chainEdgeLabelHe(a, b), isNotEmpty,
            reason: 'blank chain-diagram edge between engine neighbours '
                '${a.sku} → ${b.sku}');
        edgesChecked++;
      }
    }
    expect(edgesChecked, greaterThan(0));
  });
}

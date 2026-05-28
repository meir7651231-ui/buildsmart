// lineStructureText builds the "מבנה הקו" block in the installer BOM export —
// each product plus the joint method to the next, using the unified joint
// wording (chainEdgeLabelHe). Guards the format so the WhatsApp export stays
// readable and actually states how each piece connects.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty for a chain shorter than 2 items', () {
    expect(lineStructureText(const []), isEmpty);
    final one = kLipskeyCatalog.firstWhere((p) => kVerifiedSpecs.containsKey(p.sku));
    expect(lineStructureText([one]), isEmpty);
  });

  test('built chain lists every product + at least one 🔗 joint line', () {
    final supply = kLipskeyCatalog
        .where((p) =>
            kVerifiedSpecs.containsKey(p.sku) &&
            productSystems(p).contains(WaterSystem.supply))
        .toList();

    // Find a pair that builds a multi-item chain.
    List<LipskeyCatalogProduct>? items;
    for (var i = 0; i + 1 < supply.length && items == null; i += 9) {
      final path = findShortestPath(supply[i], supply[i + 1], maxDepth: 8);
      if (path != null && path.length >= 2) items = path;
    }
    expect(items, isNotNull, reason: 'need a buildable supply chain');

    final text = lineStructureText(items!);
    // Tree markers present.
    expect(text, contains('┌─'));
    expect(text, contains('└─'));
    // Every product name appears.
    for (final p in items) {
      expect(text, contains(p.nameHe));
    }
    // At least one real joint label between specced neighbours.
    expect(text, contains('🔗'),
        reason: 'should state the joint method between items');
  });
}

// Verify the per-chain installation-kit recommender. The brass→HDPE chain we
// keep using should pull at least: BSP wrench, PTFE tape, compression-nut
// wrench, and a cross-material sealant + dielectric (the chain crosses brass
// to HDPE).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:buildsmart/logic/install_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('kit for brass→HDPE chain includes both wrench families and PTFE', () {
    final from = kLipskeyCatalog.firstWhere((p) => p.sku == '77777641');
    final to = kLipskeyCatalog.firstWhere((p) => p.sku == '9106306310');
    final chain = findShortestPath(from, to, maxDepth: 10);
    expect(chain, isNotNull);
    final kit = recommendedKitFor(chain!);
    print('${kit.length} items in kit:');
    for (final k in kit) {
      print('  [${k.kind.name}/${k.severityHe}] ${k.label}  — ${k.reason}');
    }

    final labels = kit.map((k) => k.label).toList();
    expect(labels.any((l) => l.contains('PTFE') || l.contains('טפלון')), isTrue,
        reason: 'PTFE tape must appear for the BSP joint');
    expect(labels.any((l) => l.contains('שוודי')), isTrue,
        reason: 'BSP wrench must appear');
    expect(labels.any((l) => l.contains('חבישה') || l.contains('compression')), isTrue,
        reason: 'Compression-nut wrench must appear for HDPE joints');
  });
}

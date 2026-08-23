// Gate-118 (GATE_REGISTRY · Studio Pillar-1): every studio element id REFERENCED in
// the UI must exist in kElementRegistry — no orphan id. The inspector + publish
// validator are already fail-closed on an unknown id (descriptorFor ⇒ null), but
// this catches an un-registered adoption at TEST time too, before it ships.
//
// Scans the two adoption forms: the call-site `cfgId: '…'` (e.g. _MetricTile) and a
// direct `CfgText/CfgVisible/CfgBox('…'` literal. (Registry DEFINITIONS use `id: '…'`
// and are intentionally NOT scanned — the registry is the source of truth.)
import 'dart:io';

import 'package:buildsmart/state/studio/element_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gate-118: every studio id referenced in lib/ is registered', () {
    final patterns = <RegExp>[
      RegExp(r"cfgId:\s*'([^']+)'"),
      RegExp(r"Cfg(?:Text|Visible|Box)\(\s*'([^']+)'"),
    ];

    final referenced = <String>{};
    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final f in dartFiles) {
      final src = f.readAsStringSync();
      for (final p in patterns) {
        for (final m in p.allMatches(src)) {
          referenced.add(m.group(1)!);
        }
      }
    }

    // Non-vacuous: the pilot (s14) adopts the 5 cockpit KPI ids, so the scan must
    // find at least those — a broken pattern (0 hits) is itself a failure.
    expect(
      referenced,
      isNotEmpty,
      reason: 'gate-118 found no studio ids — the scan pattern is broken',
    );

    for (final id in referenced) {
      expect(
        findDescriptor(kElementRegistry, id),
        isNotNull,
        reason: 'UI references id "$id" but it is missing from kElementRegistry',
      );
    }
  });
}

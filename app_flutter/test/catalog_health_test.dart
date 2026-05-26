import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// Health contract for the compatibility data the Install Studio runs on.
/// Pins the coverage so a future catalog/spec edit can't silently degrade how
/// well the studio routes the existing products. Thresholds carry margin —
/// they guard against regressions, not against normal additions.
void main() {
  test('כיסוי VerifiedSpec כולל ≥ 85% מהקטלוג', () {
    final total = kCompatCatalog.length;
    final withSpec =
        kCompatCatalog.where((p) => kVerifiedSpecs[p.sku] != null).length;
    final pct = withSpec * 100 / total;
    expect(pct, greaterThanOrEqualTo(85.0),
        reason: 'כיסוי spec ירד ל-${pct.toStringAsFixed(1)}% ($withSpec/$total)');
  });

  test('כמעט כל המחברים מכוסים — connectorים ללא spec ≤ 6', () {
    // Fixtures/accessories are endpoints and need no spec; connectors are what
    // the engine must route and auto-insert, so they should be spec-covered.
    final gap = kCompatCatalog
        .where((p) =>
            kVerifiedSpecs[p.sku] == null && flowRole(p) == FlowRole.connector)
        .toList();
    expect(gap.length, lessThanOrEqualTo(6),
        reason: 'מחברים ללא spec (פוגעים בניתוב): '
            '${gap.map((p) => "${p.sku}|${p.nameHe}").join(", ")}');
  });
}

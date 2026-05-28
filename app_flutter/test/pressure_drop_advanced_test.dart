// Verify the upgraded pressure-drop math: Reynolds-aware friction factor
// (replaces the old f=0.025 constant) and static-head correction (ρgh).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:buildsmart/logic/pressure_drop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('static head: rising 10m adds ~1 bar', () {
    final from = kLipskeyCatalog.firstWhere((p) => p.sku == '77777641');
    final to = kLipskeyCatalog.firstWhere((p) => p.sku == '9106306310');
    final chain = findShortestPath(from, to, maxDepth: 10)!;
    final flat = estimatePressureDrop(chain,
        pipeLengthMeters: 5, flowRateLPS: 0.3, verticalRiseMeters: 0);
    final rise = estimatePressureDrop(chain,
        pipeLengthMeters: 5, flowRateLPS: 0.3, verticalRiseMeters: 10);
    print('Flat: $flat');
    print('Rise 10m: $rise');
    // Static head of 10m water = ρgh = 1000·9.81·10 = 98100 Pa = 0.981 bar.
    final diff = rise.dropBar - flat.dropBar;
    expect(diff, closeTo(0.98, 0.05));
  });

  test('drainage slope check: 2% threshold', () {
    final ok = checkDrainageSlope(
        horizontalRunMeters: 5.0, verticalDropMeters: 0.15);
    final bad = checkDrainageSlope(
        horizontalRunMeters: 5.0, verticalDropMeters: 0.05);
    print('5m run + 15cm drop → ${ok!.slopePercent}% — ${ok.message}');
    print('5m run + 5cm drop  → ${bad!.slopePercent}% — ${bad.message}');
    expect(ok.ok, isTrue, reason: '3% slope passes');
    expect(bad.ok, isFalse, reason: '1% slope fails');
  });
}

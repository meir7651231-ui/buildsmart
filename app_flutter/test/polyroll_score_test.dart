// After the Polyroll bridge, PPR products should score significantly higher
// in `cardReadinessScore` than they did before (because they now have a
// VerifiedSpec, install effort, install tools, compat mates, etc.).

import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/polyroll_specs.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PPR DN20 pipe scores ≥ "טוב" band (≥55) after bridge registration',
      () {
    // Score BEFORE registration to capture the baseline.
    final pipe = kPolyrollCatalog.firstWhere((p) => p.sku == '95016002');
    // Ensure no leftover state from other tests in the same run.
    kVerifiedSpecs.remove(pipe.sku);
    final pre = cardReadinessScore(pipe);
    expect(pre.score, lessThanOrEqualTo(40),
        reason:
            'PPR baseline should be low (no spec, no compat, no tools)');

    registerPolyrollSpecs();
    final post = cardReadinessScore(pipe);
    expect(post.score, greaterThan(pre.score),
        reason: 'pre=${pre.score} post=${post.score}');
    expect(post.score, greaterThanOrEqualTo(55),
        reason: 'PPR with full bridge should reach טוב band (≥55)');
  });

  test('every PPR product with a synthesised spec scores > baseline', () {
    registerPolyrollSpecs();
    var checked = 0;
    var aboveBaseline = 0;
    for (final p in kPolyrollCatalog) {
      if (kVerifiedSpecs[p.sku] == null) continue;
      checked++;
      final s = cardReadinessScore(p);
      if (s.score > 20) aboveBaseline++;
    }
    expect(checked, greaterThan(700));
    expect(aboveBaseline / checked, greaterThanOrEqualTo(0.99),
        reason: '$aboveBaseline/$checked above baseline 20');
  });
}

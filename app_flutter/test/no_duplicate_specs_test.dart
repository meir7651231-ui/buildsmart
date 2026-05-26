import 'dart:io';

import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the verified-connection data.
///
/// A Dart map literal silently keeps only the LAST entry when a key repeats,
/// so a duplicate `'SKU': VerifiedSpec(...)` can override real geometry with no
/// error (this is exactly how three floor drains lost their drainOpening ends).
/// Runtime can't see the dropped duplicates, so this scans the source file.
/// CWD is the package root under `flutter test`.
void main() {
  test('kVerifiedSpecs — אין מפתחות כפולים (Dart שומר את האחרון בשקט)', () {
    final src =
        File('lib/data/lipskey_verified_connections.dart').readAsStringSync();
    final keys = RegExp(r"'([^']+)'\s*:\s*VerifiedSpec\(")
        .allMatches(src)
        .map((m) => m.group(1)!)
        .toList();
    expect(keys.length, greaterThan(800),
        reason: 'הסורק מצא מעט מדי specs — כנראה הפורמט השתנה');
    final seen = <String>{};
    final dups = <String>{};
    for (final k in keys) {
      if (!seen.add(k)) dups.add(k);
    }
    expect(dups, isEmpty,
        reason: 'מפתח VerifiedSpec כפול דורס גיאומטריה בשקט: $dups');
  });

  test('מאספי/מחסומי רצפה שומרים פתח ניקוז (drainOpening) — נגד נסיגת dedup', () {
    // 196587/116640/116175 were overridden by plain-coupler duplicates and lost
    // their drain seat; 116148/116638 are stable controls in the same section.
    for (final sku in ['196587', '116640', '116175', '116148', '116638']) {
      final spec = kVerifiedSpecs[sku];
      expect(spec, isNotNull, reason: 'חסר spec ל-$sku');
      expect(spec!.ends.any((e) => e.type == EndType.drainOpening), isTrue,
          reason: '$sku איבד את פתח הניקוז — כפילות דרסה את הגיאומטריה');
    }
  });
}

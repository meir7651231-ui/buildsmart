// GIANT Phase-2 wave-3 — the pure data-quality kernel. Non-blocking warnings
// the existing atomic parser can't catch: normName duplicate names (raw-sku
// dedup misses them) and near-identical sku (differs only by case/whitespace).
// Pure; the import sheet gates it on catalog.validation.

import 'package:buildsmart/logic/data_quality.dart';
import 'package:flutter_test/flutter_test.dart';

QualityRow _row(int line, String key, String name) =>
    QualityRow(line: line, key: key, name: name);

void main() {
  test('clean rows → no warnings, scanned counted', () {
    final r = auditRows([
      _row(1, 'A-1', 'ברז כדורי'),
      _row(2, 'B-2', 'מחבר T'),
    ]);
    expect(r.clean, isTrue);
    expect(r.flagged, 0);
    expect(r.scanned, 2);
  });

  test('duplicate NAME (different sku) → dup-name warning on the later item', () {
    final r = auditRows([
      _row(1, 'A-1', 'ברז כדורי'),
      _row(2, 'C-9', 'ברז  כדורי'), // double space folds to the same normName
    ]);
    expect(r.countOf('dup-name'), 1);
    expect(r.warnings.single.line, 2, reason: 'the SECOND item is flagged');
    expect(r.warnings.single.message, contains('פריט 1'),
        reason: 'points back to the first');
  });

  test('near-identical sku (case/space only) → near-key warning', () {
    final r = auditRows([
      _row(1, 'A-1', 'ברז'),
      _row(2, 'a 1', 'מחבר'), // 'a 1' and 'A-1' both normalize to 'a1'
    ]);
    expect(r.countOf('near-key'), 1);
    expect(r.countOf('dup-name'), 0, reason: 'names differ');
    expect(r.warnings.single.line, 2);
  });

  test('a row can trip BOTH kinds', () {
    final r = auditRows([
      _row(1, 'A-1', 'ברז כדורי'),
      _row(2, 'a1', 'ברז כדורי'), // same name AND same normalized key
    ]);
    expect(r.countOf('dup-name'), 1);
    expect(r.countOf('near-key'), 1);
    expect(r.flagged, 2);
  });

  test('empty name/key are skipped (parser already blocks missing fields)', () {
    final r = auditRows([
      _row(1, '', ''),
      _row(2, '', ''),
    ]);
    expect(r.clean, isTrue, reason: 'blank identities never collide here');
    expect(r.scanned, 2);
  });

  test('three-way name collision flags items 2 and 3, both citing item 1', () {
    final r = auditRows([
      _row(1, 'S1', 'צינור'),
      _row(2, 'S2', 'צינור'),
      _row(3, 'S3', 'צינור'),
    ]);
    expect(r.countOf('dup-name'), 2);
    expect(r.warnings.every((w) => w.message.contains('פריט 1')), isTrue);
  });
}

// p1_baseline_golden_test.dart — step 38: the IMMOVABLE flag-OFF anchor.
// Pins the LIVE word_finder material/colour/narrow axes on kDivePool to a
// blessed golden tagged "must never change". Every P1 data fix (copper
// recovery, size_equiv, color_truth, taxonomy, groups) lives in the
// unified-finder CARD path, never the live materialOf/colorOptions — so if
// this golden ever breaks, a card-only edit leaked into the live word_finder.

import 'dart:io';

import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/material_lexicon.dart';
import 'package:buildsmart/features/word_finder/narrow_axis.dart';
import 'package:flutter_test/flutter_test.dart';

String _liveAnchor() {
  final pool = kDivePool;
  final materials = materialsInPool(pool);
  final colors = colorOptions(pool);
  final axis = narrowAxis(pool, null);
  final b = StringBuffer()
    ..writeln('# LIVE word_finder flag-OFF anchor — must never change')
    ..writeln('pool.length=${pool.length}')
    ..writeln('materials=${materials.join("|")}')
    ..writeln('colors=${colors.join("|")}')
    ..writeln('narrowAxis.label=${axis.label}')
    ..writeln('narrowAxis.chips=${axis.chips.join("|")}');
  for (final m in materials) {
    b.writeln('materialCount[$m]=${productsOfMaterial(pool, m).length}');
  }
  return b.toString();
}

void main() {
  test('LIVE word_finder anchor is pure and matches the blessed golden', () {
    final actual = _liveAnchor();
    expect(_liveAnchor(), actual, reason: 'the anchor must be deterministic');

    final golden = File('test/golden/word_finder_live_anchor.txt');
    if (!golden.existsSync()) {
      golden.parent.createSync(recursive: true);
      golden.writeAsStringSync(actual);
    }
    expect(
      actual,
      golden.readAsStringSync(),
      reason: 'a P1 edit changed the LIVE axes — P1 fixes must stay card-only',
    );
  });
}

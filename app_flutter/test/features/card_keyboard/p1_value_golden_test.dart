// p1_value_golden_test.dart — step 45: the EVOLVABLE flag-ON card-path value
// golden. Unlike the immovable step-38 live anchor, this records the unified
// finder's POST-P1 axes (cardColorOptions, materialsInPoolEnriched, canonicalSize
// folds, category groups) and re-blesses when a later P1 edit intends a change.

import 'dart:io';

import 'package:buildsmart/features/word_finder/category_groups.dart';
import 'package:buildsmart/features/word_finder/color_truth.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/material_lexicon.dart'
    show materialsInPoolEnriched;
import 'package:buildsmart/features/word_finder/narrow_axis.dart'
    show sizeTokensIn;
import 'package:buildsmart/features/word_finder/size_equiv.dart';
import 'package:flutter_test/flutter_test.dart';

String _cardValueAnchor() {
  final pool = kDivePool;
  final cardColors = cardColorOptions(pool);
  final materials = materialsInPoolEnriched(pool);
  final canonSizes = sizeTokensIn(pool)
      .map((t) => canonicalSize(t.label))
      .whereType<String>()
      .toSet()
      .toList()
    ..sort();
  final groups = pool.map(groupOf).toSet().toList()..sort();
  return (StringBuffer()
        ..writeln('# flag-ON card value golden — evolves with P1 data edits')
        ..writeln('cardColors=${cardColors.join("|")}')
        ..writeln('materialsEnriched=${materials.join("|")}')
        ..writeln('canonicalSizes=${canonSizes.join("|")}')
        ..writeln('categoryGroups=${groups.join("|")}'))
      .toString();
}

void main() {
  test('flag-ON card value golden is deterministic and blessed', () {
    final actual = _cardValueAnchor();
    expect(_cardValueAnchor(), actual, reason: 'must be deterministic');

    final golden = File('test/golden/p1_card_value_anchor.txt');
    if (!golden.existsSync()) {
      golden.parent.createSync(recursive: true);
      golden.writeAsStringSync(actual);
    }
    expect(actual, golden.readAsStringSync(),
        reason: 'card value golden changed — re-bless if a P1 edit intended it');
  });
}

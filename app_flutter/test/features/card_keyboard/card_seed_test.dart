import 'package:buildsmart/features/card_keyboard/card_seed.dart';
import 'package:buildsmart/features/card_keyboard/card_signals.dart'
    show sourcesFor;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seed-axis sentinels are pairwise distinct', () {
    final all = [
      kWordSeedAxis,
      kMaterialSeedAxis,
      kJobSeedAxis,
      kCategorySeedAxis,
    ];
    expect(all.toSet().length, all.length,
        reason: 'no two mouths may share an axis sentinel');
    expect(kSeedAxisSentinels, all.toSet());
  });

  test('mouth ids are distinct', () {
    final ids = [kWordMouth, kMaterialMouth, kJobMouth, kCategoryMouth];
    expect(ids.toSet().length, ids.length);
  });

  test('no seed sentinel collides with a signal axis name', () {
    // The whole point of a sentinel: a seed must not pre-answer a real axis.
    final signalAxes = sourcesFor(null).map((s) => s.axisName).toSet();
    for (final sentinel in kSeedAxisSentinels) {
      expect(signalAxes, isNot(contains(sentinel)),
          reason: '$sentinel must not be a signal axisName');
    }
  });

  test('a seed carries its fields and a working predicate', () {
    final seed = CardSeed(
      mouthId: kMaterialMouth,
      displayLabel: 'נחושת',
      seedAxisLabel: kMaterialSeedAxis,
      seedPredicate: (_) => true,
    );
    expect(seed.mouthId, kMaterialMouth);
    expect(seed.displayLabel, 'נחושת');
    expect(seed.seedAxisLabel, kMaterialSeedAxis);
    expect(seed.emoji, isNull);
  });
}

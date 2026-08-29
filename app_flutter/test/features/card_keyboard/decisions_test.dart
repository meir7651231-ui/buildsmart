import 'package:buildsmart/features/card_keyboard/decisions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('owner-gated decisions are resolved to safe constants', () {
    // The <=6/<=4 contract tolerates NO exceptions — empty by construction
    // (round-1 blocker #4: never widen an allowlist to make the gate pass).
    expect(kReachAllowlist, isEmpty);
    // Material competes as a gated co-axis, never a forced first axis.
    expect(kMaterialIsGatedCoAxis, isTrue);
    // Identity scope is one of the two legal values.
    expect(kIdentityScope, anyOf(equals('employer'), equals('global')));
    // The reach-universe floor is a positive lower bound (absorbs ingestion drift).
    expect(kReachLowerBound, greaterThan(0));
    // Colour exclusions are the complement of a true-colours allowlist.
    expect(kColorExclusionsAreComplementOfAllowlist, isTrue);
  });
}

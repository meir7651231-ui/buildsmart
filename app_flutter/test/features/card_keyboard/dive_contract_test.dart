import 'package:buildsmart/features/card_keyboard/dive_contract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the <=6 contract constants are the single source', () {
    expect(kMaxDiveTurns, 6);
    expect(kReachListCap, 12);
    // list-then-pick: ShowProducts by turn 5 so the grid pick is the 6th action.
    expect(kListThenPickTurn, kMaxDiveTurns - 1);
    expect(kListThenPickTurn, 5);
  });
}

// Roadmap step 95 — expert/simple card-detail mode, persisted.
import 'package:buildsmart/state/card_detail_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('defaults to expert', () {
    SharedPreferences.setMockInitialValues({});
    final n = CardDetailModeNotifier();
    expect(n.state, CardDetailMode.expert);
    expect(n.isExpert, isTrue);
  });

  test('toggle flips and persists across a fresh notifier', () async {
    SharedPreferences.setMockInitialValues({});
    final n1 = CardDetailModeNotifier();
    n1.toggle();
    expect(n1.state, CardDetailMode.simple);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final n2 = CardDetailModeNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(n2.state, CardDetailMode.simple);
    expect(n2.isExpert, isFalse);
  });

  test('set is idempotent (no redundant writes)', () {
    SharedPreferences.setMockInitialValues({});
    final n = CardDetailModeNotifier();
    n.set(CardDetailMode.expert); // already expert
    expect(n.state, CardDetailMode.expert);
    n.set(CardDetailMode.simple);
    expect(n.state, CardDetailMode.simple);
  });
}

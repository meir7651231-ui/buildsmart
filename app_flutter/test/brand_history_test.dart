// Roadmap step 51 — brand selection history (state layer).
import 'package:buildsmart/state/brand_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('default empty + favouriteFor null + totalPicks 0', () {
    SharedPreferences.setMockInitialValues({});
    final n = BrandHistoryNotifier();
    expect(n.favouriteFor('faucet'), isNull);
    expect(n.totalPicks, 0);
    expect(n.countsFor('faucet'), isEmpty);
  });

  test('record increments; favouriteFor returns the brand', () {
    SharedPreferences.setMockInitialValues({});
    final n = BrandHistoryNotifier();
    n.record('faucet', 'AQUATEC');
    expect(n.favouriteFor('faucet'), 'AQUATEC');
    expect(n.countsFor('faucet'), {'AQUATEC': 1});
    expect(n.totalPicks, 1);
  });

  test('most-picked wins', () {
    SharedPreferences.setMockInitialValues({});
    final n = BrandHistoryNotifier();
    n.record('faucet', 'A');
    for (var i = 0; i < 3; i++) {
      n.record('faucet', 'B');
    }
    expect(n.favouriteFor('faucet'), 'B');
    expect(n.totalPicks, 4);
  });

  test('tie broken alphabetically', () {
    SharedPreferences.setMockInitialValues({});
    final n = BrandHistoryNotifier();
    n.record('faucet', 'B');
    n.record('faucet', 'B');
    n.record('faucet', 'A');
    n.record('faucet', 'A');
    expect(n.favouriteFor('faucet'), 'A');
  });

  test('different productKeys keep separate histories', () {
    SharedPreferences.setMockInitialValues({});
    final n = BrandHistoryNotifier();
    n.record('faucet', 'A');
    n.record('drain', 'Wisa');
    expect(n.favouriteFor('faucet'), 'A');
    expect(n.favouriteFor('drain'), 'Wisa');
    expect(n.totalPicks, 2);
  });

  test('persists across a fresh notifier', () async {
    SharedPreferences.setMockInitialValues({});
    final n1 = BrandHistoryNotifier();
    n1.record('faucet', 'X');
    n1.record('faucet', 'X');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final n2 = BrandHistoryNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(n2.favouriteFor('faucet'), 'X');
    expect(n2.countsFor('faucet'), {'X': 2});
  });
}

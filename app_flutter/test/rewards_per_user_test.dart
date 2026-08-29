// #99 — BuildCoins / progress are PRIVATE per board username (storage key =
// '$kRewardsKey.<username>'). One user's earned coins must NOT leak into another
// user's balance. The shared leaderboard is a separate concern (only your own
// 'me' row reflects your private balance). Engine-level, real-prefs round-trip.
import 'package:buildsmart/state/rewards_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('BuildCoins are private per board username (#99)', () async {
    // 'ran' earns 100 coins (340 seed → 440), persisted under ran's key.
    final ran = RewardsNotifier(username: 'ran');
    addTearDown(ran.dispose);
    await _settle();
    ran.awardCoins(100);
    await _settle();
    expect(ran.state.coins, kBuildCoinsSeed + 100);

    // a DIFFERENT user 'omer' reads omer's key → the seed, NOT ran's 440.
    final omer = RewardsNotifier(username: 'omer');
    addTearDown(omer.dispose);
    await _settle();
    expect(omer.state.coins, kBuildCoinsSeed,
        reason: "omer does not inherit ran's private balance");

    // 'ran' reloads → his own 440 survived (private, persisted per username).
    final ran2 = RewardsNotifier(username: 'ran');
    addTearDown(ran2.dispose);
    await _settle();
    expect(ran2.state.coins, kBuildCoinsSeed + 100,
        reason: 'ran keeps his own private balance across a restart');
  });
}

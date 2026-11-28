// 🪙 A coin award that lands BEFORE the rewards store finished loading must be
// ADDED to the saved balance — not saved over it.
//
// rewardsProvider is often CREATED by its first write (a courier's delivery
// award from the dashboard before any rewards/reports tab was built). The old
// `_userTouched` guard then skipped the load and persisted seed+N over the
// real balance (e.g. 500 → 340+20 = 360).
import 'dart:convert';

import 'package:buildsmart/state/rewards_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

Future<Map<String, dynamic>> _saved(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString(key)!) as Map<String, dynamic>;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('award before load → saved balance + award (state AND storage)',
      () async {
    SharedPreferences.setMockInitialValues({
      '$kRewardsKey.courier1': '{"coins":500,"claimedChallengeIds":[]}',
    });
    final n = RewardsNotifier(username: 'courier1');
    addTearDown(n.dispose);
    n.awardCoins(20); // synchronously, before the async load resolves
    await _settle();

    expect(n.state.coins, 520);
    expect(n.state.leaderboard.where((l) => l.me).map((l) => l.coins),
        everyElement(520));
    expect((await _saved('$kRewardsKey.courier1'))['coins'], 520);

    // A fresh session reads the merged balance back.
    final again = RewardsNotifier(username: 'courier1');
    addTearDown(again.dispose);
    await _settle();
    expect(again.state.coins, 520);
  });

  test('two awards before load both count', () async {
    SharedPreferences.setMockInitialValues({
      kRewardsKey: '{"coins":1000,"claimedChallengeIds":[]}',
    });
    final n = RewardsNotifier()
      ..awardCoins(20)
      ..awardCoins(15);
    addTearDown(n.dispose);
    await _settle();
    expect(n.state.coins, 1035);
    expect((await _saved(kRewardsKey))['coins'], 1035);
  });

  test('saved claimed challenges survive a pre-load award', () async {
    final claimedId = kMonthlyChallengesSeed.first.id;
    SharedPreferences.setMockInitialValues({
      kRewardsKey: jsonEncode({
        'coins': 700,
        'claimedChallengeIds': [claimedId],
      }),
    });
    final n = RewardsNotifier()..awardCoins(10);
    addTearDown(n.dispose);
    await _settle();
    expect(n.state.coins, 710);
    expect(n.state.challenges.map((c) => c.id), isNot(contains(claimedId)));
    expect((await _saved(kRewardsKey))['claimedChallengeIds'], [claimedId]);
  });

  test('award AFTER load is unchanged behaviour', () async {
    SharedPreferences.setMockInitialValues({
      kRewardsKey: '{"coins":500,"claimedChallengeIds":[]}',
    });
    final n = RewardsNotifier();
    addTearDown(n.dispose);
    await _settle();
    n.awardCoins(20);
    await _settle();
    expect(n.state.coins, 520);
    expect((await _saved(kRewardsKey))['coins'], 520);
  });

  test('redeem before load is refused (no overdraw of the saved balance)',
      () async {
    SharedPreferences.setMockInitialValues({
      kRewardsKey: '{"coins":50,"claimedChallengeIds":[]}',
    });
    final n = RewardsNotifier();
    addTearDown(n.dispose);
    const r = RwReward(id: 'x', ic: '🎁', name: 'x', cost: 250);
    expect(n.redeem(r), isFalse);
    await _settle();
    expect(n.state.coins, 50);
    expect(n.redeem(r), isFalse, reason: 'still unaffordable after load');
  });

  test('a challenge claimed before load pays once and stays claimed',
      () async {
    final done = kMonthlyChallengesSeed.where((c) => c.done).toList();
    if (done.isEmpty) return; // empty-seed build flavour
    final ch = done.first;
    SharedPreferences.setMockInitialValues({
      kRewardsKey: '{"coins":500,"claimedChallengeIds":[]}',
    });
    final n = RewardsNotifier()..claimChallenge(ch.id);
    addTearDown(n.dispose);
    await _settle();
    expect(n.state.coins, 500 + ch.reward);
    expect(n.state.challenges.map((c) => c.id), isNot(contains(ch.id)));
    expect((await _saved(kRewardsKey))['claimedChallengeIds'], [ch.id]);
  });

  test('re-claiming a challenge already claimed on disk does not pay twice',
      () async {
    final done = kMonthlyChallengesSeed.where((c) => c.done).toList();
    if (done.isEmpty) return;
    final ch = done.first;
    SharedPreferences.setMockInitialValues({
      kRewardsKey: jsonEncode({
        'coins': 500,
        'claimedChallengeIds': [ch.id],
      }),
    });
    final n = RewardsNotifier()..claimChallenge(ch.id);
    addTearDown(n.dispose);
    await _settle();
    expect(n.state.coins, 500);
  });
}

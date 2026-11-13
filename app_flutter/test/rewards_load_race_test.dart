// Load-race on the rewards balance. `RewardsNotifier` loads its persisted
// `{coins, claimedChallengeIds}` overlay lazily from the constructor. A coin
// mutation that ran BEFORE that load resolved (e.g. the courier's first
// delivery of the session — `awardCoins` is then the very first read of
// `rewardsProvider`) used to make the load bail, so the seed-based balance was
// written back over the stored one: stored 440 + 20 became 360, and every
// claimed challenge came back.
//
// A rewards mutation is a DELTA on a cumulative balance, so the fix rebases the
// pre-load delta onto the loaded overlay. These tests pin that on both the
// SharedPreferences path and the server (`rewards/{uid}`) path.
import 'dart:convert';

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/data/repositories/rewards_repository.dart';
import 'package:buildsmart/state/rewards_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

class _FakeSource implements RemoteCollectionSource {
  final Map<String, Map<String, dynamic>> docs = {};
  @override
  Stream<List<RemoteDoc>> snapshots() =>
      Stream.value([for (final e in docs.entries) RemoteDoc(e.key, e.value)]);
  @override
  Future<void> set(String id, Map<String, dynamic> data) async =>
      docs[id] = {...?docs[id], ...data};
  @override
  Future<void> delete(String id) async => docs.remove(id);
  @override
  bool get isScoped => true;
}

const _ranKey = '$kRewardsKey.ran';
const _stored = '{"coins":440,"claimedChallengeIds":["ch3"]}';

Future<Map<String, dynamic>> _disk(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString(key)!) as Map<String, dynamic>;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('prefs path', () {
    test('awardCoins before the load resolves is added to the STORED balance',
        () async {
      SharedPreferences.setMockInitialValues({_ranKey: _stored});
      final n = RewardsNotifier(username: 'ran');
      addTearDown(n.dispose);

      n.awardCoins(20); // the first touch of the session — load still pending
      expect(n.state.coins, kBuildCoinsSeed + 20,
          reason: 'the mutation stays synchronous');

      await _settle();
      expect(n.state.coins, 460, reason: '440 stored + 20, not seed + 20');
      expect(n.state.challenges.any((c) => c.id == 'ch3'), isFalse,
          reason: 'a claimed challenge must not come back');
      expect(n.state.leaderboard.firstWhere((l) => l.me).coins, 460);
      expect(await _disk(_ranKey), {
        'coins': 460,
        'claimedChallengeIds': ['ch3'],
      });

      // and a restart reads the same balance back
      final again = RewardsNotifier(username: 'ran');
      addTearDown(again.dispose);
      await _settle();
      expect(again.state.coins, 460);
    });

    test('redeem before the load resolves is subtracted from the stored balance',
        () async {
      SharedPreferences.setMockInitialValues({_ranKey: _stored});
      final n = RewardsNotifier(username: 'ran');
      addTearDown(n.dispose);
      final r = kRewardsCatalog.firstWhere((x) => x.cost <= kBuildCoinsSeed);

      expect(n.redeem(r), isTrue);
      await _settle();
      expect(n.state.coins, 440 - r.cost);
      expect((await _disk(_ranKey))['coins'], 440 - r.cost);
    });

    test('a pre-load claim of an ALREADY-claimed challenge is not paid twice',
        () async {
      SharedPreferences.setMockInitialValues({_ranKey: _stored});
      final n = RewardsNotifier(username: 'ran');
      addTearDown(n.dispose);
      final ch3 = kMonthlyChallengesSeed.firstWhere((c) => c.id == 'ch3');
      expect(ch3.done, isTrue, reason: 'precondition: ch3 is claimable');

      n.claimChallenge('ch3');
      await _settle();
      expect(n.state.coins, 440, reason: 'ch3 was already paid in the stored 440');
      expect(n.state.challenges.any((c) => c.id == 'ch3'), isFalse);
    });

    test('a pre-load claim of an unclaimed challenge pays once and sticks',
        () async {
      SharedPreferences.setMockInitialValues(
          {_ranKey: '{"coins":440,"claimedChallengeIds":[]}'});
      final n = RewardsNotifier(username: 'ran');
      addTearDown(n.dispose);
      final ch3 = kMonthlyChallengesSeed.firstWhere((c) => c.id == 'ch3');

      n.claimChallenge('ch3');
      await _settle();
      expect(n.state.coins, 440 + ch3.reward);
      expect(await _disk(_ranKey), {
        'coins': 440 + ch3.reward,
        'claimedChallengeIds': ['ch3'],
      });
    });

    test('nothing stored: a pre-load award still lands on the seed', () async {
      SharedPreferences.setMockInitialValues({});
      final n = RewardsNotifier(username: 'ran');
      addTearDown(n.dispose);
      n.awardCoins(20);
      await _settle();
      expect(n.state.coins, kBuildCoinsSeed + 20);
      expect((await _disk(_ranKey))['coins'], kBuildCoinsSeed + 20);
    });

    test('corrupt stored payload: a pre-load award keeps seed + delta, no throw',
        () async {
      SharedPreferences.setMockInitialValues({_ranKey: '{not json'});
      final n = RewardsNotifier(username: 'ran');
      addTearDown(n.dispose);
      n.awardCoins(20);
      await _settle();
      expect(n.state.coins, kBuildCoinsSeed + 20);
    });

    test('a mutation AFTER the load is applied exactly once', () async {
      SharedPreferences.setMockInitialValues({_ranKey: _stored});
      final n = RewardsNotifier(username: 'ran');
      addTearDown(n.dispose);
      await _settle();
      expect(n.state.coins, 440);
      n.awardCoins(20);
      await _settle();
      expect(n.state.coins, 460);
      expect((await _disk(_ranKey))['coins'], 460);
    });
  });

  group('server path (rewards/{uid})', () {
    test('awardCoins before the load resolves never writes a seed-based balance',
        () async {
      final src = _FakeSource()
        ..docs['u'] = {
          'coins': 440,
          'claimedChallengeIds': ['ch3'],
        };
      final n = RewardsNotifier(
          repo: RewardsRepository(src, currentUid: 'u'));
      addTearDown(n.dispose);

      n.awardCoins(20);
      await _settle();
      expect(n.state.coins, 460);
      expect(src.docs['u']!['coins'], 460);
      expect(src.docs['u']!['claimedChallengeIds'], ['ch3']);
    });
  });
}

// rewards local→server migration (rewards/{uid}, self-only) — the private
// {coins, claimedChallengeIds} overlay, keyed by uid (resolving the board-
// username→uid deferral). Pins: (1) DORMANT OFF (kUserDataServer const-false ⇒
// provider null ⇒ the per-username SharedPreferences path, byte-identical), and
// (2) the repo round-trips the overlay map through save→load.
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/data/repositories/rewards_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  test('#rewards OFF (const-false) ⇒ provider null (SharedPreferences path)', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(rewardsRepositoryProvider), isNull);
  });

  test('#rewards repo round-trips the {coins, claimedChallengeIds} overlay',
      () async {
    final src = _FakeSource();
    final repo = RewardsRepository(src, currentUid: 'u');
    await repo.save('u', {
      'coins': 340,
      'claimedChallengeIds': ['c1', 'c3'],
    });
    expect(src.docs['u']!.containsKey('updatedAt'), isTrue);

    final back = await repo.load('u');
    expect(back, isNotNull);
    expect((back!['coins'] as num).toInt(), 340);
    expect(back['claimedChallengeIds'], ['c1', 'c3']);
  });

  test('#rewards load ⇒ null when the doc is absent (keeps the seed)', () async {
    final repo = RewardsRepository(_FakeSource(), currentUid: 'u');
    expect(await repo.load('u'), isNull);
  });
}

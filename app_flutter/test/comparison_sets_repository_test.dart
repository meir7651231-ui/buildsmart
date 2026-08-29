// #user-data — a local→server user-data store migration (side-by-side compare
// set → comparisonSets/{uid}). Two things pinned: (1) the migration is DORMANT
// with kUserDataServer OFF (the provider yields null → the set keeps its
// SharedPreferences path, byte-identical), and (2) the ComparisonSetsRepository
// round-trips the Set through the neutral RemoteCollectionSource seam.
// Firebase-free — a hand-rolled fake source drives it, exactly like the
// carts/savedProjects/draftQuotes suites (no fake_cloud_firestore).
import 'package:buildsmart/data/repositories/comparison_sets_repository.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled [RemoteCollectionSource] that STORES what `set` writes and
/// re-emits it from `snapshots()` — so a save→load round-trips (same fake shape
/// as the sibling suites).
class _FakeSource implements RemoteCollectionSource {
  final Map<String, Map<String, dynamic>> docs = {};

  @override
  Stream<List<RemoteDoc>> snapshots() => Stream<List<RemoteDoc>>.value(
        [for (final e in docs.entries) RemoteDoc(e.key, e.value)],
      );

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {
    docs[id] = {...?docs[id], ...data}; // merge:true contract
  }

  @override
  Future<void> delete(String id) async => docs.remove(id);

  @override
  bool get isScoped => true; // scoped to the uid (documentId ==)
}

void main() {
  group('#user-data comparison-set migration is DORMANT off', () {
    test(
        'comparisonSetsRepositoryProvider OFF (kUserDataServer const-false) ⇒ null '
        '— the set stays on SharedPreferences, byte-identical to today', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(comparisonSetsRepositoryProvider), isNull);
    });
  });

  group('#user-data ComparisonSetsRepository round-trip (comparisonSets/{uid})',
      () {
    test('save writes {keys,updatedAt}; load decodes the set back', () async {
      final src = _FakeSource();
      final repo = ComparisonSetsRepository(src, currentUid: 'u1');

      await repo.save('u1', {'sku-a', 'sku-b', 'sku-c'});
      expect(src.docs['u1']!['keys'], isA<List<dynamic>>());
      expect((src.docs['u1']!['keys'] as List).length, 3);
      expect(src.docs['u1']!.containsKey('updatedAt'), isTrue);

      final back = await repo.load('u1');
      expect(back, {'sku-a', 'sku-b', 'sku-c'});
    });

    test('load with no doc ⇒ empty set (never throws)', () async {
      final repo = ComparisonSetsRepository(_FakeSource(), currentUid: 'u1');
      expect(await repo.load('u1'), isEmpty);
    });

    test('non-string / missing keys ⇒ empty set (defensive)', () async {
      final src = _FakeSource();
      await src.set('u1', {'keys': 'not-a-list'});
      final repo = ComparisonSetsRepository(src, currentUid: 'u1');
      expect(await repo.load('u1'), isEmpty);
    });
  });
}

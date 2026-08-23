// #user-data — the SECOND SHIPPED local→server store migration (saved install-
// studio projects → savedProjects/{uid}; notif_settings is parity-frozen). Two
// things pinned: (1) the migration is DORMANT with kUserDataServer OFF (the
// provider yields null → the projects keep their SharedPreferences path, byte-
// identical), and (2) the SavedProjectsRepository round-trips the list through the
// neutral RemoteCollectionSource seam. Firebase-free — a hand-rolled fake source
// drives it, exactly like the carts/users suites (no fake_cloud_firestore).
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/data/repositories/saved_projects_repository.dart';
import 'package:buildsmart/state/saved_projects.dart' show SavedProject;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled [RemoteCollectionSource] that actually STORES what `set` writes
/// and re-emits it from `snapshots()` — so a save→load round-trips (same fake
/// shape as the carts suite; the projects repo also writes, so it must persist).
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
  final p1 = SavedProject(
    id: 'proj-1',
    name: 'מקלחת ראשית',
    anchorSkus: const ['sku-a', 'sku-b'],
    branchSkus: const ['sku-c'],
    tempC: 60,
    accessories: {'acc-1', 'acc-2'},
    savedAt: DateTime.utc(2026, 1, 2),
  );
  final p2 = SavedProject(
    id: 'proj-2',
    name: 'מטבח',
    anchorSkus: const ['sku-x'],
    tempC: 45,
    accessories: <String>{},
    savedAt: DateTime.utc(2026, 1, 1),
  );

  group('#user-data saved-projects migration is DORMANT off', () {
    test(
        'savedProjectsRepositoryProvider OFF (kUserDataServer const-false) ⇒ null '
        '— the projects stay on SharedPreferences, byte-identical to today', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(savedProjectsRepositoryProvider), isNull);
    });
  });

  group('#user-data SavedProjectsRepository round-trip (savedProjects/{uid})', () {
    test('save writes {projects,updatedAt}; load decodes the projects back',
        () async {
      final src = _FakeSource();
      final repo = SavedProjectsRepository(src, currentUid: 'u1');

      await repo.save('u1', [p1, p2]);
      expect(src.docs['u1']!['projects'], isA<List<dynamic>>());
      expect((src.docs['u1']!['projects'] as List).length, 2);
      expect(src.docs['u1']!.containsKey('updatedAt'), isTrue);

      final back = await repo.load('u1');
      expect(back.length, 2);
      final one = back.firstWhere((p) => p.id == 'proj-1');
      expect(one.name, 'מקלחת ראשית');
      expect(one.anchorSkus, ['sku-a', 'sku-b']);
      expect(one.branchSkus, ['sku-c']);
      expect(one.tempC, 60);
      expect(one.accessories, {'acc-1', 'acc-2'});
      expect(one.savedAt, DateTime.utc(2026, 1, 2));
    });

    test('load with no doc ⇒ empty list (never throws)', () async {
      final repo = SavedProjectsRepository(_FakeSource(), currentUid: 'u1');
      expect(await repo.load('u1'), isEmpty);
    });
  });
}

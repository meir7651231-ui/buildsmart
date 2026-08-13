// #hr — courier board-profile local→server migration (courierProfiles/{uid}),
// single-doc + self-only (the worker_profile twin). Pins: (1) DORMANT with
// kUserDataServer OFF (provider → null → SharedPreferences, byte-identical), and
// (2) the CourierProfileRepository round-trips the courier's profile through the
// neutral RemoteCollectionSource seam; an absent doc ⇒ null (empty fallback).
import 'package:buildsmart/data/repositories/courier_profile_repository.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/state/courier_profile_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSource implements RemoteCollectionSource {
  final Map<String, Map<String, dynamic>> docs = {};

  @override
  Stream<List<RemoteDoc>> snapshots() => Stream<List<RemoteDoc>>.value(
        [for (final e in docs.entries) RemoteDoc(e.key, e.value)],
      );

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {
    docs[id] = {...?docs[id], ...data};
  }

  @override
  Future<void> delete(String id) async => docs.remove(id);

  @override
  bool get isScoped => true;
}

void main() {
  const p = CourierProfile(
    displayName: 'עומר שליח',
    phone: '0509998877',
    preferredHaul: 'van',
    photo: 'data:image/png;base64,AAA=',
  );

  group('#hr courier-profile migration is DORMANT off', () {
    test(
        'courierProfileRepositoryProvider OFF (kUserDataServer const-false) ⇒ '
        'null — the profile stays on SharedPreferences, byte-identical', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(courierProfileRepositoryProvider), isNull);
    });
  });

  group('#hr CourierProfileRepository round-trip (courierProfiles/{uid})', () {
    test('save writes {…profile,updatedAt}; load decodes every field back',
        () async {
      final src = _FakeSource();
      final repo = CourierProfileRepository(src, uid: 'c-uid-1');

      await repo.save(p);
      final doc = src.docs['c-uid-1']!;
      expect(doc['displayName'], 'עומר שליח');
      expect(doc.containsKey('updatedAt'), isTrue);

      final back = await repo.load();
      expect(back, isNotNull);
      expect(back!.displayName, 'עומר שליח');
      expect(back.phone, '0509998877');
      expect(back.preferredHaul, 'van'); // a valid haul id survives
      expect(back.photo, 'data:image/png;base64,AAA=');
    });

    test('load with no doc ⇒ null (caller keeps its empty fallback)', () async {
      final repo = CourierProfileRepository(_FakeSource(), uid: 'c-uid-1');
      expect(await repo.load(), isNull);
    });

    test('a bogus preferredHaul decays to "" (normalizeHaul, never invented)',
        () async {
      final src = _FakeSource();
      final repo = CourierProfileRepository(src, uid: 'c-uid-1');
      await repo.save(const CourierProfile(displayName: 'x', preferredHaul: 'x'));
      final back = await repo.load();
      expect(back!.preferredHaul, '', reason: 'unknown id → not-chosen');
    });
  });
}

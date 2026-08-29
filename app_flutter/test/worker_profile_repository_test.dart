// #hr — worker board-profile local→server migration (workerProfiles/{uid}),
// single-doc + self-only (no persona reads another worker's profile). Pins:
// (1) DORMANT with kUserDataServer OFF (provider → null → SharedPreferences,
// byte-identical), and (2) the WorkerProfileRepository round-trips the worker's
// profile (all #104 PII fields) through the neutral RemoteCollectionSource seam;
// an absent doc ⇒ null (the caller keeps its honest empty fallback).
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/data/repositories/worker_profile_repository.dart';
import 'package:buildsmart/state/worker_profile_store.dart';
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
  const p = WorkerProfile(
    name: 'רן ישראלי',
    phone: '0501234567',
    specialty: 'אינסטלטור',
    photo: 'data:image/png;base64,AAA=',
    idNumber: '123456782',
    address: 'רחוב הבניין 4, תל אביב',
    emergencyName: 'דנה',
    emergencyPhone: '0527654321',
  );

  group('#hr worker-profile migration is DORMANT off', () {
    test(
        'workerProfileRepositoryProvider OFF (kUserDataServer const-false) ⇒ null '
        '— the profile stays on SharedPreferences, byte-identical', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(workerProfileRepositoryProvider), isNull);
    });
  });

  group('#hr WorkerProfileRepository round-trip (workerProfiles/{uid})', () {
    test('save writes {…profile,updatedAt}; load decodes every field back',
        () async {
      final src = _FakeSource();
      final repo = WorkerProfileRepository(src, uid: 'w-uid-1');

      await repo.save(p);
      final doc = src.docs['w-uid-1']!;
      expect(doc['name'], 'רן ישראלי');
      expect(doc.containsKey('updatedAt'), isTrue);

      final back = await repo.load();
      expect(back, isNotNull);
      expect(back!.name, 'רן ישראלי');
      expect(back.phone, '0501234567');
      expect(back.specialty, 'אינסטלטור');
      expect(back.photo, 'data:image/png;base64,AAA=');
      expect(back.idNumber, '123456782'); // #104 PII survives
      expect(back.address, 'רחוב הבניין 4, תל אביב');
      expect(back.emergencyName, 'דנה');
      expect(back.emergencyPhone, '0527654321');
    });

    test('load with no doc ⇒ null (caller keeps its empty fallback)', () async {
      final repo = WorkerProfileRepository(_FakeSource(), uid: 'w-uid-1');
      expect(await repo.load(), isNull);
    });

    test('load only returns THIS uid (a sibling doc is ignored)', () async {
      final src = _FakeSource();
      src.docs['other'] = const WorkerProfile(name: 'לא-שלי').toJson();
      final back = await WorkerProfileRepository(src, uid: 'w-uid-1').load();
      expect(back, isNull, reason: 'the scope is documentId == uid');
    });
  });
}

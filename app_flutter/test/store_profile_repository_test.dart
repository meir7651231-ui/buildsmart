// #hr — STORE business-profile + business-cert wallet local→server migration
// (storeProfiles/{uid} + storeCerts/{uid}), single-doc + self-only (the
// worker_profile twin). Pins: (1) DORMANT with kUserDataServer OFF (both
// providers → null → SharedPreferences, byte-identical), and (2) the
// StoreProfileRepository round-trips the store's business profile — including the
// legacy-compatible JSON keys (name/bid) — through the neutral seam; an absent
// doc ⇒ null (empty fallback; the legacy-global seed is a LOCAL-only affordance).
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/data/repositories/store_profile_repository.dart';
import 'package:buildsmart/data/repositories/worker_certs_repository.dart';
import 'package:buildsmart/state/store_profile_store.dart';
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
  const p = StoreProfile(
    businessName: 'פלדות הצפון בע״מ',
    phone: '0509998877',
    address: 'האומן 12, ירושלים',
    businessId: '514888777',
    logo: 'data:image/png;base64,AAA=',
  );

  group('#hr store profile + certs migration is DORMANT off', () {
    test('storeProfileRepositoryProvider + storeCertsRepositoryProvider ⇒ null '
        'with kUserDataServer OFF (SharedPreferences, byte-identical)', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(storeProfileRepositoryProvider), isNull);
      expect(c.read(storeCertsRepositoryProvider), isNull);
    });
  });

  group('#hr StoreProfileRepository round-trip (storeProfiles/{uid})', () {
    test('save writes {name,bid,…,updatedAt}; load decodes every field back',
        () async {
      final src = _FakeSource();
      final repo = StoreProfileRepository(src, uid: 's-uid-1');

      await repo.save(p);
      final doc = src.docs['s-uid-1']!;
      // The legacy-compatible JSON keys ride the write (name/bid, not
      // businessName/businessId).
      expect(doc['name'], 'פלדות הצפון בע״מ');
      expect(doc['bid'], '514888777');
      expect(doc.containsKey('updatedAt'), isTrue);

      final back = await repo.load();
      expect(back, isNotNull);
      expect(back!.businessName, 'פלדות הצפון בע״מ');
      expect(back.phone, '0509998877');
      expect(back.address, 'האומן 12, ירושלים');
      expect(back.businessId, '514888777');
      expect(back.logo, 'data:image/png;base64,AAA=');
    });

    test('load with no doc ⇒ null (caller keeps its empty fallback; no legacy '
        'seed on the server path)', () async {
      final repo = StoreProfileRepository(_FakeSource(), uid: 's-uid-1');
      expect(await repo.load(), isNull);
    });
  });
}
